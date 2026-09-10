from __future__ import annotations

import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


SCRIPT = Path(__file__).resolve().parents[1] / "labels-ref-sync"


def aux_record(label: str, number: str, page: str, anchor: str) -> str:
    return (
        f"\\newlabel{{{label}}}{{{{{number}}}{{{page}}}{{}}{{{anchor}}}{{}}}}\n"
        f"\\newlabel{{{label}@cref}}"
        f"{{{{[theorem][1][]{{{number}}}}}{{[1][{page}][]{page}}}{{}}{{}}{{}}}}\n"
    )


def xref_record(
    label: str,
    number: str,
    page: str,
    *,
    status: str = "published",
    tag: str = "A00AA00",
) -> str:
    if status == "published":
        kind = "nfmpublished"
        display = rf"[Fixture Book, Theorem {number}, Tag \texttt {{{tag}}}]"
    else:
        kind = "nfmdraft"
        display = f"[Fixture Book, Theorem {number}]"
    return (
        f"\\NoteExternalReference{{{label}}}"
        f"{{{{[{kind}][1][]{display}}}{{[page][{page}][]{page}}}{{}}{{}}{{}}}}\n"
    )


class FakeResponse:
    def __init__(self, payload: bytes):
        self.payload = payload

    def __enter__(self) -> FakeResponse:
        return self

    def __exit__(self, *args: object) -> None:
        pass

    def read(self, size: int = -1) -> bytes:
        return self.payload[:size] if size >= 0 else self.payload


class LabelsRefSyncTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="labels-ref-sync-test.")
        self.root = Path(self.temporary.name)
        self.wrappers = {
            "book": self.root / "fixture-book.tex",
            "chapter": self.root / "chapters/c1/c1.tex",
            "s1": self.root / "chapters/c1/s1/s1.tex",
            "s2": self.root / "chapters/c1/s2/s2.tex",
        }
        for wrapper in self.wrappers.values():
            wrapper.parent.mkdir(parents=True, exist_ok=True)
            wrapper.write_text(
                "\\documentclass{noteformyself}\n"
                "\\begin{document}\n"
                "Fixture\n"
                "\\end{document}\n",
                encoding="utf-8",
            )
        manifest = {
            "schemaVersion": 3,
            "book": {
                "id": "fixture-book",
                "title": "Fixture Book",
                "tex": "fixture-book.tex",
                "url": "pdf/fixture-book.pdf",
                "chapters": [
                    {
                        "id": "c1",
                        "title": "Chapter One",
                        "tex": "chapters/c1/c1.tex",
                        "url": "pdf/chapters/c1/c1.pdf",
                        "sections": [
                            {
                                "id": "s1",
                                "title": "Section One",
                                "tex": "chapters/c1/s1/s1.tex",
                                "url": "pdf/chapters/c1/s1/s1.pdf",
                            },
                            {
                                "id": "s2",
                                "title": "Section Two",
                                "tex": "chapters/c1/s2/s2.tex",
                                "url": "pdf/chapters/c1/s2/s2.pdf",
                            },
                        ],
                    }
                ],
            },
        }
        self.manifest = manifest
        self.write_manifest()
        self.write_reference_outputs()

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_manifest(self) -> None:
        (self.root / "notes.json").write_text(
            json.dumps(self.manifest, indent=2) + "\n", encoding="utf-8"
        )

    def write_reference_outputs(self) -> None:
        alpha_by_document = {
            "book": ("1.1.7", "21", "definition.1.1.7"),
            "chapter": ("1.1.7", "8", "definition.1.1.7"),
            "s1": ("1", "4", "definition.1"),
        }
        for name, (number, page, anchor) in alpha_by_document.items():
            wrapper = self.wrappers[name]
            wrapper.with_suffix(".aux").write_text(
                aux_record("thm:alpha", number, page, anchor), encoding="utf-8"
            )
            wrapper.with_suffix(".nfm-xref").write_text(
                xref_record("thm:alpha", number, page), encoding="utf-8"
            )
        self.wrappers["s2"].with_suffix(".aux").write_text(
            aux_record("thm:beta", "2", "3", "definition.2"), encoding="utf-8"
        )

    def run_script(self, *arguments: str, check: bool = True) -> subprocess.CompletedProcess[str]:
        environment = os.environ.copy()
        environment["MANAGE_REFERENCES_ROOT"] = str(self.root)
        result = subprocess.run(
            [str(SCRIPT), *arguments],
            check=False,
            capture_output=True,
            text=True,
            env=environment,
        )
        if check and result.returncode != 0:
            self.fail(f"command failed:\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}")
        return result

    def load_script_module(self) -> object:
        module_name = f"labels_ref_sync_test_{id(self)}"
        loader = importlib.machinery.SourceFileLoader(module_name, str(SCRIPT))
        spec = importlib.util.spec_from_loader(module_name, loader)
        if spec is None:
            self.fail("could not create an import specification")
        module = importlib.util.module_from_spec(spec)
        sys.modules[module_name] = module
        with mock.patch.dict(
            os.environ, {"MANAGE_REFERENCES_ROOT": str(self.root)}, clear=False
        ):
            loader.exec_module(module)
        return module

    def test_release_uses_book_number_and_section_address(self) -> None:
        self.run_script("release")
        catalog = json.loads((self.root / "external-labels.json").read_text())
        section = next(item for item in catalog["documents"] if item["id"] == "c1/s1")
        record = next(item for item in section["labels"] if item["label"] == "thm:alpha")

        self.assertEqual(record["number"], "1.1.7")
        self.assertEqual(record["page"], "4")
        self.assertEqual(record["anchor"], "definition.1")
        self.assertEqual(record["tag"], "A00AA00")
        self.assertEqual(
            record["display"],
            "[Fixture Book, Theorem 1.1.7, Tag A00AA00]",
        )
        self.assertEqual(
            section["url"],
            "https://www.tianleyang.com/fixture-book/pdf/chapters/c1/s1/s1.pdf",
        )

    def test_release_uses_configured_file_without_changing_pdf_base(self) -> None:
        self.manifest["referenceCatalog"] = {
            "file": "release/fixture-labels.json",
            "downloadUrl": "https://notes.example.org/books/fixture/external-labels.json",
        }
        self.write_manifest()
        self.run_script("release")
        catalog = json.loads(
            (self.root / "release/fixture-labels.json").read_text()
        )
        section = next(item for item in catalog["documents"] if item["id"] == "c1/s1")

        self.assertEqual(
            section["url"],
            "https://www.tianleyang.com/fixture-book/pdf/chapters/c1/s1/s1.pdf",
        )

    def test_release_supports_an_unnumbered_semantic_environment(self) -> None:
        self.wrappers["s2"].with_suffix(".aux").write_text(
            aux_record("slogan:summary", "", "3", "thmt@dummyctr.2"),
            encoding="utf-8",
        )

        self.run_script("release")
        catalog = json.loads((self.root / "external-labels.json").read_text())
        slogan = next(
            record
            for item in catalog["documents"]
            for record in item["labels"]
            if record["label"] == "slogan:summary"
        )

        self.assertEqual(slogan["number"], "")
        self.assertEqual(slogan["display"], "[Fixture Book, Slogan]")

    def test_release_preserves_a_starred_pdf_anchor(self) -> None:
        self.wrappers["s2"].with_suffix(".aux").write_text(
            aux_record(
                "cons:starred-anchor", "2", "3", "construction*.303"
            ),
            encoding="utf-8",
        )

        self.run_script("release")
        catalog = json.loads((self.root / "external-labels.json").read_text())
        construction = next(
            record
            for item in catalog["documents"]
            for record in item["labels"]
            if record["label"] == "cons:starred-anchor"
        )

        self.assertEqual(construction["anchor"], "construction*.303")

    def test_sync_excludes_self_and_validates_generated_files(self) -> None:
        self.run_script("sync")
        s1_imports = (self.wrappers["s1"].parent / "external-labels.tex").read_text()
        s2_imports = (self.wrappers["s2"].parent / "external-labels.tex").read_text()
        local_alpha = (
            self.root / "label-references/records/self/c1--s1.tex"
        ).read_text()

        self.assertNotIn("c1--s1", s1_imports)
        self.assertIn("c1--s1", s2_imports)
        self.assertIn("\\NoteImportedReference{thm:alpha}", local_alpha)
        self.assertIn("{{1.1.7}{4}{}{definition.1}", local_alpha)
        self.assertIn(r"Theorem 1.1.7 (Tag \texttt{A00AA00})", local_alpha)
        self.assertIn(
            "https://www.tianleyang.com/fixture-book/pdf/chapters/c1/s1/s1.pdf",
            local_alpha,
        )
        self.assertNotIn("Fixture Book", local_alpha)
        self.assertEqual(self.run_script("validate").returncode, 0)

    def test_sync_migrates_the_legacy_import_filename(self) -> None:
        legacy = self.wrappers["s1"].with_name("s1.external-labels.tex")
        legacy.write_text(
            "% Generated by manage-references; do not edit.\n",
            encoding="utf-8",
        )

        self.run_script("sync")

        current = self.wrappers["s1"].parent / "external-labels.tex"
        wrapper = self.wrappers["s1"].read_text()
        self.assertTrue(current.is_file())
        self.assertFalse(legacy.exists())
        self.assertIn("\\InputIfFileExists{external-labels.tex}", wrapper)

    def test_duplicate_labels_in_leaf_sections_fail(self) -> None:
        wrapper = self.wrappers["s2"]
        wrapper.with_suffix(".aux").write_text(
            aux_record("thm:alpha", "2", "3", "definition.2"), encoding="utf-8"
        )
        result = self.run_script("sync", check=False)

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Duplicate repository label 'thm:alpha'", result.stderr)

    def test_fetch_caches_and_namespaces_remote_catalog(self) -> None:
        remote_catalog = {
            "schemaVersion": 1,
            "repository": {"id": "remote-book", "title": "Remote Book"},
            "documents": [
                {
                    "id": "remote-book",
                    "kind": "book",
                    "url": "https://example.com/remote-book/pdf/remote-book.pdf",
                    "labels": [
                        {
                            "label": "thm:remote",
                            "number": "2.3.4",
                            "page": "9",
                            "anchor": "definition.2.3.4",
                            "crefType": "nfmpublished",
                            "crefCounter": "4",
                            "display": "[Remote Book, Theorem 2.3.4, Tag B00BB00]",
                            "pageCounter": "9",
                            "pageDisplay": "9",
                            "status": "published",
                            "tag": "B00BB00",
                        }
                    ],
                }
            ],
        }
        self.manifest["externalReferences"] = [
            {
                "prefix": "remote",
                "downloadUrl": "https://example.com/remote-book/external-labels.json",
            }
        ]
        self.write_manifest()
        module = self.load_script_module()
        payload = json.dumps(remote_catalog).encode()
        with mock.patch.object(
            module.urllib.request,
            "urlopen",
            return_value=FakeResponse(payload),
        ):
            with contextlib.redirect_stdout(io.StringIO()):
                module.fetch_command(module.load_manifest(), False)

        cached = self.root / "label-references/catalogs/remote.json"
        remote_records = (
            self.root / "label-references/records/remote/remote-book.tex"
        )
        imports = (self.wrappers["s1"].parent / "external-labels.tex").read_text()
        self.assertTrue(cached.is_file())
        self.assertIn(
            "\\NoteImportedReference{remote:thm:remote}",
            remote_records.read_text(),
        )
        self.assertIn(
            "https://example.com/remote-book/pdf/remote-book.pdf",
            remote_records.read_text(),
        )
        self.assertIn(r"Tag \texttt{B00BB00}", remote_records.read_text())
        self.assertIn("label-references/records/remote/remote-book.tex", imports)

    def test_fetch_self_catalog_supplies_unprefixed_cross_section_labels(self) -> None:
        self.run_script("release")
        payload = (self.root / "external-labels.json").read_bytes()
        self.manifest["referenceCatalog"] = {
            "file": "external-labels.json",
            "downloadUrl": "https://example.com/fixture-book/external-labels.json",
        }
        self.write_manifest()
        for name, wrapper in self.wrappers.items():
            if name == "book":
                continue
            wrapper.with_suffix(".aux").unlink(missing_ok=True)
            wrapper.with_suffix(".nfm-xref").unlink(missing_ok=True)

        module = self.load_script_module()
        with mock.patch.object(
            module.urllib.request,
            "urlopen",
            return_value=FakeResponse(payload),
        ):
            with contextlib.redirect_stdout(io.StringIO()):
                module.fetch_command(module.load_manifest(), False)

        cached = self.root / "label-references/catalogs/self.json"
        local_records = (
            self.root / "label-references/records/self/c1--s1.tex"
        ).read_text()
        s1_imports = (self.wrappers["s1"].parent / "external-labels.tex").read_text()
        s2_imports = (self.wrappers["s2"].parent / "external-labels.tex").read_text()
        chapter_imports = (
            self.wrappers["chapter"].parent / "external-labels.tex"
        ).read_text()
        book_imports = (
            self.wrappers["book"].parent / "external-labels.tex"
        ).read_text()

        self.assertTrue(cached.is_file())
        self.assertNotIn("c1--s1", s1_imports)
        self.assertIn("c1--s1", s2_imports)
        self.assertNotIn("\\externalnotedocument[", s2_imports)
        self.assertIn(
            "https://www.tianleyang.com/fixture-book/pdf/chapters/c1/s1/s1.pdf",
            local_records,
        )
        self.assertIn(r"Theorem 1.1.7 (Tag \texttt{A00AA00})", local_records)
        self.assertNotIn("Fixture Book", local_records)
        self.assertNotIn("\\externalnotedocument", chapter_imports)
        self.assertNotIn("\\externalnotedocument", book_imports)

    def test_missing_self_catalog_does_not_import_a_partial_book_aux(self) -> None:
        self.manifest["referenceCatalog"] = {
            "file": "external-labels.json",
            "downloadUrl": "https://example.com/fixture-book/external-labels.json",
        }
        self.write_manifest()
        for name, wrapper in self.wrappers.items():
            if name == "book":
                continue
            wrapper.with_suffix(".aux").unlink(missing_ok=True)
            wrapper.with_suffix(".nfm-xref").unlink(missing_ok=True)

        self.run_script("sync")

        imports = (self.wrappers["s1"].parent / "external-labels.tex").read_text()
        self.assertNotIn("label-references/records/self", imports)

    def test_empty_remote_download_url_is_an_inactive_placeholder(self) -> None:
        self.manifest["externalReferences"] = [
            {"prefix": "future-book", "downloadUrl": ""}
        ]
        self.write_manifest()

        result = self.run_script("fetch")

        self.assertIn("has no downloadUrl; skipping it", result.stderr)
        imports = (self.wrappers["s1"].parent / "external-labels.tex").read_text()
        self.assertNotIn("future-book", imports)

    def test_incremental_release_keeps_uncompiled_owner_and_updates_number(self) -> None:
        self.run_script("release")
        previous = self.root / "previous-external-labels.json"
        previous.write_bytes((self.root / "external-labels.json").read_bytes())
        for name, wrapper in self.wrappers.items():
            if name == "book":
                wrapper.with_suffix(".aux").write_text(
                    aux_record("thm:alpha", "1.1.8", "22", "definition.1.1.8"),
                    encoding="utf-8",
                )
                wrapper.with_suffix(".nfm-xref").write_text(
                    xref_record("thm:alpha", "1.1.8", "22"), encoding="utf-8"
                )
            else:
                wrapper.with_suffix(".aux").unlink(missing_ok=True)
                wrapper.with_suffix(".nfm-xref").unlink(missing_ok=True)
        compiled = self.root / "compiled-documents.txt"
        compiled.write_text("fixture-book.tex\n", encoding="utf-8")

        self.run_script(
            "release",
            "--previous",
            previous.name,
            "--documents-file",
            compiled.name,
        )
        catalog = json.loads((self.root / "external-labels.json").read_text())
        section = next(item for item in catalog["documents"] if item["id"] == "c1/s1")
        alpha = next(item for item in section["labels"] if item["label"] == "thm:alpha")
        beta = next(
            record
            for item in catalog["documents"]
            for record in item["labels"]
            if record["label"] == "thm:beta"
        )

        self.assertEqual(alpha["number"], "1.1.8")
        self.assertEqual(alpha["page"], "4")
        self.assertEqual(alpha["anchor"], "definition.1")
        self.assertEqual(beta["number"], "2")

    def test_incremental_release_removes_labels_deleted_from_rebuilt_owner(self) -> None:
        self.run_script("release")
        previous = self.root / "previous-external-labels.json"
        previous.write_bytes((self.root / "external-labels.json").read_bytes())
        for wrapper in self.wrappers.values():
            wrapper.with_suffix(".aux").unlink(missing_ok=True)
            wrapper.with_suffix(".nfm-xref").unlink(missing_ok=True)
        self.wrappers["s1"].with_suffix(".aux").write_text("", encoding="utf-8")
        compiled = self.root / "compiled-documents.txt"
        compiled.write_text("chapters/c1/s1/s1.tex\n", encoding="utf-8")

        self.run_script(
            "release",
            "--previous",
            previous.name,
            "--documents-file",
            compiled.name,
        )
        catalog = json.loads((self.root / "external-labels.json").read_text())
        labels = {
            record["label"]
            for item in catalog["documents"]
            for record in item["labels"]
        }

        self.assertNotIn("thm:alpha", labels)
        self.assertIn("thm:beta", labels)


if __name__ == "__main__":
    unittest.main()

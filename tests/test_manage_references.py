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


SCRIPT = Path(__file__).resolve().parents[1] / "manage-references"


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
        display = f"[Fixture Book, Theorem {number}, Tag {tag}]"
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


class ManageReferencesTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="manage-references-test.")
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
        module_name = f"manage_references_test_{id(self)}"
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
            section["url"],
            "https://www.tianleyang.com/fixture-book/pdf/chapters/c1/s1/s1.pdf",
        )

    def test_sync_excludes_self_and_validates_generated_files(self) -> None:
        self.run_script("sync")
        s1_imports = self.wrappers["s1"].with_name("s1.external-labels.tex").read_text()
        s2_imports = self.wrappers["s2"].with_name("s2.external-labels.tex").read_text()
        local_alpha = (
            self.root / ".note-references/local/documents/c1--s1.aux"
        ).read_text()
        local_alpha_xref = (
            self.root / ".note-references/local/documents/c1--s1.nfm-xref"
        ).read_text()

        self.assertNotIn("c1--s1", s1_imports)
        self.assertIn("c1--s1", s2_imports)
        self.assertIn("[../s1/s1.pdf]", s2_imports)
        self.assertIn("{{1.1.7}{4}{}{definition.1}{}}", local_alpha)
        self.assertIn("Theorem 1.1.7 (Tag A00AA00)", local_alpha_xref)
        self.assertNotIn("Fixture Book", local_alpha_xref)
        self.assertEqual(self.run_script("validate").returncode, 0)

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
                "url": "https://example.com/remote-book/external-labels.json",
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

        cached = self.root / ".note-references/remotes/remote/external-labels.json"
        remote_aux = (
            self.root / ".note-references/remotes/remote/documents/remote-book.aux"
        )
        imports = self.wrappers["s1"].with_name("s1.external-labels.tex").read_text()
        self.assertTrue(cached.is_file())
        self.assertIn("thm:remote", remote_aux.read_text())
        self.assertIn("\\externalnotedocument[remote]", imports)
        self.assertIn("https://example.com/remote-book/pdf/remote-book.pdf", imports)


if __name__ == "__main__":
    unittest.main()

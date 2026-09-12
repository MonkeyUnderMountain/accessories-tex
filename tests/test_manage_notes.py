from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import Any


SCRIPT = Path(__file__).resolve().parents[1] / "manage-notes"


def status(published: int = 0, finished: int = 0) -> dict[str, int]:
    return {"published": published, "finished": finished}


class ManageNotesTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="manage-notes-test.")
        self.root = Path(self.temporary.name)
        self.manifest: dict[str, Any] = {
            "schemaVersion": 3,
            "build": {"engine": "xelatex"},
            "book": {
                "id": "fixture-book",
                "title": "Fixture Book",
                "tex": "fixture-book.tex",
                "url": "pdf/fixture-book.pdf",
                "status": status(),
                "chapters": [],
            },
        }
        self.write_manifest()
        self.write_wrapper(
            self.root / "fixture-book.tex",
            sectionlevel="book",
            title="Fixture Book (draft)",
            managed_name="chapters",
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_manifest(self) -> None:
        (self.root / "notes.json").write_text(
            json.dumps(self.manifest, indent=2) + "\n",
            encoding="utf-8",
        )

    def write_wrapper(
        self,
        path: Path,
        *,
        sectionlevel: str,
        title: str,
        managed_name: str,
    ) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        option = "" if sectionlevel == "section" else f"[sectionlevel={sectionlevel}]"
        path.write_text(
            "% !TeX program = xelatex\n"
            "% !TeX encoding = UTF-8\n"
            "% !BIB program = biber\n"
            f"\\documentclass{option}{{noteformyself}}\n"
            "% manage-notes:begin watermark\n"
            "\\usepackage{draftwatermark}\n"
            "% manage-notes:end watermark\n\n"
            f"\\title{{{title}}}\n"
            "\\begin{document}\n"
            f"% manage-notes:begin {managed_name}\n"
            f"% manage-notes:end {managed_name}\n"
            "\\end{document}\n",
            encoding="utf-8",
        )

    def run_manage(
        self, *arguments: str, check: bool = True
    ) -> subprocess.CompletedProcess[str]:
        environment = os.environ.copy()
        environment["MANAGE_NOTES_ROOT"] = str(self.root)
        result = subprocess.run(
            [sys.executable, str(SCRIPT), *arguments],
            cwd=self.root,
            env=environment,
            capture_output=True,
            text=True,
            check=False,
        )
        if check and result.returncode != 0:
            self.fail(
                f"manage-notes {' '.join(arguments)} failed:\n"
                f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
            )
        return result

    def load_manifest(self) -> dict[str, Any]:
        return json.loads((self.root / "notes.json").read_text(encoding="utf-8"))

    def test_create_uses_draft_options_labels_and_plain_titles(self) -> None:
        self.run_manage("create", "chapter", "First Chapter")
        self.run_manage("create", "section", "1", "First Section")
        self.run_manage("set-status", "1", "--finished", "1")
        self.run_manage("validate")

        data = self.load_manifest()
        chapter = data["book"]["chapters"][0]
        section = chapter["sections"][0]
        self.assertEqual(chapter["status"], status(0, 1))
        self.assertEqual(chapter["tag"], "000")
        self.assertEqual(section["tag"], "00000")
        self.assertEqual(chapter["label"], "chap:first-chapter")
        self.assertEqual(section["label"], "sec:first-chapter:first-section")

        book_source = (self.root / "fixture-book.tex").read_text(encoding="utf-8")
        chapter_source = (
            self.root / "chapters/first-chapter/first-chapter.tex"
        ).read_text(encoding="utf-8")
        section_source = (
            self.root
            / "chapters/first-chapter/first-section/first-section.tex"
        ).read_text(encoding="utf-8")

        for source, level in (
            (book_source, "book"),
            (chapter_source, "chapter"),
            (section_source, "section"),
        ):
            self.assertIn(
                f"\\documentclass[sectionlevel={level},status=draft]"
                "{noteformyself}",
                source,
            )
            self.assertNotIn("draftwatermark", source)
            self.assertNotIn("manage-notes:begin watermark", source)
            self.assertNotIn("(draft)", source)
            self.assertIn("% manage-notes:begin setup", source)

        self.assertIn("label=\\labelNFM{chap:first-chapter}", book_source)
        self.assertIn("tag=000", book_source)
        self.assertIn("tag=00000", book_source)
        self.assertIn(
            "label=\\labelNFM{sec:first-chapter:first-section}",
            book_source,
        )
        self.assertIn(
            "label=\\labelNFM{sec:first-chapter:first-section}",
            chapter_source,
        )
        self.assertIn(
            "label=\\labelNFM{sec:first-chapter:first-section}",
            section_source,
        )

    def test_sync_migrates_published_tagged_wrappers(self) -> None:
        chapter = {
            "id": "foundations",
            "title": "Foundations",
            "order": 1,
            "tex": "chapters/foundations/foundations.tex",
            "url": "pdf/chapters/foundations/foundations.pdf",
            "status": status(1, 1),
            "tag": "Z99",
            "sections": [
                {
                    "id": "first-results",
                    "title": "First Results",
                    "order": 1,
                    "tex": "chapters/foundations/first-results/first-results.tex",
                    "url": "pdf/chapters/foundations/first-results/first-results.pdf",
                    "status": status(1, 1),
                    "tag": "Q12W3",
                }
            ],
        }
        self.manifest["book"]["tag"] = "A"
        self.manifest["book"]["status"] = status(1, 1)
        self.manifest["book"]["chapters"] = [chapter]
        self.write_manifest()
        self.write_wrapper(
            self.root / "chapters/foundations/foundations.tex",
            sectionlevel="chapter",
            title="Foundations (draft)",
            managed_name="sections",
        )
        self.write_wrapper(
            self.root
            / "chapters/foundations/first-results/first-results.tex",
            sectionlevel="section",
            title="First Results (draft)",
            managed_name="section",
        )
        body = self.root / "chapters/foundations/first-results/text.tex"
        body.write_text("% !TeX root = first-results.tex\n", encoding="utf-8")

        self.run_manage("sync")
        self.run_manage("validate")

        normalized = self.load_manifest()
        normalized_chapter = normalized["book"]["chapters"][0]
        normalized_section = normalized_chapter["sections"][0]
        self.assertEqual(normalized_chapter["label"], "chap:foundations")
        self.assertEqual(
            normalized_section["label"],
            "sec:foundations:first-results",
        )

        book_source = (self.root / "fixture-book.tex").read_text(encoding="utf-8")
        chapter_source = (
            self.root / "chapters/foundations/foundations.tex"
        ).read_text(encoding="utf-8")
        section_source = (
            self.root
            / "chapters/foundations/first-results/first-results.tex"
        ).read_text(encoding="utf-8")
        for source, level in (
            (book_source, "book"),
            (chapter_source, "chapter"),
            (section_source, "section"),
        ):
            self.assertIn(
                f"\\documentclass[sectionlevel={level},status=published]"
                "{noteformyself}",
                source,
            )
            self.assertNotIn("draftwatermark", source)
            self.assertNotIn("manage-notes:begin watermark", source)
            self.assertNotIn("(draft)", source)
            self.assertIn("book-tag=A", source)

        self.assertIn("tag=Z99", book_source)
        self.assertIn("label=\\labelNFM{chap:foundations}", book_source)
        self.assertIn("tag=Q12W3", section_source)
        self.assertIn(
            "label=\\labelNFM{sec:foundations:first-results}",
            section_source,
        )

    def test_published_chapter_receives_the_default_tag(self) -> None:
        self.run_manage("create", "chapter", "Published Chapter", "1", "1")

        chapter = self.load_manifest()["book"]["chapters"][0]
        self.assertEqual(chapter["tag"], "000")
        wrapper = (
            self.root / "chapters/published-chapter/published-chapter.tex"
        ).read_text(encoding="utf-8")
        self.assertIn("status=published", wrapper)
        self.assertIn("chapter-tag=000", wrapper)

    def test_rename_preserves_generated_source_label(self) -> None:
        self.run_manage("create", "chapter", "First Chapter")
        original = self.load_manifest()["book"]["chapters"][0]["label"]
        self.run_manage("rename", "1", "renamed-chapter", "--no-retitle")
        chapter = self.load_manifest()["book"]["chapters"][0]
        self.assertEqual(chapter["id"], "renamed-chapter")
        self.assertEqual(chapter["label"], original)
        book_source = (self.root / "fixture-book.tex").read_text(encoding="utf-8")
        self.assertIn(f"label=\\labelNFM{{{original}}}", book_source)

    def test_reparent_preserves_the_section_tag_and_label(self) -> None:
        self.run_manage("create", "chapter", "First Chapter")
        self.run_manage("create", "chapter", "Second Chapter")
        self.run_manage("create", "section", "1", "Moving Section")
        before = self.load_manifest()["book"]["chapters"][0]["sections"][0]

        self.run_manage("move", "1.1", "2.1")
        self.run_manage("validate")

        after = self.load_manifest()["book"]["chapters"][1]["sections"][0]
        self.assertEqual(after["label"], before["label"])
        self.assertEqual(after["tag"], "00000")
        wrapper = (
            self.root
            / "chapters/second-chapter/moving-section/moving-section.tex"
        ).read_text(encoding="utf-8")
        self.assertIn("chapter-tag=000", wrapper)
        self.assertIn("tag=00000", wrapper)


if __name__ == "__main__":
    unittest.main()

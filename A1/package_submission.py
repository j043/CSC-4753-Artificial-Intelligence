"""Run with Python 3 to package current source, docs, and the exported Windows build."""
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
import hashlib


def main():
    assignment = Path(__file__).resolve().parent
    root = assignment.parent
    files = [assignment / name for name in (
        "README.md", "spec.md", "CREDITS.md", "package_submission.py"
    )]
    for folder in ("docs", "licenses", "game", "builds/windows"):
        files.extend(p for p in (assignment / folder).rglob("*")
                     if p.is_file() and ".godot" not in p.parts and p.suffix != ".tmp"
                     and p.name not in {"prompts.txt", "AGENTS.md"}
                     and not p.name.startswith(".env"))
    required = [assignment / "builds/windows" / name for name in
                ("Blackwell.exe", "Blackwell.pck", "README.txt")]
    required += [assignment / "game/project.godot",
                 assignment / "licenses/Godot-and-third-party.txt"]
    for path in files + required:
        if not path.is_file():
            raise FileNotFoundError(path)
    archive = assignment / "submission/Blackwell-A1-M6.zip"
    archive.parent.mkdir(exist_ok=True)
    with ZipFile(archive, "w", ZIP_DEFLATED) as bundle:
        for path in sorted(files):
            bundle.write(path, path.relative_to(root).as_posix())
    with ZipFile(archive) as bundle:
        bad = bundle.testzip()
        if bad:
            raise ValueError(f"CRC failure: {bad}")
        for path in files:
            if bundle.read(path.relative_to(root).as_posix()) != path.read_bytes():
                raise ValueError(f"Content mismatch: {path}")
        print(f"Verified {len(bundle.namelist())} files: {archive}")
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{digest}  {archive.name}\n", encoding="utf-8")
    print(f"SHA256: {digest}")
    print("Packaging does not re-export Godot: export after gameplay changes first.")


if __name__ == "__main__":
    main()

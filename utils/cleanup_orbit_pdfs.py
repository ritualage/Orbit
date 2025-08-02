#!/usr/bin/env python3
import argparse
import sqlite3
from pathlib import Path

# Install: pip install send2trash
try:
    from send2trash import send2trash
except ImportError:
    raise SystemExit("Please install send2trash: pip install send2trash")

# Adjusted for your environment
DB_PATHS = [
    # Primary (sandboxed, bundle-id container)
    Path.home() / "Library" / "Containers" / "com.ritualage.Orbit" / "Data" / "Library" / "Application Support" / "Orbit" / "orbit.sqlite3",
    # Legacy/mismatched container (if any)
    Path.home() / "Library" / "Containers" / "Orbit" / "Data" / "Library" / "Application Support" / "Orbit" / "orbit.sqlite3",
    # Non-sandbox fallback
    Path.home() / "Library" / "Application Support" / "Orbit" / "orbit.sqlite3",
]

PDF_FOLDERS = [
    # Primary (sandboxed, bundle-id container)
    Path.home() / "Library" / "Containers" / "com.ritualage.Orbit" / "Data" / "Documents" / "Orbit",
    # Legacy/mismatched container (if any)
    Path.home() / "Library" / "Containers" / "Orbit" / "Data" / "Documents" / "Orbit",
    # Non-sandbox fallback
    Path.home() / "Documents" / "Orbit",
    Path.home() / "Orbit",
]

def pick_existing_path(paths):
    for p in paths:
        if p.exists():
            return p
    return None

def trash(p: Path, dry_run: bool) -> bool:
    if dry_run:
        print(f"[dry-run] Would trash: {p}")
        return True
    try:
        send2trash(str(p))
        print(f"Trashed: {p}")
        return True
    except Exception as e:
        print(f"Failed to trash {p}: {e}")
        return False

def main():
    ap = argparse.ArgumentParser(description="Cleanup Orbit PDFs and DB entries")
    ap.add_argument("--dry-run", action="store_true", help="Preview actions without trashing files or modifying DB")
    ap.add_argument("--keep-db", action="store_true", help="Do not clear the saved_docs table")
    args = ap.parse_args()

    db_path = pick_existing_path(DB_PATHS)
    if not db_path:
        print("No database found in known locations:")
        for p in DB_PATHS:
            print(f" - {p}")
        db = None
        db_paths = []
    else:
        print(f"Using DB: {db_path}")
        db = sqlite3.connect(str(db_path))
        cur = db.cursor()
        cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='saved_docs';")
        if not cur.fetchone():
            print("Table 'saved_docs' not found in DB. Exiting.")
            db.close()
            return
        cur.execute("SELECT id, pdf_path FROM saved_docs;")
        rows = cur.fetchall()
        print(f"DB rows in saved_docs: {len(rows)}")
        db_paths = [(row[0], Path(row[1])) for row in rows]

    # Trash files referenced by DB if they exist
    trashed_db_files = 0
    missing_db_files = 0
    existing_db_paths = set()
    parent_dirs = set()

    for _id, p in db_paths:
        parent_dirs.add(p.parent)
        if p.exists():
            try:
                rp = p.resolve()
            except Exception:
                rp = p
            existing_db_paths.add(str(rp))
            if trash(p, args.dry_run):
                trashed_db_files += 1
        else:
            missing_db_files += 1
            print(f"Missing on disk (DB id { _id }): {p}")

    # Orphan scan in PDF folders (container first) and any parents discovered from DB
    scan_dirs = {d for d in PDF_FOLDERS if d.exists()} | {d for d in parent_dirs if d and d.exists()}
    if scan_dirs:
        print("Scanning for orphan PDFs in:")
        for d in sorted(scan_dirs):
            print(f" - {d}")
    else:
        print("No PDF folders found to scan.")

    trashed_orphans = 0
    scanned_pdfs = 0
    for folder in sorted(scan_dirs):
        for pdf in folder.glob("*.pdf"):
            scanned_pdfs += 1
            try:
                rp = str(pdf.resolve())
            except Exception:
                rp = str(pdf)
            if rp not in existing_db_paths:
                if trash(pdf, args.dry_run):
                    trashed_orphans += 1

    # Optionally clear the table
    if db and not args.keep_db:
        if args.dry_run:
            print("[dry-run] Would clear 'saved_docs' table")
        else:
            db.execute("DELETE FROM saved_docs;")
            db.commit()
            print("Cleared 'saved_docs' table.")
        db.close()

    print("Summary:")
    print(f" - Trashed referenced PDFs: {trashed_db_files}")
    print(f" - Missing referenced PDFs: {missing_db_files}")
    print(f" - Scanned PDFs: {scanned_pdfs}")
    print(f" - Trashed orphan PDFs: {trashed_orphans}")

if __name__ == "__main__":
    main()


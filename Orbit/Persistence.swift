//
//  Persistence.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//


import Foundation
import SQLite3

// Make a Swift-friendly SQLITE_TRANSIENT
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)


struct SavedDoc: Identifiable {
    let id: Int64
    let date: Date
    let taskID: String
    let emoji: String
    let title: String
    let pdfPath: String
}

final class DB {
    static let shared = DB()
    private var db: OpaquePointer?
    
    
    private init() {
        open()
        createTableIfNeeded()
    }
    deinit { if db != nil { sqlite3_close(db) } }
    
    private func open() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = dir.appendingPathComponent("Orbit", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("orbit.sqlite3")
        if sqlite3_open(url.path, &db) != SQLITE_OK {
            print("SQLite open error")
        }
    }
    
    private func createTableIfNeeded() {
        let sql = """
    CREATE TABLE IF NOT EXISTS saved_docs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at REAL NOT NULL,
        task_id TEXT NOT NULL,
        emoji TEXT NOT NULL,
        title TEXT NOT NULL,
        pdf_path TEXT NOT NULL
    );
    """
        _ = exec(sql)
    }
    
    @discardableResult
    private func exec(_ sql: String) -> Bool {
        var err: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            if let err { print("SQLite error: \(String(cString: err))") }
            return false
        }
        return true
    }
    
    func delete(id: Int64) {
        _ = exec("DELETE FROM saved_docs WHERE id = \(id);")
    }
    
    func insert(taskID: String, emoji: String, title: String, pdfPath: String) -> Int64? {
        let sql = "INSERT INTO saved_docs (created_at, task_id, emoji, title, pdf_path) VALUES (?,?,?,?,?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_double(stmt, 1, Date().timeIntervalSince1970)
        sqlite3_bind_text(stmt, 2, taskID, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, emoji, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 4, title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 5, pdfPath, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_DONE else { return nil }
        return sqlite3_last_insert_rowid(db)
    }
    
    func fetchAll() -> [SavedDoc] {
        let sql = "SELECT id, created_at, task_id, emoji, title, pdf_path FROM saved_docs ORDER BY created_at DESC;"
        var stmt: OpaquePointer?
        var results: [SavedDoc] = []
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = sqlite3_column_int64(stmt, 0)
            let created = sqlite3_column_double(stmt, 1)
            let taskID = String(cString: sqlite3_column_text(stmt, 2))
            let emoji = String(cString: sqlite3_column_text(stmt, 3))
            let title = String(cString: sqlite3_column_text(stmt, 4))
            let path = String(cString: sqlite3_column_text(stmt, 5))
            results.append(SavedDoc(id: id,
                                    date: Date(timeIntervalSince1970: created),
                                    taskID: taskID,
                                    emoji: emoji,
                                    title: title,
                                    pdfPath: path))
        }
        return results
    }
}

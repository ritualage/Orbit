CRUSH guide for Orbit (SwiftUI macOS app)

Build/Test/Lint
- Build (Xcode GUI): Open Orbit.xcodeproj and ⌘B
- Build (CLI): xcodebuild -project Orbit.xcodeproj -scheme Orbit -destination 'platform=macOS' build
- Run app (CLI): xcodebuild -project Orbit.xcodeproj -scheme Orbit -destination 'platform=macOS' build && open build/Debug/Orbit.app
- Clean: xcodebuild -project Orbit.xcodeproj -scheme Orbit clean
- Tests (if unit tests are added): xcodebuild test -project Orbit.xcodeproj -scheme Orbit -destination 'platform=macOS'
- Run a single test: xcodebuild test -project Orbit.xcodeproj -scheme Orbit -destination 'platform=macOS' -only-testing:OrbitTests/YourTestCase/testMethod
- Swift format (if swift-format available): swift-format -i -r Orbit
- SwiftLint (if configured): swiftlint

Code style
- Imports: Standard Apple frameworks first, then external libs (MarkdownUI, PDFKit, AppKit, QuickLookUI), then local modules. Group logically, no unused imports.
- Formatting: 2-space indent, trailing commas avoided, keep lines < 120 cols. Prefer multi-line string literals for prompts. No comments added by default in commits.
- Types: Prefer let over var; use explicit types for public APIs; avoid force unwrap; use optional binding/guard.
- Naming: LowerCamelCase for vars/functions, UpperCamelCase for types. Enum cases lowerCamelCase with readable raw values. Use clear, user-facing strings for UI labels.
- Error handling: Use do/try/catch; surface user-visible errors via errorMessage @Published; never crash on I/O; log with print for dev only.
- Concurrency/networking: URLSession with long timeouts; cancel previous tasks on new run(); keep UI updates on main thread. Avoid blocking UI; mark ObservableObject updates with DispatchQueue.main.async.
- View composition: Small SwiftUI subviews (Card, RunButton, SaveButton, RoundedTextField). Keep state in @State/@StateObject; pass data via bindings. Use .buttonStyle(.plain) consistently.
- Persistence: Use SQLite via Persistence.swift; all DB mutations go through DB.shared; never access sqlite3 directly elsewhere.
- PDFs: Use PrintableMarkdownView and PDFGenerator.savePDFFromMarkdownUI; store files under ~/Documents/Orbit; sanitize filenames with regex.
- Colors/Styling: Use Color extensions (accentCyan, activeGreen, inactiveGreen) and Card container for consistent UI.
- Secrets: Do not hardcode tokens. Ollama URL/model configurable via properties (baseURL, modelName) — avoid committing personal values.

Tools and repos
- No .cursor or Copilot rule files detected. If added later, mirror their constraints here.
- Required external: Ollama daemon on http://127.0.0.1:11434; model gemma3n:e4b pulled locally (see README).

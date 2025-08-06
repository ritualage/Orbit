# 🚀 Orbit — ADHD Toolkit for Mac

**Orbit** is a small, focused macOS app that helps folks with ADHD get *unstuck*. It combines practical behavioral patterns with a **local LLM** (via [Ollama](https://ollama.com)) to generate step-by-step plans, schedules, and scripts — fast, offline, and private.

---

## 🧠 What Orbit Helps With

- 🧃 **Dopamine menu builder**  
  Sandwich boring tasks between rewards and breaks.

- ⚡ **Task paralysis breaker**  
  Turn a scary task into tiny, obvious first steps.

- 🔁 **Hyperfocus hijacker**  
  Bridge your current hyperfocus into what actually matters.

- ⏳ **Time blindness fixer**  
  Estimate realistic durations and build a schedule.

- 🚧 **Executive dysfunction helper**  
  "Background process" your way past the start wall.

- 🛡️ **RSD shield builder**  
  Self-talk script and protocol to act with less fear.

> All model inference runs **locally** through Ollama. No cloud. No telemetry. Full privacy.

---

## ⚡ Quick Start (No Compile Needed)

We publish signed builds directly via [GitHub Releases](https://github.com/ritualage/orbit/releases). No Xcode required.

### ✅ Steps:

1. **Download the latest `.app`**  
   👉 [Download from Releases](https://github.com/ritualage/orbit/releases)

2. **First launch**  
   If macOS shows “unidentified developer”, **right-click → Open** the first time.

3. **Ollama is required**  
   Orbit depends on **Ollama** running locally with a specific model installed.

See [Ollama setup](#ollama-setup-required) below.

---

## 🔧 Ollama Setup (Required)

1. **Install Ollama**  
   → [https://ollama.com](https://ollama.com)

2. **Start Ollama**  
   It runs a local server at `http://127.0.0.1:11434`

3. **Pull the required model**  
   ```bash
   ollama pull gemma3n:e4b
   ```

4. **Verify it's running**  
   ```bash
   ollama list
   ```

Make sure the model appears in the list. Keep Ollama running while Orbit is open.  
If you change the model in code later, update `OllamaClient.modelName`.

---

## 🛠️ Build from Source

### 🧾 Requirements

- macOS 13+
- Xcode 15+
- Swift 5.9+

### 🧬 Steps

```bash
git clone https://github.com/ritualage/orbit.git
cd orbit
```

1. **Open in Xcode**:  
   Open `Orbit.xcodeproj` (or the workspace if present)

2. **Select the Orbit scheme**, then build and run.

3. **Ensure Ollama is running**:
   ```bash
   ollama serve        # if it's not already running
   ollama pull gemma3n:e4b
   ```

---

## 🧭 How It Works (At a Glance)

- **Left Sidebar**: Lists ADHD tools with descriptions
- **Right Sidebar**: Saved PDF outputs
- **Center Panel**: Prompt inputs + "Run with Ollama" button
- **Markdown Output**: Orbit streams responses from Ollama and renders them live
- **PDF Export**: Saved to `~/Documents/Orbit/` and shown in the right panel

---

## 🔐 Privacy

Everything runs **locally**.  
Your inputs and outputs **never leave your machine**.

---

## 🛠 Troubleshooting

### ❓ “Model not found” or no output

- Is Ollama running?  
  ```bash
  ps aux | grep ollama
  ```

- Did you pull the model?  
  ```bash
  ollama pull gemma3n:e4b
  ```

### 🌐 Network error or timeout

- Ollama runs at `http://127.0.0.1:11434`  
  If you changed ports, update `OllamaClient.baseURL`.

### 📁 PDFs not appearing

- Check `~/Documents/Orbit/`
- If prompted, grant file system access

---

## 📦 Downloading Signed Builds

We publish notarized, signed `.app` binaries under:

🔗 [https://github.com/ritualage/orbit/releases](https://github.com/ritualage/orbit/releases)

Subscribe to Releases to get updates automatically.

---

## 🗺️ Roadmap

- [ ] Additional ADHD tools and prompts
- [ ] Model selector in the UI
- [ ] Stop / Cancel generation button
- [ ] Windows / Linux ports (pending SwiftUI feasibility)

---

## 🤝 Contributing

Contributions welcome — ideas, issues, PRs, you name it!

### How to contribute:

- Open an issue to suggest a feature or report a bug
- Fork, commit, and submit a pull request
- For UI-related changes, include screenshots

---

## 📄 License

MIT License.  
See [`LICENSE`](LICENSE) for full terms.

---

## 🙏 Acknowledgements

- [Ollama](https://ollama.com) — for easy local LLM hosting
- The open-source community around local models and SwiftUI tooling

> Stay kind to your future self. Orbit exists to reduce friction — so you can start, continue, and finish with less resistance.

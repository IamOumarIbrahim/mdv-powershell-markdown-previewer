# mdv — Markdown Viewer for PowerShell

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207%2B-blue)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6)
![Dark Mode](https://img.shields.io/badge/theme-GitHub%20Dark-0d1117)
![LaTeX](https://img.shields.io/badge/math-KaTeX-green)

**Lightning-fast, Zero-Limit GitHub Dark Mode Markdown Previewer for PowerShell.**

*Never hit `fork/exec: filename or extension is too long` or 32KB process limits again.*

</div>

---

## 🔥 Why `mdv`?

Standard markdown CLI previewers like `gh markdown-preview` break on Windows when rendering large Markdown files (>32 KB) due to the Windows 32,767 character process argument limit (`CreateProcess`). They also lack native image resolution and KaTeX LaTeX math support.

`mdv` solves this completely:
- 🚀 **Zero File-Size Limit:** Renders 1 KB or 10 MB+ files instantly without command-line process errors.
- 🌙 **100% GitHub Dark Theme:** Matches official GitHub dark styling (`#0d1117`).
- 📐 **Full LaTeX Math Support:** Instant rendering of inline (`$ ... $`, `\( ... \)`) and block (`$$ ... $$`, `\[ ... \]`) equations via KaTeX.
- 🖼️ **Local Image & HTML Support:** Resolves relative image paths (`src="assets/..."`) and parses HTML tags natively (`<div align="center">`, badges, `<br />`).
- ⚡ **Multi-Tab Preview (`mdv -all`):** Open every Markdown file in your current folder simultaneously in browser tabs with a single command.

---

## ⚡ Quick 1-Click Installation

### Option A: Double-Click Installer (Batch File)
1. Download or clone this repository.
2. Double-click `install.bat`.
3. Open a new PowerShell terminal!

### Option B: One-Liner PowerShell Install
Run this command in PowerShell:

```powershell
iwr -useb https://raw.githubusercontent.com/IamOumarIbrahim/mdv/main/install.ps1 | iex
```

*Or manually copy-paste `install.ps1` into PowerShell.*

---

## 🚀 Usage

### Preview a specific file
```powershell
mdv README.md
```
*or*
```powershell
mdv .\assets\Docs\MANAR_V1_ENGINEERING_RESEARCH_V3.md
```

### Preview ALL Markdown files in the current folder
```powershell
mdv -all
```
*(or `mdv -a` or simply `mdv`)*

---

## 📊 Comparison

| Feature | `gh markdown-preview` | `mdv` |
| :--- | :---: | :---: |
| **Large File Support (>32 KB)** | ❌ Crashes (`filename too long`) | ✅ **Zero limit (10MB+)** |
| **LaTeX Math Equations** | ❌ Raw text | ✅ **KaTeX Rendered** |
| **Local Image Resolution** | ❌ Broken relative paths | ✅ **Full `<base href>` pathing** |
| **Inline HTML / Badges** | ❌ Escaped raw text | ✅ **Native HTML parsing** |
| **Multi-file / Multi-tab (`-all`)** | ❌ Broken / `path=` empty | ✅ **Instant multi-tab preview** |
| **Dark Mode** | ⚠️ Flag required | ✅ **Default GitHub Dark (`#0d1117`)** |

---

## 📜 License

Distributed under the [MIT License](LICENSE). Created and maintained by [Oumar Ibrahim](https://github.com/IamOumarIbrahim).

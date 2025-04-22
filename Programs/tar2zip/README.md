# Tar2Zip

Small GUI tool that converts **`.tar.gz` / `.tgz`** archives into regular **`.zip`** files.

---
## What it does

- Re‑packages the archive on the fly; nothing is extracted to the file‑system.
- Adjusts timestamps earlier than 1980 so every entry is ZIP‑compatible.
- Works from source on any OS with Python 3.7 + PyQt5.
- Can be distributed as a single Windows executable built with PyInstaller.

---
## Run from source (all platforms)

```bash
pip install -r requirements.txt   # installs PyQt5
python tar2zip.py                 # launches the GUI
```

---
## Build a standalone **Tar2Zip.exe** (Windows only)

```powershell
pip install pyinstaller

py -m PyInstaller `
    --onefile --windowed --clean --noconfirm `
    --name Tar2Zip `
    --icon x.ico `          # executable icon (optional)
    --add-data "x.png;." `  # splash/logo used by the app
    tar2zip.py
```

The executable appears in **`dist/Tar2Zip.exe`** and runs on any Windows PC without Python installed.

---
## Project layout

```
repo/
├─ tar2zip.py      # application entry point
├─ x.png           # splash + window icon
├─ x.ico           # executable icon (optional)
├─ requirements.txt
└─ README.md
```

---
## License

MIT © 2025 Thexhosting.com
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
TarGz → Zip Converter  🖤 Luxe Edition + Splash
────────────────────────────────────────────────
* Elegant dark UI with gold accents (responsive layout).
* Converts *.tar.gz / *.tgz* to *.zip* (clamps timestamps < 1980).
* Shows a custom **splash screen (x.png)** at startup instead of converting it
  to an .ico. The PNG is also used as the main‑window icon.
* Cross‑platform – Python ≥ 3.7 + PyQt5.
"""
from __future__ import annotations

import re
import sys
import tarfile
import time
import zipfile
from pathlib import Path
from typing import BinaryIO, List, Optional

from PyQt5.QtCore import Qt, QThread, QTimer, pyqtSignal
from PyQt5.QtGui import QColor, QFont, QIcon, QPixmap
from PyQt5.QtWidgets import (
    QApplication,
    QFileDialog,
    QFrame,
    QGridLayout,
    QGraphicsDropShadowEffect,
    QLabel,
    QLineEdit,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QProgressBar,
    QSplashScreen,
    QVBoxLayout,
    QWidget,
)

BUFFER = 128 * 1024  # 128 KiB
ZIP_MIN_YEAR = 1980

# ─────────────────────────── helper utilities ──────────────────────────

def resource_path(rel: str) -> str:
    """Return absolute path (also works for PyInstaller one‑file)."""
    base = getattr(sys, "_MEIPASS", Path(__file__).parent)
    return str(Path(base) / rel)


def copy_stream(src: BinaryIO, dst: BinaryIO, chunk: int = BUFFER) -> None:
    while data := src.read(chunk):
        dst.write(data)


def dest_zip_name(tar_path: Path) -> Path:
    name = re.sub(r"(\.tar\.gz|\.tgz)$", "", tar_path.name, flags=re.IGNORECASE)
    return tar_path.with_name(name + ".zip")


def zip_time(mtime: float):  # -> tuple[int,int,int,int,int,int]
    y, m, d, hh, mm, ss = time.localtime(mtime)[:6]
    return (ZIP_MIN_YEAR, 1, 1, 0, 0, 0) if y < ZIP_MIN_YEAR else (y, m, d, hh, mm, ss)

# ─────────────────────────── worker thread ─────────────────────────────
class ConvertWorker(QThread):
    progress = pyqtSignal(int)
    finished = pyqtSignal(str)
    failed   = pyqtSignal(str)

    def __init__(self, src: Path, dst: Path):
        super().__init__()
        self.src, self.dst = src, dst

    def run(self):  # noqa: D401
        try:
            self._convert()
            self.finished.emit(str(self.dst))
        except Exception as exc:  # pylint: disable=broad-except
            self.failed.emit(str(exc))

    def _convert(self) -> None:
        with tarfile.open(self.src, "r:gz") as tar:
            members: List[tarfile.TarInfo] = [m for m in tar.getmembers() if m.isfile() or m.isdir()]
            total = max(len(members), 1)
            with zipfile.ZipFile(self.dst, "w", zipfile.ZIP_DEFLATED) as zf:
                for idx, m in enumerate(members, 1):
                    if m.isdir():
                        zf.writestr(m.name.rstrip("/") + "/", b"")
                    else:
                        with tar.extractfile(m) as fsrc:  # type: ignore[arg-type]
                            if fsrc is None:
                                continue
                            zi = zipfile.ZipInfo(m.name.lstrip("./"), zip_time(m.mtime))
                            zi.external_attr = (m.mode & 0o777) << 16
                            with zf.open(zi, "w") as fdst:
                                copy_stream(fsrc, fdst)
                    self.progress.emit(int(idx * 100 / total))

# ─────────────────────────── main window ───────────────────────────────
class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.worker: Optional[ConvertWorker] = None
        self._build_ui()

    def _build_ui(self):
        self.setWindowTitle("TarGz → Zip Converter · Thexhosting.com")
        # Use PNG as icon (works fine on Windows, macOS, Linux). PyInstaller bundles it via --add-data.
        self.setWindowIcon(QIcon(resource_path("x.png")))
        self.resize(1100, 640)
        self.setFont(QFont("Segoe UI", 11))

        central = QWidget(objectName="background"); self.setCentralWidget(central)
        outer = QVBoxLayout(central); outer.setContentsMargins(0, 0, 0, 0)

        header = QLabel("TarGz → Zip Converter", objectName="header", alignment=Qt.AlignCenter)
        header.setFont(QFont("Segoe UI Semibold", 32)); header.setMinimumHeight(120)
        outer.addWidget(header)

        card = QFrame(objectName="card")
        card.setGraphicsEffect(QGraphicsDropShadowEffect(blurRadius=28, xOffset=0, yOffset=10, color=QColor(0, 0, 0, 120)))
        outer.addWidget(card, alignment=Qt.AlignCenter, stretch=1)

        grid = QGridLayout(card)
        grid.setContentsMargins(40, 40, 40, 40)
        grid.setHorizontalSpacing(24); grid.setVerticalSpacing(32)

        lbl_in  = QLabel("Input (.tar.gz / .tgz):")
        self.txt_in  = QLineEdit(readOnly=True)
        btn_in  = QPushButton("Browse…", clicked=self._choose_in)

        lbl_out = QLabel("Output .zip:")
        self.txt_out = QLineEdit(readOnly=True)
        btn_out = QPushButton("Save as…", clicked=self._choose_out)

        self.progress = QProgressBar(); self.progress.setRange(0, 100)
        self.btn_convert = QPushButton("Convert →", enabled=False, clicked=self._start)

        grid.addWidget(lbl_in,  0, 0); grid.addWidget(self.txt_in,  0, 1); grid.addWidget(btn_in,  0, 2)
        grid.addWidget(lbl_out, 1, 0); grid.addWidget(self.txt_out, 1, 1); grid.addWidget(btn_out, 1, 2)
        grid.addWidget(self.progress, 2, 0, 1, 3)
        grid.addWidget(self.btn_convert, 3, 0, 1, 3)
        grid.setColumnStretch(1, 1)

        self.setStyleSheet(
            """
            #background {
                background: qradialgradient(cx:0.5, cy:0.4, radius:1.2,
                                            fx:0.45, fy:0.35,
                                            stop:0 #161E2F,
                                            stop:1 #0B101E);
            }
            #header { color:#F5F5F5; letter-spacing:1px; }
            #card { background: rgba(30,34,45,0.92); border-radius:24px; }
            QLabel { color:#E0E4EB; font-weight:600; }
            QLineEdit { padding:12px 18px; border:none; border-radius:10px; background:rgba(255,255,255,0.08); color:#FAFAFA; }
            QLineEdit:focus { background:rgba(255,255,255,0.14); }
            QPushButton { background:qlineargradient(x1:0,y1:0,x2:1,y2:1, stop:0 #AA8C3D, stop:1 #DEC674); color:#141414; padding:14px 42px; border:none; border-radius:16px; font-weight:700; }
            QPushButton:hover { background:qlineargradient(x1:0,y1:0,x2:1,y2:1, stop:0 #DEC674, stop:1 #AA8C3D); }
            QPushButton:disabled { background:#44474F; color:#888A91; }
            QProgressBar { background:rgba(255,255,255,0.05); border:none; border-radius:16px; height:32px; color:#E0E4EB; font-weight:600; }
            QProgressBar::chunk { border-radius:16px; background:qlineargradient(x1:0,y1:0,x2:1,y2:1, stop:0 #C19A6B, stop:1 #F1C27D); }
            """
        )

    # ─────────── file selection & conversion control ────────────
    def _choose_in(self):
        path, _ = QFileDialog.getOpenFileName(self, "Select compressed tar archive", filter="*.tar.gz *.tgz")
        if path:
            self.txt_in.setText(path)
            if not self.txt_out.text():
                self.txt_out.setText(str(dest_zip_name(Path(path))))
            self.btn_convert.setEnabled(True)

    def _choose_out(self):
        path, _ = QFileDialog.getSaveFileName(self, "Save ZIP as…", self.txt_out.text() or "", filter="*.zip")
        if path:
            self.txt_out.setText(path)

    def _start(self):
        src, dst = Path(self.txt_in.text()), Path(self.txt_out.text())
        if not src.is_file():
            QMessageBox.warning(self, "File not found", "Please select a valid input archive.")
            return
        self.btn_convert.setEnabled(False); self.progress.setValue(0)
        self.worker = ConvertWorker(src, dst)
        self.worker.progress.connect(self.progress.setValue)
        self.worker.finished.connect(self._done)
        self.worker.failed.connect(self._fail)
        self.worker.start()

    def _done(self, dst: str):
        QMessageBox.information(self, "Done", f"ZIP created:\n{dst}")
        self._reset(); self.progress.setValue(100)

    def _fail(self, err: str):
        QMessageBox.critical(self, "Error", err)
        self._reset(); self.progress.setValue(0)

    def _reset(self):
        self.btn_convert.setEnabled(True); self.worker = None

# ─────────────────────────── main entry ───────────────────────────────

def main():
    app = QApplication(sys.argv)
    app.setAttribute(Qt.AA_EnableHighDpiScaling)

    # ── Splash screen (x.png) ────────────────────────────────
    splash_pix = QPixmap(resource_path("x.png"))
    splash = QSplashScreen(splash_pix, Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint)
    splash.show()

    # Give the splash a subtle fade‑in/out delay
    app.processEvents()  # ensure it appears immediately

    window = MainWindow(); window.show()

    QTimer.singleShot(1500, splash.close)  # hide splash after 1.5 s

    sys.exit(app.exec_())


if __name__ == "__main__":
    main()

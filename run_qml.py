import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

import os
os.environ["QT_QPA_PLATFORM"] = "xcb"
import os
os.environ["QT_QUICK_BACKEND"] = "software"


if __name__ == "__main__":
    app = QApplication(sys.argv)

    engine = QQmlApplicationEngine()
    engine.load("window.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

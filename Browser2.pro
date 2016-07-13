requires(contains(QT_CONFIG, accessibility))

TEMPLATE = app
TARGET = Browser2

QT += qml quick webengine
CONFIG += c++11

HEADERS = context.h
SOURCES += main.cpp

RESOURCES += qml.qrc

OTHER_FILES += BrowserWindow.qml \
               root.qml
               main.qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

qtHaveModule(widgets) {
    QT += widgets # QApplication is required to get native styling with QtQuickControls
}

# Default rules for deployment.
include(deployment.pri)

TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp

#RESOURCES += qml.qrc

DESTDIR = $$PWD

OTHER_FILES += main.qml MinigamesButton.qml \
                Snake.qml \
                Numbers.qml \
                Tetris.qml TetrisBlock.qml

INCLUDEPATH += tmp/moc/release_shared

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)


TEMPLATE = app

QT += qml quick
CONFIG += c++14

SOURCES += main.cpp

RESOURCES += qml.qrc

DESTDIR = $$PWD/../bin

#OTHER_FILES += main.qml MinigamesButton.qml MinigamesTouchArea.qml \
#                Snake.qml \
#                Numbers.qml \
#                Tetris.qml TetrisBlock.qml \
#                Arkanoid.qml Obstacle.qml \
#                ColorLines.qml LinesQuad.qml LinesCircle.qml \
#                Flappy.qml \
#                Labirinth.qml \
#                Defence.qml

INCLUDEPATH += tmp/moc/release_shared

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

# Adctl
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/mobile/android
include(thirdparty/adctl/AdCtl.pri)
android {
    OTHER_FILES += \
        $$PWD/mobile/android/AndroidManifest.xml
    DISTFILES += \
        mobile/android/gradle/wrapper/gradle-wrapper.jar \
        mobile/android/gradlew \
        mobile/android/res/values/libs.xml \
        mobile/android/build.gradle \
        mobile/android/gradle/wrapper/gradle-wrapper.properties \
        mobile/android/gradlew.bat \
}
ios{
    #ICON =
    QMAKE_INFO_PLIST = mobile/ios/Info.plist
}

include(../ImagesetManager/ImagesetTool.pri)


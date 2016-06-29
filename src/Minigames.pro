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

VERSION = 1.0.0
ICON = $$PWD/../icons/icon.ico
RC_ICONS = $$PWD/../icons/icon.ico
QMAKE_TARGET_PRODUCT = Colors
QMAKE_TARGET_COMPANY = 'Fajra Katviro'
LICENSE = $$PWD/../LICENSE
DEPLOY_BUILD_FOLDER = $$PWD/../packageBuild
UPGRADE_CODE = "b539003b-ccca-4096-8cc8-b031846e4f59"

include(../ImagesetManager/ImagesetTool.pri)
include(../FKDeploy/FKDeploy.pri)


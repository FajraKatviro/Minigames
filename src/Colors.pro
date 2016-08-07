TEMPLATE = app
TARGET = Colors

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

INCLUDEPATH += $$PWD/../FKUtils/sharedHeaders

#make imageset
ART_FOLDER = $$PWD/../art
ART_BUILD_FOLDER = $$PWD/../resourceBuild
include(../FKUtils/fktools/fkimageset.pri)

#make deploy
VERSION = 1.0.1
mac{
    ICON = $$PWD/../icons/icon.icns
}else{
    ICON = $$PWD/../icons/icon_128x128.png
}
RC_ICONS = $$PWD/../icons/icon.ico
QMAKE_TARGET_PRODUCT = Colors
QMAKE_TARGET_COMPANY = 'Fajra Katviro'
LICENSE = $$PWD/../LICENSE
DEPLOY_BUILD_FOLDER = $$PWD/../packageBuild
UPGRADE_CODE = "b539003b-ccca-4096-8cc8-b031846e4f59"
SHORT_DESCRIPTION="Set of minigames"
LONG_DESCRIPTION=$$PWD/../description.txt
include(../FKUtils/deployTool/fkdeploy.pri)

#iOS/android icon & splash screen
FK_IOS_PLIST = mobile/ios/Info.plist
ios:FK_MOBILE_ICONS = $$PWD/../icons/iOS
android:FK_MOBILE_ICONS = $$PWD/../icons/android
include(../FKUtils/mobileHelpers/fkdeploy_mobile.pri)




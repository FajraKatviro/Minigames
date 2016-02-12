#include <QGuiApplication>
#include <QQmlApplicationEngine>
//#include <QQmlContext>

#include <QScreen>
#include "FKUtility/loadImageset.h"

#include "thirdparty/adctl/adctl.h"

//class AE:public QQmlApplicationEngine{
//    Q_OBJECT
//public slots:
//    void resetContext(){
//        clearComponentCache();
//    }
//};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Fajra Katviro");
    app.setApplicationName("Colors");
    app.setApplicationVersion("1.0");

    if(!FKUtility::loadImageset("images",app.primaryScreen()->size())){
        qDebug("unable load imageset");
    }

    REGISTER_ADCTL;
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //engine.load(QStringLiteral("main.qml"));
    //engine.rootContext()->setContextProperty("engine",&engine);
    return app.exec();
}

//#include "main.moc"

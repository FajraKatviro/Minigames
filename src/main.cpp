#include <QGuiApplication>
#include <QQmlApplicationEngine>
//#include <QQmlContext>

#include <QScreen>
#include "FKUtility/loadImageset.h"
#include <QQmlContext>

#include "../FKDeploy/FKProjectHelper.h"

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
    QGuiApplication::setAttribute(Qt::AA_UseOpenGLES);
    QGuiApplication app(argc, argv);
    QDir::setCurrent(QCoreApplication::applicationDirPath());

    FKProjectHelper::ReplicateApplicationInfoFromProject();

    REGISTER_ADCTL;

    QSize baseSize(600,400);
    QSize screenSize(app.primaryScreen()->size());

    if(!FKUtility::loadImageset("images",screenSize)){
        qDebug("unable load imageset");
    }

    qreal sizeSet=std::max(((qreal)screenSize.height())/((qreal)baseSize.height()),
                           ((qreal)screenSize.width ())/((qreal)baseSize.width ()));

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("sizeSet",sizeSet);
    engine.rootContext()->setContextProperty("baseHeight",baseSize.height());
    engine.rootContext()->setContextProperty("baseWidth",baseSize.width());
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QMetaObject::invokeMethod(engine.rootObjects().first(), "showFullScreen");
    //engine.load(QStringLiteral("main.qml"));
    //engine.rootContext()->setContextProperty("engine",&engine);
    return app.exec();
}

//#include "main.moc"

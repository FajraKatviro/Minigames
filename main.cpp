#include <QGuiApplication>
#include <QQmlApplicationEngine>
//#include <QQmlContext>

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

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //engine.load(QStringLiteral("main.qml"));
    //engine.rootContext()->setContextProperty("engine",&engine);
    return app.exec();
}

//#include "main.moc"

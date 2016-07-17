#include <QGuiApplication>

#include <QScreen>
#include "loadImageset.h"
#include <QQmlContext>
#include <QQuickView>

#include "projectHelper.h"

#include "thirdparty/adctl/adctl.h"

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

    QQuickView window;
    window.rootContext()->setContextProperty("sizeSet",sizeSet);
    window.rootContext()->setContextProperty("baseHeight",baseSize.height());
    window.rootContext()->setContextProperty("baseWidth",baseSize.width());
    window.setResizeMode(QQuickView::SizeRootObjectToView);
    window.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    window.show();
    window.setVisibility(QWindow::FullScreen);
    return app.exec();
}

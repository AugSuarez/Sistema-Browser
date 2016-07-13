#include "context.h"

#ifndef QT_NO_WIDGETS
#include <QtWidgets/QApplication>
typedef QApplication Application;
#endif
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtWebEngine/qtwebengineglobal.h>

int main(int argc, char *argv[])
{
    Application app(argc, argv);
    QtWebEngine::initialize();

    QQmlApplicationEngine engine;
    Context context;
    engine.rootContext()->setContextProperty("Context", &context);
    engine.load(QUrl("qrc:/root.qml"));

QMetaObject::invokeMethod(engine.rootObjects().first(), "load", Q_ARG(QVariant, QUrl("http://localhost/sgac/vistas/login.php")));
//QMetaObject::invokeMethod(engine.rootObjects().first(), "load", Q_ARG(QVariant, QUrl("C:/xampp/htdocs/sgac/vistas/login.php")));
    return app.exec();
}

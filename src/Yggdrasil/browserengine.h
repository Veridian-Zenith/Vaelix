#ifndef BROWSERENGINE_H
#define BROWSERENGINE_H

#include <QObject>
#include <QString>

class BrowserEngine : public QObject
{
    Q_OBJECT

public:
    explicit BrowserEngine(QObject *parent = nullptr);

signals:
    void titleChanged(const QString &title);
    void urlChanged(const QString &url);
    void loadStarted();
    void loadFinished(bool success);
};

#endif // BROWSERENGINE_H

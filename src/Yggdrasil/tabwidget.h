#ifndef TABWIDGET_H
#define TABWIDGET_H

#include <QTabWidget>
#include <QWebEngineView>
#include <QWebEnginePage>
#include <QVBoxLayout>
#include <QWidget>
#include <QProgressBar>
#include <QLabel>
#include <QPushButton>

class TabWidget : public QTabWidget
{
    Q_OBJECT

public:
    explicit TabWidget(QWidget *parent = nullptr);
    void addNewTab(const QUrl &url = QUrl("https://www.google.com"));
    void navigateInCurrentTab(const QUrl &url);

private slots:
    void tabCloseRequested(int index);
    void tabTitleChanged(const QString &title);
    void loadProgress(int progress);
    void onUrlChanged(const QUrl &url);
    void createNewTab();

private:
    QWidget* createTabContent(const QUrl &url);
    QWidget* createNordicTab(QWebEngineView *webView);
};

#endif // TABWIDGET_H

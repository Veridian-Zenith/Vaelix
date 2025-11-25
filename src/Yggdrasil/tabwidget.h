#ifndef TABWIDGET_H
#define TABWIDGET_H

#include <QTabWidget>
#include <QWebEngineView>
#include <QWebEnginePage>
#include <QWebEngineHistory>
#include <QVBoxLayout>
#include <QWidget>
#include <QProgressBar>
#include <QLabel>
#include <QPushButton>
#include <QUrl>
#include <QString>
#include <QTimer>

class TabWidget : public QTabWidget
{
    Q_OBJECT

public:
    explicit TabWidget(QWidget *parent = nullptr);
    void addNewTab(const QUrl &url = QUrl("https://www.startpage.com"));
    void navigateInCurrentTab(const QUrl &url);
    void navigateToUrl(const QUrl &url);

    // Navigation methods
    void goBack();
    void goForward();
    void reload();
    void stopLoading();

    // Zoom methods
    void zoomIn();
    void zoomOut();
    void zoomReset();
    int getZoomLevel() const;

    // Developer tools
    void showDeveloperTools();

    // Current web view access
    QWebEngineView* currentWebView() const;

    // Signals
signals:
    void titleChanged(const QString &title);
    void urlChanged(const QUrl &url);
    void loadProgressChanged(int progress);
    void loadStarted();
    void loadFinished(bool success);

private slots:
    void tabCloseRequested(int index);
    void tabTitleChanged(const QString &title);
    void loadProgress(int progress);
    void onUrlChanged(const QUrl &url);
    void createNewTab();

private:
    QWidget* createTabContent(const QUrl &url);
    QWidget* createNordicTab(QWebEngineView *webView);
    QWebEngineView* getCurrentWebView() const;

    // Zoom state
    int currentZoomLevel;
};

#endif // TABWIDGET_H

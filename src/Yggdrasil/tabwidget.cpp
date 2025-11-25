#include "tabwidget.h"
#include <QWebEngineSettings>
#include <QWebEngineHistory>

TabWidget::TabWidget(QWidget *parent) : QTabWidget(parent)
{
    setTabsClosable(true);
    setMovable(true);
    currentZoomLevel = 100;

    // Nordic floating tab style
    setStyleSheet(R"(
        QTabWidget::pane {
            border: 1px solid rgba(255, 140, 0, 0.3);
            background: rgba(45, 24, 16, 0.8);
            border-radius: 0px 0px 8px 8px;
        }
        QTabBar::tab {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                        stop:0 rgba(61, 36, 21, 0.9),
                        stop:1 rgba(45, 24, 16, 0.8));
            border: 1px solid rgba(255, 140, 0, 0.2);
            border-bottom: none;
            padding: 12px 20px;
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
            margin-right: 2px;
            color: #d4b896;
            font-weight: 500;
            min-width: 120px;
        }
        QTabBar::tab:selected {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                        stop:0 rgba(255, 140, 0, 0.3),
                        stop:1 rgba(255, 179, 71, 0.2));
            color: #ff8c00;
            border-color: rgba(255, 140, 0, 0.5);
        }
        QTabBar::tab:hover {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                        stop:0 rgba(255, 179, 71, 0.2),
                        stop:1 rgba(255, 140, 0, 0.1));
        }
        QTabBar::close-button {
            image: none;
            background: rgba(255, 107, 107, 0.8);
            border-radius: 8px;
            width: 16px;
            height: 16px;
        }
        QTabBar::close-button:hover {
            background: rgba(255, 107, 107, 1.0);
        }
    )");

    // Double-click to create new tab
    connect(this, &QTabWidget::tabBarDoubleClicked, this, &TabWidget::createNewTab);
}

void TabWidget::addNewTab(const QUrl &url)
{
    QWidget *tabContent = createTabContent(url);
    int index = addTab(tabContent, "New Tab");
    setCurrentIndex(index);
}

void TabWidget::navigateInCurrentTab(const QUrl &url)
{
    QWidget *currentTab = widget(currentIndex());
    if (currentTab) {
        QWebEngineView *webView = currentTab->findChild<QWebEngineView*>();
        if (webView) {
            webView->setUrl(url);
        }
    }
}

void TabWidget::navigateToUrl(const QUrl &url)
{
    navigateInCurrentTab(url);
}

QWidget* TabWidget::createTabContent(const QUrl &url)
{
    QWidget *container = new QWidget;
    QVBoxLayout *layout = new QVBoxLayout(container);
    layout->setContentsMargins(0, 0, 0, 0);

    // Create web view
    QWebEngineView *webView = new QWebEngineView(container);
    webView->setUrl(url);

    // Configure web settings
    QWebEngineSettings *settings = webView->settings();
    settings->setAttribute(QWebEngineSettings::WebGLEnabled, true);
    settings->setAttribute(QWebEngineSettings::Accelerated2dCanvasEnabled, true);
    settings->setAttribute(QWebEngineSettings::JavascriptEnabled, true);
    settings->setAttribute(QWebEngineSettings::PluginsEnabled, true);

    // Connect signals
    connect(webView, &QWebEngineView::titleChanged, [this, webView](const QString &title) {
        int index = indexOf(webView->parentWidget());
        if (index >= 0) {
            setTabText(index, title.left(20) + (title.length() > 20 ? "..." : ""));
        }
    });

    connect(webView, &QWebEngineView::urlChanged, [this, webView](const QUrl &url) {
        if (url.scheme() == "file" || url.host() == "www.startpage.com") {
            return; // Don't track certain URLs
        }
        qDebug() << "Navigation to:" << url.toString();
    });

    layout->addWidget(webView);

    return container;
}

void TabWidget::tabCloseRequested(int index)
{
    removeTab(index);

    // If no tabs left, create a new one
    if (count() == 0) {
        addNewTab();
    }
}

void TabWidget::createNewTab()
{
    addNewTab();
}

void TabWidget::goBack()
{
    QWebEngineView *webView = getCurrentWebView();
    if (webView && webView->history()->canGoBack()) {
        webView->history()->back();
    }
}

void TabWidget::goForward()
{
    QWebEngineView *webView = getCurrentWebView();
    if (webView && webView->history()->canGoForward()) {
        webView->history()->forward();
    }
}

void TabWidget::reload()
{
    QWebEngineView *webView = getCurrentWebView();
    if (webView) {
        webView->reload();
    }
}

void TabWidget::stopLoading()
{
    QWebEngineView *webView = getCurrentWebView();
    if (webView) {
        webView->stop();
    }
}

void TabWidget::zoomIn()
{
    currentZoomLevel = qMin(currentZoomLevel + 10, 500);
    QWebEngineView *webView = getCurrentWebView();
    if (webView) {
        webView->setZoomFactor(currentZoomLevel / 100.0);
    }
}

void TabWidget::zoomOut()
{
    currentZoomLevel = qMax(currentZoomLevel - 10, 50);
    QWebEngineView *webView = getCurrentWebView();
    if (webView) {
        webView->setZoomFactor(currentZoomLevel / 100.0);
    }
}

void TabWidget::zoomReset()
{
    currentZoomLevel = 100;
    QWebEngineView *webView = getCurrentWebView();
    if (webView) {
        webView->setZoomFactor(1.0);
    }
}

int TabWidget::getZoomLevel() const
{
    return currentZoomLevel;
}

void TabWidget::showDeveloperTools()
{
    QWebEngineView *webView = getCurrentWebView();
    if (webView) {
        // Use Qt6 compatible dev tools approach
        webView->page()->triggerAction(QWebEnginePage::InspectElement);
    }
}

QWebEngineView* TabWidget::currentWebView() const
{
    return getCurrentWebView();
}

QWebEngineView* TabWidget::getCurrentWebView() const
{
    QWidget *currentTab = widget(currentIndex());
    if (currentTab) {
        return currentTab->findChild<QWebEngineView*>();
    }
    return nullptr;
}

void TabWidget::tabTitleChanged(const QString &title)
{
    emit titleChanged(title);
}

void TabWidget::loadProgress(int progress)
{
    emit loadProgressChanged(progress);
}

void TabWidget::onUrlChanged(const QUrl &url)
{
    emit urlChanged(url);
}

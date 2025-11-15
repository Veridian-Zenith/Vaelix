#include "mainwindow.h"
#include <QWebEngineView>
#include <QWebEngineSettings>
#include <QMenuBar>
#include <QAction>
#include <QKeySequence>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , bookmarksVisible(false)
{
    setWindowTitle("Vaelix - Nordic Browser");
    resize(1200, 800);

    setupUI();
    setupToolbars();
    setupStatusBar();

    // Create first tab
    newTab();
}

MainWindow::~MainWindow()
{
}

void MainWindow::setupUI()
{
    // Create central widget with Nordic styling
    QWidget *centralWidget = new QWidget;
    centralWidget->setStyleSheet(R"(
        QWidget {
            background-color: #1a0f0a;
            color: #fff8f0;
        }
    )");
    setCentralWidget(centralWidget);

    QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);
    mainLayout->setContentsMargins(0, 0, 0, 0);
    mainLayout->setSpacing(0);

    // Address bar and navigation
    mainLayout->addWidget(createNordicChrome());

    // Main content area
    mainLayout->addWidget(createMainSplitter(), 1);
}

QWidget* MainWindow::createNordicChrome()
{
    QWidget *chrome = new QWidget;
    chrome->setFixedHeight(60);
    chrome->setStyleSheet(R"(
        QWidget {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                        stop:0 rgba(45, 24, 16, 0.9),
                        stop:1 rgba(61, 36, 21, 0.8));
            border-bottom: 1px solid rgba(255, 140, 0, 0.3);
        }
        QPushButton {
            background: rgba(61, 36, 21, 0.8);
            border: 1px solid rgba(255, 140, 0, 0.2);
            border-radius: 8px;
            color: #d4b896;
            padding: 8px 12px;
            font-weight: 500;
        }
        QPushButton:hover {
            background: rgba(255, 179, 71, 0.2);
            border-color: #ff8c00;
        }
        QLineEdit {
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 140, 0, 0.3);
            border-radius: 8px;
            padding: 10px 12px;
            color: #fff8f0;
            font-size: 14px;
        }
        QLineEdit:focus {
            border-color: #ff8c00;
            box-shadow: 0 0 10px rgba(255, 140, 0, 0.3);
        }
    )");

    QHBoxLayout *layout = new QHBoxLayout(chrome);
    layout->setContentsMargins(15, 10, 15, 10);
    layout->setSpacing(10);

    // Navigation buttons
    backButton = new QPushButton("←");
    backButton->setFixedSize(40, 30);

    forwardButton = new QPushButton("→");
    forwardButton->setFixedSize(40, 30);

    refreshButton = new QPushButton("⟲");
    refreshButton->setFixedSize(40, 30);

    homeButton = new QPushButton("🏠");
    homeButton->setFixedSize(40, 30);

    // Address bar
    addressBar = new QLineEdit;
    addressBar->setPlaceholderText("Search or enter web address...");
    addressBar->setMinimumWidth(400);
    connect(addressBar, &QLineEdit::returnPressed, this, &MainWindow::navigateToUrl);

    // Control buttons
    bookmarksButton = new QPushButton("📚");
    bookmarksButton->setFixedSize(40, 30);
    connect(bookmarksButton, &QPushButton::clicked, this, &MainWindow::showBookmarks);

    historyButton = new QPushButton("📖");
    historyButton->setFixedSize(40, 30);
    connect(historyButton, &QPushButton::clicked, this, &MainWindow::showHistory);

    newTabButton = new QPushButton("+");
    newTabButton->setFixedSize(40, 30);
    connect(newTabButton, &QPushButton::clicked, this, &MainWindow::newTab);

    // Add to layout
    layout->addWidget(backButton);
    layout->addWidget(forwardButton);
    layout->addWidget(refreshButton);
    layout->addWidget(homeButton);
    layout->addWidget(addressBar, 1);
    layout->addWidget(bookmarksButton);
    layout->addWidget(historyButton);
    layout->addWidget(newTabButton);

    return chrome;
}

QSplitter* MainWindow::createMainSplitter()
{
    QSplitter *splitter = new QSplitter(Qt::Horizontal);
    splitter->setStyleSheet(R"(
        QSplitter::handle {
            background: rgba(255, 140, 0, 0.3);
            width: 2px;
        }
        QSplitter::handle:hover {
            background: rgba(255, 140, 0, 0.6);
        }
    )");

    // Bookmarks panel (can be hidden/shown)
    bookmarksPanel = new NordicBookmarks;
    bookmarksPanel->setMaximumWidth(300);
    splitter->addWidget(bookmarksPanel);

    // Main tab widget
    tabWidget = new TabWidget(this);
    splitter->addWidget(tabWidget);

    // Set initial sizes
    splitter->setSizes(QList<int>() << 0 << 1200);

    return splitter;
}

void MainWindow::setupToolbars()
{
    // Menu bar
    QMenuBar *menuBar = this->menuBar();

    QMenu *fileMenu = menuBar->addMenu("File");
    QAction *newTabAction = fileMenu->addAction("New Tab");
    newTabAction->setShortcut(QKeySequence::AddTab);
    connect(newTabAction, &QAction::triggered, this, &MainWindow::newTab);

    QAction *closeTabAction = fileMenu->addAction("Close Tab");
    closeTabAction->setShortcut(QKeySequence::Close);
    connect(closeTabAction, &QAction::triggered, this, &MainWindow::closeCurrentTab);

    QMenu *viewMenu = menuBar->addMenu("View");
    QAction *showBookmarksAction = viewMenu->addAction("Show Bookmarks");
    showBookmarksAction->setShortcut(QKeySequence("Ctrl+B"));
    connect(showBookmarksAction, &QAction::triggered, this, &MainWindow::showBookmarks);
}

void MainWindow::setupStatusBar()
{
    statusBar = this->statusBar();
    statusBar->showMessage("Welcome to Vaelix - Nordic Browser");
    statusBar->setStyleSheet(R"(
        QStatusBar {
            background: rgba(45, 24, 16, 0.9);
            border-top: 1px solid rgba(255, 140, 0, 0.3);
            color: #d4b896;
        }
        QStatusBar::item {
            border: none;
        }
    )");
}

void MainWindow::newTab()
{
    tabWidget->addNewTab();
    addressBar->setFocus();
}

void MainWindow::closeCurrentTab()
{
    int index = tabWidget->currentIndex();
    if (index >= 0) {
        tabWidget->removeTab(index);
    }
}

void MainWindow::navigateToUrl()
{
    QString urlText = addressBar->text();
    if (!urlText.startsWith("http://") && !urlText.startsWith("https://")) {
        // Treat as search query
        urlText = "https://www.google.com/search?q=" + urlText.replace(" ", "+");
    }

    tabWidget->navigateInCurrentTab(urlText);
}

void MainWindow::updateTabTitle(const QString &title)
{
    statusBar->showMessage("Loading: " + title);
}

void MainWindow::showBookmarks()
{
    bookmarksVisible = !bookmarksVisible;
    bookmarksButton->setText(bookmarksVisible ? "❌" : "📚");

    // Animate bookmarks panel
    if (bookmarksVisible) {
        bookmarksPanel->show();
    } else {
        bookmarksPanel->hide();
    }
}

void MainWindow::showHistory()
{
    // TODO: Implement history panel
    statusBar->showMessage("History panel coming soon...");
}

#include "mainwindow.h"
#include <QWebEngineView>
#include <QWebEngineSettings>
#include <QWebEngineProfile>
#include <QWebEnginePage>
#include <QApplication>
#include <QMainWindow>
#include <QWidget>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QKeySequence>
#include <QTimer>
#include <QProgressBar>
#include <QLabel>
#include <QComboBox>
#include <QShortcut>
#include <QCloseEvent>
#include <QKeyEvent>
#include <QContextMenuEvent>
#include <QFileDialog>
#include <QMessageBox>
#include <QInputDialog>
#include <QScreen>
#include <QStandardPaths>
#include <QDir>
#include <QSettings>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QStandardItemModel>
#include <QToolButton>
#include <QSpacerItem>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLayout>
#include <QBoxLayout>
#include <QString>
#include <QUrl>
#include <QList>
#include <QObject>
#include <QDebug>
#include <QPushButton>
#include <QStatusBar>
#include <QSplitter>
#include <QLineEdit>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , navBar(nullptr)
    , addressBar(nullptr)
    , searchEngineCombo(nullptr)
    , backButton(nullptr)
    , forwardButton(nullptr)
    , refreshButton(nullptr)
    , stopButton(nullptr)
    , homeButton(nullptr)
    , bookmarksButton(nullptr)
    , historyButton(nullptr)
    , downloadsButton(nullptr)
    , extensionsButton(nullptr)
    , settingsButton(nullptr)
    , newTabButton(nullptr)
    , tabWidget(nullptr)
    , bookmarksPanel(nullptr)
    , bookmarksBar(nullptr)
    , statusBar(nullptr)
    , loadProgress(nullptr)
    , statusLabel(nullptr)
    , connectionLabel(nullptr)
    , zoomLabel(nullptr)
    , browserEngine(nullptr)
    , defaultProfile(nullptr)
    , privateProfile(nullptr)
    , isPrivateMode(false)
    , bookmarksVisible(false)
    , bookmarksBarVisible(false)
    , isFullscreen(false)
    , sessionTimer(nullptr)
    , sessionFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/vaelix_session.json")
{
    setWindowTitle("Vaelix - Nordic Browser");
    setMinimumSize(1200, 800);
    resize(1400, 900);

    // Initialize profiles and settings
    initializeProfiles();
    setupProfileSettings();
    loadSettings();

    setupUI();
    setupToolbars();
    setupStatusBar();
    setupShortcuts();
    setupConnections();
    createMenuBar();

    // Create initial tab
    newTab();

    // Setup session management
    sessionTimer = new QTimer(this);
    connect(sessionTimer, &QTimer::timeout, this, &MainWindow::saveSession);
    sessionTimer->start(30000); // Save every 30 seconds

    // Apply Nordic theme
    applyTheme();
}

MainWindow::~MainWindow()
{
    saveSession();
    saveSettings();
}

void MainWindow::setupUI()
{
    // Create central widget with Nordic styling
    QWidget *centralWidget = new QWidget;
    centralWidget->setObjectName("centralWidget");
    centralWidget->setStyleSheet(R"(
        QWidget#centralWidget {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #0d1a0d,
                        stop:0.5 #1a2e1a,
                        stop:1 #0f1f0f);
        }
    )");
    setCentralWidget(centralWidget);

    QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);
    mainLayout->setContentsMargins(0, 0, 0, 0);
    mainLayout->setSpacing(0);

    // Navigation bar
    navBar = createNavigationBar();
    mainLayout->addWidget(navBar);

    // Bookmarks bar (hidden by default)
    bookmarksBar = createBookmarksBar();
    bookmarksBar->setVisible(bookmarksBarVisible);
    mainLayout->addWidget(bookmarksBar);

    // Main content area
    mainLayout->addWidget(createMainSplitter(), 1);
}

QWidget* MainWindow::createNavigationBar()
{
    QWidget *navBarWidget = new QWidget;
    navBarWidget->setObjectName("navBar");
    navBarWidget->setFixedHeight(60);

    QHBoxLayout *layout = new QHBoxLayout(navBarWidget);
    layout->setContentsMargins(12, 8, 12, 8);
    layout->setSpacing(8);

    // Navigation buttons group
    QWidget *navGroup = new QWidget;
    QHBoxLayout *navLayout = new QHBoxLayout(navGroup);
    navLayout->setContentsMargins(0, 0, 0, 0);
    navLayout->setSpacing(4);

    backButton = new QPushButton("⟵");
    backButton->setFixedSize(36, 32);
    backButton->setToolTip("Back (Alt+Left)");
    navLayout->addWidget(backButton);

    forwardButton = new QPushButton("⟶");
    forwardButton->setFixedSize(36, 32);
    forwardButton->setToolTip("Forward (Alt+Right)");
    navLayout->addWidget(forwardButton);

    refreshButton = new QPushButton("⟲");
    refreshButton->setFixedSize(36, 32);
    refreshButton->setToolTip("Refresh (F5)");
    navLayout->addWidget(refreshButton);

    stopButton = new QPushButton("⏹");
    stopButton->setFixedSize(36, 32);
    stopButton->setToolTip("Stop (Esc)");
    stopButton->setVisible(false);
    navLayout->addWidget(stopButton);

    homeButton = new QPushButton("🏠");
    homeButton->setFixedSize(36, 32);
    homeButton->setToolTip("Home (Alt+Home)");
    navLayout->addWidget(homeButton);

    layout->addWidget(navGroup);

    // Address bar with search
    QWidget *addressGroup = new QWidget;
    QHBoxLayout *addressLayout = new QHBoxLayout(addressGroup);
    addressLayout->setContentsMargins(8, 0, 8, 0);
    addressLayout->setSpacing(4);

    searchEngineCombo = new QComboBox;
    searchEngineCombo->addItem("🔍 Startpage");
    searchEngineCombo->addItem("🌊 DuckDuckGo");
    searchEngineCombo->addItem("🕷️ Searx");
    searchEngineCombo->setFixedWidth(120);
    addressLayout->addWidget(searchEngineCombo);

    addressBar = new QLineEdit;
    addressBar->setObjectName("addressBar");
    addressBar->setPlaceholderText("Search or enter web address...");
    addressBar->setMinimumWidth(500);
    addressBar->setMaximumWidth(700);
    connect(addressBar, &QLineEdit::returnPressed, this, [this]() {
        navigateToUrl();
    });
    connect(addressBar, &QLineEdit::textChanged, [this](const QString& text) {
        // Update URL display
        Q_UNUSED(text)
    });
    addressLayout->addWidget(addressBar, 1);

    layout->addWidget(addressGroup, 1);

    // Control buttons group
    QWidget *controlGroup = new QWidget;
    QHBoxLayout *controlLayout = new QHBoxLayout(controlGroup);
    controlLayout->setContentsMargins(0, 0, 0, 0);
    controlLayout->setSpacing(4);

    bookmarksButton = new QPushButton("📚");
    bookmarksButton->setFixedSize(36, 32);
    bookmarksButton->setToolTip("Bookmarks (Ctrl+Shift+O)");
    controlLayout->addWidget(bookmarksButton);

    historyButton = new QPushButton("📖");
    historyButton->setFixedSize(36, 32);
    historyButton->setToolTip("History (Ctrl+H)");
    controlLayout->addWidget(historyButton);

    downloadsButton = new QPushButton("⬇");
    downloadsButton->setFixedSize(36, 32);
    downloadsButton->setToolTip("Downloads (Ctrl+J)");
    controlLayout->addWidget(downloadsButton);

    extensionsButton = new QPushButton("🔌");
    extensionsButton->setFixedSize(36, 32);
    extensionsButton->setToolTip("Extensions (Ctrl+Shift+E)");
    controlLayout->addWidget(extensionsButton);

    settingsButton = new QPushButton("⚙");
    settingsButton->setFixedSize(36, 32);
    settingsButton->setToolTip("Settings (Ctrl+,)");
    controlLayout->addWidget(settingsButton);

    newTabButton = new QPushButton("+");
    newTabButton->setFixedSize(36, 32);
    newTabButton->setToolTip("New Tab (Ctrl+T)");
    controlLayout->addWidget(newTabButton);

    layout->addWidget(controlGroup);

    return navBarWidget;
}

QWidget* MainWindow::createBookmarksBar()
{
    QWidget *bookmarksBarWidget = new QWidget;
    bookmarksBarWidget->setFixedHeight(35);
    bookmarksBarWidget->setStyleSheet(R"(
        QWidget {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                        stop:0 #2d4a2d,
                        stop:1 #3a573a);
            border-bottom: 1px solid #4a6741;
        }
    )");

    QHBoxLayout *layout = new QHBoxLayout(bookmarksBarWidget);
    layout->setContentsMargins(12, 4, 12, 4);
    layout->setSpacing(8);

    QLabel *bookmarksLabel = new QLabel("⭐ Bookmarks:");
    bookmarksLabel->setStyleSheet("color: #b8d4b8; font-weight: bold;");
    layout->addWidget(bookmarksLabel);

    layout->addStretch();

    QPushButton *addBookmarkBtn = new QPushButton("+");
    addBookmarkBtn->setFixedSize(24, 24);
    addBookmarkBtn->setToolTip("Bookmark this page");
    layout->addWidget(addBookmarkBtn);

    return bookmarksBarWidget;
}

QSplitter* MainWindow::createMainSplitter()
{
    QSplitter *splitter = new QSplitter(Qt::Horizontal);
    splitter->setObjectName("mainSplitter");
    splitter->setStyleSheet(R"(
        QSplitter::handle {
            background: rgba(74, 103, 65, 0.5);
            width: 2px;
        }
        QSplitter::handle:hover {
            background: rgba(74, 103, 65, 0.8);
        }
    )");

    // Bookmarks panel (can be hidden/shown)
    bookmarksPanel = new NordicBookmarks;
    bookmarksPanel->setMaximumWidth(300);
    bookmarksPanel->setObjectName("bookmarksPanel");
    // Note: NordicBookmarks signal connection will be handled in NordicBookmarks class
    splitter->addWidget(bookmarksPanel);

    // Main tab widget
    tabWidget = new TabWidget(this);
    splitter->addWidget(tabWidget);

    // Set initial sizes
    splitter->setSizes(QList<int>() << 0 << 1200);

    return splitter;
}

void MainWindow::setupStatusBar()
{
    statusBar = this->statusBar();
    statusBar->setStyleSheet(R"(
        QStatusBar {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                        stop:0 #1a2e1a,
                        stop:1 #2d4a2d);
            border-top: 2px solid #4a6741;
            color: #b8d4b8;
            font-size: 12px;
        }
    )");

    // Load progress bar
    loadProgress = new QProgressBar;
    loadProgress->setMaximumWidth(150);
    loadProgress->setVisible(false);
    loadProgress->setStyleSheet(R"(
        QProgressBar {
            border: 1px solid #4a6741;
            border-radius: 3px;
            background-color: #2d4a2d;
            text-align: center;
        }
        QProgressBar::chunk {
            background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #6a8761,
                        stop:1 #4a6741);
            border-radius: 2px;
        }
    )");
    statusBar->addPermanentWidget(loadProgress);

    // Connection status
    connectionLabel = new QLabel("🟢 Connected");
    statusBar->addPermanentWidget(connectionLabel);

    // Zoom level
    zoomLabel = new QLabel("100%");
    statusBar->addPermanentWidget(zoomLabel);

    // Status message
    statusLabel = new QLabel("Welcome to Vaelix - Nordic Browser");
    statusBar->addWidget(statusLabel);
}

void MainWindow::setupToolbars()
{
    // Additional toolbars can be added here if needed
}

void MainWindow::setupShortcuts()
{
    // File menu shortcuts
    new QShortcut(QKeySequence::New, this, &MainWindow::newTab);
    new QShortcut(QKeySequence::Open, this, &MainWindow::newWindow);
    new QShortcut(QKeySequence::Close, this, &MainWindow::closeCurrentTab);

    // Navigation shortcuts
    new QShortcut(QKeySequence::Refresh, this, &MainWindow::reload);
    new QShortcut(QKeySequence::Back, this, &MainWindow::goBack);
    new QShortcut(QKeySequence::Forward, this, &MainWindow::goForward);
    new QShortcut(QKeySequence("Home"), this);
    connect(new QShortcut(QKeySequence("Home"), this), &QShortcut::activated, this, [this]() { home(); });

    // View shortcuts
    new QShortcut(QKeySequence("Ctrl+Shift+F"), this, &MainWindow::toggleFullscreen);
    new QShortcut(QKeySequence("Ctrl+F"), this, &MainWindow::findOnPage);
    new QShortcut(QKeySequence("F12"), this, &MainWindow::showDeveloperTools);

    // Browser shortcuts - using safer connect syntax
    new QShortcut(QKeySequence("Ctrl+T"), this);
    connect(new QShortcut(QKeySequence("Ctrl+T"), this), &QShortcut::activated, this, [this]() { newTab(); });
    QShortcut* ctrlLShortcut = new QShortcut(QKeySequence("Ctrl+L"), addressBar);
    connect(ctrlLShortcut, &QShortcut::activated, addressBar, &QLineEdit::setFocus);
    new QShortcut(QKeySequence("Ctrl+D"), this);
    connect(new QShortcut(QKeySequence("Ctrl+D"), this), &QShortcut::activated, this, [this] { /* Add bookmark */ });
    new QShortcut(QKeySequence("Ctrl+Shift+O"), this);
    connect(new QShortcut(QKeySequence("Ctrl+Shift+O"), this), &QShortcut::activated, this, [this]() { showBookmarks(); });
    new QShortcut(QKeySequence("Ctrl+H"), this);
    connect(new QShortcut(QKeySequence("Ctrl+H"), this), &QShortcut::activated, this, [this]() { showHistory(); });
    new QShortcut(QKeySequence("Ctrl+J"), this);
    connect(new QShortcut(QKeySequence("Ctrl+J"), this), &QShortcut::activated, this, [this]() { showDownloads(); });
    new QShortcut(QKeySequence("Ctrl+Shift+E"), this);
    connect(new QShortcut(QKeySequence("Ctrl+Shift+E"), this), &QShortcut::activated, this, [this]() { manageExtensions(); });

    // Settings
    new QShortcut(QKeySequence("Ctrl+Comma"), this);
    connect(zoomResetShortcut, &QShortcut::activated, this, &MainWindow::zoomReset);

    // Special shortcuts - using connect for safer method call syntax
    QShortcut* homeShortcut = new QShortcut(QKeySequence("Alt+Home"), this);
    connect(homeShortcut, &QShortcut::activated, this, &MainWindow::home);
    QShortcut* backShortcut = new QShortcut(QKeySequence("Alt+Left"), this);
    connect(backShortcut, &QShortcut::activated, this, &MainWindow::goBack);
    QShortcut* forwardShortcut = new QShortcut(QKeySequence("Alt+Right"), this);
    connect(forwardShortcut, &QShortcut::activated, this, &MainWindow::goForward);
    QShortcut* escapeShortcut = new QShortcut(QKeySequence("Escape"), this);
    connect(escapeShortcut, &QShortcut::activated, this, &MainWindow::stopLoading);
    QShortcut* f5Shortcut = new QShortcut(QKeySequence("F5"), this);
    connect(f5Shortcut, &QShortcut::activated, this, &MainWindow::reload);
}

void MainWindow::setupConnections()
{
    // Navigation buttons
    connect(backButton, &QPushButton::clicked, this, &MainWindow::goBack);
    connect(forwardButton, &QPushButton::clicked, this, &MainWindow::goForward);
    connect(refreshButton, &QPushButton::clicked, this, &MainWindow::reload);
    connect(stopButton, &QPushButton::clicked, this, &MainWindow::stopLoading);
    connect(homeButton, &QPushButton::clicked, this, &MainWindow::home);

    // Control buttons
    connect(bookmarksButton, &QPushButton::clicked, this, &MainWindow::showBookmarks);
    connect(historyButton, &QPushButton::clicked, this, &MainWindow::showHistory);
    connect(downloadsButton, &QPushButton::clicked, this, &MainWindow::showDownloads);
    connect(extensionsButton, &QPushButton::clicked, this, &MainWindow::manageExtensions);
    connect(settingsButton, &QPushButton::clicked, this, &MainWindow::showSettings);
    connect(newTabButton, &QPushButton::clicked, this, [this]() { newTab(); });

    // Tab widget connections
    connect(tabWidget, &TabWidget::titleChanged, this, &MainWindow::updateTabTitle);
    connect(tabWidget, &TabWidget::urlChanged, this, &MainWindow::updateUrl);
    connect(tabWidget, &TabWidget::loadProgressChanged, this, &MainWindow::updateLoadProgress);
    connect(tabWidget, &TabWidget::loadStarted, this, [this] {
        stopButton->setVisible(true);
        refreshButton->setVisible(false);
    });
    connect(tabWidget, &TabWidget::loadFinished, this, [this](bool success) {
        stopButton->setVisible(false);
        refreshButton->setVisible(true);
        if (success) {
            statusLabel->setText("Page loaded successfully");
        } else {
            statusLabel->setText("Page failed to load");
        }
    });

    // Search engine combo
    connect(searchEngineCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, [this](int index) {
                Q_UNUSED(index)
                // Update search engine based on combo selection
            });
}

void MainWindow::createMenuBar()
{
    createFileMenu();
    createEditMenu();
    createViewMenu();
    createNavigateMenu();
    createBookmarksMenu();
    createToolsMenu();
    createHelpMenu();
}

void MainWindow::createFileMenu()
{
    QMenuBar *menuBar = this->menuBar();
    QMenu *fileMenu = menuBar->addMenu("File");

    QAction *newTabAction = fileMenu->addAction("New Tab");
    newTabAction->setShortcut(QKeySequence::New);
    connect(newTabAction, &QAction::triggered, this, &MainWindow::newTab);

    QAction *newWindowAction = fileMenu->addAction("New Window");
    newWindowAction->setShortcut(QKeySequence::Open);
    connect(newWindowAction, &QAction::triggered, this, &MainWindow::newWindow);

    QAction *privateAction = fileMenu->addAction("New Private Window");
    privateAction->setShortcut(QKeySequence("Ctrl+Shift+N"));
    connect(privateAction, &QAction::triggered, this, &MainWindow::privateBrowsing);

    fileMenu->addSeparator();

    QAction *importAction = fileMenu->addAction("Import Bookmarks...");
    connect(importAction, &QAction::triggered, this, &MainWindow::importBookmarks);

    QAction *exportAction = fileMenu->addAction("Export Bookmarks...");
    connect(exportAction, &QAction::triggered, this, &MainWindow::exportBookmarks);

    fileMenu->addSeparator();

    QAction *printAction = fileMenu->addAction("Print...");
    printAction->setShortcut(QKeySequence::Print);

    QAction *closeTabAction = fileMenu->addAction("Close Tab");
    closeTabAction->setShortcut(QKeySequence::Close);
    connect(closeTabAction, &QAction::triggered, this, &MainWindow::closeCurrentTab);

    fileMenu->addSeparator();

    QAction *exitAction = fileMenu->addAction("Exit");
    exitAction->setShortcut(QKeySequence::Quit);
    connect(exitAction, &QAction::triggered, this, &QMainWindow::close);
}

void MainWindow::createEditMenu()
{
    QMenuBar *menuBar = this->menuBar();
    QMenu *editMenu = menuBar->addMenu("Edit");

    QAction *undoAction = editMenu->addAction("Undo");
    undoAction->setShortcut(QKeySequence::Undo);

    QAction *redoAction = editMenu->addAction("Redo");
    redoAction->setShortcut(QKeySequence::Redo);

    editMenu->addSeparator();

    QAction *cutAction = editMenu->addAction("Cut");
    cutAction->setShortcut(QKeySequence::Cut);

    QAction *copyAction = editMenu->addAction("Copy");
    copyAction->setShortcut(QKeySequence::Copy);

    QAction *pasteAction = editMenu->addAction("Paste");
    pasteAction->setShortcut(QKeySequence::Paste);

    QAction *selectAllAction = editMenu->addAction("Select All");
    selectAllAction->setShortcut(QKeySequence::SelectAll);

    editMenu->addSeparator();

    QAction *findAction = editMenu->addAction("Find on Page...");
    findAction->setShortcut(QKeySequence::Find);
    connect(findAction, &QAction::triggered, this, &MainWindow::findOnPage);
}

void MainWindow::createViewMenu()
{
    QMenuBar *menuBar = this->menuBar();
    QMenu *viewMenu = menuBar->addMenu("View");

    QAction *toolbarAction = viewMenu->addAction("Show Bookmarks Bar");
    toolbarAction->setCheckable(true);
    toolbarAction->setChecked(bookmarksBarVisible);
    connect(toolbarAction, &QAction::triggered, this, &MainWindow::toggleBookmarksBar);

    QAction *statusAction = viewMenu->addAction("Show Status Bar");
    statusAction->setCheckable(true);
    statusAction->setChecked(true);

    viewMenu->addSeparator();

    QAction *fullscreenAction = viewMenu->addAction("Fullscreen");
    fullscreenAction->setShortcut(QKeySequence("F11"));
    connect(fullscreenAction, &QAction::triggered, this, &MainWindow::toggleFullscreen);

    QAction *devtoolsAction = viewMenu->addAction("Developer Tools");
    devtoolsAction->setShortcut(QKeySequence("F12"));
    connect(devtoolsAction, &QAction::triggered, this, &MainWindow::showDeveloperTools);

    viewMenu->addSeparator();

    QAction *zoomInAction = viewMenu->addAction("Zoom In");
    zoomInAction->setShortcut(QKeySequence("Ctrl+Plus"));
    connect(zoomInAction, &QAction::triggered, this, &MainWindow::zoomIn);

    QAction *zoomOutAction = viewMenu->addAction("Zoom Out");
    zoomOutAction->setShortcut(QKeySequence("Ctrl+Minus"));
    connect(zoomOutAction, &QAction::triggered, this, &MainWindow::zoomOut);

    QAction *zoomResetAction = viewMenu->addAction("Reset Zoom");
    zoomResetAction->setShortcut(QKeySequence("Ctrl+0"));
    connect(zoomResetAction, &QAction::triggered, this, &MainWindow::zoomReset);
}

void MainWindow::createNavigateMenu()
{
    QMenuBar *menuBar = this->menuBar();
    QMenu *navMenu = menuBar->addMenu("Navigate");

    QAction *backAction = navMenu->addAction("Back");
    backAction->setShortcut(QKeySequence::Back);
    connect(backAction, &QAction::triggered, this, &MainWindow::goBack);

    QAction *forwardAction = navMenu->addAction("Forward");
    forwardAction->setShortcut(QKeySequence::Forward);
    connect(forwardAction, &QAction::triggered, this, &MainWindow::goForward);

    QAction *reloadAction = navMenu->addAction("Reload");
    reloadAction->setShortcut(QKeySequence::Refresh);
    connect(reloadAction, &QAction::triggered, this, &MainWindow::reload);

    QAction *stopAction = navMenu->addAction("Stop");
    stopAction->setShortcut(QKeySequence::Cancel);
    connect(stopAction, &QAction::triggered, this, &MainWindow::stopLoading);

    navMenu->addSeparator();

    QAction *homeAction = navMenu->addAction("Home");
    homeAction->setShortcut(QKeySequence("Home"));
    connect(homeAction, &QAction::triggered, this, &MainWindow::home);
}

void MainWindow::createBookmarksMenu()
{
    QMenuBar *menuBar = this->menuBar();
    QMenu *bookmarksMenu = menuBar->addMenu("Bookmarks");

    QAction *showBookmarksAction = bookmarksMenu->addAction("Show Bookmarks");
    showBookmarksAction->setShortcut(QKeySequence("Ctrl+Shift+O"));
    connect(showBookmarksAction, &QAction::triggered, this, &MainWindow::showBookmarks);

    QAction *addBookmarkAction = bookmarksMenu->addAction("Bookmark This Page");
    addBookmarkAction->setShortcut(QKeySequence::AddTab);

    bookmarksMenu->addSeparator();

    // Add bookmark management actions
    QAction *organizeBookmarksAction = bookmarksMenu->addAction("Organize Bookmarks...");
    QAction *importBookmarksAction = bookmarksMenu->addAction("Import Bookmarks...");
    QAction *exportBookmarksAction = bookmarksMenu->addAction("Export Bookmarks...");
}

void MainWindow::createToolsMenu()
{
    QMenuBar *menuBar = this->menuBar();
    QMenu *toolsMenu = menuBar->addMenu("Tools");

    QAction *downloadsAction = toolsMenu->addAction("Downloads");
    downloadsAction->setShortcut(QKeySequence("Ctrl+J"));
    connect(downloadsAction, &QAction::triggered, this, &MainWindow::showDownloads);

    QAction *extensionsAction = toolsMenu->addAction("Extensions");
    extensionsAction->setShortcut(QKeySequence("Ctrl+Shift+E"));
    connect(extensionsAction, &QAction::triggered, this, &MainWindow::manageExtensions);

    toolsMenu->addSeparator();

    QAction *settingsAction = toolsMenu->addAction("Settings");
    settingsAction->setShortcut(QKeySequence("Ctrl+Comma"));
    connect(settingsAction, &QAction::triggered, this, &MainWindow::showSettings);

    QAction *clearDataAction = toolsMenu->addAction("Clear Browsing Data...");
    connect(clearDataAction, &QAction::triggered, this, &MainWindow::clearBrowsingData);
}

void MainWindow::createHelpMenu()
{
    QMenuBar *menuBar = this->menuBar();
    QMenu *helpMenu = menuBar->addMenu("Help");

    QAction *shortcutsAction = helpMenu->addAction("Keyboard Shortcuts");
    connect(shortcutsAction, &QAction::triggered, this, &MainWindow::showKeyboardShortcuts);

    helpMenu->addSeparator();

    QAction *aboutAction = helpMenu->addAction("About Vaelix");
    connect(aboutAction, &QAction::triggered, this, &MainWindow::showAbout);

    QAction *checkUpdatesAction = helpMenu->addAction("Check for Updates...");
    connect(checkUpdatesAction, &QAction::triggered, this, &MainWindow::checkForUpdates);
}

void MainWindow::newTab(const QUrl &url)
{
    tabWidget->addNewTab(url);
    addressBar->setFocus();
}

void MainWindow::closeCurrentTab()
{
    int index = tabWidget->currentIndex();
    if (index >= 0) {
        tabWidget->removeTab(index);
        if (tabWidget->count() == 0) {
            newTab(); // Always keep at least one tab open
        }
    }
}

void MainWindow::navigateToUrl()
{
    QString urlText = addressBar->text().trimmed();
    if (urlText.isEmpty()) {
        return;
    }

    QUrl url;
    if (urlText.startsWith("http://") || urlText.startsWith("https://")) {
        url = QUrl(urlText);
    } else if (urlText.contains(".") && !urlText.contains(" ")) {
        // Looks like a domain
        url = QUrl("https://" + urlText);
    } else {
        // Treat as search query
        url = QUrl(getSearchUrl(urlText));
    }

    navigateToUrl(url);
}

void MainWindow::navigateToUrl(const QUrl &url)
{
    tabWidget->navigateInCurrentTab(url);
}

void MainWindow::updateTabTitle(const QString &title)
{
    setWindowTitle(title.isEmpty() ? "Vaelix - Nordic Browser" :
                  QString("%1 - Vaelix").arg(title));
    updateWindowTitle();
}

void MainWindow::updateUrl(const QUrl &url)
{
    if (addressBar->text() != url.toString()) {
        addressBar->setText(url.toString());
    }
}

void MainWindow::updateLoadProgress(int progress)
{
    if (progress >= 0 && progress <= 100) {
        loadProgress->setVisible(true);
        loadProgress->setValue(progress);
        if (progress == 100) {
            QTimer::singleShot(1000, loadProgress, &QProgressBar::hide);
        }
    } else {
        loadProgress->setVisible(false);
    }
}

void MainWindow::showBookmarks()
{
    bookmarksVisible = !bookmarksVisible;
    bookmarksButton->setText(bookmarksVisible ? "❌" : "📚");

    if (bookmarksVisible) {
        bookmarksPanel->show();
    } else {
        bookmarksPanel->hide();
    }
}

void MainWindow::showHistory()
{
    // TODO: Implement history panel
    statusLabel->setText("History panel coming soon...");
}

void MainWindow::showDownloads()
{
    // TODO: Implement downloads panel
    statusLabel->setText("Downloads panel coming soon...");
}

void MainWindow::showSettings()
{
    // TODO: Implement settings dialog
    QMessageBox::information(this, "Settings", "Settings panel coming soon...");
}

void MainWindow::showAbout()
{
    QString aboutText = R"(
        <h2>Vaelix - Nordic Browser</h2>
        <p><b>Version:</b> 1.0.0</p>
        <p><b>Built with:</b> Qt6 WebEngine</p>
        <p><b>Developer:</b> Veridian Zenith</p>
        <p><b>Website:</b> veridianzenith.qzz.io</p>
        <br>
        <p>A modern, privacy-focused browser inspired by Nordic aesthetics
        and designed for the digital nomad who values both performance and beauty.</p>
        <br>
        <p><i>"Where curiosity meets creation"</i></p>
    )";

    QMessageBox::about(this, "About Vaelix", aboutText);
}

void MainWindow::goBack()
{
    tabWidget->goBack();
}

void MainWindow::goForward()
{
    tabWidget->goForward();
}

void MainWindow::reload()
{
    tabWidget->reload();
}

void MainWindow::stopLoading()
{
    tabWidget->stopLoading();
    stopButton->setVisible(false);
    refreshButton->setVisible(true);
}

void MainWindow::home()
{
    tabWidget->navigateToUrl(QUrl("https://www.startpage.com"));
}

void MainWindow::zoomIn()
{
    tabWidget->zoomIn();
    zoomLabel->setText(QString("%1%").arg(tabWidget->getZoomLevel()));
}

void MainWindow::zoomOut()
{
    tabWidget->zoomOut();
    zoomLabel->setText(QString("%1%").arg(tabWidget->getZoomLevel()));
}

void MainWindow::zoomReset()
{
    tabWidget->zoomReset();
    zoomLabel->setText("100%");
}

void MainWindow::toggleFullscreen()
{
    if (isFullscreen) {
        showNormal();
        menuBar()->show();
        statusBar->show();
        navBar->show();
    } else {
        showFullScreen();
        menuBar()->hide();
        statusBar->hide();
        navBar->hide();
    }
    isFullscreen = !isFullscreen;
}

void MainWindow::findOnPage()
{
    // TODO: Implement find on page
    statusLabel->setText("Find on page coming soon...");
}

void MainWindow::showDeveloperTools()
{
    tabWidget->showDeveloperTools();
}

void MainWindow::toggleBookmarksBar()
{
    bookmarksBarVisible = !bookmarksBarVisible;
    bookmarksBar->setVisible(bookmarksBarVisible);
}

void MainWindow::newWindow()
{
    // TODO: Implement multiple windows
    statusLabel->setText("Multiple windows coming soon...");
}

void MainWindow::privateBrowsing()
{
    isPrivateMode = !isPrivateMode;
    statusLabel->setText(isPrivateMode ? "Private browsing mode enabled" : "Private browsing mode disabled");
    // TODO: Switch to private profile
}

void MainWindow::importBookmarks()
{
    QString fileName = QFileDialog::getOpenFileName(this,
        "Import Bookmarks", "", "Bookmark Files (*.html *.json)");
    if (!fileName.isEmpty()) {
        // TODO: Import bookmarks from file
        statusLabel->setText("Importing bookmarks...");
    }
}

void MainWindow::exportBookmarks()
{
    QString fileName = QFileDialog::getSaveFileName(this,
        "Export Bookmarks", "vaelix_bookmarks.json", "JSON Files (*.json)");
    if (!fileName.isEmpty()) {
        // TODO: Export bookmarks to file
        statusLabel->setText("Exporting bookmarks...");
    }
}

void MainWindow::onBookmarksUrlRequested(const QUrl &url)
{
    navigateToUrl(url);
}

void MainWindow::onStatusBarClicked()
{
    // Handle status bar clicks
}

void MainWindow::updateWindowTitle()
{
    QWebEngineView *currentView = tabWidget->currentWebView();
    if (currentView && !currentView->title().isEmpty()) {
        setWindowTitle(QString("%1 - Vaelix").arg(currentView->title()));
    } else {
        setWindowTitle("Vaelix - Nordic Browser");
    }
}

void MainWindow::checkForUpdates()
{
    QMessageBox::information(this, "Check for Updates",
        "You are running the latest version of Vaelix.");
}

void MainWindow::saveSession()
{
    // TODO: Implement session saving
}

void MainWindow::restoreSession()
{
    // TODO: Implement session restoration
}

void MainWindow::clearBrowsingData()
{
    // TODO: Implement clear browsing data dialog
    QMessageBox::information(this, "Clear Browsing Data",
        "Clear browsing data functionality coming soon...");
}

void MainWindow::manageExtensions()
{
    // TODO: Implement extensions management
    QMessageBox::information(this, "Extensions", "Extensions management coming soon...");
}

void MainWindow::showKeyboardShortcuts()
{
    QString shortcuts = R"(
        <h3>Vaelix Keyboard Shortcuts</h3>
        <table>
        <tr><td><b>Ctrl+T</b></td><td>New Tab</td></tr>
        <tr><td><b>Ctrl+W</b></td><td>Close Tab</td></tr>
        <tr><td><b>Ctrl+L</b></td><td>Focus Address Bar</td></tr>
        <tr><td><b>Alt+Left</b></td><td>Back</td></tr>
        <tr><td><b>Alt+Right</b></td><td>Forward</td></tr>
        <tr><td><b>F5</b></td><td>Reload</td></tr>
        <tr><td><b>Escape</b></td><td>Stop</td></tr>
        <tr><td><b>Ctrl+F</b></td><td>Find on Page</td></tr>
        <tr><td><b>Ctrl+D</b></td><td>Bookmark Page</td></tr>
        <tr><td><b>Ctrl+Shift+O</b></td><td>Show Bookmarks</td></tr>
        <tr><td><b>Ctrl+H</b></td><td>Show History</td></tr>
        <tr><td><b>Ctrl+Shift+F</b></td><td>Toggle Fullscreen</td></tr>
        <tr><td><b>F12</b></td><td>Developer Tools</td></tr>
        </table>
    )";

    QMessageBox::information(this, "Keyboard Shortcuts", shortcuts);
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    saveSession();
    saveSettings();
    event->accept();
}

void MainWindow::keyPressEvent(QKeyEvent *event)
{
    if (event->key() == Qt::Key_Escape && isFullscreen) {
        toggleFullscreen();
    }
    QMainWindow::keyPressEvent(event);
}

void MainWindow::contextMenuEvent(QContextMenuEvent *event)
{
    // TODO: Implement context menu for web view
}

void MainWindow::initializeProfiles()
{
    defaultProfile = new QWebEngineProfile("VaelixProfile", this);
    privateProfile = new QWebEngineProfile("VaelixPrivateProfile", this);

    // Configure default profile settings
    defaultProfile->settings()->setAttribute(QWebEngineSettings::PluginsEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::FullScreenSupportEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::WebGLEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::Accelerated2dCanvasEnabled, true);
}

void MainWindow::setupProfileSettings()
{
    // Configure WebEngine settings for default profile
    defaultProfile->settings()->setAttribute(QWebEngineSettings::PluginsEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::FullScreenSupportEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::WebGLEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::Accelerated2dCanvasEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::DnsPrefetchEnabled, true);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::XSSAuditingEnabled, false);
    defaultProfile->settings()->setAttribute(QWebEngineSettings::ShowScrollBars, true);

    // Configure WebEngine settings for private profile
    privateProfile->settings()->setAttribute(QWebEngineSettings::PluginsEnabled, false);
    privateProfile->settings()->setAttribute(QWebEngineSettings::FullScreenSupportEnabled, true);
    privateProfile->settings()->setAttribute(QWebEngineSettings::WebGLEnabled, true);
    privateProfile->settings()->setAttribute(QWebEngineSettings::Accelerated2dCanvasEnabled, true);
    privateProfile->settings()->setAttribute(QWebEngineSettings::DnsPrefetchEnabled, false);
    privateProfile->settings()->setAttribute(QWebEngineSettings::XSSAuditingEnabled, true);
    privateProfile->settings()->setAttribute(QWebEngineSettings::ShowScrollBars, true);
}

void MainWindow::applyTheme()
{
    updateThemeColors();
}

void MainWindow::updateThemeColors()
{
    // Nordic color scheme
    QString nordicGreen = "#4a6741";
    QString nordicDarkGreen = "#2d4a2d";
    QString nordicLightGreen = "#6a8761";
    QString nordicBackground = "#0a0f0a";

    setStyleSheet(QString(R"(
        QMainWindow {
            background: %1;
        }
    )").arg(nordicBackground));
}

void MainWindow::loadSettings()
{
    QSettings settings("Veridian Zenith", "Vaelix");
    bookmarksVisible = settings.value("bookmarks/visible", false).toBool();
    bookmarksBarVisible = settings.value("bookmarks/bar_visible", false).toBool();
    isPrivateMode = settings.value("privacy/private_mode", false).toBool();
}

void MainWindow::saveSettings()
{
    QSettings settings("Veridian Zenith", "Vaelix");
    settings.setValue("bookmarks/visible", bookmarksVisible);
    settings.setValue("bookmarks/bar_visible", bookmarksBarVisible);
    settings.setValue("privacy/private_mode", isPrivateMode);
}

QString MainWindow::getDefaultSearchEngine() const
{
    return "Startpage"; // Default to privacy-focused search engine
}

QString MainWindow::getSearchUrl(const QString &query) const
{
    QString engine = searchEngineCombo->currentText();
    if (engine.contains("DuckDuckGo")) {
        return "https://duckduckgo.com/?q=" + QUrl::toPercentEncoding(query);
    } else if (engine.contains("Searx")) {
        return "https://searx.org/?q=" + QUrl::toPercentEncoding(query);
    } else {
        // Default to Startpage
        return "https://www.startpage.com/sp/search?query=" + QUrl::toPercentEncoding(query);
    }
}

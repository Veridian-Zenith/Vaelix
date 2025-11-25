#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtWidgets/QMainWindow>
#include <QTabWidget>
#include <QLineEdit>
#include <QSplitter>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QToolBar>
#include <QStatusBar>
#include <QPushButton>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QKeySequence>
#include <QWebEngineView>
#include <QWebEngineSettings>
#include <QWebEngineProfile>
#include <QWebEnginePage>
#include <QUrl>
#include <QString>
#include <QTimer>
#include <QProgressBar>
#include <QLabel>
#include <QComboBox>
#include <QShortcut>
#include <QCloseEvent>

#include "../Yggdrasil/tabwidget.h"
#include "../Yggdrasil/nordicbookmarks.h"
#include "../Yggdrasil/browserengine.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

signals:
    void statusMessage(const QString &message);
    void titleChanged(const QString &title);

public slots:
    void newTab(const QUrl &url = QUrl("https://www.startpage.com"));
    void closeCurrentTab();
    void navigateToUrl();
    void navigateToUrl(const QUrl &url);
    void updateTabTitle(const QString &title);
    void updateUrl(const QUrl &url);
    void updateLoadProgress(int progress);
    void showBookmarks();
    void showHistory();
    void showDownloads();
    void showSettings();
    void showAbout();
    void goBack();
    void goForward();
    void reload();
    void stopLoading();
    void home();
    void zoomIn();
    void zoomOut();
    void zoomReset();
    void toggleFullscreen();
    void findOnPage();
    void showDeveloperTools();
    void toggleBookmarksBar();
    void newWindow();
    void privateBrowsing();
    void importBookmarks();
    void exportBookmarks();

private slots:
    void onBookmarksUrlRequested(const QUrl &url);
    void onStatusBarClicked();
    void updateWindowTitle();
    void checkForUpdates();
    void saveSession();
    void restoreSession();
    void clearBrowsingData();
    void manageExtensions();
    void showKeyboardShortcuts();

protected:
    void closeEvent(QCloseEvent *event) override;
    void keyPressEvent(QKeyEvent *event) override;
    void contextMenuEvent(QContextMenuEvent *event) override;

private:
    void setupUI();
    void setupToolbars();
    void setupStatusBar();
    void setupShortcuts();
    void setupConnections();

    // Layout components
    QWidget* createNavigationBar();
    QWidget* createAddressBar();
    QWidget* createControlButtons();
    QWidget* createBookmarksBar();
    QSplitter* createMainSplitter();

    // UI Components
    QWidget *navBar;
    QLineEdit *addressBar;
    QComboBox *searchEngineCombo;
    QPushButton *backButton;
    QPushButton *forwardButton;
    QPushButton *refreshButton;
    QPushButton *stopButton;
    QPushButton *homeButton;
    QPushButton *bookmarksButton;
    QPushButton *historyButton;
    QPushButton *downloadsButton;
    QPushButton *extensionsButton;
    QPushButton *settingsButton;
    QPushButton *newTabButton;

    // Main components
    TabWidget *tabWidget;
    NordicBookmarks *bookmarksPanel;
    QWidget *bookmarksBar;
    QStatusBar *statusBar;
    QProgressBar *loadProgress;
    QLabel *statusLabel;
    QLabel *connectionLabel;
    QLabel *zoomLabel;

    // Browser management
    BrowserEngine *browserEngine;
    QWebEngineProfile *defaultProfile;
    QWebEngineProfile *privateProfile;
    bool isPrivateMode;
    bool bookmarksVisible;
    bool bookmarksBarVisible;
    bool isFullscreen;

    // Session management
    QTimer *sessionTimer;
    QString sessionFile;

    // Utility functions
    void applyTheme();
    void updateThemeColors();
    void loadSettings();
    void saveSettings();
    void createMenuBar();
    void createFileMenu();
    void createEditMenu();
    void createViewMenu();
    void createNavigateMenu();
    void createBookmarksMenu();
    void createToolsMenu();
    void createHelpMenu();
    void setupContextMenus();
    QString getDefaultSearchEngine() const;
    QString getSearchUrl(const QString &query) const;
    void setupProfileSettings();
    void initializeProfiles();
};

#endif // MAINWINDOW_H

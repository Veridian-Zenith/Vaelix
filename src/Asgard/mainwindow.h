#ifndef F0BDBEDE_A755_4F1A_8031_502A5D7FA683
#define F0BDBEDE_A755_4F1A_8031_502A5D7FA683


#endif /* F0BDBEDE_A755_4F1A_8031_502A5D7FA683 */
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTabWidget>
#include <QLineEdit>
#include <QSplitter>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QToolBar>
#include <QStatusBar>
#include <QPushButton>

#include "Yggdrasil/tabwidget.h"
#include "Yggdrasil/nordicbookmarks.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void newTab();
    void closeCurrentTab();
    void navigateToUrl();
    void updateTabTitle(const QString &title);
    void showBookmarks();
    void showHistory();

private:
    void setupUI();
    void setupToolbars();
    void setupStatusBar();

    // Nordic-inspired layout
    QWidget* createNordicChrome();
    QSplitter* createMainSplitter();

private:
    QLineEdit *addressBar;
    QPushButton *backButton, *forwardButton, *refreshButton;
    QPushButton *homeButton, *bookmarksButton, *historyButton;
    QPushButton *newTabButton, *extensionsButton;

    TabWidget *tabWidget;
    NordicBookmarks *bookmarksPanel;
    QStatusBar *statusBar;

    bool bookmarksVisible;
};

#endif // MAINWINDOW_H

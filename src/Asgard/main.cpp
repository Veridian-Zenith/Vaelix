#include <QtWidgets/QApplication>
#include <QStyleFactory>
#include <QFontDatabase>
#include <QDir>
#include <QStringList>
#include <QFont>
#include <QWidget>
#include <QMainWindow>
#include <QLineEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // Set application properties
    app.setApplicationName("Vaelix");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("Veridian Zenith");
    app.setOrganizationDomain("veridianzenith.qzz.io");

    // Load Nordic-inspired fonts
    int fontId = QFontDatabase::addApplicationFont(":/fonts/norse");
    if (fontId != -1) {
        QStringList families = QFontDatabase::applicationFontFamilies(fontId);
        if (!families.isEmpty()) {
            QFont nordicFont(families.at(0));
            nordicFont.setPointSize(10);
            app.setFont(nordicFont);
        }
    }

    // Apply Nordic mystical styling
    app.setStyle(QStyleFactory::create("Fusion"));
    app.setStyleSheet(R"(
        QApplication {
            background-color: #0a0f0a;
            color: #e8f5e8;
        }

        /* Nordic Runic Window Styling */
        QMainWindow {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #0d1a0d,
                        stop:0.5 #1a2e1a,
                        stop:1 #0f1f0f);
            border: 2px solid #4a6741;
            border-radius: 8px;
        }

        /* Tab Widget Nordic Styling */
        QTabWidget::pane {
            border: 2px solid #2d4a2d;
            background: rgba(26, 46, 26, 0.9);
            border-radius: 6px;
        }

        QTabBar::tab {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #2d4a2d,
                        stop:1 #1a2e1a);
            color: #b8d4b8;
            border: 1px solid #4a6741;
            border-bottom: none;
            padding: 8px 16px;
            margin-right: 2px;
            border-top-left-radius: 6px;
            border-top-right-radius: 6px;
            min-width: 120px;
        }

        QTabBar::tab:selected {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #4a6741,
                        stop:1 #2d4a2d);
            color: #e8f5e8;
            font-weight: bold;
        }

        QTabBar::tab:hover:!selected {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #3a573a,
                        stop:1 #2d4a2d);
            color: #d4f0d4;
        }

        /* Navigation Bar Nordic Styling */
        QWidget#navBar {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                        stop:0 #1a2e1a,
                        stop:0.5 #2d4a2d,
                        stop:1 #1a2e1a);
            border-bottom: 2px solid #4a6741;
            padding: 8px;
        }

        QPushButton {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #3a573a,
                        stop:1 #2d4a2d);
            border: 1px solid #4a6741;
            border-radius: 6px;
            color: #b8d4b8;
            padding: 8px 12px;
            font-weight: 500;
            min-width: 32px;
            min-height: 32px;
        }

        QPushButton:hover {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #4a6741,
                        stop:1 #3a573a);
            border-color: #6a8761;
            color: #e8f5e8;
        }

        QPushButton:pressed {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #2d4a2d,
                        stop:1 #1a2e1a);
        }

        /* Address Bar Nordic Styling */
        QLineEdit#addressBar {
            background: rgba(10, 15, 10, 0.8);
            border: 2px solid #4a6741;
            border-radius: 8px;
            padding: 10px 12px;
            color: #e8f5e8;
            font-size: 14px;
            selection-background-color: #4a6741;
        }

        QLineEdit#addressBar:focus {
            border-color: #6a8761;
            background: rgba(10, 15, 10, 0.9);
        }

        /* Bookmarks Panel Nordic Styling */
        QWidget#bookmarksPanel {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                        stop:0 #1a2e1a,
                        stop:1 #2d4a2d);
            border-right: 2px solid #4a6741;
        }

        QListWidget {
            background: rgba(10, 15, 10, 0.6);
            border: 1px solid #2d4a2d;
            border-radius: 6px;
            color: #b8d4b8;
            padding: 4px;
        }

        QListWidget::item {
            padding: 8px 12px;
            border-radius: 4px;
            margin: 2px 0;
        }

        QListWidget::item:hover {
            background: rgba(74, 103, 65, 0.3);
            color: #e8f5e8;
        }

        QListWidget::item:selected {
            background: rgba(74, 103, 65, 0.5);
            color: #e8f5e8;
            font-weight: bold;
        }

        /* Status Bar Nordic Styling */
        QStatusBar {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                        stop:0 #1a2e1a,
                        stop:1 #2d4a2d);
            border-top: 2px solid #4a6741;
            color: #b8d4b8;
            font-size: 12px;
        }

        QStatusBar::item {
            border: none;
        }

        /* Menu Bar Nordic Styling */
        QMenuBar {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                        stop:0 #2d4a2d,
                        stop:1 #1a2e1a);
            border-bottom: 1px solid #4a6741;
            color: #b8d4b8;
            padding: 4px;
        }

        QMenuBar::item {
            padding: 6px 12px;
            border-radius: 4px;
        }

        QMenuBar::item:selected {
            background: rgba(74, 103, 65, 0.3);
        }

        QMenu {
            background: #1a2e1a;
            border: 1px solid #4a6741;
            border-radius: 6px;
            color: #b8d4b8;
        }

        QMenu::item {
            padding: 6px 20px;
        }

        QMenu::item:selected {
            background: rgba(74, 103, 65, 0.3);
        }
    )");

    MainWindow window;
    window.show();

    return app.exec();
}


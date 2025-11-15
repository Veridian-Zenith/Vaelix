#include <QApplication>
#include <QStyleFactory>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // Apply Nordic warm styling
    app.setStyle(QStyleFactory::create("Fusion"));

    // Set Nordic theme colors
    app.setStyleSheet(R"(
        QMainWindow {
            background-color: #1a0f0a;
            color: #fff8f0;
        }
        QTabWidget::pane {
            border: 1px solid rgba(255, 140, 0, 0.3);
            background: rgba(45, 24, 16, 0.8);
        }
        QTabBar::tab {
            background: rgba(61, 36, 21, 0.8);
            color: #d4b896;
            border: 1px solid rgba(255, 140, 0, 0.2);
            border-bottom: none;
            padding: 8px 16px;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
        }
        QTabBar::tab:selected {
            background: rgba(255, 140, 0, 0.2);
            color: #ff8c00;
        }
        QTabBar::tab:hover {
            background: rgba(255, 179, 71, 0.1);
        }
    )");

    MainWindow window;
    window.show();

    return app.exec();
}

#include "nordicbookmarks.h"

NordicBookmarks::NordicBookmarks(QWidget *parent) : QWidget(parent)
{
    setupUI();
    addSampleBookmarks();

    setStyleSheet(R"(
        NordicBookmarks {
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                        stop:0 rgba(45, 24, 16, 0.9),
                        stop:1 rgba(61, 36, 21, 0.8));
            border-right: 1px solid rgba(255, 140, 0, 0.3);
        }
        QLabel {
            color: #ff8c00;
            font-weight: 600;
            font-size: 16px;
        }
        QLineEdit {
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 140, 0, 0.3);
            border-radius: 8px;
            padding: 8px 10px;
            color: #fff8f0;
        }
        QLineEdit:focus {
            border-color: #ff8c00;
        }
        QPushButton {
            background: rgba(255, 140, 0, 0.2);
            border: 1px solid rgba(255, 140, 0, 0.4);
            border-radius: 8px;
            color: #ff8c00;
            padding: 8px 12px;
            font-weight: 500;
        }
        QPushButton:hover {
            background: rgba(255, 140, 0, 0.3);
        }
        QListWidget {
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255, 140, 0, 0.2);
            border-radius: 8px;
            color: #d4b896;
            padding: 8px;
        }
        QListWidget::item {
            padding: 8px;
            border-radius: 4px;
            margin: 2px 0;
        }
        QListWidget::item:hover {
            background: rgba(255, 179, 71, 0.1);
        }
        QListWidget::item:selected {
            background: rgba(255, 140, 0, 0.2);
            color: #ff8c00;
        }
    )");
}

void NordicBookmarks::setupUI()
{
    mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(15, 15, 15, 15);
    mainLayout->setSpacing(15);

    // Header
    headerLabel = new QLabel("📚 Nordic Bookmarks");
    mainLayout->addWidget(headerLabel);

    // Add bookmark form
    QWidget *addWidget = new QWidget;
    QVBoxLayout *addLayout = new QVBoxLayout(addWidget);
    addLayout->setSpacing(8);

    titleEdit = new QLineEdit;
    titleEdit->setPlaceholderText("Bookmark title...");

    urlEdit = new QLineEdit;
    urlEdit->setPlaceholderText("https://example.com");

    addButton = new QPushButton("✨ Add Bookmark");
    connect(addButton, &QPushButton::clicked, this, &NordicBookmarks::addBookmark);

    addLayout->addWidget(titleEdit);
    addLayout->addWidget(urlEdit);
    addLayout->addWidget(addButton);

    mainLayout->addWidget(addWidget);

    // Bookmarks list
    bookmarksList = new QListWidget;
    connect(bookmarksList, &QListWidget::itemClicked, this, &NordicBookmarks::loadBookmark);
    mainLayout->addWidget(bookmarksList, 1);
}

void NordicBookmarks::addSampleBookmarks()
{
    QListWidgetItem *item1 = new QListWidgetItem("🏠 Google");
    item1->setData(Qt::UserRole, "https://www.google.com");
    bookmarksList->addItem(item1);

    QListWidgetItem *item2 = new QListWidgetItem("💻 GitHub");
    item2->setData(Qt::UserRole, "https://www.github.com");
    bookmarksList->addItem(item2);

    QListWidgetItem *item3 = new QListWidgetItem("🌍 Stack Overflow");
    item3->setData(Qt::UserRole, "https://stackoverflow.com");
    bookmarksList->addItem(item3);

    QListWidgetItem *item4 = new QListWidgetItem("📰 Hacker News");
    item4->setData(Qt::UserRole, "https://news.ycombinator.com");
    bookmarksList->addItem(item4);
}

void NordicBookmarks::addBookmark()
{
    QString title = titleEdit->text().trimmed();
    QString url = urlEdit->text().trimmed();

    if (title.isEmpty() || url.isEmpty()) {
        return;
    }

    // Add protocol if missing
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "https://" + url;
    }

    QListWidgetItem *item = new QListWidgetItem("🌟 " + title);
    item->setData(Qt::UserRole, url);
    bookmarksList->insertItem(0, item);

    titleEdit->clear();
    urlEdit->clear();
}

void NordicBookmarks::loadBookmark(QListWidgetItem *item)
{
    QString url = item->data(Qt::UserRole).toString();
    emit openUrl(QUrl(url));
}

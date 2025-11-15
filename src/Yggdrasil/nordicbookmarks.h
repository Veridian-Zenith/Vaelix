#ifndef NORDICBOOKMARKS_H
#define NORDICBOOKMARKS_H

#include <QWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLineEdit>
#include <QPushButton>
#include <QListWidget>
#include <QLabel>

class NordicBookmarks : public QWidget
{
    Q_OBJECT

public:
    explicit NordicBookmarks(QWidget *parent = nullptr);

private slots:
    void addBookmark();
    void loadBookmark(QListWidgetItem *item);

private:
    void setupUI();
    void addSampleBookmarks();

private:
    QVBoxLayout *mainLayout;
    QLineEdit *titleEdit;
    QLineEdit *urlEdit;
    QPushButton *addButton;
    QListWidget *bookmarksList;
    QLabel *headerLabel;
};

#endif // NORDICBOOKMARKS_H

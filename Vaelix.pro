QT += core gui widgets webenginewidgets
TARGET = Vaelix
TEMPLATE = app
CONFIG += c++20

# Nordic architecture naming
SOURCES += \
    src/Asgard/main.cpp \
    src/Asgard/mainwindow.cpp \
    src/Yggdrasil/browserengine.cpp \
    src/Yggdrasil/tabwidget.cpp \
    src/Yggdrasil/nordicbookmarks.cpp

HEADERS += \
    src/Asgard/mainwindow.h \
    src/Yggdrasil/browserengine.h \
    src/Yggdrasil/tabwidget.h \
    src/Yggdrasil/nordicbookmarks.h

# Nordic warm color scheme
DEFINES += NORDIC_WARM_COLORS

# Linux-specific
unix {
    CONFIG += console
    QMAKE_CXXFLAGS += -std=c++20 -O3 -pipe -march=native
    QMAKE_LFLAGS += -flto=thin -fuse-ld=lld
}

QT += core gui widgets webenginewidgets webenginecore webchannel network qml quick positioning printsupport

TARGET = Vaelix
TEMPLATE = app

CONFIG += c++20
CONFIG += qt6_support
CONFIG += use_libprefix
QT_CONFIG -= no-pkg-config

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

unix {
    CONFIG += console
    QMAKE_CXXFLAGS += -std=c++20 -O3 -pipe -march=native -pthread
    QMAKE_LFLAGS += -pthread
}

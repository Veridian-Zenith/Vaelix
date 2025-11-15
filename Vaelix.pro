QT += core gui widgets webenginewidgets webengine
TARGET = Vaelix
TEMPLATE = app
CONFIG += c++17

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

# Windows-specific
win32 {
    LIBS += -luser32 -lkernel32
    CONFIG += windows
}

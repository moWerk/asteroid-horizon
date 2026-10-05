TARGET = harbour-asteroid-horizon

CONFIG += sailfishapp

SOURCES += src/main.cpp

DISTFILES += qml/harbour-asteroid-horizon.qml \
    qml/game/*.qml \
    qml/game/qmldir \
    rpm/harbour-asteroid-horizon.spec \
    harbour-asteroid-horizon.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

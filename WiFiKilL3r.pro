# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = WiFiKilL3r

CONFIG += sailfishapp

SOURCES += src/WiFiKilL3r.cpp

OTHER_FILES += qml/WiFiKilL3r.qml \
    qml/cover/CoverPage.qml \
    rpm/WiFiKilL3r.spec \
    rpm/WiFiKilL3r.yaml \
    translations/*.ts \
    WiFiKilL3r.png \
    WiFiKilL3r.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/WiFiKilL3r-nl.ts

DISTFILES += \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/images/WiFiKilL3r.png \
    qml/python/WiFiKilL3r.py \
    qml/pages/AddNew.qml \
    systemd/WiFiKilL3r.service \
    systemd/WiFiKilL3r.timer \
    rpm/WiFiKilL3r.changes

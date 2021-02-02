import QtQuick 2.4
import Sailfish.Silica 1.0

Page {
    id: mainpage
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About WiFiKilL3r")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Manage trusted networks")
                onClicked: pageStack.push(Qt.resolvedUrl("NetworksPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: mainpage.width
            spacing: Theme.paddingMedium
            PageHeader {
                title: qsTr("WiFiKilL3r")
            }

            Image {
                id: logo
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl('../images/WiFiKilL3r.png')
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }

            Label {
                x: Theme.paddingLarge
                text: qsTr("Current status")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }

            TextSwitch {
                id: wifirunning
                automaticCheck: false
                checked: wifiKillerApp.wifienabled
                text: qsTr("WiFi") + " " + (checked ? qsTr("enabled") :qsTr("disabled")) + " " + wifiKillerApp.currentwifi
                description: qsTr("Current WiFi status")
                onClicked: {
                    //wifiDevice.setPowered(!wifiKillerApp.wifienabled)
                    wifiKillerApp.togglewifi()
                }
            }

            TextSwitch {
                id: hotspotrunning
                automaticCheck: false
                checked: wifiKillerApp.hotspotenabled
                text: qsTr("Hotspot") + " " + (checked ? qsTr("enabled") :qsTr("disabled"))
                description: qsTr("Current Hotspot status")
                onClicked: {
                    //wifiDevice.setPowered(!wifiKillerApp.wifienabled)
                    //wifiKillerApp.togglewifi()
                }
            }

            TextSwitch {
                id: killerrunning
                automaticCheck: false
                checked: wifiKillerApp.cronenabled
                text: qsTr("KilL3r") + " " + (checked ? qsTr("enabled") :qsTr("disabled"))
                description: qsTr("Current KilL3r status")
                onClicked: {
                    wifiKillerApp.togglecron()
                }
            }

            TextField {
                id: lastUpdateField
                x: Theme.paddingLarge
                placeholderText: qsTr('Loading...')
                text: "\n\n" + wifiKillerApp.last_update === 0 ? qsTr('Loading...') : Qt.formatDateTime(wifiKillerApp.last_update,'dddd dd-MMM-yyyy hh:mm:ss')
                label: qsTr('Last check')
                readOnly: true
                labelVisible: true
                width: parent.width
            }
        }
    }
}

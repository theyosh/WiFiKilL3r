import QtQuick 2.4
import Sailfish.Silica 1.0

Page {
    id: settingspage

    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height + Theme.paddingMedium

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            width: settingspage.width
            spacing: Theme.paddingMedium
            PageHeader {
                title: qsTr('Settings')
            }

            Label {
                id: header
                text: qsTr('Here you can enable or disable settings.') + '\n'
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }

            TextSwitch {
                id: macverification_switch
                automaticCheck: false
                checked: wifiKillerApp.mac_verification_enabled
                text: qsTr('Accesspoint MAC verification') + ' ' + (checked ? qsTr('enabled') :qsTr('disabled'))
                description: qsTr('Current Accesspoint MAC verification status')
                onClicked: {
                    wifiKillerApp.toggle_mac_verification()
                }
            }

            TextSwitch {
                id: notifications_switch
                automaticCheck: false
                checked: wifiKillerApp.notifications_enabled
                text: qsTr('Notifications') + ' ' + (checked ? qsTr('enabled') :qsTr('disabled'))
                description: qsTr('Current notification status')
                onClicked: {
                    wifiKillerApp.toggle_notifications()
                }
            }
        }
    }
}

import QtQuick 2.4
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: title
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
        }
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "\n" + qsTr('WiFiKilL3r')
    }

    Label {
        id: version
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeSmall
        text: "\n\n\n\n" + qsTr('Last check') + "\n" + (wifiKillerApp.last_update === 0 ? qsTr('Loading...') : Qt.formatDateTime(wifiKillerApp.last_update,'d-M-yy hh:mm:ss'))
    }

    CoverPlaceholder {
        anchors.fill: parent
        icon.source: Qt.resolvedUrl('../images/WiFiKilL3r.png')
    }

    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: wifiKillerApp.enable_wifi()
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-" + (wifiKillerApp.cronenabled ? 'pause' : 'play')
            onTriggered: wifiKillerApp.togglecron()
        }
    }
}

import QtQuick 2.4
import Sailfish.Silica 1.0

Page {
    id: networkspage

    ViewPlaceholder {
        enabled: !wifiKillerApp.wifienabled
        text: qsTr("Please, turn WiFi on")
    }

    SilicaListView {
        id: wifiInfoList
        contentHeight: wifiInfoList.height + Theme.paddingMedium
        header: PageHeader {
            title: qsTr("Add trusted network")
        }

        model: wifiDevice
        anchors.fill: parent
        delegate: Item {
            width: parent.width
            height: Theme.itemSizeMedium

            Column {
                spacing: Theme.paddingMedium
                anchors.fill: parent
                anchors.topMargin: Theme.paddingMedium
                anchors.bottomMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                anchors.leftMargin: Theme.paddingMedium

                TextSwitch {
                    text: '<b>' + modelData.name + '</b>'
                    description: qsTr('bssid') + ': ' + modelData.bssid
                    checked: wifiKillerApp.is_trusted_network(modelData.name + '(' + modelData.bssid + ')')
                    onCheckedChanged: {
                        wifiKillerApp.save_trusted_network(modelData.name + '(' + modelData.bssid + ')',checked)
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        wifiDevice.requestScan()
    }
}

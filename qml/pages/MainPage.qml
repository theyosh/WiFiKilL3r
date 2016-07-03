/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: mainpage
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Update trusted networks")
                onClicked: pageStack.push(Qt.resolvedUrl("AddNew.qml"))
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
                text: qsTr("WiFi") + " " + (checked ? qsTr("enabled") :qsTr("disabled"))
                description: qsTr("Current WiFi status")
                onClicked: {
                    wifiDevice.setPowered(!wifiKillerApp.wifienabled)
                }
            }

            TextSwitch {
                id: killerrunning
                automaticCheck: false
                text: qsTr("KilL3r") + " " + (wifiKillerApp.killerrunning ? qsTr("enabled") :qsTr("disabled"))
                checked: wifiKillerApp.killerrunning
                description: qsTr("Current KilL3r status")
                onClicked: {
                    wifiKillerApp.killerrunning = !wifiKillerApp.killerrunning
                }
            }

            TextSwitch {
                id: reconnect
                automaticCheck: false
                checked: false
                busy: wifiKillerApp.reconnecting == 1
                text: qsTr("Reconnect WiFi")
                description: wifiKillerApp.reconnecting == 0 ? qsTr("Reconnect") : wifiKillerApp.reconnecting == 1 ? qsTr("Reconnecting...") : qsTr("Reconnected")
                onClicked: {
                    wifiKillerApp.reconnect()
                }
            }

            TextField {
                id: lastUpdateField
                x: Theme.paddingLarge
                placeholderText: qsTr('Loading...')
                text: wifiKillerApp.last_update === 0 ? qsTr('Loading...') : Qt.formatDateTime(wifiKillerApp.last_update,'dddd dd-MMM-yyyy hh:mm:ss')
                label: qsTr('Last update')
                readOnly: true
                labelVisible: true
                width: parent.width
            }
        }
    }
}

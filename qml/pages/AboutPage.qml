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
    id: aboutpage

    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height + Theme.paddingMedium

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            width: aboutpage.width
            spacing: Theme.paddingMedium
            PageHeader {
                title: qsTr("About WiFiKilL3r")
            }
            Label {
                id: header
                text: qsTr('WiFiKilL3r') + ' v' + wifiKillerApp.version + '\n'
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }

            Label {
                id: body
                text: qsTr('This app will monitor the WiFi status of your device, and will disable it when your phone is not connected to a trusted network. It will show a notification when your WiFi is being shut down.

- You can enable or disable WiFi by tapping on the WiFi indicator
- You can enable or disable the WiFi KilL3r daemon by tapping on the KilL3r indicator
- The app will show the last run time on the bottom of the app

Use the menu item \'Manage trusted networks\' in the topmenu to add or remove trusted WiFi networks. Make sure WiFi is enabled!. Tap in the WiFi name to add or remove from the trusted list. Updates are instantly!

On the coverpage you have the option to reconnect your WiFi, and enable/disable the background daemon

*Why*
This app is created in order to protect your mobile device from being tracked by wifitrackers in citymalls and other public locations. The idea is that when you leave your trusted networks, there is no need to keep WiFi running. So this app will shutdown the WiFi device for you. This way it will save battery power, but more important, you can\'t be tracked!

WiFiKilL3r app is created by TheYOSH https://theyosh.nl
(c) 2016')
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
            }
        }
    }
}

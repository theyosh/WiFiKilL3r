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

import MeeGo.Connman 0.2
import io.thp.pyotherside 1.4
import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: wifiKillerApp

    property variant last_update: 0
    property bool cronenabled: false
    property bool wifienabled: false
    property string version: '0.5'

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    function is_trusted_network(name) {
        return pythonBridge.is_trusted_network(name)
    }

    function save_trusted_network(name,save) {
        pythonBridge.save_trusted_network(name,save)
    }

    function disable_wifi() {
        pythonBridge.disable_wifi()
    }

    function enable_wifi() {
        pythonBridge.enable_wifi()
    }

    function togglewifi() {
        if (wifiKillerApp.wifienabled) {
            disable_wifi();
        } else {
            enable_wifi();
        }
    }

    function reconnect() {
        if (wifiKillerApp.reconnecting != 1) {
            wifiKillerApp.reconnecting = 1
            wifiDevice.setPowered(true)
        }
    }

    function togglecron() {
        pythonBridge.toggle_cron();
    }

    Python {
        id: pythonBridge

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('python'));
            importModule('WiFiKilL3r', function () {});
            is_cron_enabled();
            last_run();
        }

        onError: {
            // when an exception is raised, this error handler will be called
            console.log('python error: ' + traceback);
        }

        onReceived: {
            // asychronous messages from Python arrive here
            // in Python, this can be accomplished via pyotherside.send()
            console.log('got message from python: ' + data);
        }

        function is_cron_enabled() {
            call('WiFiKilL3r.is_cron_enabled', [], function(enabled) {
                wifiKillerApp.cronenabled = enabled;
            });
        }

        function last_run() {
            call('WiFiKilL3r.last_run', [], function(time) {
                wifiKillerApp.last_update = new Date(time * 1000);
            });
        }

        function toggle_cron() {
            call('WiFiKilL3r.toggle_cron_job', [], function() {
                is_cron_enabled();
            });
        }

        function is_trusted_network(name) {
            //console.log('is_trusted_network: ' + name);
            // Bug: https://together.jolla.com/question/156736/2109-pyotherside-call_sync-broken/
            //return call_sync('WiFiKilL3r.is_trusted_network',[name]);
            return evaluate('WiFiKilL3r.is_trusted_network("' + name+ '")')
        }

        function save_trusted_network(name,save) {
            //console.log('save_trusted_network: ' + name + ' ' + save);
            //call_sync('WiFiKilL3r.save_trusted_network',[name,save]);

            call('WiFiKilL3r.save_trusted_network', [name,save], function() {
                //console.log('Saved wifi ' + name);
            });
        }

        function disable_wifi() {
            call('WiFiKilL3r.disable_wifi', [], function() {
                console.log('Disabled wifi');
            });
        }

        function enable_wifi() {
            call('WiFiKilL3r.enable_wifi', [], function() {
                console.log('Enabled wifi');
            });
        }
    }

    // More info:
    // https://github.com/osanwe/harbour-wifianalyzer/tree/master/qml
    // https://github.com/nemomobile/qmlsettings/blob/master/WirelessApplet.qml
    // https://git.merproject.org/mer-core/libconnman-qt/blob/master/plugin/technologymodel.h
    // https://git.merproject.org/mer-core/libconnman-qt/blob/master/libconnman-qt/networkservice.h
    TechnologyModel {
        id: wifiDevice
        name: "wifi"

        onTechnologiesChanged: {
            wifiKillerApp.wifienabled = wifiDevice.powered
            //console.log('Wifi status changed: ' + (wifiKillerApp.wifienabled ? 'eanbled' : 'disabled'))
        }

        onPoweredChanged: {
            wifiKillerApp.wifienabled = wifiDevice.powered
            //console.log('Wifi power changed: ' + (wifiKillerApp.wifienabled ? 'eanbled' : 'disabled'))
        }
    }

    Timer {
        id: updateTimer
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            pythonBridge.is_cron_enabled()
            pythonBridge.last_run()
        }
    }
}

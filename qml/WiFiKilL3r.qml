import MeeGo.Connman 0.2
import io.thp.pyotherside 1.4
import QtQuick 2.4
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: wifiKillerApp

    property variant last_update: 0
    property bool cronenabled: false
    property bool wifienabled: false
    property bool hotspotenabled: false
    property bool mac_verification_enabled: true
    property bool notifications_enabled: true
    property string currentwifi: ''
    property string version: '0.12-3'

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

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
        pythonBridge.current_wifi();
    }

    function reconnect() {
        if (wifiKillerApp.reconnecting !== 1) {
            wifiKillerApp.reconnecting = 1
            wifiDevice.setPowered(true)
        }
    }

    function togglecron() {
        pythonBridge.toggle_cron();
    }

    function toggle_mac_verification() {
        pythonBridge.toggle_mac_verification();
    }

    function toggle_notifications() {
        pythonBridge.toggle_notifications();
    }

    Python {
        id: pythonBridge

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('python'));
            importModule('WiFiKilL3r', function () {});
            is_mac_verification_enabled();
            is_notifications_enabled();
            timer();
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

        function timer() {
           is_cron_enabled();
           current_wifi();
           running_hotspot();
           last_run();
        }

        function is_cron_enabled() {
            call('WiFiKilL3r.is_cron_enabled', [], function(state) {
                wifiKillerApp.cronenabled = state;
                if (state) {
                    call('WiFiKilL3r.run_check', [true], function() {
                        //console.log('Manual run cron job');
                    });
                }
            });
        }

        function running_hotspot() {
            call('WiFiKilL3r.runnning_hotspot', [], function(state) {
                wifiKillerApp.hotspotenabled = state;
            });
        }

        function current_wifi() {
            call('WiFiKilL3r.get_wifi_status', [], function(state) {
                wifiKillerApp.currentwifi = state;
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

        function toggle_mac_verification() {
            call('WiFiKilL3r.toggle_mac_verification', [], function() {
                is_mac_verification_enabled();
            });
        }

        function is_mac_verification_enabled() {
            call('WiFiKilL3r.is_mac_verification_enabled', [], function(state) {
                wifiKillerApp.mac_verification_enabled = state;
            });
        }

        function toggle_notifications() {
            call('WiFiKilL3r.toggle_notifications', [], function() {
                // Due to a-sync calls, the update of the state will be later. So we anticipate on this here already....
                if (!wifiKillerApp.notifications_enabled) {
                    call('WiFiKilL3r.notification', ['Notifications are enabled'], function(state) {
                    });
                }
                is_notifications_enabled();
            });
        }

        function is_notifications_enabled() {
            call('WiFiKilL3r.is_notifications_enabled', [], function(state) {
                wifiKillerApp.notifications_enabled = state;
            });
        }

        function is_trusted_network(name) {
            // Bug: https://together.jolla.com/question/156736/2109-pyotherside-call_sync-broken/
            //return call_sync('WiFiKilL3r.is_trusted_network',[name]);
            return evaluate('WiFiKilL3r.is_trusted_network("' + name+ '")')
        }

        function save_trusted_network(name,save) {
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
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            pythonBridge.timer()
        }
    }
}

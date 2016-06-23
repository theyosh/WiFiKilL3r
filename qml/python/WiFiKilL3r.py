# -*- coding: utf-8 -*-

#import pyotherside
import dbus
import subprocess
import re
import argparse
from os.path import expanduser

HOME_FOLDER = expanduser('~')
CONFIG_FILE = HOME_FOLDER + '/.wifikiller'
CRON_JOB = '* * * * * /usr/share/WiFiKilL3r/qml/python/WiFiKilL3r.py -a run_cron'
DBUS_WIFI = 'dbus-send --system --print-reply --dest=net.connman /net/connman/technology/wifi'

def notification(title = 'WifiKilL3r status:',message = 'Wifi is disabled due to leaving trusted networks!'):
    bus = dbus.SessionBus()
    object = bus.get_object('org.freedesktop.Notifications','/org/freedesktop/Notifications')
    wifikiller = dbus.Interface(object,'org.freedesktop.Notifications')
    wifikiller.Notify('WiFiKilL3r',
                 0,
                 '/usr/share/WiFiKilL3r/qml/images/WiFiKilL3r.png',
                 title,
                 message,
                 dbus.Array(['default', '']),
                 dbus.Dictionary({'x-nemo-preview-body': message,
                                  'x-nemo-preview-summary': title,
                                  'category': 'x-nemo.simple.notifications'},
                                  signature='sv'),
                 0)

def get_trusted_networks():
    content = []
    try:
        with open(HOME_FOLDER + '/.valid_networks') as f:
            content = f.read().splitlines()
    except:
        pass

    #print('Valid networks:')
    #print(content)
    return content

def is_trusted_network(name):
    #print('Check netmwork name: ' + str(name))
    return name in get_trusted_networks()

def save_trusted_network(name,save):
    trusted_networks = get_trusted_networks()
    if save and name not in trusted_networks:
        trusted_networks.append(name)

    try:
        with open(HOME_FOLDER + '/.valid_networks','w+') as f:
            for trusted_network in trusted_networks:
                if not save and name == trusted_network:
                    continue

                f.write(trusted_network + "\n")
    except:
        pass

def get_cron_job_data():
    try:
        crondata = str(subprocess.check_output('/usr/bin/crontab -l 2>/dev/null', shell=True).strip())
    except:
        crondata = ''

    return crondata

def is_cron_enabled():
    crondata = get_cron_job_data()
    #print('search for: ' + CRON_JOB)
    cron_enabled = crondata.find(CRON_JOB) > -1
    if cron_enabled:
        #print('Cron job is enabled')
        pass
    else:
        #print('Cron job is not enabled')
        pass
    return cron_enabled

def enable_cron_job():
    if not is_cron_enabled():
        current_cron_data = get_cron_job_data()
        current_cron_data += '\n' + CRON_JOB
        subprocess.check_output('echo "' + current_cron_data + '" | /usr/bin/crontab -', shell=True)

def disable_cron_job():
    if is_cron_enabled():
        current_cron_data = get_cron_job_data()
        new_cron_data = current_cron_data.replace(CRON_JOB,'')
        subprocess.check_output('echo "' + new_cron_data + '" | /usr/bin/crontab -', shell=True)

def toggle_cron_job():
    if is_cron_enabled():
        enable_cron_job()
    else:
        disable_cron_job()

def get_wifi_status():
    try:
        current_wifi =  str(subprocess.check_output('/usr/sbin/iw dev wlan0 link', shell=True).strip())
        regex = re.compile(r'Connected to (?P<mac>[^ ]+).*SSID: (?P<ssid>[^\\n]+)')
        data = re.search(regex, current_wifi)
        if data is not None:
            current_wifi = data.group('ssid') + '(' + data.group('mac') + ')'
    except:
        current_wifi = ''

    #print('Current wifi status: ' + current_wifi)
    return current_wifi

def is_wifi_enabled():
    #print(DBUS_WIFI + ' net.connman.Technology.GetProperties')
    data = str(subprocess.check_output(DBUS_WIFI + ' net.connman.Technology.GetProperties', shell=True).strip())
    p = re.compile(r'string "Powered"\n\s+variant\s+boolean true')
    re.search(p, data)
    if data is not None:
        #print('Wifi is currently running...')
        return True
    else:
        #print ('Wifi is already offline!')
        return False

def disable_wifi():
    if is_wifi_enabled():
        data = str(subprocess.check_output(DBUS_WIFI + ' net.connman.Technology.SetProperty string:"Powered" variant:boolean:false', shell=True))
    #print('Disable wifi:')
    #print(data)

def enable_wifi():
    if not is_wifi_enabled():
        data = str(subprocess.check_output(DBUS_WIFI + ' net.connman.Technology.SetProperty string:"Powered" variant:boolean:true', shell=True))
    #print('Enable wifi:')
    #print(data)

def run_cron():
    if is_wifi_enabled():
        current_wifi = get_wifi_status()
        if current_wifi == '' or current_wifi not in get_trusted_networks():
            # shutdown wifi
            #disable_wifi()
            return False
            #notification()
        else:
            #notification(message='Wifi is connected to trusted network: ' + current_wifi)
            pass
    else:
        #notification(message='Wifi is not running!! YEAH!')
        pass

    return True

if __name__ == '__main__':
  parser = argparse.ArgumentParser(description='WiFiKilL3r options')
  parser.add_argument('-a','--action', choices=['check_cron', 'enable_cron', 'disable_cron', 'run_cron','gui'], default='gui')
  args = parser.parse_args()

  if args.action == 'run_cron':
    run_cron()

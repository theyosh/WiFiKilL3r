# -*- coding: utf-8 -*-

import dbus
import subprocess
import re
import argparse
import os
import shutil
import logging
import logging.handlers
import time
import platform

DEBUG = False

APP_DIR = '/usr/share/WiFiKilL3r'
HOME_FOLDER = os.path.expanduser('~')
WIFIKILLER_FOLDER = HOME_FOLDER + '/.WiFiKilL3r'
TRUSTED_NETWORKS = WIFIKILLER_FOLDER + '/valid_networks'
LOG_FILE = WIFIKILLER_FOLDER + '/WiFiKilL3r.log'
LAST_RUN_FILE = WIFIKILLER_FOLDER + '/last_run'
DBUS_WIFI = 'dbus-send --system --print-reply --dest=net.connman /net/connman/technology/wifi'
CRON_TYPE = 'systemd'
CRON_TIME_OUT_ERROR = 10 * 60
ARM_DEVICE = 'arm' in platform.processor() or 'aarch64' in platform.processor()

if not os.path.isdir(WIFIKILLER_FOLDER):
  os.mkdir(WIFIKILLER_FOLDER)

logging.basicConfig(
  level=logging.INFO
)

logger = logging.getLogger('WiFiKilL3r')
formatter = logging.Formatter('[%(asctime)s] %(levelname)s - %(message)s', datefmt="%d-%m-%Y %H:%M:%S")
handler = logging.handlers.TimedRotatingFileHandler(LOG_FILE, when='midnight',interval=1, backupCount=30)

if DEBUG:
  logger.setLevel(logging.DEBUG)
  formatter = logging.Formatter('[%(asctime)s] %(levelname)s - [%(filename)s:%(lineno)s - %(funcName)15s() ] - %(message)s', datefmt="%d-%m-%Y %H:%M:%S")

handler.setFormatter(formatter)
logger.addHandler(handler)

def notification(title = 'WifiKilL3r status',message = 'Wifi is disabled due to leaving trusted networks!'):
  bus = dbus.SessionBus()
  object = bus.get_object('org.freedesktop.Notifications','/org/freedesktop/Notifications')
  wifikiller = dbus.Interface(object,'org.freedesktop.Notifications')
  wifikiller.Notify('WiFiKilL3r',
                     0,
                     APP_DIR + '/qml/images/WiFiKilL3r.png',
                     title,
                     message,
                     dbus.Array(['default', '']),
                     dbus.Dictionary({'x-nemo-preview-body': message,
                              'x-nemo-preview-summary': title,
                              'category': 'x-nemo.simple.notifications'},
                              signature='sv'),
                     0)
  logger.info('%s: %s' % (title, message,))

def get_trusted_networks():
  content = []
  try:
    with open(TRUSTED_NETWORKS) as f:
      content = f.read().splitlines()
  except:
    # File does not exists, return 'nothing'
    logger.debug('%s file does not exists yet' % (TRUSTED_NETWORKS,))

  logger.debug('Loaded %s trusted networks' % (len(content),))
  return content

def is_trusted_network(name):
  logger.debug('Check if %s is in trusted networks' % (name,))
  return name in get_trusted_networks()

def save_trusted_network(name,save):
  logger.debug('Update trusted network list with %s %s' % ('adding' if save else 'deleting', name,))

  trusted_networks = get_trusted_networks()
  if save and name not in trusted_networks:
    logger.info('Add network ' + name)
    trusted_networks.append(name)

  try:
    with open(TRUSTED_NETWORKS,'w+') as f:
      for trusted_network in trusted_networks:
        if not save and name == trusted_network:
          logger.info('Deleted network ' + name)
          continue

        f.write(trusted_network + "\n")
  except:
    pass

def get_wifi_status():
  logger.debug('Getting current WiFi statuss')
  current_wifi = ''
  try:
    current_wifi =  str(subprocess.check_output('/usr/sbin/iw dev wlan0 link', shell=True).strip())
    regex = re.compile(r'Connected to (?P<mac>[^ ]+).*SSID: (?P<ssid>[^\\n]+)')
    data = re.search(regex, current_wifi)
    if data is not None:
      current_wifi = data.group('ssid') + '(' + data.group('mac') + ')'
  except Exception as ex:
    logger.debug(ex)
    current_wifi = ''

  logger.debug('Connected to WiFi network: %s' % (current_wifi,))
  return current_wifi

def is_wifi_enabled():
  enabled = False
  try:
    wifi_enabled = str(subprocess.check_output(DBUS_WIFI + ' net.connman.Technology.GetProperties', shell=True).strip())
    regex = re.compile(r'string "Powered"\\n\s+variant\s+boolean true')
    enabled = re.search(regex, wifi_enabled) is not None
  except:
    enabled = False

  logger.debug('Wifi is %s' % ('enabled' if enabled else 'disabled',))
  return enabled

def runnning_hotspot():
  enabled = False
  try:
    wifi_enabled = str(subprocess.check_output(DBUS_WIFI + ' net.connman.Technology.GetProperties', shell=True).strip())
    regex = re.compile(r'string "Tethering"\\n\s+variant\s+boolean true')
    enabled = re.search(regex, wifi_enabled) is not None
  except:
    enabled = False

  logger.debug('Hotspot is %s' % ('enabled' if enabled else 'disabled',))
  return enabled

def disable_wifi():
  if is_wifi_enabled():
    logger.debug('Disable wifi')
    data = str(subprocess.check_output(APP_DIR + '/qml/bin/stop-wifi-root' + ('_arm' if ARM_DEVICE else '_intel'), shell=True))

def enable_wifi():
  if not is_wifi_enabled():
    logger.debug('Enable wifi')
    data = str(subprocess.check_output(APP_DIR + '/qml/bin/start-wifi-root' + ('_arm' if ARM_DEVICE else '_intel'), shell=True))

def init_cron_job():
  # Dirty hack.... :(
  logger.info('Reloading systemd daemon')
  subprocess.check_output('systemctl --user daemon-reload', shell=True)
  return True

def is_cron_enabled():
  cron_enabled = False
  if 'systemd' == CRON_TYPE:
    cron_enabled = os.path.isfile(HOME_FOLDER + '/.config/systemd/user/timers.target.wants/WiFiKilL3r.timer') and \
                   os.path.isfile(HOME_FOLDER + '/.config/systemd/user/user-session.target.wants/WiFiKilL3r.service')

  logger.debug('Cron is %s' % ('enabled' if cron_enabled else 'disabled'))
  return cron_enabled

def enable_cron_job():
  logger.info('Enable WiFiKilL3r cronjobs')
  if 'systemd' == CRON_TYPE:
    subprocess.check_output('systemctl --user enable WiFiKilL3r.service', shell=True)
    subprocess.check_output('systemctl --user enable WiFiKilL3r.timer', shell=True)
    subprocess.check_output('systemctl --user start WiFiKilL3r.service', shell=True)
    subprocess.check_output('systemctl --user start WiFiKilL3r.timer', shell=True)

  return True

def disable_cron_job():
  logger.info('Disable WiFiKilL3r cronjobs')
  if 'systemd' == CRON_TYPE:
    subprocess.check_output('systemctl --user stop WiFiKilL3r.timer', shell=True)
    subprocess.check_output('systemctl --user stop WiFiKilL3r.service', shell=True)
    subprocess.check_output('systemctl --user disable WiFiKilL3r.service', shell=True)
    subprocess.check_output('systemctl --user disable WiFiKilL3r.timer', shell=True)

  return True

def toggle_cron_job():
  logger.debug('Toggle Cron Job')
  init_cron_job()
  if is_cron_enabled():
    logger.debug('From on to off')
    disable_cron_job()
  else:
    logger.debug('From off to on')
    enable_cron_job()

def is_running():
  running = False
  if is_cron_enabled():
    lastrun = 0
    try:
      with open(LAST_RUN_FILE) as f:
        lastrun = int(f.read())
    except Exception as er:
      pass

    running = (int(time.time()) - lastrun) < CRON_TIME_OUT_ERROR
  return running

def last_run():
  lastrun = 0
  try:
    with open(LAST_RUN_FILE) as f:
      lastrun = int(f.read())
  except Exception as er:
    pass

  logger.debug('Last run: %s' % (lastrun,))
  return lastrun

def run_check(manual = False):
  if manual:
    logger.info('Manual check')
  else:
    logger.info('Start cron run')
  if is_wifi_enabled():
    if runnning_hotspot():
      logger.debug('WiFi network is running in hotspot mode. Ignore.')
    else:
      current_wifi = get_wifi_status()
      if current_wifi == '' or current_wifi not in get_trusted_networks():
        logger.debug('%s WiFi network is not trusted. Shutting down WiFi' % (current_wifi,))
        # shutdown wifi
        disable_wifi()
        notification()
      else:
        logger.debug('%s WiFi network is trusted!!' % (current_wifi,))
  else:
    logger.debug('WiFi is already disabled. Nothing to do...')

  try:
    with open(LAST_RUN_FILE,'w') as f:
      f.write(str(int(time.time())))
  except Exception as er:
    pass

  return True

if __name__ == '__main__':
  parser = argparse.ArgumentParser(description='WiFiKilL3r options')
  parser.add_argument('-a','--action', choices=['check_cron', 'enable_cron', 'disable_cron', 'run_check','is_running','nothing'], default='nothing')
  parser.add_argument('-d','--debug', choices=['1','0'], default=0)

  args = parser.parse_args()
  if args.debug == '1':
    handler.setLevel(logging.DEBUG)
    logger.setLevel(logging.DEBUG)
  else:
    logger.addHandler(logging.NullHandler())

  if 'check_cron' == args.action:
    is_cron_enabled()
  elif 'enable_cron' == args.action:
    enable_cron_job()
  elif 'disable_cron' == args.action:
    disable_cron_job()
  elif 'run_check' == args.action:
    run_check()
  elif 'is_running' == args.action:
    is_running()

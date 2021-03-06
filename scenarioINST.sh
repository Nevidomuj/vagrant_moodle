#!/bin/bash
MAINDB=$1
USERDB=$2
PASSWDDB=$3
BASEHOST=$4
BALHOST=$5
WWWHOST=$6
#WWWHOST=$(hostname --all-ip-addresses| awk '{ print $2}')
echo $WWWHOST

sudo /usr/bin/php /var/www/html/moodle/admin/cli/install.php --chmod=2770 --lang=uk --dbtype=mariadb --wwwroot=http://$BALHOST/ --dataroot=/var/moodledata --dbhost=$BASEHOST --dbname=$MAINDB --dbuser=$USERDB --dbpass=$PASSWDDB --dbport= --fullname=Moodle --shortname=moodle --summary=Moodle --adminpass=Admin1 --adminemail=example@example.com --non-interactive --agree-license

sudo rm /var/www/html/moodle/config.php
CFG='$CFG'
cat <<EOF | sudo tee -a /var/www/html/moodle/config.php
<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = '${BASEHOST}';
$CFG->dbname    = '${MAINDB}';
$CFG->dbuser    = '${USERDB}';
$CFG->dbpass    = '${PASSWDDB}';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_general_ci',
);

$CFG->wwwroot   = 'http://${BALHOST}';
$CFG->dataroot  = '/var/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 02770;

$CFG->session_handler_class = '\core\session\redis';
$CFG->session_redis_host = '${BASEHOST}';
$CFG->session_redis_auth = '${PASSWDDB}'; // Optional, default is don't set one.
$CFG->session_redis_port = 6379;  // Optional.
$CFG->session_redis_database = 0;  // Optional, default is db 0.
$CFG->session_redis_prefix = ''; // Optional, default is don't set one.
$CFG->session_redis_acquire_lock_timeout = 120;
$CFG->session_redis_lock_expire = 7200;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
EOF
sudo chown -R apache:apache /var/www/html/moodle/config.php

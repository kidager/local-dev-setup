<?php

declare(strict_types=1);

$servers = [
    [
        'alias'    => 'MY PRODUCTION',
        'host'     => 'distant-server.example.com',
        'port'     => '3306',
        'user'     => 'my_login',
        'password' => 'mySuperPassword',
    ],
];

###############################################################
# Other servers
###############################################################
for ($j = 0; $j < count($servers); $j++) {
    $cfg['Servers'][] = [
        'verbose'         => $servers[$j]['alias'],
        'host'            => $servers[$j]['host'],
        'port'            => isset($servers[$j]['port']) ? $servers[$j]['port'] : '3306',
        'socket'          => '',
        'connect_type'    => 'tcp',
        'extension'       => 'mysqli',
        'auth_type'       => 'config',
        'user'            => $servers[$j]['user'],
        'password'        => $servers[$j]['password'],
        'compress'        => true,
        'AllowNoPassword' => false,
        'hide_db'         => $hideDb,
    ];
}

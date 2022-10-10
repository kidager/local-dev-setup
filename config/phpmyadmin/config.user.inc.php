<?php

declare(strict_types=1);

const SERVER_SEPARATOR = "========================";

$hideDb = '(information_schema|mysql|performance_schema|phpmyadmin|sys|innodb|tmp)';

$cfg['ShowStats'] = true;
$cfg['ShowServerInfo'] = true;
$cfg['ShowPhpInfo'] = true;

$i++;
$cfg['ServerDefault'] = $i;
$cfg['Servers'][$i]['verbose'] = 'local';
$cfg['Servers'][$i]['hide_db'] = $hideDb;
$cfg['Servers'][$i]['compress'] = true;
$cfg['Servers'][$i]['AllowNoPassword'] = true;
$cfg['AllowUserDropDatabase'] = true;

$cfg['DefaultLang'] = 'en';
$cfg['QueryHistoryDB'] = true;
$cfg['QueryHistoryMax'] = 500;
$cfg['SendErrorReports'] = 'never';
$cfg['RetainQueryBox'] = true;
$cfg['ShowDatabasesNavigationAsTree'] = true;
$cfg['NavigationTreeDisplayItemFilterMinimum'] = 1000;
$cfg['FirstLevelNavigationItems'] = 1000;
$cfg['MaxNavigationItems'] = 1000;
$cfg['NavigationTreeEnableGrouping'] = false;
$cfg['DisplayServersList'] = false;
$cfg['RememberSorting'] = false;
$cfg['RepeatCells'] = 0;
$cfg['Console']['Height'] = 210;
$cfg['Console']['Mode'] = 'collapse';
$cfg['ForceSSL'] = false;
// $cfg['DefaultTabDatabase'] = 'sql';
// $cfg['DefaultTabTable'] = 'structure';
$cfg['DefaultConnectionCollation'] = 'utf8mb4_general_ci';

/* Include User Defined Settings Hook */
if (file_exists('/etc/phpmyadmin/config.creds.inc.php')) {
    include('/etc/phpmyadmin/config.creds.inc.php');
}

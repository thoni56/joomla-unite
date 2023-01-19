<?php
// Args: 0 => makedb.php, 1 => "$JOOMLA_DB_HOST", 2 => "$JOOMLA_DB_USER", 3 => "$JOOMLA_DB_PASSWORD", 4 => "$JOOMLA_DB_NAME"
$stderr = fopen('php://stderr', 'w');
fwrite($stderr, "\nEnsuring Joomla database is present\n");

$JOOMLA_DB_HOST = $argv[1];
$JOOMLA_DB_USER = $argv[2];
$JOOMLA_DB_PASSWORD = $argv[3];
$JOOMLA_DB_NAME = $argv[4];

if (strpos($JOOMLA_DB_HOST, ':') !== false)
{
	list($host, $port) = explode(':', $JOOMLA_DB_HOST, 2);
}
else
{
	$host = $JOOMLA_DB_HOST;
	$port = 3306;
}

$maxTries = 10;

do
{
	$mysql = new mysqli($host, "root", '', '', (int) $port);

	if ($mysql->connect_error)
	{
		fwrite($stderr, "\nMySQL Connection Error: ({$mysql->connect_errno}) {$mysql->connect_error}\n");
		--$maxTries;

		if ($maxTries <= 0)
		{
			exit(1);
		}

		sleep(3);
	}
}
while ($mysql->connect_error);

$mysql->query("CREATE USER IF NOT EXISTS '{$JOOMLA_DB_USER}'@'{$JOOMLA_DB_HOST}' IDENTIFIED BY '{$JOOMLA_DB_PASSWORD}';");


if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($JOOMLA_DB_NAME) . '`'))
{
	fwrite($stderr, "\nMySQL 'CREATE DATABASE' Error: " . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}

$mysql->query("GRANT ALL ON {$JOOMLA_DB_NAME}.* TO '{$JOOMLA_DB_USER}'@'{$JOOMLA_DB_HOST}';");


fwrite($stderr, "\nMySQL Database Created\n");

$mysql->close();

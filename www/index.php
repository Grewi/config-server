<?php
// test
$configDir = '/etc/nginx/conf.d';
$stacksFile = '/var/www/.stacks.list';

$stacks = explode(PHP_EOL, file_get_contents($stacksFile));
foreach ($stacks as &$i) {
    $i = str_replace('sites/', '', $i) . '.conf';
}

// print_r($stacks);
// exit();

$hosts = [];

$files = glob($configDir . '/*.conf');
$list = [];
$badList = [];
foreach ($files as $file) {
    // Показываем кофиг если он есть в списке
    $fn = str_replace($configDir . '/', '', $file);

    // print_r($fn . PHP_EOL);
    if (!in_array($fn, $stacks)) {
        continue;
    }

    $content = file_get_contents($file);
    if (preg_match_all('/server_name\s+([^;]+);/', $content, $matches)) {
        $hosts = [];
        foreach ($matches[1] as $line) {
            $names = preg_split('/\s+/', trim($line));
            foreach ($names as $name) {
                if ($name && $name !== '_' && !str_contains($name, '$')) {
                    $hosts[] = $name;
                }
            }
        }
        if (empty($hosts)) {
            continue;
        }
        $hosts = array_unique($hosts);
        $f = str_replace('.conf', '', $file);
        $f = str_replace($configDir . '/', '', $f);
        $list[$f] = $hosts;
    }
}
// print_r($list);
// exit();
?>
<!doctype html>
<html lang="ru">

<head>
    <meta charset="utf-8" />
    <title>D-Electronic</title>
</head>

<body>
    <style>
        body {
            background: #333;
        }

        .wp {
            position: fixed;
            top: 0;
            left: 0;
            bottom: 0;
            right: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .bl {
            display: flex;
            background: #444;
            padding: 20px;
            border: #777 solid 1px;
            border-radius: 10px;
            font-family: monospace;
            color: #00ed35;
        }

        .t {
            font-size: 1.5em;
            margin-bottom: 10px;
        }

        .d {
            color: #ccc;
            margin-top: 5px;
        }

        hr {
            border: 1px solid #333;
        }

        .cat {
            width: 200px;
        }

        .a {
            color: #fff;
            padding: 6px;
            display: block;
            font-size: large;
            text-decoration: none;
        }
    </style>
    <div class="wp">
        <div class="bl">
            <div class="cat">
                <div class="t"><strong>|> Сервисы</strong></div>
                <hr />
                <div><a class="a" href="http://localhost:3000/" target="_blank">Grafana</a></div>
                <div><a class="a" href="http://localhost:3001/" target="_blank">ProxyDash</a></div>
                <div><a class="a" href="http://localhost:8080/" target="_blank">phpMyAdmin</a></div>
                <div><a class="a" href="http://localhost:12345/" target="_blank">Grafana Alloy</a></div>
            </div>

            <div class="cat">
                <div class="" role="alert">
                    <div class="t"><strong>:// Хосты</strong></div>
                    <hr>
                    <?php foreach ($list as $configName => $hosts): ?>
                        <div><?= $configName ?></div>
                        <?php foreach ($hosts as $host): ?>
                            <div><a class="a" href="https://<?= $host ?>" target="_blank"><?= $host ?></a></div>
                        <?php endforeach; ?>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
    </div>
</body>

## Как запустить

1. Перейти в директорию с файлом compose.yaml
2. Запустить сервисы
    ```
    docker compose up -d
    ```
3. Инициализировать mongo кластер и заполнить его данными
    ```
    bash ./scripts/mongo-init.sh
    ```

## Как проверить (вариант 1)

В директории с файлом compose.yaml выполнить команду:

```
bash ./scripts/check.sh
```

В терминале должны отобразиться:

- Общее кол-во документов
- Кол-во документов в shard1
- Кол-во документов в shard2
- Данные по документам из API

Пример вывода:

```
[direct: mongos] somedb> [direct: mongos] test> switched to db somedb
[direct: mongos] somedb>
[direct: mongos] somedb> Всего документов:  1000

[direct: mongos] somedb> shard1 [direct: primary] test> switched to db somedb
shard1 [direct: primary] somedb>
shard1 [direct: primary] somedb> Документов в shard1:  492

shard1 [direct: primary] somedb> shard2 [direct: primary] test> switched to db somedb
shard2 [direct: primary] somedb>
shard2 [direct: primary] somedb> Документов в shard2:  508

shard2 [direct: primary] somedb> Ожидание готовности сервиса API
Сервис API запущен
Вызов localhost:8080/helloDoc/count
{"status":"OK","mongo_db":"somedb","items_count":1000}
HTTP Status: 200
```

## Как проверить (вариант 2)

Открыть в браузере на машине-хосте:

```
http://localhost:8080/helloDoc/count
```

В окне браузера должны отобразиться данные по документам в коллекции helloDoc:

```
{"status":"OK","mongo_db":"somedb","items_count":1000}
```

## Как проверить (вариант 3)

Открыть в браузере на машине-хосте:

```
http://localhost:8080/
```

В окне браузера должны отобразиться данные mongo кластера и кол-во документов в коллекции helloDoc:

```
{
  "mongo_topology_type": "Sharded",
  "mongo_replicaset_name": null,
  "mongo_db": "somedb",
  "read_preference": "Primary()",
  "mongo_nodes": [
    [
      "mongosrouter",
      27020]
  ],
  "mongo_primary_host": null,
  "mongo_secondary_hosts": [],
  "mongo_is_primary": true,
  "mongo_is_mongos": true,
  "collections": {
    "helloDoc": {
      "documents_count": 1000
    }
  },
  "shards": {
    "shard1": "shard1/shard1:27018",
    "shard2": "shard2/shard2:27019"
  },
  "cache_enabled": false,
  "status": "OK"
}
```

## Как остановить

В директории с файлом compose.yaml выполнить команду:

```
docker compose down --volumes
```

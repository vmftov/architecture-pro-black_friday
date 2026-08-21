## Как запустить

1. Перейти в директорию mongo-sharding-repl
2. Запустить сервисы
    ```
    docker compose up -d
    ```
3. Инициализировать mongo кластер и заполнить его данными
    ```
    bash ./scripts/mongo-init.sh
    ```

## Как проверить (вариант 1)

В директории mongo-sharding-repl выполнить команду:

```
bash ./scripts/check.sh
```

В терминале должны отобразиться:

- Общее кол-во документов
- Кол-во документов во всех 3 репликах shard1 (rs0)
- Кол-во документов во всех 3 репликах shard2 (rs1)
- Данные по документам из API

Пример вывода:

```
[direct: mongos] test> switched to db somedb
[direct: mongos] somedb>
[direct: mongos] somedb> Всего документов:  1000

[direct: mongos] somedb> rs0 [direct: primary] test> switched to db somedb
rs0 [direct: primary] somedb>
rs0 [direct: primary] somedb> Документов в shard1-1:  492

rs0 [direct: primary] somedb> rs0 [direct: secondary] test> switched to db somedb
rs0 [direct: secondary] somedb>
rs0 [direct: secondary] somedb> Документов в shard1-2:  492

rs0 [direct: secondary] somedb> rs0 [direct: secondary] test> switched to db somedb
rs0 [direct: secondary] somedb>
rs0 [direct: secondary] somedb> Документов в shard1-3:  492

rs0 [direct: secondary] somedb> rs1 [direct: secondary] test> switched to db somedb
rs1 [direct: secondary] somedb>
rs1 [direct: secondary] somedb> Документов в shard2-1:  508

rs1 [direct: secondary] somedb> rs1 [direct: primary] test> switched to db somedb
rs1 [direct: primary] somedb>
rs1 [direct: primary] somedb> Документов в shard2-2:  508

rs1 [direct: primary] somedb> rs1 [direct: secondary] test> switched to db somedb
rs1 [direct: secondary] somedb>
rs1 [direct: secondary] somedb> Документов в shard2-3:  508

rs1 [direct: secondary] somedb> Ожидание готовности сервиса API
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

В окне браузера должны отобразиться данные mongo кластера, все 6 реплик и кол-во документов в коллекции helloDoc:

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
    "rs0": "rs0/shard1-1:27018,shard1-2:27028,shard1-3:27038",
    "rs1": "rs1/shard2-1:27019,shard2-2:27029,shard2-3:27039"
  },
  "cache_enabled": false,
  "status": "OK"
}
```

## Как остановить

В директории mongo-sharding-repl выполнить команду:

```
docker compose down --volumes
```

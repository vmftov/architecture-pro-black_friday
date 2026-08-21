#!/bin/bash

# Ожидание готовности сервисов MongoDb

echo "Ожидание готовности сервисов MongoDb"

for service in configSrv shard1-1 shard1-2 shard1-3 shard2-1 shard2-2 shard2-3
do
    while [ "$(docker inspect -f '{{.State.Health.Status}}' $service)" != "healthy" ]; do
        echo "..."
        sleep 5
    done
done

echo "Сервисы MongoDb готовы"

# Инициализация rs0

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "shard1-1:27018" },
    { _id: 1, host: "shard1-2:27028" },
    { _id: 2, host: "shard1-3:27038" }
  ]
});
print("Ожидание выбора PRIMARY узла в rs0");
while (true) {
    try {
        let status = rs.status();
        if (!status.startupStatus && status.members.some(m => m.stateStr === 'PRIMARY')) {
            print("PRIMARY узел выбран");
            break;
        }
    } catch(err) { }
    print("...");
    sleep(2000);
}
exit();
EOF

# Инициализация rs1

docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "rs1",
  members: [
    { _id: 0, host: "shard2-1:27019" },
    { _id: 1, host: "shard2-2:27029" },
    { _id: 2, host: "shard2-3:27039" }
  ]
});
print("Ожидание выбора PRIMARY узла в rs1");
while (true) {
    try {
        let status = rs.status();
        if (!status.startupStatus && status.members.some(m => m.stateStr === 'PRIMARY')) {
            print("PRIMARY узел выбран");
            break;
        }
    } catch(err) { }
    print("...");
    sleep(2000);
}
exit();
EOF

# Инициализация сервера конфигурации

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
        _id : "config_server",
        configsvr: true,
        members: [
            { _id : 0, host : "configSrv:27017" }
        ]
  }
);
exit();
EOF

# Ожидание готовности роутера

echo "Ожидание готовности роутера"

while [ "$(docker inspect -f '{{.State.Health.Status}}' mongosRouter)" != "healthy" ]; do
    echo "..."
    sleep 5
done

echo "Роутер готов"

# Инициализация роутера

docker compose exec -T mongosRouter mongosh --port 27020 --quiet <<EOF
sh.addShard("rs0/shard1-1:27018,shard1-2:27028,shard1-3:27038");
sh.addShard("rs1/shard2-1:27019,shard2-2:27029,shard2-3:27039");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );
exit();
EOF

# Инициализация БД

docker compose exec -T mongosRouter mongosh --port 27020 --quiet <<EOF
use somedb;
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});
exit();
EOF

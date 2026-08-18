#!/bin/bash

# Проверка документов в mongo

docker compose exec -T mongosRouter mongosh --port 27020 --quiet <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Всего документов: ", count);
exit();
EOF

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Документов в shard1-1: ", count);
exit();
EOF

docker compose exec -T shard1-2 mongosh --port 27028 --quiet <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Документов в shard1-2: ", count);
exit();
EOF

docker compose exec -T shard1-3 mongosh --port 27038 --quiet <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Документов в shard1-3: ", count);
exit();
EOF

docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Документов в shard2-1: ", count);
exit();
EOF

docker compose exec -T shard2-2 mongosh --port 27029 --quiet <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Документов в shard2-2: ", count);
exit();
EOF

docker compose exec -T shard2-3 mongosh --port 27039 --quiet <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Документов в shard2-3: ", count);
exit();
EOF

# Ожидание готовности сервиса API

echo "Ожидание готовности сервиса API"

while [ "$(curl -X GET 'http://localhost:8080/' -s -o /dev/null -w '%{http_code}')" != "200" ]; do
    echo "..."
    sleep 5
done

echo "Сервис API запущен"

# Проверка документов через API

echo "Вызов localhost:8080/helloDoc/count"

curl -X GET "http://localhost:8080/helloDoc/count" -H "Content-Type: application/json" -s -w "\nHTTP Status: %{http_code}\n"

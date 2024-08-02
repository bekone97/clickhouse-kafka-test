up:
	docker compose up -d

down:
	docker compose down
	docker compose --file docker-compose-ktg.yml down

# Kafka
topic-create:
	docker exec kafka kafka-topics --bootstrap-server kafka:9092 --topic mob.km.sent.to.dashboard --create --partitions 4 --replication-factor 1
topic-check:
	docker exec kafka kafka-topics --bootstrap-server kafka:9092 --describe mob.km.sent.to.dashboard
topic-lag:
	docker exec kafka kafka-run-class kafka.admin.ConsumerGroupCommand --group mobile_scan_ch --bootstrap-server kafka:9092 --describe
topic-consumer:
	docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --from-beginning --topic mob.km.sent.to.dashboard
topic-add:
	docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic mob.km.sent.to.dashboard

# ClickHouse
clickhouse-create-tables:
	docker exec lab-clickhouse-kafka-clickhouse-1-1 clickhouse-client --multiline --queries-file /tmp/queries/test_kafka.table_mt.sql
	docker exec lab-clickhouse-kafka-clickhouse-1-1 clickhouse-client --multiline --queries-file /tmp/queries/test_kafka.table_errors.sql
clickhouse-log-errors:
	docker exec -it lab-clickhouse-kafka-clickhouse-1-1 tail -n 50 -f /var/log/clickhouse-server/clickhouse-server.err.log
clickhouse-client:
	docker exec -it lab-clickhouse-kafka-clickhouse-1-1 clickhouse client

# Prepare lab
create: up topic-create topic-check clickhouse-create-tables

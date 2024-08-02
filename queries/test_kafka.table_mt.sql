CREATE DATABASE IF NOT EXISTS test_kafka ON CLUSTER '{cluster}';

-- Main table
CREATE TABLE IF NOT EXISTS test_kafka.table_mt ON CLUSTER '{cluster}'(
id Int64,
phone String,
check_date Int64,
code String,
cis String,
status String,
product_group String,
producer_name String,
producer_inn String,
owner_name String,
owner_inn String,
check_result String,
source String,
gtin String,
product_name String,
package_type String,
product_category_code String,
product_category_name String,
locations String,
created_at Timestamp
) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/test_kafka/table_mt', '{replica}')
ORDER BY (id);

CREATE TABLE IF NOT EXISTS test_kafka.table_distributed ON CLUSTER '{cluster}' AS test_kafka.table_mt
ENGINE = Distributed('{cluster}', test_kafka, table_mt, rand());
-- DROP TABLE IF EXISTS test_kafka.table_kafka ON CLUSTER '{cluster}';


CREATE TABLE IF NOT EXISTS test_kafka.table_kafka ON CLUSTER '{cluster}'(
    data String
)
    ENGINE = Kafka
    SETTINGS kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'mob.km.sent.to.dashboard',
    kafka_group_name = 'mobile_scan_ch',
--     kafka_format = 'JSONEachRow',
    kafka_format = 'JSONAsString',
    kafka_max_block_size = 10000000,     -- The maximum batch size (in messages) for poll
    kafka_poll_timeout_ms = 1000,       -- Timeout for single poll from Kafka
    kafka_handle_error_mode = 'stream', -- Write error and message from Kafka itself to virtual columns: _error, _raw_message
    kafka_num_consumers = 4             -- The number of consumers. The total number of consumers should not exceed the number of partitions.
;
CREATE MATERIALIZED VIEW IF NOT EXISTS test_kafka.kafka_to_table ON CLUSTER '{cluster}' TO test_kafka.table_distributed AS
SELECT JSONExtractInt(data, 'id') as id
     ,JSONExtractString (data, 'phone') as phone
     ,JSONExtractInt(data, 'checkDate') as check_date
     ,JSONExtractString(data, 'cis') as cis
     ,JSONExtractString(data, 'status') as statis
     ,JSONExtractString(data, 'productGroup') as product_group
     ,JSONExtractString(data, 'producerName') as producer_name
     ,JSONExtractString(data, 'ownerName') as owner_name
     ,JSONExtractString(data, 'ownerInn') as owner_inn
     ,JSONExtractInt(data, 'productionDate') as production_date
     ,JSONExtractInt(data, 'expirationDate') as expiration_date
     ,JSONExtractString(data, 'productionSerialNumber') as production_serial_number
     ,JSONExtractString(data, 'checkResult') as check_result
     ,JSONExtractString(data, 'source') as source
     ,JSONExtractString(JSONExtractString(data, 'productInfo'), 'gtin') as gtin
     ,JSONExtractString(JSONExtractString(data, 'productInfo'), 'productName') as product_name
     ,JSONExtractString(JSONExtractString(data, 'productInfo'), 'packageType') as package_type
     ,JSONExtractString(JSONExtractString(data, 'productInfo'), 'productCategoryCode') as product_category_code
     ,JSONExtractString(JSONExtractString(data, 'productInfo'), 'productCategoryName') as product_category_name
     ,JSONExtractString(data, 'locations') as locations
     ,NOW() as created_at
FROM test_kafka.table_kafka;
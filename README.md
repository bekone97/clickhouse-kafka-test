# Clickhouse + Kafka 

## Установка
Запустить команду:
```bash
make create
```

## Что происходит при make create - запускается докер-компоуз, создаются таблицы в Clickhouse, создается топик в Kafka, после этого просто добавить сообщения в топик и проверить как они подтягиваются 

Доп make файлы : 
### ClickHouse
Создаются необходимые таблицы из каталога /queries
```bash
make clickhouse-create-tables
```

Увидеть лог erorrs clickhouse, запустить:
```bash
make clickhouse-log-errors
```

### Kafka
Чтобы создать топик в кафке, запустить :
```bash
make topic-create
```

Просмотр инфы по топику, запустить:
```bash
make topic-check
```
Просмотр сообщений в топике, запустить:
```bash
make topic-consumer
```


Записать сообщения в кафка топи, запустить:
```bash
make topic-add
```
и после этого по порядку записываем сообщения, можно взять из файла messages.txt

Проверить lag консьюмер группы, запустить:
```bash
make topic-lag
```

Подключиться к кликхаусу чтобы писать селекты, запустить
```bash
make clickhouse-client
```

Остановить все процессы и удалить контейнеры
```bash
make down
```

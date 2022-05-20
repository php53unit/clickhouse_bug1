#!/bin/bash

docker-compose up --detach --force-recreate


export ID_MYSQL=$(docker container ps -qf "name=mysql-72198374124");
echo "mysql container id: $ID_MYSQL"
printf "checking mysql.."
while ! docker exec -i $ID_MYSQL /bin/sh -c 'mysql -uroot -proot -e "select 1"' 1>/dev/null 2>/dev/null; do
    printf "."; sleep 1
done
echo " ok"
cat mysql/dump.sql | docker exec -i $ID_MYSQL mysql -uroot -proot

docker exec -i $ID_MYSQL mysql -uroot -proot -e "CREATE USER 'root'@'%' IDENTIFIED BY 'root'"
docker exec -i $ID_MYSQL mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION"

export ID_CLICKHOUSE=$(docker container ps -qf "name=clickhouse-72198374124");
echo "clickhouse container id: $ID_CLICKHOUSE"
printf "checking clickhouse.."
while ! docker exec -i $ID_CLICKHOUSE /bin/sh -c 'clickhouse-client -q "select 1"' 1>/dev/null 2>/dev/null; do
    printf "."; sleep 1
done
echo " ok"

echo "load scruct.."
echo "DROP DATABASE IF EXISTS conv" | docker exec -i $ID_CLICKHOUSE clickhouse-client
echo "CREATE DATABASE conv ENGINE = Atomic" | docker exec -i $ID_CLICKHOUSE clickhouse-client
docker exec -i $ID_CLICKHOUSE clickhouse-client  < clickhouse/struct.sql
docker exec -i $ID_CLICKHOUSE clickhouse-client  < clickhouse/struct2.sql
echo "load data.."
cat clickhouse/data.native | docker exec -i $ID_CLICKHOUSE clickhouse-client --query="INSERT INTO meter_elec_data FORMAT Native" --database=conv
echo "done"

echo "show clickhouse segfault:"
docker exec -i $ID_CLICKHOUSE clickhouse-client --database=conv --query='SELECT 1 FROM `meter_elec_data` med INNER JOIN `meter_elec` `me` ON `me`.`serial` = toString(36305840) and `me`.`id` = toUInt64(`med`.`meter_elec_id`)  WHERE `puttime` BETWEEN toDateTime(1652776857) - interval 1 hour AND toDateTime(1652949659) GROUP BY `med`.`meter_elec_id`, `me`.`ratio`'
docker exec -i $ID_CLICKHOUSE clickhouse-client --database=conv --query='SELECT 1 FROM `meter_elec_data` med INNER JOIN `meter_elec` `me` ON `me`.`serial` = toString(36305840) and `me`.`id` = toUInt64(`med`.`meter_elec_id`)  WHERE `puttime` BETWEEN toDateTime(1652776857) - interval 1 hour AND toDateTime(1652949659) GROUP BY `med`.`meter_elec_id`, `me`.`ratio`'
docker exec -i $ID_CLICKHOUSE clickhouse-client --database=conv --query='SELECT 1 FROM `meter_elec_data` med INNER JOIN `meter_elec` `me` ON `me`.`serial` = toString(36305840) and `me`.`id` = toUInt64(`med`.`meter_elec_id`)  WHERE `puttime` BETWEEN toDateTime(1652776857) - interval 1 hour AND toDateTime(1652949659) GROUP BY `med`.`meter_elec_id`, `me`.`ratio`'

docker-compose down

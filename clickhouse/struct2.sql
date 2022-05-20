
CREATE DICTIONARY conv.meter_elec
(
    `id` UInt64,
    `type` UInt8,
    `serial` String,
    `addr` String,
    `ip` UInt32,
    `port` UInt16,
    `desc` String,
    `ratio` UInt32 EXPRESSION round(ratio * 1000)
)
PRIMARY KEY id
SOURCE(MYSQL(HOST 'mysql' PORT 3306 USER 'root' PASSWORD 'root' DB 'conv' TABLE 'meter_elec'))
LIFETIME(MIN 30 MAX 60)
LAYOUT(HASHED())

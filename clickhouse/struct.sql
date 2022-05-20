
CREATE TABLE conv.meter_elec_data
(
    `puttime` DateTime DEFAULT now(),
    `meter_elec_id` UInt32,
    `active` Int64,
    `active_f1` Int64,
    `active_f2` Int64,
    `active_f3` Int64,
    `reactive` Int64,
    `voltage` Int16
)
    ENGINE = MergeTree
PARTITION BY toYYYYMM(puttime)
ORDER BY (puttime, meter_elec_id)
SETTINGS index_granularity = 8192

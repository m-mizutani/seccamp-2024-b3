WITH
recent_logs AS (
    SELECT *
    FROM
        `mztn-seccamp-2024.secmon_vermilion.logs`
    WHERE
        timestamp BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 MINUTE)
        AND CURRENT_TIMESTAMP()
    LIMIT
        10000
),

final AS (
    SELECT
        recent_logs.user,
        recent_logs.remote,
        recent_logs.timestamp
    FROM
        `mztn-seccamp-2024.secmon_vermilion.ioc` AS ioc
    INNER JOIN
        recent_logs
        ON
            ioc.value = recent_logs.remote
)

SELECT *
FROM
    final;

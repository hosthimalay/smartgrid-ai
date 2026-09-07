-- Hourly demand profile over the last seven days.
SELECT
  site_id,
  date_trunc('hour', from_iso8601_timestamp(timestamp)) AS reading_hour,
  avg(power_kw) AS average_power_kw,
  max(power_kw) AS peak_power_kw,
  sum(solar_generation_kw) AS solar_generation_kw
FROM raw_telemetry
WHERE from_iso8601_timestamp(timestamp) >= current_timestamp - INTERVAL '7' DAY
GROUP BY 1, 2
ORDER BY 2 DESC, 1;

-- Data-quality check: required identifiers or physically invalid readings.
SELECT *
FROM raw_telemetry
WHERE site_id IS NULL OR device_id IS NULL OR power_kw < 0 OR voltage < 0;


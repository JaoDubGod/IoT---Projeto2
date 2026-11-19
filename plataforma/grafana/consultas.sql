-- MySQL datasource: mysql-db:3306 | DB fei | usuário grafana
-- Painel a: duas consultas (temperature e relativeHumidity) no mesmo gráfico.
SELECT CAST(recvTime AS DATETIME(3)) AS time,
       CAST(attrValue AS DECIMAL(6,1)) AS temperature
FROM estufa
WHERE attrName = 'temperature' AND $__timeFilter(recvTime)
ORDER BY time;

SELECT CAST(recvTime AS DATETIME(3)) AS time,
       CAST(attrValue AS DECIMAL(6,1)) AS relativeHumidity
FROM estufa
WHERE attrName = 'relativeHumidity' AND $__timeFilter(recvTime)
ORDER BY time;

-- Painel b: umidade do solo
SELECT CAST(recvTime AS DATETIME(3)) AS time,
       CAST(attrValue AS DECIMAL(6,1)) AS soilMoisture
FROM estufa
WHERE attrName = 'soilMoisture' AND $__timeFilter(recvTime)
ORDER BY time;

-- Painel c: State timeline do relé (formato Table)
SELECT CAST(recvTime AS DATETIME(3)) AS time,
       IF(attrValue = '1', 'ligado', 'desligado') AS relay
FROM estufa
WHERE attrName = 'relayState' AND $__timeFilter(recvTime)
ORDER BY time;

-- Painel d: Stat/Gauge para valor mais recente de luminosidade
SELECT CAST(attrValue AS DECIMAL(6,1)) AS illuminance
FROM estufa
WHERE attrName = 'illuminance'
ORDER BY CAST(recvTimeTs AS UNSIGNED) DESC
LIMIT 1;

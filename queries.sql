--landing
select * from delta.`/Volumes/bridge_monitoring/00_landing/streaming/puente_temperatura/`;
select * from delta.`/Volumes/bridge_monitoring/00_landing/streaming/puente_inclinacion/`;
select * from delta.`/Volumes/bridge_monitoring/00_landing/streaming/puente_vibracion/`;

--bronze
select * from bridge_monitoring.`01_bronze`.puente_temperatura order by event_time desc;
select * from bridge_monitoring.`01_bronze`.puente_inclinacion order by event_time desc;
select * from bridge_monitoring.`01_bronze`.puente_vibracion order by event_time desc;

--silver
select * from bridge_monitoring.`02_silver`.puente_temperatura order by event_time desc;
select * from bridge_monitoring.`02_silver`.puente_inclinacion order by event_time desc;
select * from bridge_monitoring.`02_silver`.puente_vibracion order by event_time desc;

--gold
select * from bridge_monitoring.`03_gold`.puente_metrics order by window_start desc;



-- Insertar valores de prueba 
insert into delta.`/Volumes/bridge_monitoring/00_landing/streaming/puente_temperatura/` values('1', NULL, 20);

insert into delta.`/Volumes/bridge_monitoring/00_landing/streaming/puente_temperatura/` values('1', '2025-11-13T14:33:00.610', 65);





-- BRONZE
DROP TABLE IF EXISTS bridge_monitoring.`01_bronze`.puente_temperatura;
DROP TABLE IF EXISTS bridge_monitoring.`01_bronze`.puente_inclinacion;
DROP TABLE IF EXISTS bridge_monitoring.`01_bronze`.puente_vibracion;

-- SILVER
DROP TABLE IF EXISTS bridge_monitoring.`02_silver`.puente_temperatura;
DROP TABLE IF EXISTS bridge_monitoring.`02_silver`.puente_inclinacion;
DROP TABLE IF EXISTS bridge_monitoring.`02_silver`.puente_vibracion;
DROP TABLE IF EXISTS bridge_monitoring.`02_silver`.puente_metadata;

-- GOLD
DROP TABLE IF EXISTS bridge_monitoring.`03_gold`.puente_metrics;
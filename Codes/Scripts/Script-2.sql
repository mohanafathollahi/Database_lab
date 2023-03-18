CREATE VIEW LogBookReporting_A_M_P AS 
SELECT l.AircraftID AS aircraft, l.monthID AS MONTH, l.personID as person
    , SUM(CASE WHEN p.role='P' THEN counter ELSE 0 END) AS PIREP
    , SUM(CASE WHEN p.role='M' THEN counter ELSE 0 END) AS MAREP
FROM LogBookReporting l, peopleDimension p 
WHERE l.personID=p.ID
GROUP BY l.aircraftID, l.monthID, l.personID;

CREATE VIEW AircraftUtilization_A_M AS 
SELECT a.AircraftID AS aircraft, t.monthID AS month
    , SUM(a.flightHours) AS FH
    , SUM(a.flightCycles) AS FC
	, COUNT(DISTINCT t.ID)-SUM(a.scheduledOutOfService)-SUM(a.unscheduledOutOfService) AS ADIS
	, SUM(a.scheduledOutOfService) AS ADOSS
	, SUM(a.unscheduledOutOfService) AS ADOSU
	, SUM(delays) AS DY
	, SUM(delayedMinutes) AS delayedMinutes
	, SUM(cancellations) AS CN
FROM AircraftUtilization a, TemporalDimension t
WHERE a.timeID=t.ID
GROUP BY a.AircraftID, t.monthID;
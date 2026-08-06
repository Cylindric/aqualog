SELECT * FROM alembic_version;
SELECT * FROM aquariums;
SELECT * FROM aquarium_measurements;
SELECT * FROM parameters;
SELECT * FROM units;
SELECT * FROM parameter_units;

;
SELECT a.name, am.measured_at, p.display_name, am.value, u.unit
FROM aquariums a
JOIN aquarium_measurements am ON a.id=am.aquarium_id
JOIN parameters p ON am.parameter_id=p.id
JOIN units u ON am.unit_id=u.id
;
SELECT p.display_name AS "Parameter", u.unit AS "Units", pu.is_canonical
FROM parameters p
JOIN parameter_units pu ON p.id=pu.parameter_id
JOIN units u ON pu.unit_id=u.id
;
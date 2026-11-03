-- Ridango fork: the internal agent's display name is 'Ridango GDPR Safe'
-- (045 set it to 'Ridango Agent'; applied migrations are immutable, so this
-- renames on top). Only rows still carrying either earlier name change.
UPDATE agent_metadata
SET name = 'Ridango GDPR Safe',
    updated_at = CAST(strftime('%s', 'now') AS INTEGER) * 1000
WHERE id = '632f31d2' AND agent_source = 'internal' AND name IN ('Aion CLI', 'Ridango Agent');

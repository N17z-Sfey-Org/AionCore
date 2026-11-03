-- Ridango fork: rename the user-visible identifiers that upstream stores in
-- the database. Upstream migrations are immutable (sqlx checksums), so this
-- runs on top of them and only touches rows that still carry the old values.
--
--   * Internal agent 632f31d2 display name: 'Aion CLI' -> 'Ridango Agent'.
--     001 seeds the vendor name and nothing refreshes it at startup; the
--     generated `bare:632f31d2` assistant definition follows the agent name
--     on the next bootstrap.
--   * Built-in skill 'aionui-config' -> 'ridango-config' wherever its name is
--     stored: the global skill catalog (the old row would otherwise linger as
--     a stale entry whose path no longer exists), built-in assistant defaults,
--     legacy assistant rows, conversation snapshots and per-conversation
--     `extra.skills` lists.
--   * The built-in assistant keeps its id 'aionui-assistant'; its name and
--     skill list are manifest-owned and re-synced at every startup.

UPDATE agent_metadata
SET name = 'Ridango Agent',
    updated_at = CAST(strftime('%s', 'now') AS INTEGER) * 1000
WHERE id = '632f31d2' AND agent_source = 'internal' AND name = 'Aion CLI';

UPDATE skills
SET name = 'ridango-config',
    path = replace(path, 'aionui-config', 'ridango-config'),
    updated_at = CAST(strftime('%s', 'now') AS INTEGER) * 1000
WHERE user_id IS NULL AND source = 'builtin' AND name = 'aionui-config'
  AND NOT EXISTS (SELECT 1 FROM skills s WHERE s.user_id IS NULL AND s.name = 'ridango-config');

DELETE FROM skills
WHERE user_id IS NULL AND source = 'builtin' AND name = 'aionui-config';

UPDATE assistant_definitions
SET default_skill_ids = replace(default_skill_ids, '"aionui-config"', '"ridango-config"'),
    default_disabled_builtin_skill_ids = replace(default_disabled_builtin_skill_ids, '"aionui-config"', '"ridango-config"'),
    updated_at = CAST(strftime('%s', 'now') AS INTEGER) * 1000
WHERE default_skill_ids LIKE '%"aionui-config"%'
   OR default_disabled_builtin_skill_ids LIKE '%"aionui-config"%';

UPDATE assistants
SET enabled_skills = replace(enabled_skills, '"aionui-config"', '"ridango-config"'),
    disabled_builtin_skills = replace(disabled_builtin_skills, '"aionui-config"', '"ridango-config"')
WHERE enabled_skills LIKE '%"aionui-config"%'
   OR disabled_builtin_skills LIKE '%"aionui-config"%';

UPDATE conversation_assistant_snapshots
SET resolved_skill_ids = replace(resolved_skill_ids, '"aionui-config"', '"ridango-config"')
WHERE resolved_skill_ids LIKE '%"aionui-config"%';

UPDATE conversations
SET extra = replace(extra, '"aionui-config"', '"ridango-config"')
WHERE extra LIKE '%"aionui-config"%';

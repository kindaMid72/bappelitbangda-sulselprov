-- Privilege tests. Tables the app must not edit or delete (for example the access log, NFR-08) get a check here.
-- Skeleton baseline: the runtime role must not be able to create objects.
DO $$
BEGIN
  ASSERT NOT has_schema_privilege('app', 'public', 'CREATE'),
    'role app must not be able to create objects in schema public';
  ASSERT NOT has_database_privilege('app', current_database(), 'CREATE'),
    'role app must not be able to create schemas';
END
$$;

-- PostgreSQL startup script — runs on EVERY container start.
-- All app databases/users are created here (idempotent).

-- === litellm ===
SELECT 'CREATE DATABASE litellm'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'litellm')
\gexec

DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'llmproxy') THEN
    CREATE USER llmproxy WITH PASSWORD 'dbpassword9090';
  END IF;
END $$;

GRANT ALL PRIVILEGES ON DATABASE litellm TO llmproxy;

-- Grant schema permissions (needed for creating tables)
\c litellm
GRANT ALL ON SCHEMA public TO llmproxy;
\c postgres

-- === Add other services below ===
-- SELECT 'CREATE DATABASE my_app'
--   WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'my_app')
-- \gexec

-- DO $$ BEGIN
--   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'my_app_user') THEN
--     CREATE USER my_app_user WITH PASSWORD 'strong_password';
--   END IF;
-- END $$;

-- GRANT ALL PRIVILEGES ON DATABASE my_app TO my_app_user;
-- \c my_app
-- GRANT ALL ON SCHEMA public TO my_app_user;
-- \c postgres

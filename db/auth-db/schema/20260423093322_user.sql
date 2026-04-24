-- +goose Up
CREATE TABLE IF NOT EXISTS users(
  id         BIGSERIAL  PRIMARY KEY ,
  email      TEXT       UNIQUE NOT NULL,
  password   TEXT       NOT NULL,
  first_name TEXT       NOT NULL,
  last_name  TEXT       NOT NULL,
  phone      TEXT,

  is_active  BOOLEAN    NOT NULL DEFAULT TRUE,
  role       USER_ROLE  NOT NULL DEFAULT 'customer',
  
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users (deleted_at);
SELECT set_updated_at('users');


-- +goose Down
-- DROP TABLE IF EXISTS users;

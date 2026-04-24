-- +goose Up
CREATE TYPE USER_ROLE AS ENUM ('admin', 'customer');

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION automatic_update_property()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION set_updated_at(_tbl regclass)
RETURNS void AS $$
BEGIN
  EXECUTE format('DROP FUNCTION IF EXISTS automatic_updated_at ON %s;', _tbl);
  EXECUTE format('
    CREATE TRIGGER automatic_updated_at
    BEFORE UPDATE ON %s
    FOR EACH ROW
    EXECUTE FUNCTION automatic_update_property();
  ', _tbl);
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
-- DROP FUNCTION IF EXISTS set_updated_at;
-- DROP FUNCTION IF EXISTS automatic_update_property;
-- DROP TYPE IF EXISTS USER_ROLE;
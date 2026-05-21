-- +goose Up
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
  EXECUTE format('DROP TRIGGER IF EXISTS automatic_updated_at ON %s', _tbl);
  EXECUTE format('
    CREATE TRIGGER automatic_udpated_at
    BEFORE UPDATE ON %s
    FOR EACH ROW
    EXECUTE FUNCTION automatic_update_property();
  ', _tbl);
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- +goose Down
SELECT 'down SQL query';

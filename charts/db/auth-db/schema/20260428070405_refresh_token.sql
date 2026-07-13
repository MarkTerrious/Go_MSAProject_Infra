-- +goose Up
CREATE TABLE refresh_tokens (
  id          BIGSERIAL     PRIMARY KEY, 
  user_id     BIGSERIAL     NOT NULL,
  token       TEXT          UNIQUE      NOT NULL,
  expires_at  TIMESTAMPTZ   NOT NULL,
  created_at  TIMESTAMPTZ   NOT NULL    DEFAULT NOW(),   
  deleted_at  TIMESTAMPTZ,

  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_r_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_r_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_r_tokens_deleted_at ON refresh_tokens(deleted_at);

-- +goose Down
DROP TABLE IF EXISTS refresh_tokens;

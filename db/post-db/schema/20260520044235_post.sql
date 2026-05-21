-- +goose Up
CREATE TABLE IF NOT EXISTS posts(
  id          BIGINT       PRIMARY KEY,
  user_id     BIGINT       NOT NULL,
  title       text         NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_post_user_id ON posts(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_post_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_post_deleted_at ON posts(deleted_at);

SELECT set_updated_at('posts');

CREATE TABLE IF NOT EXISTS post_contents(
  id       BIGINT      PRIMARY KEY,
  post_id  BIGINT      NOT NULL,
  content  TEXT        NOT NULL,
  order_no SMALLINT    NOT NULL,

  CONSTRAINT fk_post_contents_post_id
    FOREIGN KEY (post_id) 
    REFERENCES posts(id) 
    ON DELETE CASCADE,

  CONSTRAINT fk_post_contents_unique
    UNIQUE (post_id, order_no)
);
CREATE INDEX IF NOT EXISTS idx_post_contents_post ON post_contents(post_id, order_no);

CREATE TYPE FORMAT_TYPE AS ENUM('image', 'video');
CREATE TABLE IF NOT EXISTS post_media(
  id        BIGINT      PRIMARY KEY,
  post_id   BIGINT      NOT NULL,
  format    FORMAT_TYPE NOT NULL,
  furl      TEXT        NOT NULL,
  order_no  SMALLINT    NOT NULL,

  CONSTRAINT fk_post_media_post_id
    FOREIGN KEY (post_id)
    REFERENCES posts(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_post_media_unique
    UNIQUE (post_id, order_no)
);

CREATE INDEX IF NOT EXISTS idx_pmd_post ON post_media(post_id, order_no);


-- +goose Down
SELECT 'down SQL query';

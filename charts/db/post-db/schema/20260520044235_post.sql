-- +goose Up
CREATE TABLE IF NOT EXISTS posts(
  id          BIGINT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id     BIGINT       NOT NULL,
  title       text         NOT NULL,
  comment_num INT          NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_post_user_id ON posts(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_post_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_post_deleted_at ON posts(deleted_at);

SELECT set_updated_at('posts');

CREATE TYPE FORMAT_TYPE AS ENUM('text', 'image', 'url');
CREATE TABLE IF NOT EXISTS post_contents(
  id       BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  post_id  BIGINT      NOT NULL,
  image_id BIGINT,
  format   FORMAT_TYPE NOT NULL,
  content  TEXT        NOT NULL,
  order_no SMALLINT    NOT NULL,

  CONSTRAINT fk_post_contents_post_id
    FOREIGN KEY (post_id) 
    REFERENCES posts(id) 
    ON DELETE CASCADE,

  CONSTRAINT fk_post_contents_unique
    UNIQUE (post_id, order_no)
);
CREATE INDEX IF NOT EXISTS idx_post_contents_multi_post ON post_contents(post_id, format, order_no);
CREATE INDEX IF NOT EXISTS idx_post_contents_post ON post_contents(post_id, order_no);

CREATE TYPE IMAGE_STATUS AS ENUM('pending', 'completed', 'cancel');
CREATE TABLE IF NOT EXISTS images(
  id          BIGINT        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id     BIGINT        NOT NULL,
  category    TEXT          NOT NULL,
  istatus     IMAGE_STATUS  NOT NULL,
  origin_name TEXT          NOT NULL,
  stored_name TEXT          NOT NULL,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT images_stored_name_unique
    UNIQUE (stored_name)
);

-- Upload Index
CREATE INDEX IF NOT EXISTS idx_img_user ON images(id, user_id, istatus);
-- Select Index
CREATE INDEX IF NOT EXISTS idx_img_istatus ON images(istatus);

-- +goose Down
DROP TYPE FORMAT_TYPE;
DROP TYPE IMAGE_STATUS;

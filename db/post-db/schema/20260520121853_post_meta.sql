-- +goose Up

CREATE TABLE IF NOT EXISTS post_comments(
  id          BIGINT PRIMARY KEY,
  post_id     BIGINT NOT NULL,
  user_id     BIGINT NOT NULL,
  refer_id    BIGINT,
  comment     TEXT NOT NULL,
  lv          SMALLINT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ,

  CONSTRAINT fk_post_comments_post
    FOREIGN KEY (post_id)
    REFERENCES posts(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_post_comments_refer
    FOREIGN KEY (refer_id)
    REFERENCES post_comments(id)
    ON DELETE SET NULL,
  CONSTRAINT chk_lv CHECK (lv IN (0, 1, 2)),
  CONSTRAINT chk_refer CHECK ( lv = 0 OR refer_id IS NOT NULL )
);

SELECT set_updated_at('post_comments');

CREATE INDEX IF NOT EXISTS idx_post_comments_post ON post_comments(post_id, refer_id, created_at);
CREATE INDEX IF NOT EXISTS idx_post_comments_user ON post_comments(user_id, created_at);

CREATE TABLE IF NOT EXISTS post_likes(
  post_id     BIGINT  NOT NULL,
  user_id     BIGINT  NOT NULL,
  stat        BOOLEAN NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  PRIMARY KEY (post_id, user_id),
  CONSTRAINT fk_post_likes_post
    FOREIGN KEY (post_id)
    REFERENCES posts(id)
    ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_post_likes_post ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user ON post_likes(user_id, created_at);


-- +goose Down
SELECT 'down SQL query';

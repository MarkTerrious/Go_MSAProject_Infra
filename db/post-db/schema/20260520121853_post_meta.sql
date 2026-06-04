-- +goose Up
CREATE TABLE IF NOT EXISTS post_comments(
  id          BIGINT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  post_id     BIGINT  NOT NULL,
  user_id     BIGINT  NOT NULL,
  refer_id    BIGINT,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ,

  CONSTRAINT fk_post_comments_post
    FOREIGN KEY (post_id)
    REFERENCES posts(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_post_comments_refer
    FOREIGN KEY (refer_id)
    REFERENCES post_comments(id)
    ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_post_comments_post ON post_comments(post_id, refer_id, created_at);
CREATE INDEX IF NOT EXISTS idx_post_comments_user ON post_comments(user_id, created_at);
SELECT set_updated_at('post_comments');

CREATE TABLE IF NOT EXISTS comments_block(
  id          BIGINT        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  comment_id  BIGINT        NOT NULL,
  format      FORMAT_TYPE   NOT NULL,  
  content     TEXT          NOT NULL,
  order_no    SMALLINT      NOT NULL,

  CONSTRAINT fk_comments_block_cmt_id
    FOREIGN KEY (comment_id)
    REFERENCES post_comments(id)
    ON DELETE CASCADE,
  CONSTRAINT comments_block_unique
    UNIQUE (comment_id, order_no)
);

CREATE INDEX IF NOT EXISTS idx_comments_block_cmt_id ON comments_block(comment_id, order_no);

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

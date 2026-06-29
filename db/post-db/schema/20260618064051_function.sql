-- +goose Up

-- 게시판 Like 관련 함수
-- #region post_like_toggle
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION post_like_toggle(
  p_post_id BIGINT,
  p_user_id BIGINT,
  p_stat    BOOLEAN
) RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  d_stat    BOOLEAN;
  d_exists  BOOLEAN := FALSE;
BEGIN
  -- post_like 에 유저가 like, unlike 준 적 있는지 확인
  SELECT stat INTO d_stat
  FROM post_likes
  WHERE (post_id, user_id) = (p_post_id, p_user_id);

  -- 최근 SELECT 가 성공했는지 여부를 가져온다.
  d_exists := FOUND;

  -- Table의 User Like 존재 여부
  IF d_exists THEN
    -- 존재 시 같으면 삭제
    IF d_stat = p_stat THEN
      DELETE FROM post_likes WHERE (post_id, user_id) = (p_post_id, p_user_id);
    -- 같지 않으면 업데이트
    ELSE
      UPDATE post_likes
      SET stat = p_stat
      WHERE (post_id, user_id) = (p_post_id, p_user_id);
    END IF;
  ELSE
    -- 존재 x시 생성
    INSERT INTO post_likes (post_id, user_id, stat)
    VALUES (p_post_id, p_user_id, p_stat);
  END IF;
END;
$$;
-- +goose StatementEnd
-- #endregion

-- 게시판 내용 수정 함수
-- #region UpdatePostFunction
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION update_post_function(
  p_post_id   BIGINT,
  p_user_id   BIGINT,
  p_title     TEXT,
  p_image_ids BIGINT[],
  p_formats   FORMAT_TYPE[],
  p_contents  TEXT[],
  p_order_nos SMALLINT[]
) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  -- posts 행 잠금 (동시 수정 방지)
  PERFORM id FROM posts WHERE id = p_post_id FOR UPDATE;

  -- 제목 변경
  UPDATE posts
  SET title = p_title
  WHERE 
    id = p_post_id AND 
    user_id = p_user_id;

  -- IMAGE 삭제
  UPDATE images
  SET istatus = 'cancel'
  WHERE
    id IN (
      SELECT image_id FROM post_contents
      WHERE
        post_id = p_post_id AND
        image_id IS NOT NULL
    ) AND
    id != ALL(p_image_ids) AND
    user_id = p_user_id;

  -- IMAGE 업데이트
  UPDATE images
  SET istatus = 'completed'
  WHERE
    user_id = p_user_id AND
    istatus = 'pending' AND
    id = ANY(p_image_ids);

  -- 게시판 내용 삭제
  DELETE FROM post_contents
  WHERE post_id = p_post_id;

  -- 게시판 내용 새로 생성
  INSERT INTO post_contents(post_id, image_id, format, content, order_no)
  SELECT
    p_post_id,
    unnest(p_image_ids),
    unnest(p_formats::FORMAT_TYPE[]),
    unnest(p_contents),
    unnest(p_order_nos);
END;
$$;
-- +goose StatementEnd
-- #endregion

-- 게시판 댓글 내용 수정 함수
-- #region UpdateCommentFunction
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION update_comment_function(
  p_user_id     BIGINT,
  p_comment_id  BIGINT,
  p_image_ids   BIGINT[],
  p_formats     FORMAT_TYPE[],
  p_content     TEXT[],
  p_order_nos   SMALLINT[]
) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  -- Validation 해당 댓글이 유저가 작성한 것이 맞는가
  PERFORM id FROM post_comments
  WHERE id = p_comment_id AND user_id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'comment % does not belong to user %', p_comment_id, p_user_id;
  END IF;

  RAISE NOTICE 'POST LOCK';

  -- 기존 이미지 삭제
  UPDATE images
  SET istatus = 'cancel'
  WHERE
    id IN (
      SELECT image_id FROM comments_block
      WHERE
        comment_id = p_comment_id AND
        image_id IS NOT NULL
    ) AND
    id != ALL(p_image_ids) AND
    user_id = p_user_id;

  RAISE NOTICE 'Image 삭제';

  -- 업데이트
  UPDATE images
  SET istatus = 'completed'
  WHERE
    user_id = p_user_id AND
    istatus = 'pending' AND
    id = ANY(p_image_ids);

  RAISE NOTICE 'Image Update';

  -- 기존 댓글 내용 삭제
  DELETE FROM comments_block
  WHERE comment_id = p_comment_id;

  -- 새 댓글 내용 생성
  INSERT INTO comments_block (comment_id, image_id, format, content, order_no)
  SELECT
    p_comment_id,
    unnest(p_image_ids),
    unnest(p_formats::FORMAT_TYPE[]),
    unnest(p_content),
    unnest(p_order_nos);
END;
$$;
-- +goose StatementEnd
-- #endregion

-- +goose Down
DROP FUNCTION IF EXISTS post_like_toggle(BIGINT, BIGINT, BOOLEAN);
DROP FUNCTION IF EXISTS update_post_function(BIGINT, BIGINT, BIGINT[], TEXT[], TEXT[], SMALLINT[]);
DROP FUNCTION IF EXISTS update_comment_function(BIGINT, BIGINT, BIGINT, BIGINT[], TEXT[], TEXT[], SMALLINT[]);

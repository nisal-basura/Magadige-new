-- ============================================================================
-- MAGADIGE TASK — Relational Database Design (PostgreSQL)
-- Backs both the web front end and the Flutter app via a shared REST/GraphQL
-- API. Mirrors the current localStorage demo data model 1:1 so the eventual
-- API layer is a drop-in replacement for js/data.js, js/admin-data.js,
-- js/quotes.js and js/seasonal.js.
-- ============================================================================

CREATE TYPE user_role      AS ENUM ('user', 'admin');
CREATE TYPE user_plan      AS ENUM ('Free', 'Pro', 'Team');
CREATE TYPE theme_pref     AS ENUM ('day', 'night', 'auto');
CREATE TYPE task_priority  AS ENUM ('low', 'medium', 'high');
CREATE TYPE task_status    AS ENUM ('pending', 'in-progress', 'completed', 'overdue');
CREATE TYPE reminder_type  AS ENUM ('none', '10m', '1h', '1d');
CREATE TYPE repeat_type    AS ENUM ('none', 'daily', 'weekly', 'monthly');
CREATE TYPE notif_type     AS ENUM ('reminder', 'achievement', 'dream', 'summary', 'comment', 'system');
CREATE TYPE activity_type  AS ENUM ('complete', 'create', 'dream', 'badge', 'overdue');
CREATE TYPE quote_mood     AS ENUM ('morning', 'afternoon', 'evening', 'night', 'calm', 'momentum',
                                    'struggle', 'complete', 'work', 'learning', 'dream', 'overdue');
CREATE TYPE seasonal_theme AS ENUM ('none', 'christmas', 'newyear');

-- ----------------------------------------------------------------------------
-- Users (regular users AND admins — distinguished by role, not a separate table)
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(120)  NOT NULL,
    email               VARCHAR(160)  NOT NULL UNIQUE,
    password_hash       VARCHAR(255)  NOT NULL,
    avatar_url          VARCHAR(255),
    role                user_role     NOT NULL DEFAULT 'user',
    plan                user_plan     NOT NULL DEFAULT 'Free',
    headline            VARCHAR(160),                     -- e.g. "Product Designer @ Northwind Labs"
    timezone            VARCHAR(60),
    theme_preference    theme_pref    NOT NULL DEFAULT 'auto',
    streak_current      INT           NOT NULL DEFAULT 0,
    streak_longest      INT           NOT NULL DEFAULT 0,
    productivity_score  SMALLINT      NOT NULL DEFAULT 0,
    is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),   -- = "joined" for admin growth stats
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_plan       ON users(plan);

-- ----------------------------------------------------------------------------
-- Lookup: task categories
-- ----------------------------------------------------------------------------
CREATE TABLE categories (
    id     VARCHAR(30) PRIMARY KEY,      -- 'work' | 'personal' | 'health' | 'learning' | 'finance'
    label  VARCHAR(60) NOT NULL,
    color  VARCHAR(30) NOT NULL,
    icon   VARCHAR(30) NOT NULL
);

-- ----------------------------------------------------------------------------
-- Dreams (Dream Board)
-- ----------------------------------------------------------------------------
CREATE TABLE dreams (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title        VARCHAR(160) NOT NULL,
    emoji        VARCHAR(10),
    motivation   TEXT,
    target_date  DATE,
    progress     SMALLINT NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    color        VARCHAR(30),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_dreams_user ON dreams(user_id);

-- ----------------------------------------------------------------------------
-- Tasks
-- ----------------------------------------------------------------------------
CREATE TABLE tasks (
    id                BIGSERIAL PRIMARY KEY,
    user_id           BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id       VARCHAR(30) NOT NULL REFERENCES categories(id),
    dream_id          BIGINT REFERENCES dreams(id) ON DELETE SET NULL,   -- optional "related dream"
    title             VARCHAR(200) NOT NULL,
    description       TEXT,
    priority          task_priority NOT NULL DEFAULT 'medium',
    status            task_status   NOT NULL DEFAULT 'pending',
    due_date          DATE,
    estimate_minutes  INT,                        -- store as minutes; format "1h 30m" at the UI layer
    progress          SMALLINT NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    is_favorite       BOOLEAN NOT NULL DEFAULT FALSE,
    color_tag         VARCHAR(10),
    reminder          reminder_type NOT NULL DEFAULT 'none',
    repeat_rule       repeat_type   NOT NULL DEFAULT 'none',
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at      TIMESTAMPTZ,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_tasks_user_status ON tasks(user_id, status);
CREATE INDEX idx_tasks_due_date    ON tasks(due_date);
CREATE INDEX idx_tasks_dream       ON tasks(dream_id);

-- ----------------------------------------------------------------------------
-- Subtasks (checklist items within a task)
-- ----------------------------------------------------------------------------
CREATE TABLE subtasks (
    id        BIGSERIAL PRIMARY KEY,
    task_id   BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    title     VARCHAR(200) NOT NULL,
    is_done   BOOLEAN NOT NULL DEFAULT FALSE,
    position  SMALLINT NOT NULL DEFAULT 0
);
CREATE INDEX idx_subtasks_task ON subtasks(task_id);

-- ----------------------------------------------------------------------------
-- Tags (many-to-many with tasks)
-- ----------------------------------------------------------------------------
CREATE TABLE tags (
    id     BIGSERIAL PRIMARY KEY,
    label  VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE task_tags (
    task_id  BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    tag_id   BIGINT NOT NULL REFERENCES tags(id)  ON DELETE CASCADE,
    PRIMARY KEY (task_id, tag_id)
);

-- ----------------------------------------------------------------------------
-- Attachments
-- ----------------------------------------------------------------------------
CREATE TABLE attachments (
    id               BIGSERIAL PRIMARY KEY,
    task_id          BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    file_name        VARCHAR(255) NOT NULL,
    file_url         VARCHAR(500) NOT NULL,
    file_size_bytes  BIGINT,
    mime_type        VARCHAR(120),
    uploaded_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_attachments_task ON attachments(task_id);

-- ----------------------------------------------------------------------------
-- Badges (global catalog) + per-user earned/progress state
-- ----------------------------------------------------------------------------
CREATE TABLE badges (
    id           VARCHAR(30) PRIMARY KEY,      -- 'b1', 'b2', ...
    label        VARCHAR(80) NOT NULL,
    icon         VARCHAR(30) NOT NULL,
    description  VARCHAR(255) NOT NULL
);

CREATE TABLE user_badges (
    user_id      BIGINT NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    badge_id     VARCHAR(30) NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned       BOOLEAN NOT NULL DEFAULT FALSE,
    earned_date  DATE,
    progress     SMALLINT CHECK (progress BETWEEN 0 AND 100),
    PRIMARY KEY (user_id, badge_id)
);

-- ----------------------------------------------------------------------------
-- Notifications
-- ----------------------------------------------------------------------------
CREATE TABLE notifications (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(160) NOT NULL,
    body        VARCHAR(400) NOT NULL,
    type        notif_type NOT NULL,
    is_unread   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_unread);

-- ----------------------------------------------------------------------------
-- Activity feed
-- ----------------------------------------------------------------------------
CREATE TABLE activity_log (
    id                BIGSERIAL PRIMARY KEY,
    user_id           BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type              activity_type NOT NULL,
    description       VARCHAR(255) NOT NULL,
    related_task_id   BIGINT REFERENCES tasks(id)  ON DELETE SET NULL,
    related_dream_id  BIGINT REFERENCES dreams(id) ON DELETE SET NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_activity_user ON activity_log(user_id, created_at DESC);

-- ----------------------------------------------------------------------------
-- Inspiration quotes (admin-managed) + moods (many-to-many)
-- ----------------------------------------------------------------------------
CREATE TABLE quotes (
    id          BIGSERIAL PRIMARY KEY,
    text        TEXT NOT NULL,
    author      VARCHAR(120) NOT NULL DEFAULT 'Unknown',
    is_custom   BOOLEAN NOT NULL DEFAULT TRUE,       -- FALSE = seeded/built-in library quote
    created_by  BIGINT REFERENCES users(id) ON DELETE SET NULL,  -- admin who published it
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE quote_moods (
    quote_id  BIGINT NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    mood      quote_mood NOT NULL,
    PRIMARY KEY (quote_id, mood)
);

-- ----------------------------------------------------------------------------
-- Site-wide seasonal effect toggle (admin dashboard; enforced single row)
-- ----------------------------------------------------------------------------
CREATE TABLE seasonal_settings (
    id            SMALLINT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    active_theme  seasonal_theme NOT NULL DEFAULT 'none',
    updated_by    BIGINT NOT NULL REFERENCES users(id),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------------------------
-- Seed the fixed category lookup (matches js/data.js MDG.CATEGORIES)
-- ----------------------------------------------------------------------------
INSERT INTO categories (id, label, color, icon) VALUES
    ('work',     'Work',     'indigo', 'briefcase'),
    ('personal', 'Personal', 'sky',    'user'),
    ('health',   'Health',   'mint',   'heart'),
    ('learning', 'Learning', 'amber',  'book'),
    ('finance',  'Finance',  'gray',   'wallet');

-- ============================================================
-- graddu.com official website schema
-- Database: official_website
-- ============================================================

CREATE TABLE IF NOT EXISTS contacts (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL,
    contact     VARCHAR(200)  NOT NULL,
    message     TEXT          NOT NULL,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS news (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(300)  NOT NULL,
    summary     VARCHAR(1000) NOT NULL DEFAULT '',
    content     TEXT          NOT NULL DEFAULT '',
    published   TINYINT(1)    NOT NULL DEFAULT 1,
    created_at  DATE          NOT NULL DEFAULT (CURRENT_DATE),
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed default news if table is empty
INSERT IGNORE INTO news (id, title, summary, created_at) VALUES
(1, '官网第一版发布', '官网已上线公司概况、技术方案与下载模块。', '2026-03-10'),
(2, 'WebRTC 实时互动方案升级', '新增弱网优化策略与端到端时延监控能力。', '2026-03-08'),
(3, 'AI 实时交互能力上线', '提供语音识别、问答与实时反馈接口。', '2026-03-05');

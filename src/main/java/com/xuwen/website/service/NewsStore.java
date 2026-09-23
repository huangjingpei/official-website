package com.xuwen.website.service;

import com.xuwen.website.dto.NewsItem;
import com.xuwen.website.dto.NewsRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;

@Service
public class NewsStore {

    private final JdbcTemplate jdbc;

    private static final RowMapper<NewsItem> ROW_MAPPER = (rs, rowNum) -> {
        java.sql.Date sqlDate = rs.getDate("created_at");
        LocalDate date = sqlDate != null ? sqlDate.toLocalDate() : null;
        return new NewsItem(
                rs.getLong("id"),
                rs.getString("title"),
                rs.getString("summary"),
                rs.getString("content"),
                rs.getBoolean("published"),
                date
        );
    };

    public NewsStore(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** Public list: only published items, newest first */
    public List<NewsItem> listPublished() {
        return jdbc.query(
                "SELECT id, title, summary, content, published, created_at FROM news WHERE published = 1 ORDER BY created_at DESC, id DESC",
                ROW_MAPPER
        );
    }

    /** Admin list: all items */
    public List<NewsItem> listAll() {
        return jdbc.query(
                "SELECT id, title, summary, content, published, created_at FROM news ORDER BY created_at DESC, id DESC",
                ROW_MAPPER
        );
    }

    public Optional<NewsItem> findById(Long id) {
        List<NewsItem> result = jdbc.query(
                "SELECT id, title, summary, content, published, created_at FROM news WHERE id = ?",
                ROW_MAPPER, id
        );
        return result.isEmpty() ? Optional.empty() : Optional.of(result.get(0));
    }

    public NewsItem create(NewsRequest req) {
        String sql = "INSERT INTO news (title, summary, content, published, created_at) VALUES (?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbc.update(con -> {
            var ps = con.prepareStatement(sql, new String[]{"id"});
            ps.setString(1, req.title());
            ps.setString(2, req.summary() == null ? "" : req.summary());
            ps.setString(3, req.content() == null ? "" : req.content());
            ps.setBoolean(4, req.published() == null || req.published());
            ps.setTimestamp(5, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            return ps;
        }, keyHolder);
        Long id = keyHolder.getKey().longValue();
        return findById(id).orElseThrow();
    }

    public Optional<NewsItem> update(Long id, NewsRequest req) {
        int rows = jdbc.update(
                "UPDATE news SET title=?, summary=?, content=?, published=? WHERE id=?",
                req.title(),
                req.summary() == null ? "" : req.summary(),
                req.content() == null ? "" : req.content(),
                req.published() == null || req.published(),
                id
        );
        if (rows == 0) return Optional.empty();
        return findById(id);
    }

    public boolean delete(Long id) {
        return jdbc.update("DELETE FROM news WHERE id = ?", id) > 0;
    }
}

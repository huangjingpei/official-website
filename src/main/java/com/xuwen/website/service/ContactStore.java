package com.xuwen.website.service;

import com.xuwen.website.dto.ContactRecord;
import com.xuwen.website.dto.ContactRequest;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

@Service
public class ContactStore {

    private final JdbcTemplate jdbc;

    private static final RowMapper<ContactRecord> ROW_MAPPER = (rs, rowNum) -> new ContactRecord(
            rs.getLong("id"),
            rs.getString("name"),
            rs.getString("contact"),
            rs.getString("message"),
            rs.getObject("created_at", LocalDateTime.class)
    );

    public ContactStore(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void save(ContactRequest req) {
        jdbc.update(
                "INSERT INTO contacts (name, contact, message, created_at) VALUES (?, ?, ?, ?)",
                req.name(), req.contact(), req.message(), LocalDateTime.now()
        );
    }

    public List<ContactRecord> listAll() {
        return jdbc.query(
                "SELECT id, name, contact, message, created_at FROM contacts ORDER BY created_at DESC",
                ROW_MAPPER
        );
    }
}

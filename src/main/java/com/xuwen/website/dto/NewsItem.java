package com.xuwen.website.dto;

import java.time.LocalDate;

public record NewsItem(Long id, String title, String summary, String content, Boolean published, LocalDate date) {
    public NewsItem(Long id, String title, String summary, LocalDate date) {
        this(id, title, summary, "", true, date);
    }
}

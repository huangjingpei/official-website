package com.xuwen.website.dto;

import java.time.LocalDate;

public record NewsItem(Long id, String title, String summary, LocalDate date) {
}

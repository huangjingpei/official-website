package com.xuwen.website.dto;

import java.time.LocalDateTime;

public record ContactRecord(Long id, String name, String contact, String message, LocalDateTime createdAt) {
}

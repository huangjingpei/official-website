package com.xuwen.website.dto;

import java.time.LocalDate;

public record DownloadItem(String id, String name, String version, LocalDate date, String url, String originalFilename, String storedFilename) {
}

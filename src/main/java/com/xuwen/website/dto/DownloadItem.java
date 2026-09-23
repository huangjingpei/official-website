package com.xuwen.website.dto;

import java.time.LocalDate;

public record DownloadItem(
        String id,
        String name,
        String version,
        LocalDate date,
        String url,
        String originalFilename,
        String storedFilename,
        String platform,
        String sha256
) {
    /** Backward-compat constructor without platform/sha256 (used by DownloadStore.add) */
    public DownloadItem(String id, String name, String version, LocalDate date,
                        String url, String originalFilename, String storedFilename) {
        this(id, name, version, date, url, originalFilename, storedFilename, null, null);
    }
}

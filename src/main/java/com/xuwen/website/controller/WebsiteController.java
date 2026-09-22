package com.xuwen.website.controller;

import com.xuwen.website.dto.ContactRequest;
import com.xuwen.website.dto.DownloadItem;
import com.xuwen.website.dto.NewsItem;
import com.xuwen.website.service.DownloadStore;
import jakarta.validation.Valid;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.ResourceRegion;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpRange;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api")
public class WebsiteController {
    private final DownloadStore downloadStore;

    public WebsiteController(DownloadStore downloadStore) {
        this.downloadStore = downloadStore;
    }


    @GetMapping("/news")
    public List<NewsItem> getNews() {
        return List.of(
                new NewsItem(1L, "官网第一版发布", "官网已上线公司概况、技术方案与下载模块。", LocalDate.of(2026, 3, 10)),
                new NewsItem(2L, "WebRTC 实时互动方案升级", "新增弱网优化策略与端到端时延监控能力。", LocalDate.of(2026, 3, 8)),
                new NewsItem(3L, "AI 实时交互能力上线", "提供语音识别、问答与实时反馈接口。", LocalDate.of(2026, 3, 5))
        );
    }

    @GetMapping("/downloads")
    public List<DownloadItem> getDownloads() {
        return downloadStore.list();
    }

    @GetMapping("/downloads/{id}")
    public ResponseEntity<DownloadItem> getDownloadDetail(@PathVariable String id) {
        return downloadStore.findById(id).map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/downloads/{id}/download")
    public ResponseEntity<?> downloadFile(@PathVariable String id, @RequestHeader(value = "Range", required = false) String range) {
        DownloadItem item = downloadStore.findById(id).orElse(null);
        if (item == null) {
            return ResponseEntity.notFound().build();
        }

        FileSystemResource resource = new FileSystemResource(downloadStore.resolveFilePath(item));
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }

        String filename = item.originalFilename();
        if (filename == null || filename.isBlank()) {
            filename = item.name();
        }
        if (filename == null || filename.isBlank()) {
            filename = "download";
        }
        filename = filename.replace("\r", "").replace("\n", "");
        String asciiFallback = filename
                .replaceAll("[^\\x20-\\x7E]", "_")
                .replace("\"", "_")
                .replace("\\", "_");
        if (asciiFallback.isBlank()) {
            asciiFallback = "download";
        }
        String encoded = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");
        String contentDisposition = "attachment; filename=\"" + asciiFallback + "\"; filename*=UTF-8''" + encoded;
        long contentLength = -1;
        try {
            contentLength = resource.contentLength();
        } catch (IOException ignored) {
        }

        ResponseEntity.BodyBuilder response = ResponseEntity.status(HttpStatus.OK)
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition);

        response.header(HttpHeaders.ACCEPT_RANGES, "bytes");

        if (contentLength >= 0) {
            response.contentLength(contentLength);
        }

        if (contentLength >= 0 && range != null && !range.isBlank()) {
            try {
                List<HttpRange> ranges = HttpRange.parseRanges(range);
                if (!ranges.isEmpty()) {
                    HttpRange firstRange = ranges.get(0);
                    long start = firstRange.getRangeStart(contentLength);
                    long end = firstRange.getRangeEnd(contentLength);
                    if (start >= contentLength) {
                        return ResponseEntity.status(HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE)
                                .header(HttpHeaders.CONTENT_RANGE, "bytes */" + contentLength)
                                .build();
                    }
                    long count = Math.min(end - start + 1, contentLength - start);
                    ResourceRegion region = new ResourceRegion(resource, start, count);
                    return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                            .contentType(MediaType.APPLICATION_OCTET_STREAM)
                            .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition)
                            .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                            .header(HttpHeaders.CONTENT_RANGE, "bytes " + start + "-" + (start + count - 1) + "/" + contentLength)
                            .contentLength(count)
                            .body(region);
                }
            } catch (IllegalArgumentException ignored) {
            }
        }

        return response.body(resource);
    }

    private final List<Map<String, Object>> contactList = new java.util.concurrent.CopyOnWriteArrayList<>();

    @PostMapping(value = "/admin/downloads", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public DownloadItem uploadDownload(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String version,
            @RequestParam MultipartFile file
    ) {
        return downloadStore.add(name, version, file);
    }

    @PostMapping("/contacts")
    public ResponseEntity<Map<String, String>> submitContact(@Valid @RequestBody ContactRequest request) {
        Map<String, Object> record = new java.util.LinkedHashMap<>();
        record.put("id", System.currentTimeMillis());
        record.put("name", request.name());
        record.put("contact", request.contact());
        record.put("message", request.message());
        record.put("createdAt", java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        contactList.add(0, record);
        return ResponseEntity.ok(Map.of("message", "提交成功，我们会尽快联系您。"));
    }

    @GetMapping("/admin/contacts")
    public List<Map<String, Object>> getAdminContacts() {
        return contactList;
    }

}

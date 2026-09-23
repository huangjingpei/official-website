package com.xuwen.website.controller;

import com.xuwen.website.dto.ContactRequest;
import com.xuwen.website.dto.DownloadItem;
import com.xuwen.website.dto.NewsItem;
import com.xuwen.website.dto.NewsRequest;
import com.xuwen.website.service.ContactStore;
import com.xuwen.website.service.DownloadStore;
import com.xuwen.website.service.NewsStore;
import jakarta.validation.Valid;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api")
public class WebsiteController {

    private final DownloadStore downloadStore;
    private final NewsStore newsStore;
    private final ContactStore contactStore;

    public WebsiteController(DownloadStore downloadStore, NewsStore newsStore, ContactStore contactStore) {
        this.downloadStore = downloadStore;
        this.newsStore = newsStore;
        this.contactStore = contactStore;
    }

    // ── Public news ──────────────────────────────────────────────────────────

    @GetMapping("/news")
    public List<NewsItem> getNews() {
        return newsStore.listPublished();
    }

    @GetMapping("/news/{id}")
    public ResponseEntity<NewsItem> getNewsDetail(@PathVariable Long id) {
        return newsStore.findById(id)
                .filter(n -> Boolean.TRUE.equals(n.published()))
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // ── Downloads (public) ───────────────────────────────────────────────────

    @GetMapping("/downloads")
    public List<DownloadItem> getDownloads() {
        return downloadStore.list();
    }

    @GetMapping("/downloads/{id}")
    public ResponseEntity<DownloadItem> getDownloadDetail(@PathVariable String id) {
        return downloadStore.findById(id).map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/downloads/{id}/download")
    public ResponseEntity<?> downloadFile(
            @PathVariable String id,
            @RequestHeader(value = "Range", required = false) String range) {

        DownloadItem item = downloadStore.findById(id).orElse(null);
        if (item == null) return ResponseEntity.notFound().build();

        FileSystemResource resource = new FileSystemResource(downloadStore.resolveFilePath(item));
        if (!resource.exists()) return ResponseEntity.notFound().build();

        String filename = item.originalFilename();
        if (filename == null || filename.isBlank()) filename = item.name();
        if (filename == null || filename.isBlank()) filename = "download";
        filename = filename.replace("\r", "").replace("\n", "");
        String asciiFallback = filename.replaceAll("[^\\x20-\\x7E]", "_").replace("\"", "_").replace("\\", "_");
        if (asciiFallback.isBlank()) asciiFallback = "download";
        String encoded = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");
        String contentDisposition = "attachment; filename=\"" + asciiFallback + "\"; filename*=UTF-8''" + encoded;

        long contentLength = -1;
        try { contentLength = resource.contentLength(); } catch (IOException ignored) {}

        ResponseEntity.BodyBuilder response = ResponseEntity.status(HttpStatus.OK)
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition)
                .header(HttpHeaders.ACCEPT_RANGES, "bytes");
        if (contentLength >= 0) response.contentLength(contentLength);

        if (contentLength >= 0 && range != null && !range.isBlank()) {
            try {
                List<HttpRange> ranges = HttpRange.parseRanges(range);
                if (!ranges.isEmpty()) {
                    HttpRange firstRange = ranges.get(0);
                    long start = firstRange.getRangeStart(contentLength);
                    long end = firstRange.getRangeEnd(contentLength);
                    if (start >= contentLength) {
                        return ResponseEntity.status(HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE)
                                .header(HttpHeaders.CONTENT_RANGE, "bytes */" + contentLength).build();
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
            } catch (IllegalArgumentException ignored) {}
        }
        return response.body(resource);
    }

    // ── Contacts (public submit) ──────────────────────────────────────────────

    @PostMapping("/contacts")
    public ResponseEntity<Map<String, String>> submitContact(@Valid @RequestBody ContactRequest req) {
        contactStore.save(req);
        return ResponseEntity.ok(Map.of("message", "提交成功，我们会尽快联系您。"));
    }

    // ── Admin: contacts ───────────────────────────────────────────────────────

    @GetMapping("/admin/contacts")
    public Object getAdminContacts() {
        return contactStore.listAll();
    }

    // ── Admin: downloads ──────────────────────────────────────────────────────

    @PostMapping(value = "/admin/downloads", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public DownloadItem uploadDownload(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String version,
            @RequestParam MultipartFile file) {
        return downloadStore.add(name, version, file);
    }

    // ── Admin: news CRUD ──────────────────────────────────────────────────────

    @GetMapping("/admin/news")
    public List<NewsItem> adminListNews() {
        return newsStore.listAll();
    }

    @PostMapping("/admin/news")
    public ResponseEntity<NewsItem> adminCreateNews(@Valid @RequestBody NewsRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(newsStore.create(req));
    }

    @PutMapping("/admin/news/{id}")
    public ResponseEntity<NewsItem> adminUpdateNews(@PathVariable Long id, @Valid @RequestBody NewsRequest req) {
        return newsStore.update(id, req)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/admin/news/{id}")
    public ResponseEntity<Void> adminDeleteNews(@PathVariable Long id) {
        return newsStore.delete(id)
                ? ResponseEntity.noContent().<Void>build()
                : ResponseEntity.notFound().build();
    }
}

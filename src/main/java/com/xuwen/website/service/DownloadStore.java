package com.xuwen.website.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.xuwen.website.dto.DownloadItem;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class DownloadStore {

    private final ObjectMapper objectMapper;
    private final Path uploadDir;
    private final Path metadataFile;

    public DownloadStore(
            ObjectMapper objectMapper,
            @Value("${app.storage.upload-dir}") String uploadDir,
            @Value("${app.storage.metadata-file}") String metadataFile
    ) {
        this.objectMapper = objectMapper;
        this.uploadDir = Path.of(uploadDir).toAbsolutePath().normalize();
        this.metadataFile = Path.of(metadataFile).toAbsolutePath().normalize();
    }

    public synchronized List<DownloadItem> list() {
        List<DownloadItem> items = new ArrayList<>(readAll());
        items.sort(Comparator.comparing(DownloadItem::date).reversed());
        return items;
    }

    public synchronized Optional<DownloadItem> findById(String id) {
        return readAll().stream().filter(i -> i.id().equals(id)).findFirst();
    }

    public synchronized DownloadItem add(String name, String version, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }

        ensureDirectories();

        String originalFilename = file.getOriginalFilename() == null ? "unknown" : file.getOriginalFilename();
        String storedFilename = buildStoredFilename(originalFilename);
        Path target = uploadDir.resolve(storedFilename);

        try {
            file.transferTo(target);
        } catch (IOException e) {
            throw new IllegalStateException("保存文件失败");
        }

        String id = UUID.randomUUID().toString();
        String url = "/api/downloads/" + id + "/download";
        DownloadItem item = new DownloadItem(
                id,
                name == null || name.isBlank() ? originalFilename : name,
                version == null ? "" : version,
                LocalDate.now(),
                url,
                originalFilename,
                storedFilename
        );

        List<DownloadItem> items = new ArrayList<>(readAll());
        items.add(item);
        writeAll(items);
        return item;
    }

    public Path resolveFilePath(DownloadItem item) {
        return uploadDir.resolve(item.storedFilename());
    }

    private void ensureDirectories() {
        try {
            Files.createDirectories(uploadDir);
            if (metadataFile.getParent() != null) {
                Files.createDirectories(metadataFile.getParent());
            }
        } catch (IOException e) {
            throw new IllegalStateException("初始化存储目录失败");
        }
    }

    private List<DownloadItem> readAll() {
        ensureDirectories();
        if (!Files.exists(metadataFile)) {
            return List.of();
        }
        try {
            return objectMapper.readValue(metadataFile.toFile(), new TypeReference<List<DownloadItem>>() {});
        } catch (IOException e) {
            return List.of();
        }
    }

    private void writeAll(List<DownloadItem> items) {
        ensureDirectories();
        try {
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(metadataFile.toFile(), items);
        } catch (IOException e) {
            throw new IllegalStateException("写入元数据失败");
        }
    }

    private String buildStoredFilename(String originalFilename) {
        String safe = originalFilename.replaceAll("[\\\\/:*?\"<>|]+", "_").trim();
        String prefix = UUID.randomUUID().toString().replace("-", "");
        return prefix + "__" + safe;
    }
}

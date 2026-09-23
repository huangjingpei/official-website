package com.xuwen.website.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record NewsRequest(
        @NotBlank(message = "标题不能为空")
        @Size(max = 300, message = "标题不能超过300字")
        String title,

        @Size(max = 1000, message = "摘要不能超过1000字")
        String summary,

        String content,

        Boolean published
) {
}

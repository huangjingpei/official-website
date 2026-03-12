package com.xuwen.website.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ContactRequest(
        @NotBlank(message = "姓名不能为空")
        String name,
        @NotBlank(message = "联系方式不能为空")
        String contact,
        @NotBlank(message = "需求描述不能为空")
        @Size(max = 1000, message = "需求描述不能超过1000字")
        String message
) {
}

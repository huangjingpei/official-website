package com.xuwen.website.controller;

import com.xuwen.website.dto.ChangePasswordRequest;
import java.util.List;
import java.util.Map;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.JdbcUserDetailsManager;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final JdbcUserDetailsManager userDetailsManager;
    private final PasswordEncoder passwordEncoder;
    private final org.springframework.core.env.Environment environment;

    public AuthController(
            JdbcUserDetailsManager userDetailsManager,
            PasswordEncoder passwordEncoder,
            org.springframework.core.env.Environment environment
    ) {
        this.userDetailsManager = userDetailsManager;
        this.passwordEncoder = passwordEncoder;
        this.environment = environment;
    }

    @GetMapping("/me")
    public Map<String, Object> me(@AuthenticationPrincipal UserDetails user) {
        List<String> roles = user.getAuthorities().stream().map(GrantedAuthority::getAuthority).toList();
        boolean isAdmin = roles.contains("ROLE_ADMIN");
        boolean needsPasswordChange = false;
        if (isAdmin) {
            String defaultAdminPassword = environment.getProperty("app.security.admin-password", "admin123");
            if (user.getPassword() != null && passwordEncoder.matches(defaultAdminPassword, user.getPassword())) {
                needsPasswordChange = true;
            }
        }
        return Map.of(
                "username", user.getUsername(),
                "roles", roles,
                "needsPasswordChange", needsPasswordChange
        );
    }

    @PostMapping("/change-password")
    public Map<String, Object> changePassword(
            @AuthenticationPrincipal UserDetails user,
            @jakarta.validation.Valid @RequestBody ChangePasswordRequest request
    ) {
        String defaultAdminPassword = environment.getProperty("app.security.admin-password", "admin123");
        if (request.newPassword().equals(defaultAdminPassword)) {
            throw new IllegalArgumentException("新密码不能与初始密码相同");
        }

        UserDetails existing = userDetailsManager.loadUserByUsername(user.getUsername());
        UserDetails updated = org.springframework.security.core.userdetails.User.withUserDetails(existing)
                .password(passwordEncoder.encode(request.newPassword()))
                .build();
        userDetailsManager.updateUser(updated);
        return Map.of("message", "密码修改成功");
    }
}

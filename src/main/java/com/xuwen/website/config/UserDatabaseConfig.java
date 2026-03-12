package com.xuwen.website.config;

import javax.sql.DataSource;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.CannotGetJdbcConnectionException;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.JdbcUserDetailsManager;

@Configuration
public class UserDatabaseConfig {

    @Bean
    public JdbcUserDetailsManager userDetailsService(DataSource dataSource) {
        return new JdbcUserDetailsManager(dataSource);
    }

    @Bean
    public CommandLineRunner seedDefaultUsers(
            JdbcUserDetailsManager userDetailsManager,
            PasswordEncoder passwordEncoder,
            JdbcTemplate jdbcTemplate,
            org.springframework.core.env.Environment environment
    ) {
        return args -> {
            try {
                jdbcTemplate.execute("""
                        CREATE TABLE IF NOT EXISTS users (
                            username VARCHAR(50) NOT NULL PRIMARY KEY,
                            password VARCHAR(500) NOT NULL,
                            enabled TINYINT(1) NOT NULL DEFAULT 1
                        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
                        """);

                jdbcTemplate.execute("""
                        CREATE TABLE IF NOT EXISTS authorities (
                            username VARCHAR(50) NOT NULL,
                            authority VARCHAR(50) NOT NULL,
                            CONSTRAINT fk_authorities_users FOREIGN KEY (username) REFERENCES users (username),
                            UNIQUE KEY ix_auth_username (username, authority)
                        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
                        """);
            } catch (CannotGetJdbcConnectionException ex) {
                String url = environment.getProperty("spring.datasource.url", "");
                String username = environment.getProperty("spring.datasource.username", "");
                throw new IllegalStateException("无法连接数据库，请检查 MySQL 是否启动、库是否可用，以及 MYSQL_URL/MYSQL_USERNAME/MYSQL_PASSWORD 配置是否正确。url=" + url + ", username=" + username, ex);
            }

            String adminUsername = environment.getProperty("app.security.admin-username", "administrator");
            String adminPassword = environment.getProperty("app.security.admin-password", "admin123");

            if (!userDetailsManager.userExists(adminUsername)) {
                userDetailsManager.createUser(User.withUsername(adminUsername)
                        .password(passwordEncoder.encode(adminPassword))
                        .roles("ADMIN")
                        .build());
            }
        };
    }
}

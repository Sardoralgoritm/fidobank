package uz.ssardor.bank;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;

public final class Db {

    private static final HikariDataSource DS;

    static {
        HikariConfig cfg = new HikariConfig();
        // WAR ichidagi drayverni DriverManager o'zi topa olmaydi, aniq ko'rsatamiz
        cfg.setDriverClassName("oracle.jdbc.OracleDriver");
        cfg.setJdbcUrl(env("DB_URL", "jdbc:oracle:thin:@//oracle:1521/XEPDB1"));
        cfg.setUsername(env("DB_USER", "bank"));
        cfg.setPassword(env("DB_PASS", "bank123"));
        cfg.setPoolName("fidobank-pool");
        cfg.setMaximumPoolSize(10);
        cfg.setMinimumIdle(2);
        cfg.setConnectionTimeout(30_000);
        cfg.setConnectionTestQuery("SELECT 1 FROM dual");
        // Baza hali tayyor bo'lmasa ham Tomcat ishga tushaversin
        cfg.setInitializationFailTimeout(-1);
        DS = new HikariDataSource(cfg);
    }

    private Db() {
    }

    public static DataSource ds() {
        return DS;
    }

    private static String env(String key, String fallback) {
        String v = System.getenv(key);
        return (v == null || v.isBlank()) ? fallback : v;
    }
}

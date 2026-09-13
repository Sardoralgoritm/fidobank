# FidoBank demo

Pul o'tkazma uchun kichik web ilova. Biznes mantiq to'liq **Oracle PL/SQL paketida**,
Java faqat transport va ekran vazifasini bajaradi.

## Stack

| Qatlam | Texnologiya |
|---|---|
| Frontend | JSP |
| Web | Servlet (javax.servlet), Tomcat 9 |
| Ulanish | JDBC, `CallableStatement`, HikariCP connection pool |
| Baza | Oracle XE 21c, PL/SQL paket |
| Ishga tushirish | Docker Compose, multi-stage Maven build |

## Bazadagi mantiq

`pkg_bank.transfer` procedurasi:

- lock'lar **har doim `id` bo'yicha o'sish tartibida** olinadi, shuning uchun
  `A -> B` va `B -> A` o'tkazmalari bir vaqtda ketsa ham deadlock bo'lmaydi
- balans lock olingandan **keyin** o'qiladi, aks holda orada boshqa sessiya
  qiymatni o'zgartirib ketishi mumkin edi
- biznes xatolar `RAISE_APPLICATION_ERROR(-20010..-20013)` orqali qaytadi va
  Java tomonda ushlanib, ekranda ko'rsatiladi
- xatolar `PRAGMA AUTONOMOUS_TRANSACTION` bilan `err_log` jadvaliga yoziladi,
  shuning uchun ona tranzaksiya `ROLLBACK` bo'lsa ham log saqlanib qoladi

`pkg_bank.get_accounts` funksiyasi `SYS_REFCURSOR` qaytaradi, Java uni
`registerOutParameter(1, OracleTypes.CURSOR)` orqali `ResultSet` sifatida o'qiydi.

Barcha parametrlar **bind variable** (`?`) orqali uzatiladi: SQL injection'dan
himoya va execution plan qayta ishlatiladi.

## Ishga tushirish

```bash
docker compose up -d --build
docker compose logs -f app
```

Birinchi ishga tushirish 3-5 daqiqa oladi: Oracle bazani yaratadi va
`db/init/01_schema.sql` ni bir marta bajaradi.

Ochish: http://localhost:8080

## Qayta boshlash

```bash
docker compose down -v     # -v baza volume'ini ham o'chiradi, sxema qaytadan quriladi
docker compose up -d --build
```

## Bazaga ulanish

```bash
docker exec -it fidobank-oracle sqlplus bank/bank123@//localhost:1521/XEPDB1
```

```sql
SELECT * FROM accounts;
SELECT * FROM err_log ORDER BY log_date DESC;
```

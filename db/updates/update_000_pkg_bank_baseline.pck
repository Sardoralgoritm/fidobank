CREATE OR REPLACE PACKAGE pkg_bank AS

   PROCEDURE transfer (p_from   IN NUMBER,
                       p_to     IN NUMBER,
                       p_amount IN NUMBER);

   FUNCTION get_accounts RETURN SYS_REFCURSOR;

END pkg_bank;
/
CREATE OR REPLACE PACKAGE BODY pkg_bank AS

   -- Autonomous: ona tranzaksiya ROLLBACK bo'lsa ham log saqlanib qoladi
   PROCEDURE log_err (p_module IN VARCHAR2,
                      p_code   IN NUMBER,
                      p_msg    IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO err_log (module, err_code, err_msg)
      VALUES (p_module, p_code, SUBSTR(p_msg, 1, 4000));
      COMMIT;
   END log_err;


   PROCEDURE transfer (p_from   IN NUMBER,
                       p_to     IN NUMBER,
                       p_amount IN NUMBER)
   IS
      v_bal accounts.bal%TYPE;
   BEGIN
      IF p_amount IS NULL OR p_amount <= 0 THEN
         RAISE_APPLICATION_ERROR(-20010, 'Summa musbat bo''lishi kerak');
      END IF;

      IF p_from = p_to THEN
         RAISE_APPLICATION_ERROR(-20011, 'Bir xil hisob tanlandi');
      END IF;

      -- Deadlock'ning oldini olish: lock'lar HAR DOIM id bo'yicha o'sish
      -- tartibida olinadi, shuning uchun A->B va B->A bir vaqtda ketsa ham
      -- aylanma kutish hosil bo'lmaydi.
      FOR r IN (SELECT id
                  FROM accounts
                 WHERE id IN (p_from, p_to)
                 ORDER BY id
                   FOR UPDATE)
      LOOP
         NULL;
      END LOOP;

      -- Balans lock'dan KEYIN o'qiladi: orada boshqa sessiya o'zgartira olmaydi
      SELECT bal INTO v_bal FROM accounts WHERE id = p_from;

      IF v_bal < p_amount THEN
         RAISE_APPLICATION_ERROR(-20012, 'Mablag'' yetarli emas');
      END IF;

      UPDATE accounts SET bal = bal - p_amount WHERE id = p_from;
      UPDATE accounts SET bal = bal + p_amount WHERE id = p_to;

      COMMIT;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;
         log_err('transfer', SQLCODE, SQLERRM);
         RAISE_APPLICATION_ERROR(-20013, 'Hisob topilmadi');
      WHEN OTHERS THEN
         ROLLBACK;
         log_err('transfer', SQLCODE, SQLERRM);
         RAISE;
   END transfer;


   FUNCTION get_accounts RETURN SYS_REFCURSOR IS
      c SYS_REFCURSOR;
   BEGIN
      OPEN c FOR
         SELECT id, owner, bal
           FROM accounts
          ORDER BY id;
      RETURN c;
   END get_accounts;

END pkg_bank;
/

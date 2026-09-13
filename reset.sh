#!/usr/bin/env bash
# Demo ma'lumotini boshlang'ich holatga qaytaradi.
set -euo pipefail

docker exec -i fidobank-oracle \
  sqlplus -s bank/bank123@//localhost:1521/XEPDB1 <<'EOF'
UPDATE accounts SET bal = 5000000 WHERE id = 1001;
UPDATE accounts SET bal = 1250000 WHERE id = 1002;
UPDATE accounts SET bal = 8300000 WHERE id = 1003;
UPDATE accounts SET bal =   75000 WHERE id = 1004;
DELETE FROM err_log;
COMMIT;
SELECT id, owner, bal FROM accounts ORDER BY id;
EOF

#!/usr/bin/env bash
# End-to-end API smoke test for the TypeScript backend.
set -u
BASE="http://localhost:4000/api/v1"
CURL="curl -s -m 8"
PASS=0; FAIL=0
ok(){ echo "  ✅ $1"; PASS=$((PASS+1)); }
bad(){ echo "  ❌ $1 -> $2"; FAIL=$((FAIL+1)); }

# helper: extract json field via node
jqf(){ node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{try{const o=JSON.parse(d);console.log(o$1??'')}catch{console.log('')}})"; }

echo "== 1. Health =="
H=$($CURL http://localhost:4000/health)
[[ "$H" == *'"db":true'* ]] && ok "health db:true" || bad "health" "$H"

echo "== 2. Super admin login =="
SA=$($CURL -X POST "$BASE/auth/login" -H 'Content-Type: application/json' -d '{"phone":"918888800000","password":"Password@123"}')
SA_T=$(echo "$SA" | jqf ".accessToken")
[[ -n "$SA_T" ]] && ok "super_admin login" || bad "super_admin login" "$SA"

echo "== 3. Super admin analytics =="
A=$($CURL "$BASE/superadmin/analytics" -H "Authorization: Bearer $SA_T")
[[ "$A" == *'"totalTenants"'* ]] && ok "analytics" || bad "analytics" "$A"

echo "== 4. Super admin leads inbox =="
L=$($CURL "$BASE/superadmin/leads" -H "Authorization: Bearer $SA_T")
[[ "$L" == *'"instituteName"'* ]] && ok "leads list" || bad "leads list" "$L"

echo "== 5. Public lead submission =="
NL=$($CURL -X POST "$BASE/leads" -H 'Content-Type: application/json' -d '{"ownerName":"Test Owner","instituteName":"TS Test Institute","phone":"919333300001","city":"Nashik","studentCount":50}')
[[ "$NL" == *'"success":true'* ]] && ok "public lead submit" || bad "public lead submit" "$NL"

sleep 1
echo "== 6. Apex admin login =="
AA=$($CURL -X POST "$BASE/auth/login" -H 'Content-Type: application/json' -d '{"phone":"919000000011","password":"Password@123"}')
AA_T=$(echo "$AA" | jqf ".accessToken")
[[ -n "$AA_T" ]] && ok "apex admin login" || bad "apex admin login" "$AA"

echo "== 7. Apex admin dashboard =="
D=$($CURL "$BASE/admin/dashboard" -H "Authorization: Bearer $AA_T")
[[ "$D" == *'"studentCount"'* ]] && ok "admin dashboard" || bad "admin dashboard" "$D"

echo "== 8. Apex students list =="
ST=$($CURL "$BASE/admin/students" -H "Authorization: Bearer $AA_T")
[[ "$ST" == *'"fullName"'* ]] && ok "students list" || bad "students list" "$ST"
SID=$(echo "$ST" | jqf "[0].id")

echo "== 9. Fee reminder wa.me link =="
FR=$($CURL -X POST "$BASE/admin/fees/$SID/remind" -H "Authorization: Bearer $AA_T")
[[ "$FR" == *'https://wa.me/'* ]] && ok "fee reminder wa.me" || bad "fee reminder" "$FR"

echo "== 10. Admin create batch (subscription active/trial => allowed) =="
CB=$($CURL -X POST "$BASE/admin/batches" -H "Authorization: Bearer $AA_T" -H 'Content-Type: application/json' -d '{"name":"TS Batch","grade":"Class 11"}')
[[ "$CB" == *'"name":"TS Batch"'* ]] && ok "create batch" || bad "create batch" "$CB"

sleep 1
echo "== 11. Apex student login =="
STU=$($CURL -X POST "$BASE/auth/login" -H 'Content-Type: application/json' -d '{"phone":"919000000013","password":"Password@123"}')
STU_T=$(echo "$STU" | jqf ".accessToken")
[[ -n "$STU_T" ]] && ok "student login" || bad "student login" "$STU"

echo "== 12. Student dashboard =="
SD=$($CURL "$BASE/student/dashboard" -H "Authorization: Bearer $STU_T")
[[ "$SD" == *'"pendingFees"'* ]] && ok "student dashboard" || bad "student dashboard" "$SD"

echo "== 13. Student ask-doubt wa.me (Apex's teacher) =="
AD=$($CURL "$BASE/student/ask-doubt?teacherId=3&chapter=Kinematics" -H "Authorization: Bearer $STU_T")
[[ "$AD" == *'https://wa.me/'* ]] && ok "ask-doubt wa.me" || bad "ask-doubt" "$AD"

echo "== 14. Tenant isolation: student can't hit admin (403) =="
ISO=$($CURL -o /dev/null -w '%{http_code}' "$BASE/admin/dashboard" -H "Authorization: Bearer $STU_T")
[[ "$ISO" == "403" ]] && ok "role guard 403" || bad "role guard" "$ISO"

echo "== 15. No token => 401 =="
NT=$($CURL -o /dev/null -w '%{http_code}' "$BASE/admin/dashboard")
[[ "$NT" == "401" ]] && ok "no token 401" || bad "no token" "$NT"

echo "== 16. Bad login => 401 =="
BL=$($CURL -o /dev/null -w '%{http_code}' -X POST "$BASE/auth/login" -H 'Content-Type: application/json' -d '{"phone":"919000000011","password":"wrongpass"}')
[[ "$BL" == "401" ]] && ok "bad login 401" || bad "bad login" "$BL"

sleep 1
echo "== 17. Payment: subscription status (apex) =="
PS=$($CURL "$BASE/payments/subscription" -H "Authorization: Bearer $AA_T")
[[ "$PS" == *'"status"'* ]] && ok "subscription status" || bad "subscription status" "$PS"

echo "== 18. Payment: create mock order =="
CO=$($CURL -X POST "$BASE/payments/create-order" -H "Authorization: Bearer $AA_T")
OID=$(echo "$CO" | jqf ".orderId")
[[ "$OID" == order_mock_* ]] && ok "create mock order ($OID)" || bad "create order" "$CO"

echo "== 19. Payment: verify mock order => active =="
VP=$($CURL -X POST "$BASE/payments/verify" -H "Authorization: Bearer $AA_T" -H 'Content-Type: application/json' -d "{\"orderId\":\"$OID\",\"paymentId\":\"pay_mock_123\"}")
[[ "$VP" == *'"status":"active"'* ]] && ok "verify => active" || bad "verify" "$VP"

echo ""
echo "==================== RESULT ===================="
echo "PASS=$PASS  FAIL=$FAIL"
[[ $FAIL -eq 0 ]] && echo "🎉 ALL TESTS PASSED" || echo "⚠️  SOME TESTS FAILED"

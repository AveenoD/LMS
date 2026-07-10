#!/usr/bin/env bash
set -u
BASE="http://localhost:4000/api/v1"
CURL="curl -s"
DB_CMD="docker exec edtech-db psql -U postgres -d edtech_os -t -c"

echo "== 1. Update Pioneer Tenant to Basic Plan =="
# Get ID for Basic plan
BASIC_PLAN_ID=$(psql postgres://postgres:postgres@localhost:5432/edtech_os -t -c "SELECT id FROM plan_catalog WHERE name = 'Basic';" | xargs)
PIONEER_TENANT_ID=$(psql postgres://postgres:postgres@localhost:5432/edtech_os -t -c "SELECT id FROM tenants WHERE slug = 'pioneer';" | xargs)

psql postgres://postgres:postgres@localhost:5432/edtech_os -c "UPDATE subscriptions SET plan_catalog_id = $BASIC_PLAN_ID, status = 'active' WHERE tenant_id = $PIONEER_TENANT_ID;"

echo "== 2. Login as Pioneer Admin =="
ADMIN_LOGIN=$($CURL -X POST "$BASE/auth/login" -H 'Content-Type: application/json' -d '{"slug":"pioneer","phone":"919000000021","password":"Password@123"}')
ADMIN_TOKEN=$(node -e "console.log(JSON.parse('$ADMIN_LOGIN').accessToken)")

echo "== 3. Access Gated Route (Performance Reports - Requires Pro) with Basic Plan =="
RESPONSE=$($CURL -w "\nHTTP_CODE:%{http_code}" "$BASE/admin/reports/performance" -H "Authorization: Bearer $ADMIN_TOKEN")
echo "$RESPONSE"

if [[ "$RESPONSE" == *"PLAN_UPGRADE_REQUIRED"* ]]; then
  echo "✅ SUCCESS: featureGuard successfully blocked access for Basic tenant."
else
  echo "❌ FAIL: featureGuard failed to block access."
fi

echo "== 4. Update Pioneer Tenant to Pro Plan =="
PRO_PLAN_ID=$(psql postgres://postgres:postgres@localhost:5432/edtech_os -t -c "SELECT id FROM plan_catalog WHERE name = 'Pro';" | xargs)
psql postgres://postgres:postgres@localhost:5432/edtech_os -c "UPDATE subscriptions SET plan_catalog_id = $PRO_PLAN_ID WHERE tenant_id = $PIONEER_TENANT_ID;"

echo "== 5. Access Gated Route (Performance Reports - Requires Pro) with Pro Plan =="
RESPONSE2=$($CURL -w "\nHTTP_CODE:%{http_code}" "$BASE/admin/reports/performance" -H "Authorization: Bearer $ADMIN_TOKEN")
echo "$RESPONSE2"

if [[ "$RESPONSE2" == *"200"* ]] || [[ "$RESPONSE2" == *"success"* ]]; then
  echo "✅ SUCCESS: featureGuard successfully allowed access for Pro tenant."
else
  echo "❌ FAIL: featureGuard failed to allow access."
fi

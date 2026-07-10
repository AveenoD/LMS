import { Pool } from 'pg';
import * as dotenv from 'dotenv';
dotenv.config();

async function testFeatureGuard() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const BASE = "http://localhost:4000/api/v1";

  try {
    console.log("== 1. Update Pioneer Tenant to Basic Plan ==");
    const { rows: basicPlanRows } = await pool.query("SELECT id FROM plan_catalog WHERE name = 'Basic';");
    const basicPlanId = basicPlanRows[0].id;
    
    const { rows: pioneerRows } = await pool.query("SELECT id FROM tenants WHERE slug = 'pioneer';");
    const pioneerId = pioneerRows[0].id;

    await pool.query("UPDATE subscriptions SET plan_catalog_id = $1, status = 'active' WHERE tenant_id = $2;", [basicPlanId, pioneerId]);

    console.log("== 2. Login as Pioneer Admin ==");
    const loginRes = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ slug: "pioneer", phone: "919000000021", password: "Password@123" })
    });
    const loginData = await loginRes.json() as any;
    const adminToken = loginData.accessToken;

    if (!adminToken) throw new Error("Login failed");

    console.log("== 3. Access Gated Route (Performance Reports - Requires Pro) with Basic Plan ==");
    const res1 = await fetch(`${BASE}/admin/reports/performance`, {
      headers: { 'Authorization': `Bearer ${adminToken}` }
    });
    const data1 = await res1.json() as any;
    console.log("Status:", res1.status, data1);

    if (res1.status === 403 && data1.code === 'PLAN_UPGRADE_REQUIRED') {
      console.log("✅ SUCCESS: featureGuard successfully blocked access for Basic tenant.");
    } else {
      console.log("❌ FAIL: featureGuard failed to block access.");
    }

    console.log("== 4. Update Pioneer Tenant to Pro Plan ==");
    const { rows: proPlanRows } = await pool.query("SELECT id FROM plan_catalog WHERE name = 'Pro';");
    const proPlanId = proPlanRows[0].id;
    await pool.query("UPDATE subscriptions SET plan_catalog_id = $1 WHERE tenant_id = $2;", [proPlanId, pioneerId]);

    console.log("== 5. Access Gated Route (Performance Reports - Requires Pro) with Pro Plan ==");
    const res2 = await fetch(`${BASE}/admin/reports/performance`, {
      headers: { 'Authorization': `Bearer ${adminToken}` }
    });
    const data2 = await res2.json() as any;
    console.log("Status:", res2.status, data2);

    if (res2.status === 200 || data2.success) {
      console.log("✅ SUCCESS: featureGuard successfully allowed access for Pro tenant.");
    } else {
      console.log("❌ FAIL: featureGuard failed to allow access.");
    }

  } catch (err) {
    console.error("Test Error:", err);
  } finally {
    await pool.end();
  }
}

testFeatureGuard();

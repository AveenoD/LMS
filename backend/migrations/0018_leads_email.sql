-- ============================================================
-- Marketing-site demo-booking forms collect an email address, but leads
-- had nowhere to store it — it was getting silently dropped. Nullable
-- since city/message etc. are already optional on this table.
-- ============================================================

ALTER TABLE leads ADD COLUMN email VARCHAR(120);

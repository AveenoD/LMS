-- ============================================================
-- Removes the custom-branding feature entirely (admin-editable logo/color
-- per tenant). Every tenant now uses the app's single fixed theme —
-- institute NAME still shows in the UI (e.g. app header), that's a
-- separate concern from the logo/color customization being removed here.
-- ============================================================

ALTER TABLE tenants DROP COLUMN logo_url;
ALTER TABLE tenants DROP COLUMN primary_color;

-- Strip the now-nonexistent 'custom_branding' feature key out of any plan's
-- seeded features array (only the Elite plan had it, but this covers any
-- plan, including ones a super_admin may have added since).
UPDATE plan_catalog
   SET features = (
     SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
       FROM jsonb_array_elements(features) elem
      WHERE elem <> '"custom_branding"'::jsonb
   )
 WHERE features @> '["custom_branding"]'::jsonb;

-- Additive Database Migration: P7 Import Records
-- Milestone P7: Remaining OpenGym Parity & Optional Integrations
--
-- Tracks imported workout files so the same file is not re-imported twice
-- (duplicate-import protection). Records are owner-scoped and keyed by a
-- deterministic file fingerprint (content hash), not the file name.
--
-- No existing tables/columns are dropped, renamed, or truncated. No RLS is
-- weakened. Production is NOT applied by this migration; locally testable only.

CREATE TABLE IF NOT EXISTS public.import_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  file_name TEXT NOT NULL,
  file_fingerprint TEXT NOT NULL,
  format TEXT NOT NULL,
  imported_workout_ids UUID[] NOT NULL DEFAULT '{}',
  imported_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE (user_id, file_fingerprint)
);

ALTER TABLE public.import_records ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own import records" ON public.import_records;
CREATE POLICY "Users can view own import records" ON public.import_records FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own import records" ON public.import_records;
CREATE POLICY "Users can insert own import records" ON public.import_records FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own import records" ON public.import_records;
CREATE POLICY "Users can update own import records" ON public.import_records FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own import records" ON public.import_records;
CREATE POLICY "Users can delete own import records" ON public.import_records FOR DELETE
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_import_records_user_id ON public.import_records(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_import_records_user_fingerprint
  ON public.import_records(user_id, file_fingerprint);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.import_records TO authenticated;

COMMENT ON TABLE public.import_records IS
  'Owner-scoped record of imported workout files for duplicate-import protection. Keyed by content fingerprint, not file name.';
COMMENT ON COLUMN public.import_records.file_fingerprint IS
  'Deterministic hash of the imported file content; used to detect duplicate re-imports.';

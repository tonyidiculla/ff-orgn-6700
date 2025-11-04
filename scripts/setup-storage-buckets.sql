-- ============================================================================
-- Storage Bucket Setup for Furfield Organization Management
-- Date: 2025-10-30
-- Description: Creates standardized storage buckets for avatars and logos
--
-- BUCKET STRUCTURE:
-- 1. organizations: Organization logos → {organization_platform_id}/{filename}
-- 2. entities: Entity/Hospital logos and licenses → {entity_platform_id}/{filename}
-- 3. avatars: User and pet avatars → users/{user_id}/{filename} or pets/{pet_id}/{filename}
-- ============================================================================

-- Step 1: Create the storage buckets (or update if they exist)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('organizations', 'organizations', true, 52428800, ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']),
  ('entities', 'entities', true, 52428800, ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif', 'application/pdf']),
  ('avatars', 'avatars', true, 10485760, ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Step 2: Drop existing policies (clean slate)
DROP POLICY IF EXISTS "Public read access for organizations logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload to organizations" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update organizations files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete organizations files" ON storage.objects;
DROP POLICY IF EXISTS "Public read access for entities files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload to entities" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update entities files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete entities files" ON storage.objects;
DROP POLICY IF EXISTS "Public read access for avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can manage pet avatars" ON storage.objects;

-- Step 3: Create RLS policies for organizations bucket
CREATE POLICY "Public read access for organizations logos"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'organizations');

CREATE POLICY "Authenticated users can upload to organizations"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'organizations');

CREATE POLICY "Authenticated users can update organizations files"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'organizations');

CREATE POLICY "Authenticated users can delete organizations files"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'organizations');

-- Step 4: Create RLS policies for entities bucket
CREATE POLICY "Public read access for entities files"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'entities');

CREATE POLICY "Authenticated users can upload to entities"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'entities');

CREATE POLICY "Authenticated users can update entities files"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'entities');

CREATE POLICY "Authenticated users can delete entities files"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'entities');

-- Step 5: Create RLS policies for avatars bucket
CREATE POLICY "Public read access for avatars"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatars"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

CREATE POLICY "Users can update their own avatars"
ON storage.objects FOR UPDATE TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

CREATE POLICY "Users can delete their own avatars"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

CREATE POLICY "Users can manage pet avatars"
ON storage.objects FOR ALL TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = 'pets'
);

-- Step 6: Add comments
COMMENT ON TABLE storage.buckets IS 'Storage buckets for Furfield application. See STORAGE_SERVICE.md for folder structure.';

-- ============================================================================
-- VERIFICATION (run these after to confirm setup)
-- ============================================================================
-- SELECT * FROM storage.buckets WHERE id IN ('organizations', 'entities', 'avatars');
-- SELECT * FROM storage.objects WHERE bucket_id IN ('organizations', 'entities', 'avatars') LIMIT 10;

-- ============================================================================
-- Fix Storage RLS Policies
-- Date: 2025-10-30
-- Description: Adds RLS policies to allow authenticated users to upload/manage files
-- ============================================================================

-- Drop existing policies if any (to avoid conflicts)
DROP POLICY IF EXISTS "Public read access for organizations logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can read organizations files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload to organizations" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update organizations files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete organizations files" ON storage.objects;
DROP POLICY IF EXISTS "Public read access for entities files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can read entities files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload to entities" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update entities files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete entities files" ON storage.objects;
DROP POLICY IF EXISTS "Public read access for avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can manage pet avatars" ON storage.objects;

-- Organizations bucket policies (authenticated users only)
-- Simplified policies without folder structure restrictions
CREATE POLICY "Authenticated users can read organizations files"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'organizations');

CREATE POLICY "Authenticated users can upload to organizations"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'organizations');

CREATE POLICY "Authenticated users can update organizations files"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'organizations')
WITH CHECK (bucket_id = 'organizations');

CREATE POLICY "Authenticated users can delete organizations files"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'organizations');

-- Entities bucket policies (authenticated users only)
-- Simplified policies without folder structure restrictions
CREATE POLICY "Authenticated users can read entities files"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'entities');

CREATE POLICY "Authenticated users can upload to entities"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'entities');

CREATE POLICY "Authenticated users can update entities files"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'entities')
WITH CHECK (bucket_id = 'entities');

CREATE POLICY "Authenticated users can delete entities files"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'entities');

-- Avatars bucket policies
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete avatars" ON storage.objects;

CREATE POLICY "Public read access for avatars"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'avatars');

CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Authenticated users can update avatars"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Authenticated users can delete avatars"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'avatars');

-- Optional: More restrictive policy for user avatars (users can only manage their own)
-- Uncomment if you want users to only manage their own avatars
/*
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete avatars" ON storage.objects;

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
*/

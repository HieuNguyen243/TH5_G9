-- 1. Table: majors
CREATE TABLE majors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    major_code VARCHAR(50) UNIQUE NOT NULL,
    major_name VARCHAR(255) NOT NULL
);

-- 2. Table: students
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_code VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    major_id UUID REFERENCES majors(id),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table: courses
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_code VARCHAR(50) UNIQUE NOT NULL,
    course_name VARCHAR(255) NOT NULL,
    credits INTEGER NOT NULL
);

-- 4. Table: grades
CREATE TABLE grades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    score NUMERIC(3, 2) CHECK (score >= 0 AND score <= 10.0)
);

-- 5. Storage Bucket: student_avatars
-- Lệnh tạo bucket qua SQL (nếu dùng Supabase Dashboard thì có thể tạo qua UI)
-- insert into storage.buckets (id, name, public) values ('student_avatars', 'student_avatars', true);

-- Policies for student_avatars bucket
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'student_avatars');
CREATE POLICY "Allow Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'student_avatars');
CREATE POLICY "Allow Update" ON storage.objects FOR UPDATE WITH CHECK (bucket_id = 'student_avatars');
CREATE POLICY "Allow Delete" ON storage.objects FOR DELETE USING (bucket_id = 'student_avatars');

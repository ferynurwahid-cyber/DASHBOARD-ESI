# Panduan Deployment

## 1. Setup Supabase

### Buat Project Baru
1. Login ke [supabase.com](https://supabase.com)
2. Klik **New Project**
3. Isi nama project: `esi-pipeline`
4. Pilih region: **Southeast Asia (Singapore)**
5. Set database password yang kuat → simpan di tempat aman

### Jalankan Schema
1. Masuk ke **SQL Editor** di sidebar Supabase
2. Klik **New Query**
3. Copy seluruh isi `database/migrations/001_initial_schema.sql`
4. Paste ke editor → klik **Run**
5. Pastikan hasil: `0 rows` tanpa error

### Verifikasi
Cek di **Table Editor** — seharusnya muncul 10 tabel:
`rfi` · `converted` · `rfp` · `status_tracker` · `approved` · `projects` · `monev` · `weekly` · `project_report` · `research_doc`

---

## 2. Deploy Aplikasi

### Opsi A — GitHub Pages (Recommended)
1. Push repo ke GitHub
2. Masuk ke **Settings → Pages**
3. Source: `Deploy from branch` → branch `main` → folder `/app`
4. Klik **Save**
5. Akses di: `https://USERNAME.github.io/esi-pipeline/pipeline.html`

### Opsi B — Supabase Storage
1. Masuk ke **Storage** di Supabase
2. Buat bucket baru: `app` (Public)
3. Upload `app/pipeline.html` dan `app/dashboard.html`
4. Akses via public URL bucket

### Opsi C — Buka Lokal
Buka langsung file `app/pipeline.html` di browser — tidak perlu server.

---

## 3. Integrasi Supabase ke App (Opsional)

Saat ini app menggunakan `localStorage`. Untuk connect ke Supabase:

### Tambahkan Supabase Client
```html
<!-- Tambahkan di <head> sebelum </head> -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  const SUPABASE_URL = 'https://XXXX.supabase.co';
  const SUPABASE_ANON_KEY = 'eyJ...';
  const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
</script>
```

### Ganti localStorage dengan Supabase calls
```javascript
// Sebelum (localStorage):
DB.rfi.push(obj);
localStorage.setItem('e3_rfi', JSON.stringify(DB.rfi));

// Sesudah (Supabase):
const { data, error } = await supabase.from('rfi').insert(obj);
```

---

## 4. Environment Variables

Jangan pernah commit API key ke GitHub. Gunakan cara ini:

```javascript
// config.js (di-gitignore)
const CONFIG = {
  supabaseUrl: 'https://XXXX.supabase.co',
  supabaseKey: 'eyJ...'
};
```

Tambahkan `config.js` ke `.gitignore`.

---

## 5. Reset Database

Untuk reset total dan mulai dari awal:
```sql
-- Jalankan di SQL Editor Supabase
-- File: database/migrations/001_initial_schema.sql
-- (Sudah include DROP semua di awal file — aman dijalankan ulang)
```

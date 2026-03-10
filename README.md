# 🌿 ESI Pipeline

**Platform manajemen pipeline bisnis & proyek Enviro Strategic Indonesia**

Sistem terpadu untuk tracking seluruh alur bisnis — dari inquiry klien, proposal, hingga eksekusi proyek dan dokumentasi riset — dengan antarmuka modern berbasis browser dan database Supabase.

---

## ✨ Fitur

| Modul | Deskripsi |
|-------|-----------|
| 📥 **RFI Tracker** | Catat & kualifikasi inquiry masuk dari calon klien |
| 🔀 **Converted Bridge** | Bridge otomatis Phase 1 → Phase 2 |
| 📝 **Request Form** | Penyusunan proposal & BOQ |
| 📊 **Status Tracker** | Monitor status seluruh proposal berjalan |
| 🚀 **Approved Bridge** | Bridge otomatis Phase 2 → Phase 3 |
| 📁 **Data Project** | Registry master semua proyek aktif |
| 🔬 **MONEV 4-Gate** | Review kualitas 4 gate per proyek |
| 📅 **Weekly Update** | Log progress mingguan per proyek |
| 📋 **Project Report** | Tracking penulisan laporan (Bab 1–5) |
| 📂 **Research Docs** | Arsip dokumentasi riset & metodologi |

---

## 📁 Struktur Repo

```
esi-pipeline/
│
├── app/
│   ├── pipeline.html        # Aplikasi utama ESI Pipeline (Taskora style)
│   └── dashboard.html       # Executive Dashboard (dark mode)
│
├── database/
│   ├── migrations/
│   │   └── 001_initial_schema.sql   # Schema lengkap Supabase
│   └── seeds/
│       └── sample_data.sql          # Data contoh untuk testing
│
├── docs/
│   ├── ARCHITECTURE.md      # Arsitektur sistem & alur data
│   ├── DATABASE.md          # Dokumentasi tabel & relasi
│   └── DEPLOYMENT.md        # Panduan deploy ke Supabase
│
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── PULL_REQUEST_TEMPLATE.md
│
├── .gitignore
├── CHANGELOG.md
└── README.md
```

---

## 🚀 Quick Start

### 1. Clone repo

```bash
git clone https://github.com/USERNAME/esi-pipeline.git
cd esi-pipeline
```

### 2. Setup database Supabase

1. Buka [supabase.com](https://supabase.com) → buat project baru
2. Masuk ke **SQL Editor**
3. Copy-paste isi file `database/migrations/001_initial_schema.sql`
4. Klik **Run**

### 3. Jalankan aplikasi

Buka langsung di browser — tidak perlu server:

```bash
# macOS / Linux
open app/pipeline.html

# Windows
start app/pipeline.html
```

> **Catatan:** Data disimpan di `localStorage` browser secara lokal. Untuk integrasi penuh dengan Supabase, lihat `docs/DEPLOYMENT.md`.

---

## 🗄️ Database Schema

```
rfi ──────────────► converted ──► rfp ──► status_tracker ──► approved
                                                                   │
                                                                   ▼
research_doc ◄── project_report ◄── monev ◄── weekly ◄── projects ◄┘
```

**10 tabel utama:**
`rfi` · `converted` · `rfp` · `status_tracker` · `approved` · `projects` · `monev` · `weekly` · `project_report` · `research_doc`

**4 views siap pakai:**
- `v_pipeline_summary` — KPI ringkasan seluruh pipeline
- `v_project_aktif` — Project aktif + info gate + status laporan
- `v_funnel_konversi` — Funnel dari inquiry sampai selesai
- `v_weekly_terbaru` — Update mingguan terbaru per proyek

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Frontend | HTML5 · CSS3 · Vanilla JavaScript |
| Database | PostgreSQL via Supabase |
| Storage (lokal) | Browser localStorage |
| Font | Plus Jakarta Sans · JetBrains Mono |
| Hosting | GitHub Pages / Supabase Storage |

---

## 📦 Versi

| Versi | Tanggal | Deskripsi |
|-------|---------|-----------|
| v4.0 | Mar 2026 | Taskora UI redesign + Research Docs module |
| v3.0 | Feb 2026 | Supabase schema + RLS + Views |
| v2.0 | Jan 2026 | Project Report Tracker + auto-sync |
| v1.0 | Des 2025 | Initial release — 8 modul pipeline |

---

## 🤝 Kontribusi

1. Fork repo ini
2. Buat branch fitur: `git checkout -b feat/nama-fitur`
3. Commit perubahan: `git commit -m 'feat: tambah fitur X'`
4. Push ke branch: `git push origin feat/nama-fitur`
5. Buat Pull Request

---

## 📄 Lisensi

Proprietary — © 2026 Enviro Strategic Indonesia. All rights reserved.

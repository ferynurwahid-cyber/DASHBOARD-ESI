# Changelog

Semua perubahan penting pada project ini didokumentasikan di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [4.0.0] - 2026-03-10

### Added
- Redesign UI Pipeline menggunakan Taskora-style (light mode, card-based, Plus Jakarta Sans)
- Executive Dashboard dark mode dengan neon accent (Gen Z aesthetic)
- Modul **Project Report Tracker** — tracking penulisan Bab 1–5 per proyek
- Modul **Research Documentation** — arsip riset lengkap dengan metodologi & temuan
- Supabase PostgreSQL schema lengkap (v4) — 10 tabel, 4 views, 12 triggers, 19 index
- Row Level Security (RLS) di semua tabel
- Auto-sync: Project Report otomatis dibuat saat project baru ditambahkan
- Trigger sync progress dari MONEV gate (tiap gate ✅ = +25%)

### Changed
- Sidebar dari dark green menjadi light white (Taskora style)
- Typography dari Syne + DM Sans → Plus Jakarta Sans
- Button style lebih rounded dengan colored shadow
- Progress bar lebih tebal (6px) dengan pill border-radius

### Fixed
- Badge count di sidebar tidak update setelah delete item
- MONEV gate sync tidak trigger saat insert pertama

---

## [3.0.0] - 2026-02-01

### Added
- Supabase SQL schema pertama (v1–v3)
- Executive Dashboard dengan McKinsey-style editorial design
- Funnel konversi visual di halaman dashboard
- Donut chart distribusi status project

### Fixed
- SQL error `type already exists` pada re-run schema
- SQL error `relation already exists` untuk index

---

## [2.0.0] - 2026-01-15

### Added
- Integrasi data Excel Project Report ke dalam app
- Auto-create MONEV entry saat project baru dibuat
- Weekly Update dengan card layout
- Export CSV untuk semua modul

### Changed
- Versi dari v3.0 ke v4.0 Data Enviro

---

## [1.0.0] - 2025-12-01

### Added
- Initial release ESI Pipeline App
- 8 modul: RFI, Converted, RFP, Status, Approved, Projects, MONEV, Weekly
- localStorage persistence
- Toast notification system
- Modal form dengan auto-fill dari data proyek

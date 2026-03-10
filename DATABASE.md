# Dokumentasi Database

## Tabel & Relasi

### `rfi` — Phase 1 Inquiry
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | UUID PK | Auto-generate |
| perusahaan | TEXT | Nama perusahaan klien |
| industri | ENUM | Kluster industri |
| pic | TEXT | Nama contact person |
| status | ENUM | Diskusi Awal / Qualified / Converted / Tidak Dilanjutkan |
| potensi | ENUM | High / Medium / Low |

### `converted` — Bridge 1→2
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | UUID PK | |
| rfi_id | UUID FK | → rfi.id |
| tgl_converted | DATE | |
| status_rfp | ENUM | Status request form |

### `rfp` — Request Form / Proposal
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | UUID PK | |
| converted_id | UUID FK | → converted.id |
| layanan | ENUM | Jenis layanan ESI |
| prioritas | ENUM | High / Medium / Low |
| deadline | DATE | Deadline pengiriman proposal |

### `status_tracker` — Status Proposal
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | UUID PK | |
| rfp_id | UUID FK | → rfp.id |
| status | ENUM | Draft → Review → Terkirim → Disetujui / Ditolak |
| nilai | NUMERIC | Nilai proposal (Rp) |

### `approved` — Bridge 2→3
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | UUID PK | |
| status_tracker_id | UUID FK | → status_tracker.id |
| pm | TEXT | Project Manager ditugaskan |
| status_onboarding | ENUM | Status onboarding |

### `projects` — Data Project
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| id | UUID PK | |
| nama | TEXT UNIQUE | Nama proyek (key untuk relasi) |
| progress | SMALLINT | 0–100, sync dari MONEV |
| fase | ENUM | Fase aktif proyek |
| status | ENUM | 🟢 On Track / 🟡 Perhatian / 🔴 Terlambat / ✅ Selesai |

### `monev` — MONEV 4-Gate
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| project_id | UUID FK UNIQUE | → projects.id |
| g1–g4 | ENUM | ⬜ Belum / 🔄 On Review / ❌ Revisi / ✅ Approved |
| keputusan | ENUM | Keputusan final gate review |

### `weekly` — Weekly Update
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| project_id | UUID FK | → projects.id |
| minggu | SMALLINT | Nomor minggu |
| progress | SMALLINT | % progress saat update |
| sudah / rencana / kendala | TEXT | Isi laporan mingguan |

### `project_report` — Tracker Laporan
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| project_id | UUID FK | → projects.id |
| bab1–bab5 | BOOLEAN | Status penulisan per bab |
| status | ENUM | Belum Mulai → Dalam Pengerjaan → Selesai |

### `research_doc` — Dokumentasi Riset
| Kolom | Tipe | Keterangan |
|-------|------|-----------|
| project_id | UUID FK | → projects.id |
| metodologi | ENUM | Kuantitatif / Kualitatif / Mixed / dll |
| research_output | ENUM | Jenis output riset |

---

## Views

### `v_pipeline_summary`
KPI ringkasan seluruh pipeline — cocok untuk card angka di dashboard.
```sql
SELECT * FROM v_pipeline_summary;
```

### `v_project_aktif`
Project yang sedang berjalan + info gate MONEV + status laporan.
```sql
SELECT * FROM v_project_aktif ORDER BY deadline;
```

### `v_funnel_konversi`
Jumlah per stage pipeline dari inquiry sampai selesai.
```sql
SELECT * FROM v_funnel_konversi;
```

### `v_weekly_terbaru`
Update mingguan terbaru (1 row per project).
```sql
SELECT * FROM v_weekly_terbaru;
```

---

## Triggers

| Trigger | Tabel | Fungsi |
|---------|-------|--------|
| `trg_*_upd` (×10) | Semua tabel | Auto-update kolom `updated_at` |
| `trg_monev_sync` | monev | Sync `progress` project saat gate diupdate |
| `trg_project_auto` | projects | Auto-create monev + project_report saat project baru |

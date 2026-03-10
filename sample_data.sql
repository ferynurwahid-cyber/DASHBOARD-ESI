-- ============================================================
--  ESI PIPELINE — Sample Data / Seeds
--  Jalankan SETELAH 001_initial_schema.sql
-- ============================================================

-- Sample RFI
INSERT INTO rfi (perusahaan, industri, pic, jabatan, kontak, sumber, kebutuhan, lokasi, status, potensi, next_action) VALUES
  ('PT Semen Nusantara',   'Manufaktur',   'Budi Santoso',  'CSR Manager',           'budi@semen.co.id',     'Referral',               'Pemetaan Sosial area tambang Tuban',       'Tuban, Jawa Timur',   'Qualified',               'High',   'Kirim proposal minggu ini'),
  ('PLN Persero',          'Energi',       'Ratna Dewi',    'Head of Sustainability', 'ratna@pln.co.id',      'LinkedIn',               'SLH untuk PLTU Suralaya',                  'Cilegon, Banten',     'Diskusi Awal',            'High',   'Follow up 3 hari lagi'),
  ('PT Freeport Indonesia','Pertambangan', 'James Tanaka',  'Community Relations',    'james@freeport.com',   'Conference / Exhibition', 'PROPER & Stakeholder Engagement',          'Timika, Papua',       'Converted to Proposal',   'High',   NULL),
  ('Bank Mandiri',         'Perbankan',    'Dewi Kusuma',   'CSR Officer',            'dewi.k@mandiri.co.id', 'Referral',               'IKM UMKM Binaan Mandiri Jawa Tengah',      'Semarang, Jawa Tengah','Qualified',              'Medium', 'Siapkan proposal IKM'),
  ('PT Pertamina EP',      'Migas',        'Hendra Wijaya', 'Field Relations Manager','hendra@pertamina.com', 'Cold Call / Email',      'Stakeholder Engagement area Cepu',         'Blora, Jawa Tengah',  'Diskusi Awal',            'High',   'Presentasi konsep minggu depan');

-- Sample Projects (trigger akan auto-create MONEV + Project Report)
INSERT INTO projects (nama, jenis_riset, klien, pm, tgl_mulai, deadline, tim_peneliti, lokasi, nilai, progress, fase, status) VALUES
  ('Pemetaan Sosial Tuban 2026',     'Pemetaan Sosial',       'PT Semen Nusantara',    'Andi Prasetyo',    '2026-01-15', '2026-04-30', 'Andi P, Sari W, Bimo R',  'Tuban, Jawa Timur',    180000000, 60, 'Penulisan',  '🟢 On Track'),
  ('SLH PLTU Suralaya',             'SLH',                   'PLN Persero',           'Sari Wulandari',   '2026-02-01', '2026-06-30', 'Sari W, Deni K',          'Cilegon, Banten',      250000000, 25, 'Fieldwork',  '🟡 Perhatian'),
  ('PROPER Freeport Papua',         'PROPER',                'PT Freeport Indonesia', 'Reza Mahendra',    '2026-01-20', '2026-05-31', 'Reza M, Ayu N, Fajar S',  'Timika, Papua',        320000000, 75, 'Gate Review','🟢 On Track'),
  ('IKM UMKM Bank Mandiri Jateng',  'IKM',                   'Bank Mandiri',          'Novia Anggraeni',  '2026-03-01', '2026-07-31', 'Novia A, Yusuf H',        'Semarang, Jawa Tengah', 95000000,  5, 'Persiapan',  '🟢 On Track');

-- Sample Weekly Updates
INSERT INTO weekly (project_id, nama_proyek, pm, minggu, progress, tgl_update, sudah, rencana, kendala) VALUES
  ((SELECT id FROM projects WHERE nama = 'Pemetaan Sosial Tuban 2026'),
   'Pemetaan Sosial Tuban 2026', 'Andi Prasetyo', 8, 60, '2026-03-08',
   'Selesai penulisan Bab 3 dan 4. FGD dengan komunitas tambang Desa Sulorejo.',
   'Mulai penulisan Bab 5. Review internal dengan QA.',
   NULL),

  ((SELECT id FROM projects WHERE nama = 'SLH PLTU Suralaya'),
   'SLH PLTU Suralaya', 'Sari Wulandari', 5, 25, '2026-03-07',
   'Fieldwork minggu ke-2. Pengambilan sampel udara dan air di 3 titik lokasi.',
   'Analisis laboratorium sampel. Input data ke sistem.',
   'Akses ke zona buffer PLTU terbatas — perlu koordinasi ulang dengan pihak PLN.');

-- Update MONEV untuk project PROPER (sudah advanced)
UPDATE monev SET
  g1 = '✅ Approved',
  g2 = '✅ Approved',
  g3 = '🔄 On Review',
  g4 = '⬜ Belum',
  keputusan = 'Dalam Proses'
WHERE nama_proyek = 'PROPER Freeport Papua';

-- Update Project Report untuk project Tuban (sudah banyak progress)
UPDATE project_report SET
  input_data = TRUE,
  bab1       = TRUE,
  bab2       = TRUE,
  bab3       = TRUE,
  bab4       = TRUE,
  bab5       = FALSE,
  status     = 'Dalam Pengerjaan',
  link_draft = 'https://drive.google.com/drive/example'
WHERE jenis_riset = 'Pemetaan Sosial Tuban 2026';

-- Sample Research Doc
INSERT INTO research_doc (project_id, judul, client, lokasi, tgl_mulai, tgl_selesai, metodologi, research_output, temuan, scope) VALUES
  ((SELECT id FROM projects WHERE nama = 'PROPER Freeport Papua'),
   'PROPER Assessment PT Freeport Indonesia 2025',
   'PT Freeport Indonesia',
   'Timika, Papua',
   '2025-02-01',
   '2025-07-30',
   'Mixed Methods',
   'Laporan Riset',
   'Program CSR berkontribusi signifikan pada peningkatan IPM di Kabupaten Mimika sebesar 2.3 poin dalam 3 tahun terakhir. Keterlibatan komunitas adat meningkat 40%.',
   'Kabupaten Mimika, 12 distrik, 68 kampung, ±45.000 jiwa');

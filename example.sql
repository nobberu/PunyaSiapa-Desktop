BEGIN;

CREATE TABLE pengguna (
    id_pengguna BIGINT NOT NULL AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    nomor_kontak VARCHAR(20) NOT NULL,
    foto_profil VARCHAR(255),
    PRIMARY KEY (id_pengguna),
    UNIQUE KEY pengguna_username_key (username)
);

CREATE TABLE kategori (
    id_kategori BIGINT NOT NULL AUTO_INCREMENT,
    nama_kategori VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_kategori)
);

CREATE TABLE postingan (
    id_postingan BIGINT NOT NULL AUTO_INCREMENT,
    id_pengguna BIGINT NOT NULL,
    id_kategori BIGINT NOT NULL,
    nama_barang VARCHAR(100) NOT NULL,
    deskripsi TEXT NOT NULL,
    foto VARCHAR(255) NOT NULL,
    lokasi_kejadian VARCHAR(100) NOT NULL,
    waktu_kejadian DATE NOT NULL,
    jenis_postingan VARCHAR(20) NOT NULL,
    status_barang VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_tampil ENUM('tampil', 'disembunyikan', 'dihapus') NOT NULL DEFAULT 'tampil',
    PRIMARY KEY (id_postingan),
    FULLTEXT KEY idx_postingan_fts (nama_barang, deskripsi, lokasi_kejadian)
);

CREATE TABLE komentar (
    id_komentar BIGINT NOT NULL AUTO_INCREMENT,
    id_pengguna BIGINT NOT NULL,
    id_postingan BIGINT NOT NULL,
    isi_komentar TEXT NOT NULL,
    waktu_komentar TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_tampil ENUM('tampil', 'disembunyikan', 'dihapus') NOT NULL DEFAULT 'tampil',
    PRIMARY KEY (id_komentar)
);

CREATE TABLE report_postingan (
    id_report_postingan BIGINT NOT NULL AUTO_INCREMENT,
    id_postingan BIGINT NOT NULL,
    id_pengguna BIGINT NOT NULL,
    kategori_report VARCHAR(30) NOT NULL DEFAULT 'other',
    alasan_report TEXT NOT NULL,
    waktu_report TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_report VARCHAR(30) NOT NULL DEFAULT 'pending',
    reviewed_by BIGINT,
    reviewed_at TIMESTAMP NULL,
    catatan_admin TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active_report_user BIGINT GENERATED ALWAYS AS (
        CASE WHEN status_report IN ('pending', 'reviewing') THEN id_pengguna END
    ) STORED,
    active_report_target BIGINT GENERATED ALWAYS AS (
        CASE WHEN status_report IN ('pending', 'reviewing') THEN id_postingan END
    ) STORED,
    PRIMARY KEY (id_report_postingan),
    UNIQUE KEY uq_report_postingan_aktif (active_report_user, active_report_target),
    CONSTRAINT chk_report_postingan_kategori CHECK (kategori_report IN ('spam', 'fraud', 'harassment', 'misleading', 'privacy', 'inappropriate', 'other')),
    CONSTRAINT chk_report_postingan_status CHECK (status_report IN ('pending', 'reviewing', 'resolved', 'rejected'))
);

CREATE TABLE claim (
    id_claim BIGINT NOT NULL AUTO_INCREMENT,
    id_pengguna BIGINT NOT NULL,
    id_postingan BIGINT NOT NULL,
    bukti_claim TEXT NOT NULL,
    status_claim VARCHAR(255) NOT NULL,
    waktu_claim TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    foto_bukti VARCHAR(255),
    PRIMARY KEY (id_claim)
);

CREATE TABLE report_komentar (
    id_report_komentar BIGINT NOT NULL AUTO_INCREMENT,
    id_komentar BIGINT NOT NULL,
    id_pengguna BIGINT NOT NULL,
    kategori_report VARCHAR(30) NOT NULL DEFAULT 'other',
    alasan_report TEXT NOT NULL,
    waktu_report TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_report VARCHAR(30) NOT NULL DEFAULT 'pending',
    reviewed_by BIGINT,
    reviewed_at TIMESTAMP NULL,
    catatan_admin TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active_report_user BIGINT GENERATED ALWAYS AS (
        CASE WHEN status_report IN ('pending', 'reviewing') THEN id_pengguna END
    ) STORED,
    active_report_target BIGINT GENERATED ALWAYS AS (
        CASE WHEN status_report IN ('pending', 'reviewing') THEN id_komentar END
    ) STORED,
    PRIMARY KEY (id_report_komentar),
    UNIQUE KEY uq_report_komentar_aktif (active_report_user, active_report_target),
    CONSTRAINT chk_report_komentar_kategori CHECK (kategori_report IN ('spam', 'fraud', 'harassment', 'misleading', 'privacy', 'inappropriate', 'other')),
    CONSTRAINT chk_report_komentar_status CHECK (status_report IN ('pending', 'reviewing', 'resolved', 'rejected'))
);

CREATE TABLE log_moderasi (
    id_log BIGINT NOT NULL AUTO_INCREMENT,
    id_admin BIGINT NOT NULL,
    jenis_target VARCHAR(20) NOT NULL,
    id_target BIGINT NOT NULL,
    jenis_aksi VARCHAR(30) NOT NULL,
    alasan TEXT,
    status_sebelum VARCHAR(30),
    status_sesudah VARCHAR(30),
    waktu_aksi TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_log),
    CONSTRAINT chk_log_moderasi_target CHECK (jenis_target IN ('postingan', 'komentar')),
    CONSTRAINT chk_log_moderasi_aksi CHECK (jenis_aksi IN ('review', 'reject', 'hide', 'restore'))
);

ALTER TABLE postingan
    ADD CONSTRAINT fk_postingan_id_pengguna
    FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

ALTER TABLE postingan
    ADD CONSTRAINT fk_postingan_id_kategori
    FOREIGN KEY (id_kategori) REFERENCES kategori (id_kategori) ON DELETE RESTRICT;

ALTER TABLE komentar
    ADD CONSTRAINT fk_komentar_id_pengguna
    FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

ALTER TABLE komentar
    ADD CONSTRAINT fk_komentar_id_postingan
    FOREIGN KEY (id_postingan) REFERENCES postingan (id_postingan) ON DELETE RESTRICT;

ALTER TABLE report_postingan
    ADD CONSTRAINT fk_report_postingan_id_postingan
    FOREIGN KEY (id_postingan) REFERENCES postingan (id_postingan) ON DELETE RESTRICT;

ALTER TABLE report_postingan
    ADD CONSTRAINT fk_report_postingan_id_pengguna
    FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

ALTER TABLE claim
    ADD CONSTRAINT fk_claim_id_pengguna
    FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

ALTER TABLE claim
    ADD CONSTRAINT fk_claim_id_postingan
    FOREIGN KEY (id_postingan) REFERENCES postingan (id_postingan) ON DELETE RESTRICT;

ALTER TABLE report_komentar
    ADD CONSTRAINT fk_report_komentar_id_komentar
    FOREIGN KEY (id_komentar) REFERENCES komentar (id_komentar) ON DELETE RESTRICT;

ALTER TABLE report_komentar
    ADD CONSTRAINT fk_report_komentar_id_pengguna
    FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

ALTER TABLE report_postingan
    ADD CONSTRAINT fk_report_postingan_reviewed_by
    FOREIGN KEY (reviewed_by) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

ALTER TABLE report_komentar
    ADD CONSTRAINT fk_report_komentar_reviewed_by
    FOREIGN KEY (reviewed_by) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

ALTER TABLE log_moderasi
    ADD CONSTRAINT fk_log_moderasi_id_admin
    FOREIGN KEY (id_admin) REFERENCES pengguna (id_pengguna) ON DELETE RESTRICT;

COMMIT;

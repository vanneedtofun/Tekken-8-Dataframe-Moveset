# Tekken Move Guide

Aplikasi Android berbasis Flutter untuk melihat daftar jurus dan mencari informasi moveset Tekken 8.

## Struktur File

```text
tekken_move_guide_fixed/
├── android/                  # Konfigurasi aplikasi Android
├── backend/
│   ├── app/
│   │   ├── main.py           # Endpoint API untuk tabel dan pencarian jurus
│   │   ├── model.py          # Model data request API
│   │   ├── movetable.py      # Pengambilan dan pencarian data jurus
│   │   └── notation.py       # Pembuatan gambar notasi tombol
│   └── run_api.ps1           # Menjalankan server API lokal di Windows
├── lib/
│   ├── models/
│   │   └── move_model.dart   # Model data jurus di aplikasi
│   ├── screens/
│   │   ├── home_page.dart        # Halaman utama dan formulir pencarian
│   │   ├── move_table_page.dart   # Daftar lengkap jurus karakter
│   │   └── find_move_page.dart    # Hasil pencarian jurus
│   ├── services/
│   │   ├── api_config.dart          # Alamat server API
│   │   └── tekken_api_service.dart  # Komunikasi aplikasi dengan API
│   ├── widgets/
│   │   ├── move_card.dart     # Tampilan informasi satu jurus
│   │   ├── loading_widget.dart # Tampilan saat data dimuat
│   │   └── error_widget.dart  # Tampilan error dan tombol coba lagi
│   └── main.dart              # Titik masuk aplikasi Flutter
├── pubspec.yaml               # Dependensi dan konfigurasi Flutter
└── README.md                  # Dokumentasi proyek
```

## Fitur Utama Aplikasi

- Menampilkan daftar jurus berdasarkan nama karakter.
- Mencari jurus berdasarkan nama atau notasi tombol, seperti `jab`, `df+2`, dan `EWGF`.
- Menampilkan input, startup frame, damage, hit level, frame on hit/block, counter hit, state, dan catatan jurus.
- Menampilkan status pemuatan data, pesan error, dan tombol untuk mencoba kembali.
- Halaman utama dapat dibuka tanpa server. Tabel dan pencarian memerlukan server API lokal serta koneksi internet.
- Data Tekken 8 diambil dari [Tekken Frame Data](https://tekkenframedata.net/database). Jalankan server API di PowerShell pada folder proyek dengan perintah ` .\backend\run_api.ps1 `; server memakai port `8000` dan emulator Android mengaksesnya melalui `http://10.0.2.2:8000`.

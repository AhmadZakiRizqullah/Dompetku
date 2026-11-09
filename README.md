# Dompetku Tracker 💰

> **Aplikasi Pencatatan Keuangan Pribadi (Offline-First Personal Finance Tracker)**  
> Dibangun dengan Flutter & Drift (SQLite) dengan desain *Modern & Minimalist*.

---

## 📱 Tentang Dompetku

**Dompetku** adalah aplikasi manajemen dan pencatatan keuangan pribadi yang mengutamakan privasi pengguna (*100% offline-first*). Semua data tersimpan aman secara lokal di perangkat Anda tanpa perlu koneksi internet atau server pihak ketiga.

Dirancang dengan prinsip estetika *Modern & Minimalist* menggunakan palet warna *Warm Cream* dan *Deep Teal*, Dompetku memberikan pengalaman pencatatan keuangan harian yang nyaman, bersih, dan intuitif.

---

## ✨ Fitur Utama

- **Multi-Wallet Management**: Kelola banyak dompet sekaligus (Rekening Bank, E-Wallet seperti GoPay/OVO/ShopeePay, dan Uang Tunai) dengan saldo *real-time*.
- **Privasi Saldo (Toggle Visibility)**: Sembunyikan atau tampilkan saldo wallet pada halaman utama sesuai kenyamanan Anda.
- **Pencatatan Transaksi Lengkap**:
  - **Pemasukan (*Income*)**: Catat penghasilan berdasarkan kategori.
  - **Pengeluaran (*Expense*)**: Pantau pengeluaran harian dan bulanan.
  - **Transfer antar Wallet**: Pindah dana antar akun dengan dukungan biaya admin transaksi.
- **Konsistensi Saldo Atomik**: Pembaruan saldo otomatis menggunakan transaksi database Drift (*ACID compliant*).
- **Statistik & Visualisasi**: Ringkasan arus kas serta grafik persentase pengeluaran per kategori (*FL Chart*).
- **Ekspor & Impor Data**:
  - **Excel (.xlsx)**: Impor transaksi dari file Excel atau unduh rekapan transaksi dengan verifikasi data duplikat.
  - **PDF (.pdf)**: Cetak laporan keuangan rapi dengan ringkasan mutasi siap bagikan.
- **Notifikasi Pengingat Harian**: Pengingat otomatis untuk mencatat keuangan setiap hari.

---

## 🛠️ Tech Stack & Dependencies

| Kategori | Teknologi / Pustaka |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart SDK `>=3.2.0 <4.0.0`) |
| **State Management** | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| **Local Database** | [Drift (SQLite)](https://drift.simonbinder.eu/) + `sqlite3_flutter_libs` |
| **Charts & Graphs** | [fl_chart](https://pub.dev/packages/fl_chart) |
| **Typography & UI** | [google_fonts](https://pub.dev/packages/google_fonts) (Poppins), `intl` |
| **Export / Reporting**| [excel](https://pub.dev/packages/excel), [pdf](https://pub.dev/packages/pdf), [printing](https://pub.dev/packages/printing) |
| **Local Notifications**| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications), `timezone` |

---

## 🎨 Design System

- **Personality**: Modern, Clean & Minimalist
- **Typography**: Poppins
- **Color Palette**:
  - **Background**: `#FDFBEE` (*Warm Cream*)
  - **Primary**: `#015551` (*Deep Teal*)
  - **Secondary**: `#57B4BA` (*Soft Teal*)
  - **Accent / Alert**: `#FE4F2D` (*Vibrant Orange*)

---

## 📂 Struktur Proyek

```text
lib/
├── core/
│   ├── constants/       # Konstanta & konfigurasi umum
│   ├── theme/           # Tema aplikasi & palet warna
│   └── utils/           # Helper format mata uang (Rp) & tanggal
├── data/
│   ├── local/           # Konfigurasi Drift SQLite (tabel & DAOs)
│   └── services/        # Service Excel, PDF, & Notifikasi
├── presentation/
│   ├── dashboard/       # Tampilan utama & ringkasan saldo
│   ├── transaction/     # Riwayat & form tambah transaksi
│   ├── wallet/          # Manajemen & daftar wallet
│   ├── category/        # Manajemen kategori transaksi
│   ├── statistics/      # Grafik & analisis keuangan
│   ├── splash/          # Tampilan pembuka aplikasi
│   ├── settings/        # Pengaturan, Backup & Restore (Excel/PDF)
│   └── widgets/         # Komponen UI reusable
├── providers/           # Riverpod state providers
└── main.dart            # Titik masuk utama aplikasi
```

---

## 🚀 Memulai (Getting Started)

### 1. Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi stable terbaru)
- Android Studio / VS Code
- Perangkat Android (USB Debugging) atau Emulator

### 2. Kloning Repository
```bash
git clone https://github.com/<username>/dompetku-tracker.git
cd dompetku-tracker
```

### 3. Pasang Dependencies
```bash
flutter pub get
```

### 4. Generate Kode Drift (Database)
Jalankan `build_runner` untuk men-generate file `*.g.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

*(Opsional: gunakan mode watch jika sedang dalam tahap pengembangan)*
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 5. Jalankan Aplikasi
```bash
flutter run
```

### 6. Build APK Rilis
Untuk meng-generate APK siap pasang yang dioptimalkan:
```bash
flutter build apk --release --split-per-abi
```
File APK akan berada pada direktori:  
`build/app/outputs/flutter-apk/`

---

## 🔒 Privasi & Keamanan
Aplikasi ini tidak mengirim data keuangan Anda ke server manapun. Seluruh database SQLite tersimpan secara lokal di *sandbox storage* perangkat Anda. Pastikan untuk memanfaatkan fitur ekspor Excel/PDF secara berkala untuk mencadangkan (*backup*) data Anda.

---

## 📄 Lisensi
Didistribusikan di bawah lisensi MIT. Silakan gunakan dan sesuaikan sesuai kebutuhan Anda.

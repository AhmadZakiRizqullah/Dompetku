# **Daftar Tugas Pengembangan (Task List)**

Dokumen ini berisi tahapan pengerjaan aplikasi pencatatan keuangan pribadi menggunakan Flutter dan Drift (SQLite).

## **Fase 1: Persiapan & Inisialisasi Proyek**

> * [x] **1.1 Setup Flutter Project**  
  * Buat project Flutter baru (flutter create nama\_aplikasi).  
  * Atur struktur folder (misal: data, domain, presentation, utils).  
> * [x] **1.2 Instalasi Dependencies**  
  * Tambahkan package utama di pubspec.yaml: drift, sqlite3\_flutter\_libs, path\_provider, path, flutter\_riverpod (atau state management pilihan), intl, excel, pdf, printing, file\_picker, share\_plus, fl\_chart.  
  * Tambahkan dev\_dependencies: drift\_dev, build\_runner.  
> * [x] **1.3 Konfigurasi Tema & Utilitas Dasar**  
  * Buat helper format mata uang Rupiah (Rp 10.000) dan format tanggal menggunakan intl.  
  * Siapkan tema aplikasi (warna untuk pemasukan/hijau, pengeluaran/merah, transfer/biru).

## **Fase 2: Database Layer (Drift SQLite)**

> * [x] **2.1 Definisi Tabel Drift**  
  * Buat class tabel Wallets, Categories, dan Transactions.  
  * Jalankan dart run build\_runner build untuk men-generate kode Drift.  
> * [x] **2.2 Seeding Data Awal (Default Data)**  
  * Buat fungsi pada MigrationStrategy (beforeOpen) di Drift untuk mengisi kategori default (Makan, Transport, Tagihan, Gaji, dll) saat aplikasi pertama kali diinstal.  
> * [x] **2.3 Pembuatan DAO (Data Access Objects)**  
  * **WalletDao:** CRUD Wallet, stream total saldo semua wallet, stream daftar wallet.  
  * **CategoryDao:** CRUD Kategori, filter kategori berdasarkan tipe (INCOME/EXPENSE).  
  * **TransactionDao:**  
    * Fungsi tambah transaksi menggunakan blok transaction(() async { ... }) di Drift agar pencatatan transaksi dan update saldo current\_balance pada tabel Wallets berjalan secara *atomic* (aman dari gagal sebagian).  
    * Fungsi edit & hapus transaksi (otomatis mengembalikan/menyesuaikan saldo pada wallet terkait).  
    * Query transaksi berdasarkan rentang tanggal, wallet, dan kategori.

## **Fase 3: Fitur Manajemen Wallet & Kategori**

> * [x] **3.1 Halaman Daftar Wallet**  
  * Tampilkan list rekening bank, e-wallet, dan uang tunai beserta saldonya masing-masing.  
  * Tampilkan total keseluruhan saldo di bagian atas halaman.  
> * [x] **3.2 Form Tambah/Edit Wallet**  
  * Input nama wallet, tipe (Bank, E-Wallet, Tunai), dan saldo awal.  
  * Fitur "Sesuaikan Saldo" (membuat transaksi penyesuaian otomatis atau mengubah saldo langsung).  
> * [x] **3.3 Halaman Manajemen Kategori**  
  * Tampilan tab terpisah untuk kategori Pemasukan dan Pengeluaran.  
  * Dialog/Form untuk menambah dan mengedit nama kategori.

## **Fase 4: Fitur Pencatatan Transaksi & Dashboard**

> * [x] **4.1 Halaman Utama (Dashboard)**  
  * Card ringkasan: Total Kekayaan Bersih, Total Pemasukan & Pengeluaran bulan ini.  
  * Horizontal list/carousel untuk melihat saldo masing-masing Wallet dengan cepat.  
  * Daftar 5-10 transaksi terakhir.  
> * [x] **4.2 Form Tambah/Edit Transaksi**  
  * Buat 3 pilihan mode/tab: **Pengeluaran**, **Pemasukan**, **Transfer**.  
  * Mode Pengeluaran/Pemasukan: Input Nominal, Pilih Wallet, Pilih Kategori, Pilih Tanggal, Catatan.  
  * Mode Transfer: Input Nominal, Biaya Admin (opsional), Pilih Wallet Sumber, Pilih Wallet Tujuan, Tanggal, Catatan.  
> * [x] **4.3 Halaman Riwayat Transaksi & Filter**  
  * Daftar seluruh transaksi yang dikelompokkan per tanggal.  
  * Fitur filter berdasarkan Bulan/Tahun atau Rentang Tanggal Custom.  
  * Fitur filter berdasarkan Wallet tertentu (untuk melihat mutasi spesifik satu rekening/e-wallet).  
> * [x] **4.4 Halaman Statistik**  
  * Integrasi fl\_chart (Pie Chart) untuk menampilkan persentase pengeluaran per kategori pada bulan yang dipilih.

## **Fase 5: Fitur Export & Import (Excel & PDF)**

> * [x] **5.1 Fitur Export ke Excel (.xlsx)**  
  * Buat service menggunakan package excel.  
  * Ambil data transaksi sesuai filter tanggal \-\> susun ke dalam baris sheet Excel \-\> simpan ke direktori sementara \-\> panggil share\_plus atau simpan ke folder Download.  
> * [x] **5.2 Fitur ExportTemplate & Import dari Excel (.xlsx)**  
  * Buat fitur "Unduh Template Excel" agar user tahu format kolom yang benar.  
  * Buat fungsi baca file menggunakan file\_picker dan package excel.  
  * Validasi baris demi baris: cocokkan nama Wallet & Kategori (buat baru otomatis jika belum ada di DB), lalu masukkan ke tabel Transactions dan update saldo Wallets dalam satu *batch transaction* Drift.  
> * [x] **5.3 Fitur Export ke PDF (.pdf)**  
  * Buat layout dokumen laporan menggunakan package pdf.  
  * Desain Header laporan (Judul, Periode Tanggal, Ringkasan Total Pemasukan, Pengeluaran, dan Selisih).  
  * Buat Tabel Mutasi Transaksi di bawahnya.  
  * Gunakan package printing untuk menampilkan preview PDF dan opsi download/share.

## **Fase 6: Pengujian & Penyempurnaan (Finishing)**

> * [x] **6.1 Pengujian Logika Saldo (Crucial Testing)**  
  * Uji coba tambah pemasukan, pengeluaran, dan transfer (pastikan saldo kedua wallet saat transfer dihitung dengan benar termasuk biaya admin).  
  * Uji coba hapus dan edit transaksi lama (pastikan saldo wallet kembali akurat).  
  * Suite Automated Unit Tests dibuat di `test/database_test.dart` & `test/widget_test.dart` (12 tests passed).  
> * [ ] **6.2 Pengujian Import/Export & Permission**  
  * Uji coba import file Excel dengan data transaksi.  
  * Pastikan permission penyimpanan Android (terutama Android 11 ke atas / Scoped Storage) berjalan lancar dengan share\_plus atau file\_picker.  
> * [x] **6.3 Build APK Release**  
  * Atur nama aplikasi ("Dompetku" di AndroidManifest.xml) dan ikon aplikasi.  
  * Jalankan flutter build apk \--release untuk dipasang di HP Android pribadi (Selesai: `build/app/outputs/flutter-apk/app-release.apk` - 64.3 MB).
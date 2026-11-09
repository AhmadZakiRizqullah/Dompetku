# **Aplikasi Pencatatan Keuangan Pribadi (Personal Finance Tracker)**

Aplikasi pencatatan keuangan pribadi berbasis Android (*offline-first*) yang dibangun menggunakan **Flutter** dan **Drift (SQLite)**. Dirancang dengan tampilan *Modern & Minimalist* untuk melacak pemasukan, pengeluaran, mutasi antar *wallet* (rekening bank, e-wallet, tunai), serta dilengkapi fitur ekspor/impor data ke Excel dan PDF.

## **✨ Fitur Utama**

> * **Multi-Wallet Management:** Pantau saldo berbagai rekening bank, e-wallet (GoPay, OVO, ShopeePay, dll), dan uang tunai secara *real-time*.  
> * **Pencatatan Transaksi Lengkap:** Mendukung transaksi Pemasukan (*Income*), Pengeluaran (*Expense*), dan Transfer antar Wallet (*Mutasi* \+ Biaya Admin).  
> * **Atomic Balance Update:** Saldo *wallet* otomatis ter-update secara akurat setiap kali transaksi ditambah, diubah, atau dihapus menggunakan fitur *database transaction* Drift.  
> * **Statistik & Visualisasi:** Ringkasan arus kas bulanan dan grafik persentase pengeluaran per kategori (*Pie Chart*).  
> * **Import & Export Data:**  
  * **Import Excel (.xlsx):** Migrasi atau input banyak data sekaligus dari template Excel.  
  * **Export Excel (.xlsx):** Unduh riwayat transaksi ke dalam tabel spreadsheet.  
  * **Export PDF (.pdf):** Cetak laporan keuangan rapi lengkap dengan ringkasan saldo dan tabel mutasi.

## **🎨 Identitas Visual (Design System)**

> * **Kepribadian Desain:** Modern & Minimalist  
> * **Font Utama:** Poppins (google\_fonts)  
> * **Palet Warna:**  
  * Background / Surface: \#FDFBEE (*Warm Cream*)  
  * Primary: \#015551 (*Deep Teal*)  
  * Secondary: \#57B4BA (*Soft Teal*)  
  * Accent / CTA / Expense: \#FE4F2D (*Vibrant Orange*)

## **📂 Struktur Folder Proyek**

Proyek ini menggunakan pendekatan *Feature-First / Clean Layered Architecture* yang ringkas dan mudah dikelola:  
`lib/`  
`├── core/`  
`│   ├── theme/`  
`│   │   └── app_theme.dart          # Konfigurasi warna (#FDFBEE, dll) & font Poppins`  
`│   ├── utils/`  
`│   │   ├── currency_formatter.dart # Format Rupiah (Rp)`  
`│   │   └── date_formatter.dart     # Format tanggal Indonesia`  
`│   └── constants/`  
`├── data/`  
`│   ├── local/`  
`│   │   ├── database.dart           # Konfigurasi utama Drift SQLite`  
`│   │   ├── database.g.dart         # Generated file oleh build_runner`  
`│   │   ├── tables/                 # Definisi tabel (Wallets, Categories, Transactions)`  
`│   │   └── daos/                   # Data Access Objects (Query & Transaksi DB)`  
`│   └── services/`  
`│       ├── excel_service.dart      # Logika Import & Export Excel (.xlsx)`  
`│       └── pdf_service.dart        # Logika Generate Laporan PDF (.pdf)`  
`├── providers/                      # Riverpod State Management Providers`  
`├── presentation/`  
`│   ├── dashboard/                  # Halaman utama, total saldo, transaksi terakhir`  
`│   ├── wallet/                     # Daftar wallet, tambah/edit & sesuaikan saldo`  
`│   ├── transaction/                # Form tambah/edit (Income/Expense/Transfer) & riwayat`  
`│   ├── category/                   # Manajemen kategori pemasukan & pengeluaran`  
`│   ├── statistics/                 # Grafik Pie Chart pengeluaran`  
`│   └── settings/                   # Menu Export/Import Excel & PDF`  
`└── main.dart                       # Entry point aplikasi`

## **🚀 Cara Menjalankan Proyek (Getting Started)**

### **1\. Prasyarat**

> * Flutter SDK (Versi terbaru / Stable, Dart 3.x)  
> * Android Studio / VS Code  
> * Perangkat Android fisik atau Emulator

### **2\. Instalasi Package**

Jalankan perintah berikut di terminal proyek untuk mengunduh semua *dependencies*:  
`flutter pub get`

### **3\. Generate Kode Database (Drift)**

Karena proyek ini menggunakan **Drift**, Anda wajib menjalankan build\_runner untuk men-generate file .g.dart:  
`# Untuk sekali generate:`  
`dart run build_runner build --delete-conflicting-outputs`

`# Atau gunakan mode watch saat sedang aktif ngoding:`  
`dart run build_runner watch --delete-conflicting-outputs`

### **4\. Menjalankan Aplikasi**

`flutter run`

### **5\. Build APK untuk HP Android Pribadi**

Untuk membuat file .apk siap pasang yang ringan dan optimal:  
`flutter build apk --release --split-per-abi`

File APK hasil build dapat ditemukan di: build/app/outputs/flutter-apk/

## **📚 Dokumen Terkait**

> * [prd.md](http://docs.google.com/prd.md) \- Spesifikasi lengkap kebutuhan produk dan skema database.  
> * [task.md](http://docs.google.com/task.md) \- Urutan langkah pengerjaan proyek dari awal hingga rilis.  
> * [style\_guide.md](http://docs.google.com/style_guide.md) \- Panduan UI/UX, aturan palet warna, tipografi, dan komponen.  
> * [techstack.md](http://docs.google.com/techstack.md) \- Rincian pustaka (*libraries*) dan arsitektur teknis.
# **Tech Stack & Spesifikasi Pustaka (Dependencies)**

Dokumen ini menjelaskan arsitektur teknis, daftar *package* yang digunakan beserta alasan pemilihannya, serta template pubspec.yaml yang siap digunakan.

## **1\. Fondasi Utama (Core Stack)**

| Komponen | Teknologi / Package | Alasan Pemilihan |
| :---- | :---- | :---- |
| **Framework** | **Flutter (Dart 3\)** | Performa *native* 60/120 fps di Android, kustomisasi UI sangat fleksibel untuk menerapkan desain minimalis. |
| **Database Lokal** | **Drift (drift \+ sqlite3\_flutter\_libs)** | ORM reaktif terbaik di atas SQLite untuk Flutter. Mendukung *Type-Safe SQL*, *Streams* (UI otomatis berubah saat data berubah), dan *Database Transactions* untuk menjaga akurasi saldo *wallet*. |
| **State Management** | **Flutter Riverpod (flutter\_riverpod)** | Sangat mudah dikombinasikan dengan Stream milik Drift, aman saat *compile-time*, dan tidak membutuhkan BuildContext yang rumit. |

## **2\. Pustaka Pendukung (Supporting Libraries)**

### **2.1 UI, Tipografi & Grafik**

> * **google\_fonts**: Memuat font **Poppins** secara konsisten sesuai style\_guide.md.  
> * **fl\_chart**: Membuat *Pie Chart* dan *Bar Chart* interaktif yang ringan dan mudah disesuaikan warnanya dengan palet (\#015551, \#57B4BA, \#FE4F2D).  
> * **lucide\_icons / Material Icons**: Menyediakan ikon modern dengan garis yang bersih (*clean stroke*) untuk kategori dan jenis *wallet*.

### **2.2 Pemrosesan Dokumen (Excel & PDF)**

> * **excel**: Membaca (*parsing*) baris dari file .xlsx saat proses *Import*, serta membuat file .xlsx baru saat *Export*.  
> * **pdf**: Menyusun tata letak halaman laporan keuangan (Header, Ringkasan Saldo, dan Tabel Mutasi) secara programatik.  
> * **printing**: Menampilkan pratinjau (*preview*) dokumen PDF langsung di dalam aplikasi, menyimpannya sebagai file, atau mencetaknya.

### **2.3 Sistem File & Utilitas Perangkat**

> * **file\_picker**: Membuka *File Explorer* bawaan Android untuk memilih file .xlsx yang akan diimpor (mendukung penuh aturan keamanan *Scoped Storage* Android 11+).  
> * **share\_plus**: Membagikan atau menyimpan file hasil *Export* (Excel/PDF) ke WhatsApp, Google Drive, atau aplikasi pengelola file tanpa memerlukan izin penyimpanan (*storage permission*) yang rumit.  
> * **path\_provider & path**: Menentukan lokasi penyimpanan file database SQLite (.sqlite) dan direktori sementara (*temp directory*) saat men-generate file Excel/PDF.  
> * **intl**: Memformat angka menjadi mata uang Rupiah (Rp 1.500.000) dan memformat tanggal lokal Indonesia (31 Okt 2026).

## **3\. Konfigurasi pubspec.yaml**

Salin konfigurasi berikut ke dalam file pubspec.yaml proyek Flutter Anda:  
name: dompetku\_tracker  
description: Aplikasi pencatatan keuangan pribadi offline-first dengan Flutter & Drift.  
publish\_to: 'none'  
version: 1.0.0+1

environment:  
  sdk: '\>=3.2.0 \<4.0.0'

dependencies:  
  flutter:  
    sdk: flutter

  \# State Management  
  flutter\_riverpod: ^2.5.1

  \# Local Database (Drift SQLite)  
  drift: ^2.18.0  
  sqlite3\_flutter\_libs: ^0.5.24  
  path\_provider: ^2.1.3  
  path: ^1.9.0

  \# UI, Fonts & Charts  
  google\_fonts: ^6.2.1  
  fl\_chart: ^0.68.0  
  intl: ^0.19.0

  \# Excel & PDF Processing  
  excel: ^4.0.3  
  pdf: ^3.10.8  
  printing: ^5.12.0

  \# File Handling & Sharing  
  file\_picker: ^8.0.3  
  share\_plus: ^9.0.0

dev\_dependencies:  
  flutter\_test:  
    sdk: flutter  
  flutter\_lints: ^4.0.0

  \# Code Generators untuk Drift  
  drift\_dev: ^2.18.0  
  build\_runner: ^2.4.11

flutter:  
  uses-material-design: true

## **4\. Catatan Penting Konfigurasi Android (AndroidManifest.xml)**

Karena aplikasi ini berjalan secara *offline-first* dan menggunakan file\_picker serta share\_plus:

> 1. **Tidak perlu izin MANAGE\_EXTERNAL\_STORAGE**: Pada Android 11 ke atas (API 30+), file\_picker menggunakan *Storage Access Framework* (SAF) bawaan sistem untuk membaca file Excel, dan share\_plus menggunakan *FileProvider* untuk mengekspor file. Ini membuat aplikasi aman dan tidak bermasalah dengan izin penyimpanan Android modern.  
> 2. **Izin Internet (Opsional untuk Font)**: Package google\_fonts secara default mengunduh font *Poppins* saat pertama kali dijalankan. Namun, agar 100% berjalan tanpa internet sejak instalasi pertama, disarankan untuk mengunduh file .ttf Poppins (Regular, Medium, SemiBold, Bold) dan mendaftarkannya di folder assets/fonts/.
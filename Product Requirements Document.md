# **Product Requirements Document (PRD): Aplikasi Pencatatan Keuangan Pribadi**

## **1\. Ringkasan Proyek**

Aplikasi pencatatan keuangan pribadi berbasis Android yang dirancang untuk penggunaan individu (offline-first). Aplikasi ini memungkinkan pengguna untuk melacak pemasukan, pengeluaran, serta transfer antar saldo (Wallet) yang mencakup rekening bank, e-wallet, dan uang tunai. Dilengkapi dengan fitur ekspor/impor data menggunakan format Excel dan PDF.

> * **Platform Target:** Android  
> * **Framework:** Flutter  
> * **Database Lokal:** Drift (SQLite)  
> * **Pengguna Target:** Penggunaan Pribadi (Single User, Offline-First)

## **2\. Fitur Utama (Core Features)**

### **2.1 Manajemen Wallet (Rekening & E-Wallet)**

> * **Multi-Wallet:** Pengguna dapat membuat berbagai jenis dompet (misal: BCA, Mandiri, GoPay, OVO, Shopeepay, Tunai).  
> * **Lacak Saldo Real-time:** Saldo setiap wallet akan otomatis bertambah/berkurang berdasarkan transaksi yang dicatat.  
> * **Penyesuaian Saldo (Adjustment):** Fitur untuk menyamakan saldo di aplikasi dengan saldo asli jika terjadi selisih tanpa harus membuat transaksi palsu.

### **2.2 Pencatatan Transaksi**

> * **Tiga Jenis Transaksi:**  
  1. **Pemasukan (Income):** Menambah saldo pada wallet yang dipilih.  
  2. **Pengeluaran (Expense):** Mengurangi saldo pada wallet yang dipilih.  
  3. **Transfer (Mutasi):** Memindahkan dana dari satu wallet ke wallet lain (misal: Top up GoPay dari BCA), lengkap dengan opsi biaya admin (jika ada).  
> * **Detail Transaksi:** Tanggal & waktu, nominal, kategori, wallet, dan catatan tambahan (opsional).  
> * **Filter & Pencarian:** Filter transaksi berdasarkan rentang tanggal (harian, bulanan, tahunan, custom), jenis wallet, atau kategori.

### **2.3 Manajemen Kategori**

> * Kategori dikelompokkan berdasarkan jenisnya: Pemasukan (Gaji, Bonus, Investasi) dan Pengeluaran (Makan, Transportasi, Tagihan, Belanja).  
> * Pengguna dapat menambah, mengubah, atau menghapus kategori sesuai kebutuhan.

### **2.4 Dashboard & Statistik Ringkas**

> * Menampilkan total kekayaan bersih (akumulasi seluruh saldo wallet).  
> * Daftar saldo masing-masing wallet.  
> * Ringkasan total pemasukan dan pengeluaran pada bulan berjalan.  
> * Grafik sederhana (Pie Chart) untuk melihat persentase pengeluaran per kategori.

### **2.5 Ekspor & Impor Data**

> * **Import dari Excel (.xlsx):**  
  * Mengimpor daftar transaksi dari file Excel berdasarkan template standar.  
  * Otomatis menyesuaikan saldo wallet terkait setelah proses impor berhasil.  
> * **Export ke Excel (.xlsx):**  
  * Mengekspor data transaksi berdasarkan rentang tanggal yang dipilih ke dalam format tabel Excel.  
> * **Export ke PDF (.pdf):**  
  * Menghasilkan laporan keuangan rapi (termasuk ringkasan pemasukan, pengeluaran, sisa saldo, dan tabel mutasi transaksi) yang siap dicetak atau disimpan.

## **3\. Spesifikasi Teknis & Arsitektur**

### **3.1 Tech Stack & Rekomendasi Package Flutter**

> * **State Management:** flutter\_riverpod atau flutter\_bloc (Direkomendasikan Riverpod karena mudah diintegrasikan dengan Stream dari Drift).  
> * **Database:** drift, sqlite3\_flutter\_libs, path\_provider, path.  
> * **Excel Processing:** excel (untuk baca dan tulis file .xlsx).  
> * **PDF Processing:** pdf dan printing (untuk generate dan preview laporan PDF).  
> * **File Picker & Sharing:** file\_picker (untuk memilih file Excel saat import), share\_plus (untuk membagikan/menyimpan hasil export).  
> * **UI & Charts:** fl\_chart (untuk grafik pengeluaran), intl (untuk format mata uang Rupiah dan tanggal).

### **3.2 Desain Skema Database (Drift / SQLite)**

#### **Tabel 1: Wallets**

Menyimpan data rekening bank, e-wallet, dan uang tunai.

| Kolom | Tipe Data (Drift) | Keterangan |
| :---- | :---- | :---- |
| id | IntColumn | Primary Key, Auto Increment |
| name | TextColumn | Nama wallet (contoh: "BCA", "GoPay") |
| type | TextColumn | Jenis: BANK, EWALLET, CASH |
| initial\_balance | IntColumn / RealColumn | Saldo awal saat wallet dibuat |
| current\_balance | IntColumn / RealColumn | Saldo terkini |
| icon\_name | TextColumn | Identifier ikon/warna untuk UI |
| created\_at | DateTimeColumn | Waktu pembuatan |

#### **Tabel 2: Categories**

Menyimpan kategori pemasukan dan pengeluaran.

| Kolom | Tipe Data (Drift) | Keterangan |
| :---- | :---- | :---- |
| id | IntColumn | Primary Key, Auto Increment |
| name | TextColumn | Nama kategori (contoh: "Makanan", "Gaji") |
| type | TextColumn | Jenis: INCOME, EXPENSE |
| icon\_name | TextColumn | Identifier ikon untuk UI |

#### **Tabel 3: Transactions**

Menyimpan seluruh riwayat pencatatan keuangan.

| Kolom | Tipe Data (Drift) | Keterangan |
| :---- | :---- | :---- |
| id | IntColumn | Primary Key, Auto Increment |
| amount | IntColumn / RealColumn | Nominal transaksi |
| admin\_fee | IntColumn / RealColumn | Biaya admin (khusus tipe TRANSFER, default 0\) |
| type | TextColumn | Jenis: INCOME, EXPENSE, TRANSFER |
| transaction\_date | DateTimeColumn | Tanggal dan waktu transaksi |
| wallet\_id | IntColumn | Foreign Key ke Wallets.id (Wallet utama/sumber) |
| to\_wallet\_id | IntColumn (Nullable) | Foreign Key ke Wallets.id (Wallet tujuan jika TRANSFER) |
| category\_id | IntColumn (Nullable) | Foreign Key ke Categories.id (Null jika TRANSFER) |
| note | TextColumn (Nullable) | Catatan tambahan |
| created\_at | DateTimeColumn | Waktu pencatatan dibuat |

## **4\. Format Standar Import Excel**

Agar fitur Import Excel berjalan lancar dan minim error, file Excel yang diimpor harus memiliki struktur kolom (Header di baris pertama) sebagai berikut:

| Tanggal (YYYY-MM-DD) | Tipe (INCOME/EXPENSE/TRANSFER) | Wallet Sumber | Wallet Tujuan (Opsional) | Kategori | Nominal | Biaya Admin | Catatan |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| 2026-10-01 | INCOME | BCA |  | Gaji | 5000000 | 0 | Gaji Bulan Oktober |
| 2026-10-02 | TRANSFER | BCA | GoPay |  | 500000 | 1000 | Topup GoPay |
| 2026-10-03 | EXPENSE | GoPay |  | Makanan | 45000 | 0 | Beli kopi dan roti |

*Catatan Logika Import:* Jika nama Wallet atau Kategori pada Excel belum ada di database, sistem akan otomatis membuatkan Wallet atau Kategori baru tersebut.

## **5\. Alur Pengguna (User Flow) Utama**

> 1. **Onboarding Awal:** Pengguna membuka aplikasi pertama kali \-\> Sistem men-generate kategori default \-\> Pengguna diarahkan untuk membuat minimal 1 Wallet (misal: "Uang Tunai" atau "Rekening Utama").  
> 2. **Mencatat Pengeluaran/Pemasukan:** Klik tombol \+ (FAB) \-\> Pilih tab Pengeluaran/Pemasukan \-\> Masukkan nominal \-\> Pilih Kategori & Wallet \-\> Simpan \-\> Saldo Wallet otomatis ter-update menggunakan fitur *Database Transaction* milik Drift.  
> 3. **Mencatat Transfer Antar Wallet:** Klik tombol \+ \-\> Pilih tab Transfer \-\> Pilih Wallet Sumber & Wallet Tujuan \-\> Masukkan nominal & biaya admin (jika ada) \-\> Simpan \-\> Saldo Wallet Sumber berkurang (Nominal \+ Admin) dan Wallet Tujuan bertambah (Nominal).
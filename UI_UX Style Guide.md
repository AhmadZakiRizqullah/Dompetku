# **UI/UX Style Guide: Aplikasi Pencatatan Keuangan**

Dokumen ini merupakan panduan standar visual dan antarmuka (UI/UX) untuk memastikan desain aplikasi tetap konsisten dengan kepribadian **Modern & Minimalist**.

## **1\. Kepribadian Desain (Design Personality)**

> * **Modern:** Menggunakan sudut membulat yang halus (*smooth rounded corners*), *whitespace* (ruang kosong) yang lega, dan hierarki tipografi yang tegas.  
> * **Minimalist:** Menghindari garis pembatas (*border/divider*) yang berlebihan dan bayangan (*drop shadow*) yang terlalu tebal. Pemisahan antar elemen dilakukan menggunakan kontras warna latar belakang dan jarak (*spacing*).  
> * **Warm & Trustworthy:** Latar belakang *cream* hangat (\#FDFBEE) membuat mata tidak cepat lelah dibandingkan putih murni, dipadukan dengan warna *deep teal* (\#015551) yang memberikan kesan finansial yang stabil dan terpercaya.

## **2\. Palet Warna (Color Palette)**

### **2.1 Warna Utama (Core Brand Colors)**

| Peran Warna | Kode Hex | Kode Flutter | Penggunaan Utama |
| :---- | :---- | :---- | :---- |
| **Background / Surface** | \#FDFBEE | Color(0xFFFDFBEE) | Latar belakang utama layar (*Scaffold background*), memberikan kesan bersih dan hangat. |
| **Primary (Deep Teal)** | \#015551 | Color(0xFF015551) | Kartu saldo utama (Total Kekayaan), AppBar teks, tombol utama, dan teks judul utama. |
| **Secondary (Soft Teal)** | \#57B4BA | Color(0xFF57B4BA) | Aksen sekunder, indikator tab aktif, kartu e-wallet, ikon kategori, dan grafik. |
| **Accent / CTA (Vibrant Orange)** | \#FE4F2D | Color(0xFFFE4F2D) | *Floating Action Button* (Tombol \+ Transaksi), *alert* penting, dan indikator **Pengeluaran**. |

### **2.2 Warna Semantik & Transaksi (Semantic Colors)**

Agar tetap menyatu dengan palet utama, indikator jenis transaksi diatur sebagai berikut:

> * **Pengeluaran (Expense):** \#FE4F2D (Menggunakan warna *Accent Vibrant Orange* — tegas dan langsung menarik perhatian saat uang keluar).  
> * **Pemasukan (Income):** \#015551 atau \#2A9D8F (Menggunakan *Primary Deep Teal* atau *Teal* kehijauan agar selaras dengan tema tanpa menabrak warna).  
> * **Transfer (Mutasi):** \#57B4BA (Menggunakan *Secondary Soft Teal* — netral dan menenangkan).

### **2.3 Warna Netral & Permukaan (Neutrals & Surfaces)**

Karena latar utama adalah \#FDFBEE (Off-White/Cream), kartu (*Card*) membutuhkan kontras halus:

> * **Card Surface:** \#FFFFFF (Putih murni) dengan *border* tipis \#EFECE6 agar menonjol secara minimalis di atas latar \#FDFBEE.  
> * **Text Primary:** \#013230 (Turunan sangat gelap dari \#015551, lebih lembut dari hitam pekat \#000000).  
> * **Text Secondary / Muted:** \#6B8E8C (Abu-abu kehijauan untuk tanggal, catatan, dan sub-judul).

## **3\. Tipografi (Typography)**

Menggunakan font **Poppins** (melalui package google\_fonts). Poppins adalah font *geometric sans-serif* yang sangat cocok untuk menampilkan angka nominal uang dan teks UI yang rapi.

### **Skala Tipografi**

| Gaya Teks | Ukuran | Ketebalan (Weight) | Penggunaan |
| :---- | :---- | :---- | :---- |
| **Display Balance** | 28 sp | Bold (w700) | Nominal Total Saldo di Dashboard. |
| **Heading 1 (H1)** | 22 sp | SemiBold (w600) | Judul Halaman Utama. |
| **Heading 2 (H2)** | 18 sp | SemiBold (w600) | Judul Seksi (misal: "Transaksi Terakhir", "Wallet Saya"). |
| **Title / Nominal Item** | 16 sp | SemiBold (w600) | Nama Kategori di list & Nominal uang per transaksi. |
| **Body Text** | 14 sp | Regular (w400) | Catatan transaksi, nama wallet di list, teks input form. |
| **Caption / Label** | 12 sp | Medium (w500) | Tanggal transaksi, label tab bawah, *badge* tipe wallet. |

## **4\. Komponen & Layout (UI Components)**

### **4.1 Spacing & Border Radius**

> * **Padding Layar Utama:** 20.0 px (Horizontal) untuk memberikan kesan ruang yang lega.  
> * **Jarak Antar Elemen:** Kelipatan 8 px (8, 16, 24, 32).  
> * **Border Radius:**  
  * Kartu Utama & Bottom Sheet: 24.0 px  
  * Kartu Item Transaksi & Input Text: 16.0 px  
  * Tombol (Button) & Chip Filter: 12.0 px

### **4.2 Desain Komponen Kunci**

> 1. **Kartu Total Saldo (Hero Card):**  
   * Latar belakang: \#015551 (*Primary Deep Teal*).  
   * Teks Saldo: \#FDFBEE (*Cream*).  
   * Aksen dekorasi lingkaran transparan di sudut kartu menggunakan warna \#57B4BA dengan opasitas 15%.  
> 2. **Kartu Wallet (Horizontal Carousel):**  
   * Latar belakang: \#FFFFFF dengan *border* 1px warna \#57B4BA (opasitas 30%).  
   * Ikon Wallet dibungkus lingkaran kecil berwarna \#57B4BA (opasitas 15%) dengan ikon berwarna \#015551.  
> 3. **Floating Action Button (Tombol Tambah Transaksi):**  
   * Latar belakang: \#FE4F2D (*Vibrant Orange*).  
   * Ikon \+: \#FDFBEE, bentuk *Rounded Square* (borderRadius: 18).  
> 4. **Item Riwayat Transaksi:**  
   * Tanpa garis pembatas (*divider*). Setiap item dibungkus *container* putih bersih (\#FFFFFF), padding: 16px, margin-bottom: 12px, dan borderRadius: 16px.

## **5\. Implementasi Kode Tema Flutter (app\_theme.dart)**

Berikut adalah kode konfigurasi langsung yang dapat Anda pasang pada project Flutter menggunakan package google\_fonts:  
`import 'package:flutter/material.dart';`  
`import 'package:google_fonts/google_fonts.dart';`

`class AppColors {`  
  `static const Color background = Color(0xFFFDFBEE);`  
  `static const Color primary = Color(0xFF015551);`  
  `static const Color secondary = Color(0xFF57B4BA);`  
  `static const Color accent = Color(0xFFFE4F2D);`

  `static const Color surface = Color(0xFFFFFFFF);`  
  `static const Color textPrimary = Color(0xFF013230);`  
  `static const Color textSecondary = Color(0xFF6B8E8C);`  
  `static const Color border = Color(0xFFEAE6DF);`

  `// Semantic Transaction Colors`  
  `static const Color income = Color(0xFF015551);`  
  `static const Color expense = Color(0xFFFE4F2D);`  
  `static const Color transfer = Color(0xFF57B4BA);`  
`}`

`class AppTheme {`  
  `static ThemeData get lightTheme {`  
    `final baseTextTheme = GoogleFonts.poppinsTextTheme();`

    `return ThemeData(`  
      `useMaterial3: true,`  
      `scaffoldBackgroundColor: AppColors.background,`  
      `primaryColor: AppColors.primary,`  
      `colorScheme: const ColorScheme.light(`  
        `primary: AppColors.primary,`  
        `secondary: AppColors.secondary,`  
        `tertiary: AppColors.accent,`  
        `surface: AppColors.surface,`  
        `error: AppColors.accent,`  
        `onPrimary: AppColors.background,`  
        `onSecondary: Colors.white,`  
        `onSurface: AppColors.textPrimary,`  
      `),`  
      `appBarTheme: AppBarTheme(`  
        `backgroundColor: AppColors.background,`  
        `elevation: 0,`  
        `scrolledUnderElevation: 0,`  
        `centerTitle: false,`  
        `iconTheme: const IconThemeData(color: AppColors.primary),`  
        `titleTextStyle: GoogleFonts.poppins(`  
          `color: AppColors.primary,`  
          `fontSize: 20,`  
          `fontWeight: FontWeight.w600,`  
        `),`  
      `),`  
      `textTheme: baseTextTheme.copyWith(`  
        `displayLarge: GoogleFonts.poppins(`  
          `fontSize: 28,`  
          `fontWeight: FontWeight.w700,`  
          `color: AppColors.textPrimary,`  
        `),`  
        `titleLarge: GoogleFonts.poppins(`  
          `fontSize: 18,`  
          `fontWeight: FontWeight.w600,`  
          `color: AppColors.textPrimary,`  
        `),`  
        `titleMedium: GoogleFonts.poppins(`  
          `fontSize: 16,`  
          `fontWeight: FontWeight.w600,`  
          `color: AppColors.textPrimary,`  
        `),`  
        `bodyMedium: GoogleFonts.poppins(`  
          `fontSize: 14,`  
          `fontWeight: FontWeight.w400,`  
          `color: AppColors.textPrimary,`  
        `),`  
        `bodySmall: GoogleFonts.poppins(`  
          `fontSize: 12,`  
          `fontWeight: FontWeight.w500,`  
          `color: AppColors.textSecondary,`  
        `),`  
      `),`  
      `cardTheme: CardTheme(`  
        `color: AppColors.surface,`  
        `elevation: 0,`  
        `shape: RoundedRectangleBorder(`  
          `borderRadius: BorderRadius.circular(16),`  
          `side: const BorderSide(color: AppColors.border, width: 1),`  
        `),`  
      `),`  
      `floatingActionButtonTheme: FloatingActionButtonThemeData(`  
        `backgroundColor: AppColors.accent,`  
        `foregroundColor: AppColors.background,`  
        `elevation: 2,`  
        `shape: RoundedRectangleBorder(`  
          `borderRadius: BorderRadius.circular(18),`  
        `),`  
      `),`  
      `elevatedButtonTheme: ElevatedButtonThemeData(`  
        `style: ElevatedButton.styleFrom(`  
          `backgroundColor: AppColors.primary,`  
          `foregroundColor: AppColors.background,`  
          `elevation: 0,`  
          `padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),`  
          `shape: RoundedRectangleBorder(`  
            `borderRadius: BorderRadius.circular(12),`  
          `),`  
          `textStyle: GoogleFonts.poppins(`  
            `fontSize: 15,`  
            `fontWeight: FontWeight.w600,`  
          `),`  
        `),`  
      `),`  
      `inputDecorationTheme: InputDecorationTheme(`  
        `filled: true,`  
        `fillColor: AppColors.surface,`  
        `contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),`  
        `border: OutlineInputBorder(`  
          `borderRadius: BorderRadius.circular(14),`  
          `borderSide: const BorderSide(color: AppColors.border),`  
        `),`  
        `enabledBorder: OutlineInputBorder(`  
          `borderRadius: BorderRadius.circular(14),`  
          `borderSide: const BorderSide(color: AppColors.border),`  
        `),`  
        `focusedBorder: OutlineInputBorder(`  
          `borderRadius: BorderRadius.circular(14),`  
          `borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),`  
        `),`  
      `),`  
    `);`  
  `}`  
`}`  

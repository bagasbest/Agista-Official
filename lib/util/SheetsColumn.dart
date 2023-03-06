class SheetsColumn {
  static final date_time = "Tanggal Transaksi";
  static final user_name = "Username";
  static final receiver_name = "Nama Lengkap / Penerima";
  static final phone = "Nomor Handphone";
  static final product_name = "Nama Produk";
  static final product_category = "Kategori Produk";
  static final product_description = "Deskripsi Produk";
  static final product_buy = "Kuantitas Pembelian";
  static final total_price = "Total Harga";
  static final address = "Alamat Lengkap Pengguna";

  static List<String> getColumn() => [
        date_time,
        user_name,
        receiver_name,
        phone,
        product_name,
        product_category,
        product_description,
        product_buy,
        total_price,
        address,
      ];
}

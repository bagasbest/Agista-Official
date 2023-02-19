import 'package:agistaofficial/database/database_service.dart';
import 'package:agistaofficial/screens/home_screen.dart';
import 'package:agistaofficial/screens/login_screen.dart';
import 'package:agistaofficial/screens/product/product_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../util/common.dart';
import '../../util/themes.dart';

class ProductDetail extends StatefulWidget {
  var product;
  var role;
  var categoryList;

  ProductDetail(
      {required this.product, required this.role, required this.categoryList});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<String> image = [];
  var formattedCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  bool _visible = false;


  var _stock = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  _initializeData() async {
    List<dynamic> img = widget.product["image"];
    img.forEach((element) {
      image.add(element.toString());
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Themes(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (widget.product["stock"] > 0) {
                                inputStock();
                              } else {
                                toast('Stok produk ini sedang kosong!');
                              }
                            },
                            child: Icon(
                              Icons.shopping_cart,
                              color: Colors.grey,
                            ),
                          ),
                          (widget.role == "admin")
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Route route = MaterialPageRoute(
                                          builder: (context) =>
                                              ProductEditScreen(
                                            product: widget.product,
                                            categoryList: widget.categoryList,
                                          ),
                                        );
                                        Navigator.push(context, route);
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDeleteConfirm();
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
                ImageSlideshow(
                  /// Width of the [ImageSlideshow].
                  width: double.infinity,

                  /// Height of the [ImageSlideshow].
                  height: 400,

                  /// The page to show when first creating the [ImageSlideshow].
                  initialPage: 0,

                  /// The color to paint the indicator.
                  indicatorColor: Colors.blue,

                  /// The color to paint behind th indicator.
                  indicatorBackgroundColor: Colors.grey,

                  /// The widgets to display in the [ImageSlideshow].
                  /// Add the sample image file into the images folder
                  children: [
                    for (String url in image)
                      Image.network(
                        url,
                        fit: BoxFit.cover,
                      ),
                  ],

                  /// Called whenever the page in the center of the viewport change

                  /// Auto scroll interval.
                  /// Do not auto scroll with null or 0.

                  /// Loops back to first slide.
                  isLoop: false,
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            (widget.product["disc_percentage"]>0)?
                            "${formattedCurrency.format(widget.product["disc_price"])}" : "${formattedCurrency.format(widget.product["price"])}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (widget.product["disc_percentage"] > 0)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Colors.pink[100]),
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "${widget.product["disc_percentage"]}%",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${formattedCurrency.format(widget.product["price"])}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black26,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.product["name"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Terjual: ${widget.product["sold"]}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Text(
                        "Kategori: ${widget.product["category"]}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Stok tersedia: ${widget.product["stock"]}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Text(
                        "Deskripsi Produk: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${widget.product["description"]}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: (widget.product["stock"] > 0)
                            ? () {
                                inputStock();
                              }
                            : null,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: (widget.product["stock"] > 0)
                                  ? AppCommon.green
                                  : Colors.grey),
                          child: Center(
                            child: Text(
                              'Checkout Produk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Apakah Anda yakin ingin menghapus produk "${widget.product["name"]}" ?'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.grey),
                            child: Text("Tidak",
                                style: TextStyle(color: Colors.white))),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: AppCommon.green,
                            ),
                            child: Text("Ya",
                                style: TextStyle(color: Colors.white))),
                        onTap: () async {
                          // Implement saving logic here

                          await FirebaseFirestore.instance
                              .collection('product')
                              .doc(widget.product["product_id"])
                              .delete();
                          toast(
                              'Berhasil menghapus produk ${widget.product["name"]}');
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (Route<dynamic> route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  inputStock() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Kategori Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                child:
                    const Divider(height: 3, thickness: 3, color: Colors.grey),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _stock,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: "Input stok pembelian",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppCommon.green, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppCommon.green, width: 1)),
                    // Focused Border
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppCommon.green, width: 1)),
                    // Focused Error Border
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red, width: 1))),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Stok Produk tidak boleh kosong';
                  } else if (int.parse(value) > widget.product["stock"]) {
                    return 'Maksimum ${widget.product["stock"]} pcs';
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.grey),
                          child: Text("Batal",
                              style: TextStyle(color: Colors.white))),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    /// LOADING INDIKATOR
                    (_visible)
                        ? Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Visibility(
                        visible: _visible,
                        child: const SpinKitRipple(
                          color: AppCommon.green,
                        ),
                      ),
                    )
                        : Container(),
                    SizedBox(
                      width: 16,
                    ),
                    InkWell(
                      child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: AppCommon.green,
                          ),
                          child: Text("Konfirmasi",
                              style: TextStyle(color: Colors.white))),
                      onTap: () async {
                        // Implement saving logic here
                        setState(() {
                          _visible = true;
                        });


                        bool isSuccessfully = await DatabaseService.addToCart(widget.product, _stock.text);

                        if(isSuccessfully) {
                          setState(() {
                            _visible = false;
                          });
                          toast('Berhasil menambahkan produk kedalam keranjang!');
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                                  (Route<dynamic> route) => false);
                        } else {
                          setState(() {
                            _visible = false;
                          });
                          toast('Gagal menambahkan produk kedalam keranjang, silahkan cek koneksi internet anda dan coba lagi!');
                        }


                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
          elevation: 10,
        );
      },
    );
  }
}

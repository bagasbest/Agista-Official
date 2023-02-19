import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/database_service.dart';
import '../../util/common.dart';
import '../../util/themes.dart';
import '../login_screen.dart';

class ProductAddScreen extends StatefulWidget {
  final List<String> category;

  ProductAddScreen({required this.category});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  var _name = TextEditingController();
  var _description = TextEditingController();
  var _price = TextEditingController();
  var _stock = TextEditingController();
  XFile? _image;
  bool _isImageAdd = false;
  String image = "";
  var category = "";
  bool _visible = false;
  final _formKey = GlobalKey<FormState>();
  List<XFile> images = [];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Themes(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Tambah Produk Baru',
            style: TextStyle(color: Colors.white),
          ),
          leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: MediaQuery.of(context).size.width,
                    child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSearchBox: true,
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Pilih Kategori Produk",
                      ),
                      items: widget.category,
                      onChanged: (String? newValue) {
                        setState(() {
                          category = newValue!;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _name,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        hintText: "Input Nama Produk",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Border
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Error Border
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: Colors.red, width: 1))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nama Produk tidak boleh kosong';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _description,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: "Input Deskripsi Produk",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Border
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Error Border
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: Colors.red, width: 1))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Deskripsi Produk tidak boleh kosong';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _price,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Input Harga Produk",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Border
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Error Border
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: Colors.red, width: 1))),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Harga Produk tidak boleh kosong';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _stock,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Input Stok Produk",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Border
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppCommon.green, width: 1)),
                        // Focused Error Border
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: Colors.red, width: 1))),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Stok Produk tidak boleh kosong';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload Foto Produk',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () async {
                          _image = await DatabaseService.getImageGallery();

                          setState(() {
                            images.add(_image!);
                            _isImageAdd = true;
                          });

                         // image = await DatabaseService.uploadImage(_image!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.black, width: 2)),
                          child: Text(
                            'Ambil Foto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          padding: EdgeInsets.all(5),
                        ),
                      ),
                    ],
                  ),
                  (_isImageAdd)
                      ? Container(
                    height: 150,
                    margin: EdgeInsets.only(bottom: 32),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            showDeleteConfirm(index);
                          },
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: Image.file(
                              File(images[index].path),
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : Padding(padding: EdgeInsets.only(bottom: 32)),

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

                  InkWell(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _visible = true;
                        });

                        /// CREATE NEW USER
                        bool shouldNavigate = await DatabaseService.uploadProduct(
                          _name.text,
                          _price.text,
                          _description.text,
                          _stock.text,
                          images,
                          category
                        );

                        if (shouldNavigate) {
                          setState(() {
                            _name.text = "";
                            _stock.text = "";
                            _description.text = "";
                            _price.text = "";
                            category = "";
                            _isImageAdd = false;
                            images.clear();
                          });

                          if (shouldNavigate) {
                            /// SHOW SUCCESS DIALOG
                            _showSuccessRegistration();
                          } else {
                            toast(
                                'Gagal upload produk, silahkan cek koneksi internet anda');
                          }

                          setState(() {
                            _visible = false;
                          });
                        }
                      } else if (images.length == 0) {
                        toast(
                            'Anda harus menambahkan foto produk');
                        setState(() {
                          _visible = false;
                        });
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: AppCommon.green),
                      child: Center(
                        child: Text(
                          'Upload Produk',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showDeleteConfirm(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Apakah Anda yakin ingin menghapus gambar ke-${index+1} ini ?'),
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
                      SizedBox(width: 16,),
                      InkWell(
                        child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: AppCommon.green,
                            ),
                            child: Text("Ya",
                                style: TextStyle(color: Colors.white))),
                        onTap: () {
                          // Implement saving logic here
                          setState(() {
                            images.removeAt(index);
                            if(images.length == 0) {
                              _isImageAdd = false;
                            }
                          });
                          Navigator.of(context).pop();
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


  _showSuccessRegistration() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          backgroundColor: AppCommon.green,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Sukses Unggah Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
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
                child: const Divider(
                  color: Colors.white,
                  height: 3,
                  thickness: 3,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Produk ${_name.text} akan tampil di halaman utama!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppCommon.green,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      "Tutup",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        letterSpacing: 1,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          elevation: 10,
        );
      },
    );
  }
}

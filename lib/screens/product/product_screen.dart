import 'package:agistaofficial/database/database_service.dart';
import 'package:agistaofficial/screens/login_screen.dart';
import 'package:agistaofficial/screens/product/product_add_screen.dart';
import 'package:agistaofficial/screens/product/product_list.dart';
import 'package:agistaofficial/util/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../util/themes.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var categoryList = [
    'Kesehatan',
    "Kecantikan",
    "Pakaian",
    "Obat",
    "Herbal",
    "Makanan"
  ];

  var _address = TextEditingController();
  var _search = TextEditingController();
  var uid = "";
  var address = "";
  var role = "";
  var category = "";
  var search = "";

  String name = "";
  String phone = "";

  @override
  void initState() {
    super.initState();
    _initializeRole();
  }

  _initializeRole() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        uid = value.data()!["uid"];
        address = value.data()!["address"];
        role = value.data()!["role"];
        name = value.data()!["name"];
        phone = value.data()!["phone"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Themes(),
        child: Scaffold(
          floatingActionButton: (role == "admin")
              ? FloatingActionButton(
                  onPressed: () {
                    Route route = MaterialPageRoute(
                        builder: (context) =>
                            ProductAddScreen(category: categoryList));
                    Navigator.push(context, route);
                  },
                  backgroundColor: AppCommon.green,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
              : Container(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: AppCommon.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 45,
                            width: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                            child: TextField(
                              controller: _search,
                              decoration: InputDecoration(
                                hintText: "Cari produk",
                                suffix: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      search = _search.text.toString();
                                      setState(() {});
                                    },
                                    child: Text(
                                      'Cari',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    showCategory();
                                  },
                                  child: Icon(
                                    Icons.category,
                                    color: Colors.white,
                                  )),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                  onTap: () {
                                    confirmLogout();
                                  },
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ))
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Dikirim Ke  ',
                            style: TextStyle(color: Colors.white),
                          ),
                          InkWell(
                            onTap: () {
                              showInputAddress();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                (address.isNotEmpty)
                                    ? address
                                    : "Tambah Alamat + ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  height: MediaQuery.of(context).size.height * 0.76,
                  child: StreamBuilder(
                    stream: (category == "")
                        ? FirebaseFirestore.instance
                            .collection('product')
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('product')
                            .where("category", isEqualTo: category)
                            .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> dataList = [];
                        dataList.addAll(snapshot.data!.docs);

                        if (search != "") {
                          var i = 0;
                          snapshot.data!.docs.forEach((element) {
                            String name = snapshot.data!.docs[i]['name'].toString().toLowerCase();
                            if (!name.contains(search)) {
                              try {
                                print("deteted wanbt: $i");
                                dataList.remove(dataList[i]);
                              }catch(err) {
                                print("Error: $err");
                              }
                            }
                            i++;
                          });
                        }


                        return (dataList.length > 0)
                            ? ProductList(
                                document: dataList,
                                role: role,
                                categoryList: categoryList,
                        uid: uid,
                        name: name,
                        phone: phone,
                        address: address,
                        )
                            : _emptyData();
                      } else {
                        return _emptyData();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _emptyData() {
    return Container(
      child: Center(
        child: Text(
          'Tidak Ada Produk\nTersedia',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  showInputAddress() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Produk akan dikirim ke: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _address,
                    decoration: InputDecoration(
                      hintText: "Input alamat lengkap",
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
                    ),
                    maxLines: 5,
                  ),
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
                            child: Text("Simpan",
                                style: TextStyle(color: Colors.white))),
                        onTap: () async {
                          // Implement saving logic here
                          Navigator.of(context).pop();
                          var isSuccessUpdateAddress =
                              await DatabaseService.updateAddress(
                            _address.text,
                            uid,
                          );
                          if (isSuccessUpdateAddress) {
                            toast('Berhasil perbarui alamat');
                            setState(() {
                              address = _address.text;
                            });
                          }
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

  showCategory() {
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                width: MediaQuery.of(context).size.width,
                child: DropdownSearch<String>(
                  mode: Mode.MENU,
                  showSearchBox: false,
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Pilih Kategori",
                  ),
                  items: categoryList,
                  onChanged: (String? newValue) {
                    category = newValue!;
                  },
                ),
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
                          child: Text(
                              (category == "") ? "Tidak" : "Hapus Kategori",
                              style: TextStyle(color: Colors.white))),
                      onTap: () {
                        if (category != "") {
                          category = "";
                          setState(() {});
                        }
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
                        if (category != "") {
                          setState(() {});
                          Navigator.of(context).pop();
                        } else {
                          toast('Choose category first');
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

  confirmLogout() {
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
                  'Konfirmasi Logout',
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
                'Apakah anda yakin ingin logout ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
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
                        ),
                        child:
                            Text("Ya", style: TextStyle(color: Colors.white))),
                    onTap: () async {
                      // Implement saving logic here

                      await FirebaseAuth.instance.signOut();

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            ],
          ),
          elevation: 10,
        );
      },
    );
  }
}

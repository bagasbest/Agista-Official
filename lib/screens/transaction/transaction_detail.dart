import 'package:agistaofficial/database/database_service.dart';
import 'package:agistaofficial/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/common.dart';
import '../../util/themes.dart';

class TransactionDetail extends StatefulWidget {
  final DocumentSnapshot document;
  final String role;

  TransactionDetail({
    required this.document,
    required this.role,
  });

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  String role = "";
  String adminNumber = "082214300463";
  bool isAcc = false;
  List<DocumentSnapshot> documents = [];
  var _receiverName = TextEditingController();
  var _address = TextEditingController();

  var formattedCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

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
        role = value.data()!["role"];
        var nowUid = value.data()!["uid"];
        if(nowUid == widget.document["user_id"]) {
          _receiverName.text = value.data()!["receiver_name"];
          _address.text = value.data()!["address"];
        }else {
          _receiverName.text = widget.document["receiver_name"];
          _address.text = widget.document["user_address"];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Themes(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                padding: EdgeInsets.only(top: 30),
                color: AppCommon.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Detail Transaksi',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    (!isAcc)
                        ? InkWell(
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onTap: () {
                              print(widget.document["status"]);
                              if (widget.document["status"] !=
                                      "Transaksi Selesai" &&
                                  widget.document["status"] !=
                                      "Transaksi Dibatalkan") {
                                confirmCancelTransaction();
                              } else {
                                confirmDeleteTransaction();
                              }
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 100),
                margin: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Transaksi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                            Text('Kustomer: ${widget.document["user_name"]}'),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                'Tanggal Transaksi: ${widget.document["date_time"]}'),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                'Total Transaksi: ${formattedCurrency.format(widget.document["totalTransaction"])}'),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                'Status Transaksi: ${widget.document["status"]}'),
                            SizedBox(
                              height: 16,
                            ),
                            (role == "admin" &&
                                    (widget.document["status"] ==
                                        "Menunggu Konfirmasi Admin") &&
                                    !isAcc)
                                ? Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          confirmAccTransaction();
                                        },
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: AppCommon.green),
                                          child: Center(
                                            child: Text(
                                              'Konfirmasi Transaksi',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Text(
                                          'Konformasi oleh admin di butuhkan agar produk yang akan di berikan ketika COD sesuai dan tidak Out of Stock!'),
                                    ],
                                  )
                                : Container(),
                            (widget.document["status"] !=
                                    "Transaksi Dibatalkan")
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Divider(
                                            thickness: 1,
                                          ),
                                        ),
                                        (role == "user")
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Silahkan hubungi admin untuk menentukan lokasi COD Transaksi ini, melalui salah satu dari cara dibawah:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          openDialer(
                                                              adminNumber);
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: AppCommon
                                                                  .green),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                          height: 40,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .phone_android,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  'Telepon',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          whatsapp(adminNumber);
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: AppCommon
                                                                  .green),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                          height: 40,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .chat_bubble,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  'WhatsApp',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Silahkan hubungi kustomer untuk menentukan lokasi COD Transaksi ini, melalui salah satu dari cara dibawah:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          openDialer(widget
                                                                  .document[
                                                              "user_phone"]);
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: AppCommon
                                                                  .green),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                          height: 40,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .phone_android,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  'Telepon',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          whatsapp(widget
                                                                  .document[
                                                              "user_phone"]);
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: AppCommon
                                                                  .green),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                          height: 40,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .chat_bubble,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  'WhatsApp',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                      ],
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Tambahan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                            Text(
                              'Produk akan dikirim ke: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
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
                                  enabled: (role == "user") ? true : false,
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
                                ),
                                maxLines: 5,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Atas Nama / Penerima: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _receiverName,
                                decoration: InputDecoration(
                                  hintText: "Input Nama Lengkap",
                                  enabled: (role == "user") ? true : false,
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
                                ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            (role == "user")
                                ? InkWell(
                                    onTap: () async {
                                      if (_address.text != "" &&
                                          _receiverName.text != "") {
                                        await DatabaseService.updateAddress(
                                            _address.text,
                                            _receiverName.text,
                                            widget.document["user_id"]);

                                        await DatabaseService
                                            .saveAdditionalInfoTransaction(
                                                _address.text,
                                                _receiverName.text,
                                                widget.document[
                                                    "transaction_id"]);
                                        toast(
                                            'Sukses memperbarui informasi tambahan');
                                      } else {
                                        toast(
                                            'Mohon isi 2 kolom diatas dengan informasi yang sesuai');
                                      }
                                    },
                                    child: Container(
                                      height: 40,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppCommon.green,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Simpan Informasi Tambahan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Produk Transaksi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('transaction_product')
                            .where("transaction_id",
                                isEqualTo: widget.document["transaction_id"])
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            return (snapshot.data!.size > 0)
                                ? cartList(
                                    snapshot.data!.docs,
                                  )
                                : _emptyData();
                          } else {
                            return _emptyData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  confirmDeleteTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Konfirmasi Menghapus Transaksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Text('Apakah anda yakin ingin menghapus transaksi ini ?'),
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
                          await DatabaseService.deleteTransaction(
                              widget.document["transaction_id"]);

                          await DatabaseService.deleteTransactionProduct(
                              widget.document["transaction_id"], documents);

                          Navigator.of(context).pop();
                          toast('Sukses menghapus transaksi!');
                          setState(() {
                            isAcc = true;
                          });
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

  confirmCancelTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Konfirmasi Membatalkan Transaksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Text('Apakah anda yakin ingin membatalkan transaksi ini ?'),
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
                          await DatabaseService.cancelTransaction(
                              widget.document["transaction_id"]);

                          Navigator.of(context).pop();
                          toast('Sukses membatalkan transaksi!');
                          setState(() {
                            isAcc = true;
                          });
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

  static Future<void> openDialer(String phoneNumber) async {
    var url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  whatsapp(String phoneNumber) async {
    var contact = "+62${phoneNumber.substring(1)}";
    var androidUrl =
        "whatsapp://send?phone=$contact&text=Halo, Bisakah kita berduskusi untuk menentukan lokasi COD transaksi Agista Official ?";

    try {
      await launchUrl(Uri.parse(androidUrl));
    } on Exception {}
  }

  confirmAccTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Konfirmasi Menyetujui Transaksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Text(
                    'Apakah anda yakin ingin bahwa produk telah siap, dan bersedia untuk melakukan COD bersama kustomer ini ?'),
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
                          await DatabaseService.accTransaction(
                              widget.document["transaction_id"]);
                          Navigator.of(context).pop();
                          toast('Siap Untuk COD!');
                          setState(() {
                            isAcc = true;
                          });
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

  Widget cartList(List<DocumentSnapshot> document) {
    documents.clear();
    documents.addAll(document);
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: document.length,
      itemBuilder: (context, i) {
        String name = document[i]['name'].toString();
        int price = document[i]['price'];
        int disc_percentage = document[i]['disc_percentage'];
        int disc_price = document[i]['disc_price'];
        List<dynamic> url = document[i]['image'];

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: MediaQuery.of(context).size.width - 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: Image.network(
                          url[0],
                          fit: BoxFit.cover,
                          height: 100,
                          width: 100,
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 225,
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: 5,
                            ),
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              "Qty: ${document[i]["stock_buy"].toString()}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              (disc_percentage > 0)
                                  ? "${formattedCurrency.format(disc_price * document[i]["stock_buy"])}"
                                  : "${formattedCurrency.format(price * document[i]["stock_buy"])}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyData() {
    return Container(
      child: Center(
        child: Text(
          'Tidak Ada Produk',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:agistaofficial/database/database_service.dart';
import 'package:agistaofficial/screens/login_screen.dart';
import 'package:agistaofficial/util/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../util/SheetsColumn.dart';
import '../../util/google_sheet.dart';
import '../../util/themes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var totalCartProduct = 0;
  List<bool> isChecked = [];
  List<DocumentSnapshot> cartData = [];
  String userName = "";
  String receiverName = "";
  String address = "";
  String role = "";
  String uid = "";
  String phone = "";
  String adminToken = "";
  bool isTransaction = false;

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
        userName = value.data()!["name"];
        receiverName = value.data()!["receiver_name"];
        phone = value.data()!["phone"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Themes(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              padding: EdgeInsets.only(top: 30),
              color: AppCommon.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Center(
                      child: Text(
                    'Keranjang',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )),
                  (isTransaction)
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Container(),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 100, bottom: 70),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('cart')
                    .where("user_id",
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return (snapshot.data!.size > 0 && !isTransaction)
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
            (totalCartProduct > 0)
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        var isAnyChecked = false;
                        try {
                          for (int i = 0; i < cartData.length; i++) {
                            if (isChecked[i]) {
                              isAnyChecked = true;
                            }
                          }
                        } catch (err) {}

                        if (isAnyChecked) {
                          showCheckoutDialog();
                        } else {
                          toast(
                              'Silahkan pilih produk yang ingin anda checkout terlebih dahulu!');
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(16),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppCommon.green,
                        ),
                        child: Center(
                          child: Text(
                            'Checkout Produk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ))
                : Container()
          ],
        ),
      ),
    );
  }

  Widget cartList(List<DocumentSnapshot> document) {
    cartData.clear();
    cartData.addAll(document);
    if (isChecked.length == 0) {
      document.forEach((element) {
        isChecked.add(false);
      });
    }

    return ListView.builder(
      itemCount: document.length,
      itemBuilder: (context, i) {
        String name = document[i]['name'].toString();
        int price = document[i]['price'];
        int disc_percentage = document[i]['disc_percentage'];
        int disc_price = document[i]['disc_price'];
        String cartId = document[i]['cart_id'].toString();
        List<dynamic> url = document[i]['image'];

        var formattedCurrency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
                value: isChecked[i],
                onChanged: (value) {
                  setState(() {
                    totalCartProduct = document.length;
                    isChecked[i] = value!;
                  });
                }),
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                    InkWell(
                      onTap: () {
                        showDialogDelete(name, cartId, i);
                      },
                      child: Icon(
                        Icons.delete,
                        size: 35,
                        color: Colors.redAccent,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyData() {
    return Container(
      child: Center(
        child: Text(
          'Tidak Ada Produk\nDalam Keranjang',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  showDialogDelete(String name, String cartId, int index) {
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
                  'Konfirmasi Menghapus Produk',
                  textAlign: TextAlign.center,
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
                'Apakah anda yakin ingin menghapus produk ${name} dari keranjang ?',
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
                      await FirebaseFirestore.instance
                          .collection("cart")
                          .doc(cartId)
                          .delete()
                          .then(
                              (value) => {isChecked.clear(), setState(() {})});
                      Navigator.of(context).pop();
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

  showCheckoutDialog() {
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
                  'Konfirmasi Checkout Produk',
                  textAlign: TextAlign.center,
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
                'Apakah anda yakin ingin melakukan checkout pada produk yang anda pilih ?',
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
                      setState(() {
                        isTransaction = true;
                      });
                      Navigator.of(context).pop();
                      // Implement saving logic here
                      DateTime now = DateTime.now();
                      int transactionId = now.millisecondsSinceEpoch;
                      String dateTime =
                          DateFormat('dd MMM yyyy, HH:mm').format(now);
                      num totalTransaction = 0;
                      for (int i = 0; i < cartData.length; i++) {
                        if (isChecked[i]) {
                          if (cartData[i]["disc_percentage"] > 0) {
                            totalTransaction += cartData[i]["disc_price"] *
                                cartData[i]["stock_buy"];
                          } else {
                            totalTransaction +=
                                cartData[i]["price"] * cartData[i]["stock_buy"];
                          }
                        }
                      }

                      /// CREATE TRANSACTION
                      await DatabaseService.createTransaction(
                          transactionId,
                          uid,
                          userName,
                          receiverName,
                          phone,
                          address,
                          totalTransaction,
                          dateTime,
                          "Menunggu Konfirmasi Admin");

                      for (int i = 0; i < cartData.length; i++) {
                        if (isChecked[i]) {
                          DateTime now = DateTime.now();
                          int transactionProductId = now.millisecondsSinceEpoch;

                          String product_id = cartData[i]["product_id"];
                          String user_id = cartData[i]["user_id"];
                          String name = cartData[i]["name"];
                          num price = cartData[i]["price"];
                          num stock_before = cartData[i]["stock_before"];
                          String description = cartData[i]["description"];
                          String category = cartData[i]["category"];
                          List<dynamic> image = cartData[i]['image'];
                          num sold = cartData[i]["sold"];
                          num disc_percentage = cartData[i]["disc_percentage"];
                          num disc_price = cartData[i]["disc_price"];
                          num stock_buy = cartData[i]["stock_buy"];

                          /// CREATE TRANSACTION_PRODUCT
                          await DatabaseService.createTransactionProduct(
                            transactionProductId.toString(),
                            transactionId.toString(),
                            product_id,
                            user_id,
                            name,
                            price,
                            stock_before,
                            description,
                            category,
                            image,
                            sold,
                            disc_percentage,
                            disc_price,
                            stock_buy,
                          );
                        }
                      }

                      var i = 0;
                      await Future.forEach(cartData, (element) async {
                        print(cartData.length);
                        print(isChecked.length);
                        if (isChecked[i]) {
                          String cart_id = cartData[i]["cart_id"];

                          /// DELETE CART
                          await FirebaseFirestore.instance
                              .collection('cart')
                              .doc(cart_id)
                              .delete();
                        }
                        i++;
                      });

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(AppCommon.adminUid)
                          .get()
                          .then((value) {
                        adminToken = value.data()!["token"];
                      });
                      sendPushMessage();

                      setState(() {
                        isChecked.clear();
                        print(isChecked.toString());
                        isTransaction = false;
                      });

                      toast('Berhasil membuat transakci baru!');

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

  Future<void> sendPushMessage() async {
    if (adminToken == '') {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${AppCommon.serverKey}',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Silahkan konfirmasi transaksi baru",
              'title': "Agista Official",
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": adminToken,
          },
        ),
      );
      print('done');
      print('$adminToken');
    } catch (e) {
      print("error push notification");
    }
  }
}

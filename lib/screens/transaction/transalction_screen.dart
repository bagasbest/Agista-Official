import 'package:agistaofficial/screens/transaction/transaction_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/common.dart';
import '../../util/themes.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<String> statusList = [
    "Semua",
    "Menunggu Konfirmasi Admin",
    "Transaksi Selesai",
    "Transaksi Dibatalkan"
  ];
  String status = "";
  String role = "";

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
              child: Center(
                  child: Text(
                'Transaksi',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              )),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 16,
                top: 100,
                right: 16,
              ),
              width: MediaQuery.of(context).size.width,
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSearchBox: false,
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Pilih Status Transaksi",
                ),
                items: statusList,
                onChanged: (String? newValue) {
                  setState(() {
                    status = newValue!;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 170),
              child: StreamBuilder(
                stream: (status == "" || status == "Semua")
                    ? (role == "user")
                        ? FirebaseFirestore.instance
                            .collection('transaction')
                            .where("user_id",
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('transaction')
                            .snapshots()
                    : (role == "user")
                        ? FirebaseFirestore.instance
                            .collection('transaction')
                            .where("user_id",
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .where("status", isEqualTo: status)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('transaction')
                            .where("status", isEqualTo: status)
                            .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return (snapshot.data!.size > 0)
                        ? transactionList(
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
    );
  }

  Widget transactionList(List<DocumentSnapshot> document) {
    var docs = document.reversed.toList();
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, i) {
        String date_time = docs[i]['date_time'].toString();
        String status = docs[i]['status'].toString();
        int total_transaction = docs[i]['totalTransaction'];
        String transaction_id = docs[i]['transaction_id'].toString();
        String user_address = docs[i]['user_address'].toString();
        String user_id = docs[i]['user_id'].toString();
        String user_name = docs[i]['user_name'].toString();
        String user_phone = docs[i]['user_phone'].toString();

        var formattedCurrency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        );
        return InkWell(
          onTap: () {
            Route route = MaterialPageRoute(
                builder: (context) => TransactionDetail(
                      document: docs[i],
                      role: role,
                    ));
            Navigator.push(context, route);
          },
          child: Container(
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width - 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: Text(
                            'Nama: $user_name',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Tanggal: $date_time',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Total Transaksi: ${formattedCurrency.format(total_transaction)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: (status == "Menunggu Konfirmasi Admin")
                                  ? Colors.orange
                                  : (status == "Siap Untuk COD")
                                      ? Colors.blue
                                      : (status == "Transaksi Selesai")
                                          ? Colors.green
                                          : Colors.red,
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                      ],
                    ),
                  ],
                ),
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
          'Tidak Ada Transaksi\nTersedia',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}

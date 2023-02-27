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
    "Menunggu Konfirmasi Admin",
    "Lengkapi Alamat Anda",
    "Siap Untuk COD",
    "Transaksi Selesai",
    "Transaksi Dibatalkan"
  ];
  String status = "";

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
                showSearchBox: true,
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
                stream: FirebaseFirestore.instance
                    .collection('transaction')
                    .where("user_id",
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
    return ListView.builder(
      itemCount: document.length,
      itemBuilder: (context, i) {
        String date_time = document[i]['date_time'].toString();
        String status = document[i]['status'].toString();
        int total_transaction = document[i]['totalTransaction'];
        String transaction_id = document[i]['transaction_id'].toString();
        String user_address = document[i]['user_address'].toString();
        String user_id = document[i]['user_id'].toString();
        String user_name = document[i]['user_name'].toString();
        String user_phone = document[i]['user_phone'].toString();

        var formattedCurrency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        );
        return Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                          left: 8,
                          right: 8,
                          bottom: 5,
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
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total Transaksi: ${formattedCurrency.format(total_transaction)}',
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
                  InkWell(
                    onTap: () {},
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

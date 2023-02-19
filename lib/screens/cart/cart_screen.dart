import 'package:agistaofficial/screens/cart/cart_list.dart';
import 'package:agistaofficial/util/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../util/themes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Themes(),
        child: Scaffold(
          body:SafeArea(
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  color: AppCommon.green,
                  child: Center(child: Text('Keranjang',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),)),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('cart')
                        .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return (snapshot.data!.size > 0)
                            ? CartList(
                            document: snapshot.data!.docs,)
                            : _emptyData();
                      } else {
                        return _emptyData();
                      }
                    },
                  ),
                )
              ],
            ),
          )
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
}

import 'package:flutter/material.dart';

import '../../util/common.dart';
import '../../util/themes.dart';

class CODScreen extends StatefulWidget {
  const CODScreen({Key? key}) : super(key: key);

  @override
  State<CODScreen> createState() => _CODScreenState();
}

class _CODScreenState extends State<CODScreen> {
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
                      'COD ',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
              ),
            ],
          ),
        ));
  }
}

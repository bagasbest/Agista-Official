import 'package:agistaofficial/screens/register_screen.dart';
import 'package:agistaofficial/util/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../database/database_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isFocused = false;
  bool _isInput = false;
  var _phone = TextEditingController();
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/welcome.PNG',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Selamat datang di\nAgista Official.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Image.asset(
                    'assets/smaller_logo.PNG',
                    width: 200,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Silahkan login dengan nomor handphone kamu, kami menyediakan kebutuhanmu pada aplikasi ini!',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          controller: _phone,
                          decoration: InputDecoration(
                            hintText: 'Nomor Handphone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: _isFocused ? AppCommon.green : Colors.grey,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: _isFocused ? AppCommon.green : Colors.grey,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(10.0),
                            hintStyle: TextStyle(
                              color: _isFocused ? AppCommon.green : Colors.grey,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            if (value.length >= 10 && value.length <= 13) {
                              setState(() {
                                _isInput = true;
                              });
                            } else {
                              setState(() {
                                _isInput = false;
                              });
                            }
                            return null;
                          },
                          onTap: () {
                            setState(() {
                              _isFocused = !_isFocused;
                            });
                          },
                        ),
                        (_isFocused)
                            ? Padding(
                          padding: const EdgeInsets.only(left: 5, top: 5),
                          child: Text(
                            'Nomor Handphone (contoh:081122335566)',
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        )
                            : Container(),
                        const SizedBox(
                          height: 30,
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

                        InkWell(
                          onTap: () async {
                            print(_phone.text.toString().length);
                            if (_phone.text.toString().length >= 10 && _phone.text.toString().length <= 13) {
                              setState(() {
                                _visible = true;
                              });


                              /// cek apakah sudah terdaftar no tersebut
                              var isStored = await isPhoneNumberStored(_phone.text);



                              setState(() {
                                _visible = false;
                              });

                              if (isStored) {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                        (Route<dynamic> route) => false);
                              }
                            } else {
                             toast('Nomor Handphone terdiri dari 10 - 13 karakter');
                            }
                            return null;
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                color: (_isInput) ? AppCommon.green : Colors.grey[300]),
                            child: Center(
                              child: Text(
                                'Masuk Sekarang',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Saya belum memiliki akun, ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            InkWell(
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterScreen());
                                Navigator.push(context, route);
                              },
                              child: Text(
                                'ingin Mendaftar',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: AppCommon.green),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<bool> isPhoneNumberStored(String phoneNumber) async {
    // 1. Retrieve all documents from the collection
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    // 2. Loop through each document
    var i = 0;
    for (var document in documents) {
      // 3. Retrieve the phone number field
      String storedPhoneNumber = document.get("phone");
      String email = document.get("email");
      String pwd = document.get("password");
      String uid = document.get("uid");

      // 4. Compare the retrieved phone number with the desired phone number
      if (storedPhoneNumber == phoneNumber) {
        // 5. If a match is found, return true
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pwd);

        /// MASUK KE HOMEPAGE JIKA SUKSES LOGIN
        if(email == 'admin@gmail.com') {
          String? token = await FirebaseMessaging.instance.getToken();
          await DatabaseService.updateAdminToken(token, uid);
        }

        return true;
      } else if(i == documents.length-1) {
        toast('Nomor handphone anda belum terdaftar di aplikasi Agista Official');
      }
      i++;
    }

    // 6. If no match is found, return false
    return false;
  }
}
/// CUSTOM TOAST
void toast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppCommon.green,
      textColor: Colors.white,
      fontSize: 16.0);
}
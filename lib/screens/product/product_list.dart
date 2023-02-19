import 'package:agistaofficial/screens/product/product_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';

class ProductList extends StatelessWidget {
  final List<DocumentSnapshot> document;
  final String role;
  final List<String> categoryList;

  ProductList({
    required this.document,
    required this.role,
    required this.categoryList,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      itemCount: document.length,
      itemBuilder: (context, i) {
        String name = document[i]['name'].toString();
        int price = document[i]['price'];
        int disc_percentage = document[i]['disc_percentage'];
        int disc_price = document[i]['disc_price'];
        String sold = document[i]['sold'].toString();
        List<dynamic> url = document[i]['image'];

        var formattedCurrency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        );
        return GestureDetector(
          onTap: () {
            Route route = MaterialPageRoute(
              builder: (context) => ProductDetail(product: document[i], role: role, categoryList: categoryList),
            );
            Navigator.push(context, route);
          },
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url[0],
                        fit: BoxFit.cover,
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      document[i]["category"],
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
                        (disc_percentage>0)?
                      "${formattedCurrency.format(disc_price)}" : "${formattedCurrency.format(price)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),

                  (disc_percentage > 0) ? Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.pink[100]
                          ),
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            "$disc_percentage%",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                          )),
                      SizedBox(width: 10,),
                      Text(
                        "${formattedCurrency.format(price)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black26,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ) : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  (int.parse(sold) > 0)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "$sold kali terjual",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

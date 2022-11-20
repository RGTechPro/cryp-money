import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptapp/network/coin_geckp_api.dart';
import 'package:cryptapp/pojo/gecko_market.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  late Future<List<GeckoMarket>> futureGeckoMarket;

  List<GeckoMarket> _marketData = [];
  List<GeckoMarket> _copyMarketData = [];
  bool isMarketLoaded = false;
  @override
  void initState() {
    getdata();
    super.initState();
  }

  void getdata() async {
    _marketData = await getGeckoMarket();
    setState(() {
      isMarketLoaded = true;
    });
  }

  TextEditingController _textFieldController = TextEditingController();
  @override
  CollectionReference portfolio =
      FirebaseFirestore.instance.collection('portfolio');
  Widget build(BuildContext context) {
    String? codeDialog;
    String? valueText;
    bool cancel = false;
    Future<void> _displayTextInputDialog(BuildContext context) async {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Enter new quantity to add to portfolio'),
              content: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
                ],
                onChanged: (value) {
                  setState(() {
                    valueText = value;
                  });
                },
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Quantity"),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text('CANCEL'),
                  onPressed: () {
                    setState(() {
                      cancel = true;
                      Navigator.pop(context);
                    });
                  },
                ),
                FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('ADD'),
                  onPressed: () {
                    setState(() {
                      codeDialog = valueText;
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
    }

    void deleteP(String crypname, context) {
      CollectionReference portfolio =
          FirebaseFirestore.instance.collection('portfolio');
      portfolio
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({crypname: FieldValue.delete()})
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
          setState(() {
            
          });
      final snackBar = new SnackBar(
          content: new Text('Deleted successfully!'),
          backgroundColor: Colors.red);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    void upadteValue(String crypname, context) async {
      await _displayTextInputDialog(context);
      if (!cancel) {
        CollectionReference portfolio =
            FirebaseFirestore.instance.collection('portfolio');
        portfolio
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({crypname: codeDialog})
            .then((value) => print("User Added"))
            .catchError((error) => print("Failed to add user: $error"));
        final snackBar = new SnackBar(
            content: new Text('Updated successfully!'),
            backgroundColor: Colors.red);

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return (isMarketLoaded)
        ? SafeArea(
            child: Scaffold(
                body: FutureBuilder<DocumentSnapshot>(
              future:
                  portfolio.doc(FirebaseAuth.instance.currentUser!.uid).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.hasData && !snapshot.data!.exists) {
                  return Center(child: Text("Nothing in the portfolio"));
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  var mData = _marketData;
                  double totalValue = 0;
                  print('size${mData.length}');
                  List<GeckoMarket> aData = [];
                  for (int i = 0; i < data.length; i++) {
                    String crypName = data.keys.toList()[i];
                    mData.forEach((element) {
                      print(crypName);
                      if (element.name == crypName) {
                        print('hi');
                        aData.add(element);
                      }
                    });
                  }
                  for (int i = 0; i < aData.length; i++) {
                    totalValue = totalValue +
                        aData[i].currentPrice! *
                            double.parse(data.values.toList()[i]);
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${FirebaseAuth.instance.currentUser!.displayName}'s Portfolio",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Total Value: ₹ ${totalValue.toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return CryptoPCard(
                              id: '1',
                              cryptoName: data.keys.toList()[index],
                              quantity:
                                  double.parse(data.values.toList()[index]),
                              price: aData[index].currentPrice! *
                                  double.parse(data.values.toList()[index]),
                              change: aData[index].priceChangePercentage_24h!,
                              image: aData[index].image!,
                              delete: deleteP,
                              upadte: upadteValue,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return Center(child: CircularProgressIndicator());
              },
            )),
          )
        : Center(child: CircularProgressIndicator());
  }
}

class CryptoPCard extends StatelessWidget {
  final String id;
  final String cryptoName;
  final double quantity;
  final double price;
  final double change;
  final String image;
  Function? delete;
  Function? upadte;
  CryptoPCard(
      {required this.id,
      required this.cryptoName,
      required this.quantity,
      required this.price,
      required this.change,
      required this.image,
      this.delete,
      this.upadte});
  @override
  CollectionReference portfolio =
      FirebaseFirestore.instance.collection('portfolio');
  Widget build(BuildContext context) {
    var tArrow;
    if (change > 0) {
      tArrow = upArrow();
    } else {
      tArrow = downArrow();
    }
    return SwipeActionCell(
      key: Key(cryptoName),
      performsFirstActionWithFullSwipe: true,
      leadingActions: <SwipeAction>[
        SwipeAction(
            title: 'Delete',
            onTap: (CompletionHandler handler) async {
              delete!(cryptoName, context);
            })
      ],
      trailingActions: <SwipeAction>[
        SwipeAction(
            title: "Update quantity",
            onTap: (CompletionHandler handler) async {
              upadte!(cryptoName, context);
            },
            color: Colors.green),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: TextButton(
          onPressed: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => CryptoDetailCard(id: id)));
          },
          style: TextButton.styleFrom(
            padding:
                EdgeInsets.only(top: 3.0, bottom: 3.0, left: 6.0, right: 6.0),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Row(
              children: [
                Expanded(
                  child: Image.network(
                    image,
                    height: 45,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          cryptoName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text('Quantity: ${quantity.toStringAsFixed(2)}'),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text('₹ ${price.toStringAsFixed(2)}'),
                      ),
                      Row(
                        children: [
                          tArrow,
                          Text('${change.toStringAsFixed(2)}%'),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget upArrow() {
  return Icon(
    Icons.arrow_upward_rounded,
    color: Colors.green,
  );
}

Widget downArrow() {
  return Icon(
    Icons.arrow_downward_rounded,
    color: Colors.red,
  );
}

//   Future<void> _displayTextInputDialog(BuildContext context) async {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Enter new quantity to add to portfolio'),
//             content: TextField(keyboardType: TextInputType.numberWithOptions(decimal: true),
//             inputFormatters: <TextInputFormatter>[
//    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
// ],
//               onChanged: (value) {
//                 setState(() {
//                   valueText = value;
//                 });
//               },
//               controller: _textFieldController,
//               decoration: InputDecoration(hintText: "Quantity"),
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 color: Colors.red,
//                 textColor: Colors.white,
//                 child: Text('CANCEL'),
//                 onPressed: () {
//                   setState(() {
//                     Navigator.pop(context);
//                   });
//                 },
//               ),
//               FlatButton(
//                 color: Colors.green,
//                 textColor: Colors.white,
//                 child: Text('ADD'),
//                 onPressed: () {
//                   setState(() {
//                     codeDialog = valueText;
//                     Navigator.pop(context);
//                   });
//                 },
//               ),
//             ],
//           );
//         });
//   }
// void deleteP(String crypname, context) {
//   CollectionReference portfolio =
//       FirebaseFirestore.instance.collection('portfolio');
//   portfolio
//       .doc(FirebaseAuth.instance.currentUser!.uid)
//       .update({crypname: FieldValue.delete()})
//       .then((value) => print("User Added"))
//       .catchError((error) => print("Failed to add user: $error"));
//   final snackBar = new SnackBar(
//       content: new Text('Deleted successfully!'), backgroundColor: Colors.red);

//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }

// void upadteValue(String crypname,  context)async {
//    await _displayTextInputDialog(context);
//   CollectionReference portfolio =
//       FirebaseFirestore.instance.collection('portfolio');
//   portfolio
//       .doc(FirebaseAuth.instance.currentUser!.uid)
//       .update({crypname: codeDialog})
//       .then((value) => print("User Added"))
//       .catchError((error) => print("Failed to add user: $error"));
//   final snackBar = new SnackBar(
//       content: new Text('Updated successfully!'), backgroundColor: Colors.red);

//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }

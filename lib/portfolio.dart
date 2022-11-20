import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptapp/network/coin_geckp_api.dart';
import 'package:cryptapp/pojo/gecko_market.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  CollectionReference portfolio =
      FirebaseFirestore.instance.collection('portfolio');
  Widget build(BuildContext context) {
    return (isMarketLoaded)
        ? SafeArea(
            child: Scaffold(
                body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${FirebaseAuth.instance.currentUser!.displayName}'s Portfolio",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: portfolio
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get(),
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
                        return ListView.builder(
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
                                image: aData[index].image!);
                          },
                        );
                      }

                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
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
  CryptoPCard(
      {required this.id,
      required this.cryptoName,
      required this.quantity,
      required this.price,
      required this.change,
      required this.image});
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
    return Padding(
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
                      child: Text(quantity.toStringAsFixed(2)),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text('₹ ${price.toString()}'),
                    ),
                    Row(
                      children: [
                        tArrow,
                        Text('${change.toString()}%'),
                      ],
                    )
                  ],
                ),
              )
            ],
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

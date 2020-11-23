import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'premium.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PurchaserInfo purchaserInfo;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("your-api-key");
    purchaserInfo = await Purchases.getPurchaserInfo();
  }

  Future<bool> userIsPremium() async {
    purchaserInfo = await Purchases.getPurchaserInfo();
    return purchaserInfo.entitlements.all["premium"] != null &&
        purchaserInfo.entitlements.all["premium"].isActive;
  }

  Future<void> showPaywall() async {
    Offerings offerings = await Purchases.getOfferings();
    if (offerings.current != null && offerings.current.monthly != null) {
      final currentMonthlyProduct = offerings.current.monthly.product;
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text(currentMonthlyProduct.description),
                content: Row(
                  children: [Text(currentMonthlyProduct.priceString)],
                ),
                actions: [
                  RaisedButton(
                      onPressed: () async {
                        await makePurchases(offerings.current.monthly);
                      },
                      child: Text('Buy'))
                ],
              ));
    }
  }

  Future<void> makePurchases(Package package) async {
    try {
      purchaserInfo = await Purchases.purchasePackage(package);
      print(purchaserInfo);
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  onPressed: () async {
                    if (await userIsPremium()) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PremiumScreen()));
                    } else {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("You aren't premium user")));
                    }
                  },
                  child: Text('Go to premium page')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPaywall();
        },
        tooltip: 'Buy',
        child: Icon(Icons.euro),
      ),
    );
  }
}

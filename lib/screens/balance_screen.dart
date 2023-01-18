import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/material.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  String moneyText = "Rs. 500";

  Widget currentBalance() {
    return Card(
      shape: RoundedRectangleBorder(
        //<-- SEE HERE
        side: BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      color: lightGrey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Balance",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(moneyText),
                Text(
                  "ADD ETAXI Money",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget serviceRowListItem(Icon icon, String title) {
    return Card(
      color: lightGrey,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            icon,
            Text(
              title,
              style: TextStyle(fontSize: 10, color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget serviceList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "  Service",
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
        ),
        Card(
          color: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 1,
                  child: serviceRowListItem(
                      Icon(Icons.money, color: primaryColor), "Pay"),
                ),
                Expanded(
                  flex: 1,
                  child: serviceRowListItem(
                      Icon(Icons.send_outlined, color: primaryColor), "Send Money"),
                ),
                Expanded(
                  flex: 1,
                  child: serviceRowListItem(Icon(Icons.receipt_long, color: primaryColor),
                      "Bill payment"),
                ),
                Expanded(
                  flex: 1,
                  child: serviceRowListItem(
                      Icon(
                        Icons.history,
                        color: primaryColor,
                      ),
                      "History"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget lastActivity() {
    return Card(
      color: lightGrey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Last Activity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ETaxi"),
                Text(
                  "60.72",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Other"),
                Text(
                  "-20.21",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget cashbackView() {
    return Card(
      color: lightGrey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cashback & Discounts",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: primaryColor,
                    )),
              ],
            ),
            Text(
              "Make your money go step up",
              style: TextStyle(
                color: primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget addressList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.home,
              color: primaryColor,
            ),
            label: Text(
              "ADD YOUR HOME ADDRESS",
              style: TextStyle(color: Colors.black,),
            ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0
              )
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.warehouse_rounded,
              color: primaryColor,
            ),
            label: Text(
              "ADD YOUR WORK/OFFICE ADDRESS",
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black),
            ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                elevation: 0
              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BOOK MY ETAXI Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        child: Column(
          children: [
            Expanded(flex: 3, child: Icon(Icons.money)),
            Expanded(flex: 2, child: currentBalance()),
            Expanded(flex: 2, child: serviceList()),
            Expanded(flex: 2, child: lastActivity()),
            Expanded(flex: 2, child: cashbackView()),
            Expanded(flex: 2, child: addressList()),
          ],
        ),
      ),
    );
  }
}

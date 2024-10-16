import 'package:book_my_taxi/service/razor_pay.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String amt;

  const PaymentScreen({Key? key, required this.amt}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Payment mode"),
        elevation: 0,
        backgroundColor: Colors.grey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        "Rs. ${widget.amt}",
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "ESTIMATED FARE",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "SELECT PAYMENT MODE",
                              textAlign: TextAlign.start,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              currentIndex = 0;
                            });
                          },
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.paypal),
                              title: const Text("RazorPay"),
                              trailing: currentIndex == 0
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.orange,
                                    )
                                  : const Icon(null),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              currentIndex = 2;
                            });
                          },
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.money),
                              title: const Text("Cash"),
                              trailing: currentIndex == 2
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.orange,
                                    )
                                  : const Icon(null),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (currentIndex == 0) {
                          RazorPayService().initRazorPay();
                          await RazorPayService().createOrder(widget.amt);
                        } else {
                          RazorPayService.paymentSuccess = true;
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text("DONE"),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

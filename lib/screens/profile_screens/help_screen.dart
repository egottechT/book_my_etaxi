import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  TextStyle customStyle(isBold) {
    return TextStyle(
        color: primaryColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: 15);
  }

  Widget spaceBetweenWidget() {
    return const SizedBox(
      height: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "We are always ready to help you. Any query please free to contact us",
                style: customStyle(false),
              ),
            ),
            firstCardView(),
            secondCardView(),
            lastCardView(),
          ],
        ),
      ),
    );
  }

  firstCardView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Image.asset("assets/images/permission_page.png"),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: "Customer Support", style: customStyle(false)),
                TextSpan(text: " 24/7", style: customStyle(true)),
              ])),
              Text("Customer support email id", style: customStyle(false)),
              const Text("buymyeticket.com@gmail.com"),
              Container(
                height: 2,
                width: MediaQuery.of(context).size.width * 0.5,
                color: Colors.black,
              ),
              Text("Customer care Number :", style: customStyle(false)),
              const Text("IND +91 9435351122")
            ],
          )
        ],
      ),
    );
  }

  secondCardView() {
    return Container(
      color: primaryColor,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("The start guide to Book My ETaxi",
                    style: customStyle(true)),
                const SizedBox(
                  height: 20,
                ),
                const Text("How to book your ride on Book My ETaxi"),
                const Text("just follow the simple steps."),
              ],
            ),
          ),
        ),
      ),
    );
  }

  lastCardView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Help Tabs", style: TextStyle(color: primaryColor,fontSize: 18,fontWeight: FontWeight.bold)),
          const SizedBox(height: 5,),
          iconWithText(Icon(Icons.person_pin,color: primaryColor,), "My Account",
              "Accounts, Earn & Referral code, and more benefits"),
          spaceBetweenWidget(),
          iconWithText(
              Icon(Icons.currency_exchange,color: primaryColor,),
              "Taxi Charges or Fare",
              "Book my etaxi offers car-sharing services.\nSo you can save your time & money"),
          spaceBetweenWidget(),
          iconWithText(Icon(Icons.safety_check,color: primaryColor,), "Safety Term",
              "For any questions concerns or queries.\nWe're happy to talk with you."),
          spaceBetweenWidget(),
          iconWithText(
              Icon(Icons.car_rental,color: primaryColor,),
              "About BOOK MY ETAXI services",
              "-Online solo booking\n-Online sharing booking\n-Rental booking\n-Outstation booking"),
          spaceBetweenWidget(),
          iconWithText(
              Icon(Icons.car_rental,color: primaryColor,),
              "A step-by-step guide to BOOK MY ETAXI",
              "How does taxi booking apps works?"),
        ],
      ),
    );
  }

  iconWithText(Icon icon, String title, String value) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 5,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: customStyle(true),
            ),
            Text(
              value,
              style: const TextStyle(overflow: TextOverflow.clip),
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.8,
              height: 2,
              color: Colors.black,
            )
          ],
        ),
      ],
    );
  }
}

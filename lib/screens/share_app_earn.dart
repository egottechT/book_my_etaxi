import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/material.dart';

class ShareAppEarnScreen extends StatefulWidget {
  const ShareAppEarnScreen({Key? key}) : super(key: key);

  @override
  State<ShareAppEarnScreen> createState() => _ShareAppEarnScreenState();
}

//share_app.png
class _ShareAppEarnScreenState extends State<ShareAppEarnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share & Earn"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              color: secondaryColor,
              child: Row(
                children: [
                  const Expanded(
                      flex: 2,
                      child: Text(
                        "Invite your friends & family get Rs.100 per referral",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                  Expanded(
                      flex: 1,
                      child: Image.asset("assets/images/share_app.png")),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Your invites"),
                  const SizedBox(
                    height: 20,
                  ),
                  cardDetailView(),
                  const SizedBox(
                    height: 200,
                  ),
                  Container(
                    color: Colors.grey[200],
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Referral Code"),
                          Text(
                            "GPRR1U",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Share Code"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  cardDetailView() {
    return Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  detailTextView("Rs. 500", "Pending"),
                  const VerticalDivider(
                    width: 2,
                    color: Colors.grey,
                    thickness: 2,
                  ),
                  detailTextView("Rs. 3000", "Earned"),
                ],
              ),
              InkWell(
                onTap: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "See All",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              )
            ],
          ),
        ));
  }

  detailTextView(String value, String title) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: primaryColor),
        ),
        Text(title)
      ],
    );
  }
}

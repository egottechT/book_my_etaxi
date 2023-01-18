import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/material.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({Key? key}) : super(key: key);

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            cardView(
                "Share Referral Code to Friend/Family. Earn Rs. 50 per Referral",
                "Apply before 5 august 2022, enjoy the ride with your loved ones.",
                "Apply Now",
                Icon(Icons.speaker,size: 75,)),
            cardView(
                "Invite your Family & Friends to ride with BOOK MY ETAXI",
                "GPRR1U",
                "Share",
                Icon(Icons.share,size: 75)),
            cardView(
                "Email Verification",
                "Please verify Email ID to protect your account. After verifing your email can link with your profile",
                "View Profile",
                Icon(Icons.email_sharp,size: 75))
          ],
        ),
      ),
    );
  }

  Widget cardView(String title, String subtitle, String buttonText, Icon icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15,5,15,5),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Text(title,
                  style: TextStyle(color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),),
                  SizedBox(height: 20,),
                  Text(subtitle),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(buttonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    )),
                  )
                ],
              ),
            ),
            Expanded(flex: 1,child: icon)
          ],
        ),
      ),
    );
  }
}

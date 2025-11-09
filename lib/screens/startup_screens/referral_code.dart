import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/user_model.dart';
import 'package:book_my_taxi/repository/user_repo.dart';
import 'package:book_my_taxi/screens/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  UserModel userModel = UserModel();

  getData() async {
    UserModel model = await UserRepo().getUserInfo(context, true);
    setState(() {
      userModel = model;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share & Earn"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              color: secondaryColor,
              padding: EdgeInsets.only(left: 10),
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
                  ElevatedButton(
                    onPressed: () {
                      String referral = UserRepo.userUUid;
                      Share.share(referral,
                          subject: 'Share your referral Code');
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Share Code"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showReferAndBox(context, userModel.referred);
                      setState(() {
                        userModel.referred = true;
                      });
                      debugPrint("values is ${userModel.referred}");
                      Provider.of<UserModelProvider>(context, listen: false)
                          .setData(userModel);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Have a referral Code."),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/permissionScreen");
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("DONE"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

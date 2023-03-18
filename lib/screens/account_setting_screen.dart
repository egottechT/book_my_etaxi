import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  TextStyle customStyle(isBold) {
    return TextStyle(
        color: primaryColor,
        overflow: TextOverflow.clip,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: 16);
  }

  ShapeBorder coloredBorder = const RoundedRectangleBorder(
    side: BorderSide(
      color: Colors.deepPurpleAccent, //<-- SEE HERE
    ),
  );

  Widget spaceBetweenWidget() {
    return const SizedBox(
      height: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Account Setting"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            profileSection(),
            spaceBetweenWidget(),
            firstCardView(),
            spaceBetweenWidget(),
            secondCardView(),
            spaceBetweenWidget(),
            thirdCardView(),
            spaceBetweenWidget(),
            fourthCardView(),
            spaceBetweenWidget(),
            ElevatedButton(onPressed: () {}, child: const Text("Sign out"))
          ],
        ),
      ),
    );
  }

  profileSection() {
    UserModel model = Provider.of<UserModelProvider>(context,listen: false).data;
    return Container(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ListTile(
            leading: const Icon(
              Icons.person_pin,
              size: 75,
            ),
            title: Text(
              model.name,
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: Text(model.phoneNumber),
          )),
    );
  }

  firstCardView() {
    return Card(
      shape: coloredBorder,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose your location",
              style: customStyle(true),
            ),
            iconWithText(
                Icon(
                  Icons.home,
                  color: primaryColor,
                ),
                "Add your Home Address"),
            iconWithText(
                Icon(
                  Icons.storefront_outlined,
                  color: primaryColor,
                ),
                "Add your Work Address"),
            iconWithText(
                Icon(
                  Icons.location_on,
                  color: primaryColor,
                ),
                "Others"),
          ],
        ),
      ),
    );
  }

  iconWithText(Icon icon, String title) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        icon,
        const SizedBox(
          width: 5,
        ),
        Text(
          title,
          style: const TextStyle(overflow: TextOverflow.clip),
        ),
      ],
    );
  }

  secondCardView() {
    return Card(
      shape: coloredBorder,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please verify your Email id for add security",
              style: customStyle(true),
            ),
            iconWithText(Icon(Icons.cloud, color: primaryColor),
                "2-step verification to add an extra layer of\nsecurity")
          ],
        ),
      ),
    );
  }

  thirdCardView() {
    return Card(
      shape: coloredBorder,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manage your reliable Contacts", style: customStyle(true)),
            iconWithText(Icon(Icons.contact_page, color: primaryColor),
                "Share your trip with friends & family in one click"),
          ],
        ),
      ),
    );
  }

  fourthCardView() {
    return Card(
      shape: coloredBorder,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Privacy Terms", style: customStyle(true)),
            iconWithText(
                Icon(
                  Icons.document_scanner_sharp,
                  color: primaryColor,
                ),
                "We manage all the data with security & privacy\nterms")
          ],
        ),
      ),
    );
  }
}

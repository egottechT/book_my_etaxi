import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Widget showRatingBar(int rating) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(
      5,
      (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.orange,
        size: 25,
      ),
    ),
  );
}

Widget editableRatingBar(onStarChange) {
  return RatingBar(
      initialRating: 4,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      ratingWidget: RatingWidget(
          full: const Icon(Icons.star, color: Colors.orange),
          half: const Icon(
            Icons.star_half,
            color: Colors.orange,
          ),
          empty: const Icon(
            Icons.star_outline,
            color: Colors.orange,
          )),
      onRatingUpdate: onStarChange);
}

void showAddressSaveField(
  context,
  bool isHomeAddress,
) async {
  String label = "Work/Office Address";
  if (isHomeAddress) label = "Home Address";

  TextEditingController controller = TextEditingController();
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update you $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your address',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                String value = controller.text;
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      });
}

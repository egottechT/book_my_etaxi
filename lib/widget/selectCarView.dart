import 'package:flutter/material.dart';

Widget carCardView(Image image, String title, String desp, String price,
    int index, Function changeCar,
    {Color color = Colors.white}) {
  return DecoratedBox(
    decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20)),
    child: InkWell(
      onTap: () {
        changeCar(index, price);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          leading: image,
          title: Text(title),
          subtitle: Text(desp),
          trailing: Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}

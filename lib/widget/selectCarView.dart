import 'package:flutter/material.dart';

Widget carCardView(Image image,String title,String desp,String price,int index,Function changeCar){
    return InkWell(
      onTap: (){
        changeCar(index);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
          child: ListTile(
              leading: image,
              title: Text(title),
              subtitle: Text(desp),
              trailing: Text(price,style: TextStyle(fontWeight: FontWeight.bold),),
          ),
      ),
    );
}
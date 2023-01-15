import 'package:flutter/material.dart';

class PanelWidget extends StatelessWidget {
  final ScrollController controller;
  String drive = "mini";

  PanelWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      controller: controller,
      children: [
        Container(
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Flexible(
                      child: RadioListTile(
                          value: "micro",
                          title: Text(
                            "Micro",
                            style: TextStyle(fontSize: 10),
                          ),
                          groupValue: drive,
                          onChanged: (val) {
                            // setState(() {
                            //   drive = val as String;
                            // });
                          }),
                    ),
                    Flexible(
                      child: RadioListTile(
                          value: "mini",
                          title: Text(
                            "Mini",
                            style: TextStyle(fontSize: 10),
                          ),
                          groupValue: drive,
                          onChanged: (val) {
                            // setState(() {
                            //   drive = val as String;
                            // });
                          }),
                    ),
                    Flexible(
                      child: RadioListTile(
                          value: "sedan",
                          title: Text(
                            "Sedan",
                            style: TextStyle(fontSize: 10),
                          ),
                          groupValue: drive,
                          onChanged: (val) {
                            // setState(() {
                            //   drive = val as String;
                            // });
                          }),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          color: Colors.grey[300],
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                splashColor: Colors.grey,
                                icon: Icon(Icons.search),
                                onPressed: () {},
                              ),
                              const Expanded(
                                child: TextField(
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.text,
                                  textInputAction:
                                  TextInputAction.go,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                      EdgeInsets.symmetric(
                                          horizontal: 15),
                                      hintText:
                                      "Search Your Destination"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            splashColor: Colors.grey,
                            icon: const Icon(
                              Icons.home,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {

                              },
                              child: const Text(
                                "ADD YOUR HOME ADDRESS",
                                textAlign: TextAlign.left,
                                style:
                                TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            splashColor: Colors.grey,
                            icon: const Icon(
                              Icons.warehouse_rounded,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "ADD YOUR WORK/OFFICE ADDRESS",
                                textAlign: TextAlign.left,
                                style:
                                TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              )
            ],
          ),
        )
      ],
    );
  }
}

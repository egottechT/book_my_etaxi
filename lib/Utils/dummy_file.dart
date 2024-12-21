import 'package:firebase_database/firebase_database.dart';

// final databaseReference = FirebaseDatabase(
//         databaseURL:
//             "https://book-my-etaxi-default-rtdb.asia-southeast1.firebasedatabase.app")
//     .ref();

final databaseReference = FirebaseDatabase.instance.ref();

Future<void> uploadDummyDataType() async {
  Map map = {
    "Andhra Pradesh".toLowerCase(): {
      "sedan": 200,
      "suv": 500,
      "mini": 100,
    },
    "Arunachal Pradesh".toLowerCase(): {
      "sedan": 180,
      "suv": 450,
      "mini": 90,
    },
    "Assam".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Bihar".toLowerCase(): {
      "sedan": 190,
      "suv": 500,
      "mini": 110,
    },
    "Chhattisgarh".toLowerCase(): {
      "sedan": 250,
      "suv": 600,
      "mini": 130,
    },
    "Goa".toLowerCase(): {
      "sedan": 170,
      "suv": 400,
      "mini": 80,
    },
    "Gujarat".toLowerCase(): {
      "sedan": 210,
      "suv": 530,
      "mini": 100,
      "franchise": {
        "0": "aryan_bisht",
        "1": "swasstik",
        "3": "abhay",
      }
    },
    "Haryana".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Himachal Pradesh".toLowerCase(): {
      "sedan": 190,
      "suv": 480,
      "mini": 100,
    },
    "Jharkhand".toLowerCase(): {
      "sedan": 180,
      "suv": 450,
      "mini": 90,
    },
    "Karnataka".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Kerala".toLowerCase(): {
      "sedan": 200,
      "suv": 500,
      "mini": 110,
    },
    "Madhya Pradesh".toLowerCase(): {
      "sedan": 210,
      "suv": 530,
      "mini": 100,
    },
    "Maharashtra".toLowerCase(): {
      "sedan": 250,
      "suv": 600,
      "mini": 130,
    },
    "Manipur".toLowerCase(): {
      "sedan": 190,
      "suv": 480,
      "mini": 100,
    },
    "Meghalaya".toLowerCase(): {
      "sedan": 180,
      "suv": 450,
      "mini": 90,
    },
    "Mizoram".toLowerCase(): {
      "sedan": 170,
      "suv": 400,
      "mini": 80,
      "franchise": {
        "0": "aryan_bisht",
        "1": "swasstik",
        "3": "abhay",
      }
    },
    "Nagaland".toLowerCase(): {
      "sedan": 160,
      "suv": 390,
      "mini": 70,
    },
    "Odisha".toLowerCase(): {
      "sedan": 200,
      "suv": 500,
      "mini": 100,
    },
    "Punjab".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Rajasthan".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Sikkim".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Tamil Nadu".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Telangana".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Tripura".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Uttar Pradesh".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Uttarakhand".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "West Bengal".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Delhi".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    },
    "Chandigarh".toLowerCase(): {
      "sedan": 220,
      "suv": 550,
      "mini": 120,
    }
  };
  databaseReference.child("state").set(map);
}

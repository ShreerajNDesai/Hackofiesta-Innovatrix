import 'package:flutter/material.dart';

class Numbers {
  String name;
  int phoneNo;
  // String iconPath;
  Color boxColor;

  Numbers({
    required this.name,
    required this.phoneNo,
    // required this.iconPath,
    required this.boxColor,
  });

  static List<Numbers> getNumbers() {
    List<Numbers> numbers = [];

    numbers.add(Numbers(
        name: 'Women Help Line Number',
        phoneNo: 1090,
        // iconPath:'assets/icons/Con Per.png',
        boxColor: Color.fromARGB(23, 62, 62, 63)));
    numbers.add(Numbers(
        name: 'Police',
        phoneNo: 100,
        // iconPath:'assets/icons/Con Per.png',
        boxColor: Color.fromARGB(34, 142, 142, 145)));
    return numbers;
  }
}

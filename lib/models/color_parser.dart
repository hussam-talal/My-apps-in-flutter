import 'package:flutter/material.dart';

Color parseColor(String colorValue) {
  if (colorValue.startsWith('#')) {
    return Color(int.parse(colorValue.substring(1), radix: 16));
  } else {
    switch (colorValue.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'gray':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'teal':
        return Colors.teal;
      case 'cyan':
        return Colors.cyan;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'lime':
        return Colors.lime;
      case 'deepOrange':
        return Colors.deepOrange;
      case 'deepPurple':
        return Colors.deepPurple;
      case 'lightBlue':
        return Colors.lightBlue;
      case 'lightGreen':
        return Colors.lightGreen;

      case 'indigoAccent':
        return Colors.indigoAccent;
      default:
        return Colors.white;
    }
  }
}

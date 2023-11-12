// ignore_for_file: file_names

class Car {
  String model;
  String color;
  String plateNumber;

  Car(this.model, this.color, this.plateNumber);

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'color': color,
      'plateNumber': plateNumber,
    };
  }

  static Car fromMap(Map<String, dynamic> map) {
    return Car(
      map['model'],
      map['color'],
      map['plateNumber'],
    );
  }
}

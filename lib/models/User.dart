import 'Car.dart';

class User {
  final String nationalId;
  final String phoneNumber;
  final String username;
  final String password;
  final List<Car> cars;
  User(this.nationalId, this.phoneNumber, this.username, this.password,
      this.cars);
  Map<String, dynamic> toMap() {
    return {
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
      for (int i = 0; i < cars.length; i++) ...{
        'car_$i': cars[i].toMap(),
      },
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    List<Car> cars = [];
    for (int i = 0; map.containsKey('car_$i'); i++) {
      Map<String, dynamic> carMap = map['car_$i'];
      Car car = Car.fromMap(carMap);
      cars.add(car);
    }
    return User(
      map['nationalId'],
      map['phoneNumber'],
      map['username'],
      map['password'],
      cars,
    );
  }
}

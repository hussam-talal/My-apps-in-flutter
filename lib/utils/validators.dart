// TODO Implement this library.
class Validators {
  static bool isValidNationalId(String nationalId) {
    return nationalId.length == 10 && int.tryParse(nationalId) != null;
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    RegExp regExp = RegExp(r'^05\d{8}$');
    return regExp.hasMatch(phoneNumber);
  }

  static bool isValidCarPlateNumber(String PlateNumber) {
    RegExp regExp = RegExp(
        r'^\d{4}\s[A-Za-z]{1}\s[A-Za-z]{1}\s[A-Za-z]{1}\s\|\s[\u0660-\u0669]{4}\s[A-Za-z\u0621-\u064A]{1}\s[A-Za-z\u0621-\u064A]{1}\s[A-Za-z\u0621-\u064A]{1}$');
    return regExp.hasMatch(PlateNumber);
  }

  static bool isValidUsername(String username) {
    return username.isNotEmpty;
  }

 static bool isValidPassword(String password) {
 RegExp regExp =
 RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

 return regExp.hasMatch(password); }
}


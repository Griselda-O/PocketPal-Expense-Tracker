import 'package:pigeon/pigeon.dart';

class PigeonUserDetails {
  String? name;
  String? email;
  String? phone;
}

@HostApi()
abstract class UserApi {
  PigeonUserDetails getUserDetails();
  void registerUser(PigeonUserDetails details);
}

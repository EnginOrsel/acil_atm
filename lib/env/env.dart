import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'assets/api.env')
abstract class Env {
  @EnviedField(varName: 'GOOGLE_MAPS_API_KEY', obfuscate: true)
  static String googleMapsApiKey = _Env.googleMapsApiKey;
}

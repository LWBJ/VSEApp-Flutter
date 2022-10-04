import 'package:vseapp/Models/vse_data.dart';

class TokenPair implements VSEData {
  String refreshToken;
  String accessToken;

  TokenPair(this.refreshToken, this.accessToken);

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      (json.containsKey('refresh') ? json['refresh'] : ""),
      (json.containsKey('access') ? json['access'] : ""),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'refresh': refreshToken,
        'access': accessToken,
      };
}

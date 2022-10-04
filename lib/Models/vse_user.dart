import 'package:vseapp/Models/vse_data.dart';

class VSEUser extends VSEData {
  String username;
  String url;

  VSEUser(this.username, this.url);

  factory VSEUser.fromJson(Map<String, dynamic> json) {
    return VSEUser(
      json['username'],
      json['url'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'username': username,
        'url': url,
      };
}

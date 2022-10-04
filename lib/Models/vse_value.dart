import 'package:vseapp/Models/vse_data.dart';

class VSEValue extends VSEItem {
  //Inherits a 'name' and 'url' field from VSEItem
  List<String> experienceList;
  List<String> experienceURLList;

  VSEValue(super.name, super.url, super.id, this.experienceList,
      this.experienceURLList);

  factory VSEValue.fromJson(Map<String, dynamic> json) {
    //Manually cast a List<dynamic> into a List<String>
    List<String> experiences = ((json['experience_names'] as List)
        .map((item) => item.toString())).toList();
    List<String> experienceURLs =
        ((json['experiences'] as List).map((item) => item.toString())).toList();
    return VSEValue(
        json['name'], json['url'], json['id'], experiences, experienceURLs);
  }

  static List<VSEValue> fromJsonList(List<dynamic> json) {
    return json.map((item) => VSEValue.fromJson(item)).toList();
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': super.name,
        'url': super.url,
        'experience_names': experienceList,
      };
}

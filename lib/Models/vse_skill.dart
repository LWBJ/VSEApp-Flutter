import 'package:vseapp/Models/vse_data.dart';

class VSESkill extends VSEItem {
  //Inherits a 'name' and 'url' field from VSEItem
  List<String> experienceList;
  List<String> experienceURLList;

  VSESkill(super.name, super.url, super.id, this.experienceList,
      this.experienceURLList);

  factory VSESkill.fromJson(Map<String, dynamic> json) {
    //Manually cast a List<dynamic> into a List<String>
    List<String> experiences = ((json['experience_names'] as List)
        .map((item) => item.toString())).toList();
    List<String> experienceURLs =
        ((json['experiences'] as List).map((item) => item.toString())).toList();
    return VSESkill(
      json['name'],
      json['url'],
      json['id'],
      experiences,
      experienceURLs,
    );
  }

  static List<VSESkill> fromJsonList(List<dynamic> json) {
    return json.map((item) => VSESkill.fromJson(item)).toList();
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': super.name,
        'url': super.url,
        'experience_names': experienceList,
      };
}

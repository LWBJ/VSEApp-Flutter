import 'package:vseapp/Models/vse_data.dart';

class VSEExperience extends VSEItem {
  //Inherits a 'name' and 'url' field from VSEItem
  List<String> valueList;
  List<String> valueURLList;
  List<String> skillList;
  List<String> skillURLList;

  VSEExperience(super.name, super.url, super.id, this.valueList,
      this.valueURLList, this.skillList, this.skillURLList);

  factory VSEExperience.fromJson(Map<String, dynamic> json) {
    //Manually cast a List<dynamic> into a List<String>
    List<String> values =
        ((json['value_names'] as List).map((item) => item.toString())).toList();
    List<String> valueURLs =
        ((json['value_set'] as List).map((item) => item.toString())).toList();
    List<String> skills =
        ((json['skill_names'] as List).map((item) => item.toString())).toList();
    List<String> skillURLs =
        ((json['skill_set'] as List).map((item) => item.toString())).toList();

    return VSEExperience(
      json['name'],
      json['url'],
      json['id'],
      values,
      valueURLs,
      skills,
      skillURLs,
    );
  }

  static List<VSEExperience> fromJsonList(List<dynamic> json) {
    return json.map((item) => VSEExperience.fromJson(item)).toList();
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': super.name,
        'url': super.url,
        'value_names': valueList,
        'skill_names': skillList,
      };
}

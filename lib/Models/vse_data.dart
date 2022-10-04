class VSEData {
  Map<String, dynamic> toJson() => {
        '': '',
      };
}

class VSEItem extends VSEData {
  String name;
  String url;
  int id;

  VSEItem(this.name, this.url, this.id);
}

enum VSEType {
  value('Value'),
  skill('Skill'),
  experience('Experience');

  const VSEType(this.asString);
  final String asString;
}

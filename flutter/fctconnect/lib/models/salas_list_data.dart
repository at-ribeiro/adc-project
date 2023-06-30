class SalasListData {
  final String name;
  final String building;
  final String? url;

  SalasListData({
    required this.name,
    required this.building,
    this.url,

  });

  factory SalasListData.fromJson(Map<String, dynamic> json) {
    return SalasListData(
      name: json['name'],
      building: json['building'],
      url: json['url'],
    );
  }
}
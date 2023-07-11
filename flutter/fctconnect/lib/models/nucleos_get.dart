import 'dart:convert';

class NucleosGet {
  final List<String> admins;
  final String name;
  final String type;
  final String email;
  final String subtitle;
  final String description;
  final String foundation;
  final String facebook;
  final String instagram;
  final String website;
  final String url;
  final List<String> members;
  final List<String> events;

  NucleosGet({
    required this.admins,
    required this.name,
    required this.type,
    required this.email,
    required this.subtitle,
    required this.description,
    required this.foundation,
    required this.facebook,
    required this.instagram,
    required this.website,
    required this.url,
    required this.members,
    required this.events,
  });

  factory NucleosGet.fromJson(Map<String, dynamic> json) {

    return NucleosGet(
      admins: List<String>.from(json['admins'] ?? []),
      name: json['name'] is String ? json['name'] : '',
      type: json['type'] is String ? json['type'] : '',
      email: json['email'] is String ? json['email'] : '',
      subtitle: json['subtitle'] is String ? json['subtitle'] : '',
      description: json['description'] is String ? json['description'] : '',
      foundation: json['foundation'] is String ? json['foundation'] : '',
      facebook: json['facebook'] is String ? json['facebook'] : '',
      instagram: json['instagram'] is String ? json['instagram'] : '',
      website: json['website'] is String ? json['website'] : '',
      url: json['url'] is String ? json['url'] : '',
      members: List<String>.from(json['members'] ?? []),
      events: List<String>.from(json['events'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'admins': admins,
      'name': name,
      'type': type,
      'email': email,
      'subtitle': subtitle,
      'description': description,
      'foundation': foundation,
      'facebook': facebook,
      'instagram': instagram,
      'website': website,
      'url': url,
      'members': members,
      'events': events,
    };
  }

  String toJson() => json.encode(toMap());
}

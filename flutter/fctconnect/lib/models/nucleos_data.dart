import 'dart:convert';
import 'dart:typed_data';

class NucleosData {
  final String admin;
  final String name;
  final String type;
  final String email;
  final String subtitle;
  final String description;
  final String foundation;
  final String facebook;
  final String instagram;
  final String website;
  Uint8List? imageData;
  String? fileName;

  NucleosData({
    required this.admin,
    required this.name,
    required this.type,
    required this.email,
    required this.subtitle,
    required this.description,
    required this.foundation,
    required this.facebook,
    required this.instagram,
    required this.website,
    this.imageData,
    this.fileName,
  });

  factory NucleosData.fromJson(Map<String, dynamic> json) {
    return NucleosData(
      admin: json['admin'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      email: json['email'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      foundation: json['foundation'] as String,
      facebook: json['facebook'] as String,
      instagram: json['instagram'] as String,
      website: json['website'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'admin': admin,
      'name': name,
      'type': type,
      'email': email,
      'subtitle': subtitle,
      'description': description,
      'foundation': foundation,
      'facebook': facebook,
      'instagram': instagram,
      'website': website,
    };
  }

  String toJson() => json.encode(toMap());
}

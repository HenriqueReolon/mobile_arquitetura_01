import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.gender,
    required super.age,
    required super.birthDate,
    required super.image,
    required super.bloodGroup,
    required super.height,
    required super.weight,
    required super.eyeColor,
    required super.role,
    required super.university,
    super.city,
    super.country,
    super.companyName,
    super.companyTitle,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    final company = json['company'] as Map<String, dynamic>?;

    return UserProfileModel(
      id: json['id'] as int,
      username: json['username']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      birthDate: json['birthDate']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      bloodGroup: json['bloodGroup']?.toString() ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      eyeColor: json['eyeColor']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      city: address?['city']?.toString(),
      country: address?['country']?.toString(),
      companyName: company?['name']?.toString(),
      companyTitle: company?['title']?.toString(),
    );
  }
}

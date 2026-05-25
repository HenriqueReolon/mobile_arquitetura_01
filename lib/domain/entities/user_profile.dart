class UserProfile {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final int age;
  final String birthDate;
  final String image;
  final String bloodGroup;
  final double height;
  final double weight;
  final String eyeColor;
  final String role;
  final String university;
  final String? city;
  final String? country;
  final String? companyName;
  final String? companyTitle;

  UserProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.age,
    required this.birthDate,
    required this.image,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.role,
    required this.university,
    this.city,
    this.country,
    this.companyName,
    this.companyTitle,
  });

  String get fullName => '$firstName $lastName'.trim();
}

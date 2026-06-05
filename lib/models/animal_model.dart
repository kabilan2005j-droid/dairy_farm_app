class AnimalModel {
  final String id;
  final String name;
  final String tagNumber;
  final String breed;
  final String gender;
  final String animalType; // Cow or Buffalo
  final String imageUrl;
  final bool isPregnant;
  final DateTime? lastVaccinationDate;
  final DateTime? calvingDate;
  final DateTime createdAt;

  AnimalModel({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.breed,
    required this.gender,
    required this.animalType,
    required this.imageUrl,
    required this.isPregnant,
    this.lastVaccinationDate,
    this.calvingDate,
    required this.createdAt,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tagNumber': tagNumber,
      'breed': breed,
      'gender': gender,
      'animalType': animalType,
      'imageUrl': imageUrl,
      'isPregnant': isPregnant,
      'lastVaccinationDate': lastVaccinationDate?.toIso8601String(),
      'calvingDate': calvingDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert from Firestore map
  factory AnimalModel.fromMap(Map<String, dynamic> map) {
    return AnimalModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      tagNumber: map['tagNumber'] ?? '',
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      animalType: map['animalType'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isPregnant: map['isPregnant'] ?? false,
      lastVaccinationDate: map['lastVaccinationDate'] != null
          ? DateTime.parse(map['lastVaccinationDate'])
          : null,
      calvingDate: map['calvingDate'] != null
          ? DateTime.parse(map['calvingDate'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
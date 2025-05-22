import 'diagnosis_result_model.dart';

class DiagnosisModel {
  final int? id;
  final int userId;
  final String petName;
  final String petGender;
  final DiagnosisResult results;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DiagnosisModel({
    required this.id,
    required this.userId,
    required this.petName,
    required this.petGender,
    required this.results,
    this.createdAt,
    this.updatedAt,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id'] is int ? json['id'] : null,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      petName: json['pet_name'] ?? '',
      petGender: json['pet_gender'] ?? '',
      results: DiagnosisResult.fromJson(json['results'] ?? {}),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_name': petName,
      'pet_gender': petGender,
      'results': results.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

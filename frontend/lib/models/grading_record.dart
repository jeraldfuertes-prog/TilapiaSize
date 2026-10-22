import 'dart:convert';
import 'dart:typed_data';

class GradingRecord {
  const GradingRecord({
    required this.id,
    required this.createdAt,
    required this.imageBytes,
    required this.imageName,
    required this.lengthCm,
    required this.confidence,
    required this.grade,
    required this.category,
  });

  final String id;
  final DateTime createdAt;
  final Uint8List imageBytes;
  final String imageName;
  final double lengthCm;
  final int confidence;
  final String grade;
  final String category;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'imageData': base64Encode(imageBytes),
    'imageName': imageName,
    'length': lengthCm,
    'confidence': confidence,
    'grade': grade,
    'category': category,
  };

  factory GradingRecord.fromJson(Map<String, dynamic> json) {
    return GradingRecord(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageBytes: base64Decode(json['imageData'] as String),
      imageName: json['imageName'] as String? ?? 'fish-photo.jpg',
      lengthCm: (json['length'] as num).toDouble(),
      confidence: (json['confidence'] as num).toInt(),
      grade: json['grade'] as String,
      category: json['category'] as String,
    );
  }
}

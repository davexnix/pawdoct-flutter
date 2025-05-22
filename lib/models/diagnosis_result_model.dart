class DiagnosisResult {
  final Map<String, int> featuresUsed;
  final String prediction;
  final Map<String, double> probabilities;
  final List<String> suggestions;

  DiagnosisResult({
    required this.featuresUsed,
    required this.prediction,
    required this.probabilities,
    required this.suggestions,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final featuresDynamic = (json['features_used'] as Map<String, dynamic>? ?? {});
    final featuresProcessed = featuresDynamic.map(
          (key, value) => MapEntry(key, (value ?? 0) is int ? value : int.tryParse(value.toString()) ?? 0),
    );
    final features = Map<String, int>.from(featuresProcessed);

    final rawProbs = (json['probabilities'] as Map<String, dynamic>? ?? {});
    final probs = rawProbs.map(
          (key, value) {
        final numValue = value is num ? value : double.tryParse(value.toString()) ?? 0.0;
        return MapEntry(key, numValue.toDouble());
      },
    );

    return DiagnosisResult(
      featuresUsed: features,
      prediction: json['prediction'] ?? '',
      probabilities: probs,
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'features_used': featuresUsed,
      'prediction': prediction,
      'probabilities': probabilities,
      'suggestions': suggestions,
    };
  }
}

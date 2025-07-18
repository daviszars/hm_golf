class GolfSwingParameters {
  final List<double> flexExtValues;
  final List<double> radUlnValues;
  final List<double> rotationValues;

  const GolfSwingParameters({
    required this.flexExtValues,
    required this.radUlnValues,
    required this.rotationValues,
  });

  factory GolfSwingParameters.fromJson(Map<String, dynamic> json) {
    return GolfSwingParameters(
      flexExtValues: List<double>.from(
        (json['HFA_crWrFlexEx']?['values'] as List?)?.map(
              (x) => x.toDouble(),
            ) ??
            [],
      ),
      radUlnValues: List<double>.from(
        (json['HFA_crWrRadUln']?['values'] as List?)?.map(
              (x) => x.toDouble(),
            ) ??
            [],
      ),
      rotationValues: List<double>.from(
        (json['HFA_glfCapRot']?['values'] as List?)?.map((x) => x.toDouble()) ??
            [],
      ),
    );
  }
}

class GolfSwing {
  final String id;
  final String title;
  final GolfSwingParameters parameters;
  final String fileName;

  const GolfSwing({
    required this.id,
    required this.title,
    required this.parameters,
    required this.fileName,
  });

  factory GolfSwing.fromJson(Map<String, dynamic> json, String fileName) {
    final fileNumber = fileName.replaceAll('.json', '');

    return GolfSwing(
      id: 'swing_$fileNumber',
      title: 'Golf Swing $fileNumber',
      parameters: GolfSwingParameters.fromJson(json['parameters'] ?? {}),
      fileName: fileName,
    );
  }

  int get maxDataPoints {
    return [
      parameters.flexExtValues.length,
      parameters.radUlnValues.length,
    ].reduce((a, b) => a > b ? a : b);
  }

  bool get hasValidData {
    return parameters.flexExtValues.isNotEmpty &&
        parameters.radUlnValues.isNotEmpty;
  }
}
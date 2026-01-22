import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';

/// Repository for handling grade scale persistence
class GradeScaleRepository {
  Box? _scaleBox;

  /// Initialize Hive box
  Future<void> init() async {
    try {
      _scaleBox = await Hive.openBox('grade_scales');
    } catch (e) {
      debugPrint('Error initializing GradeScaleRepository: $e');
    }
  }

  /// Save current scale ID
  Future<void> saveCurrentScaleId(String scaleId) async {
    await _scaleBox?.put('current_scale_id', scaleId);
  }

  /// Load saved scale ID
  String loadCurrentScaleId() {
    return _scaleBox?.get('current_scale_id', defaultValue: 'default') ??
        'default';
  }

  /// Save all custom scales map
  Future<void> saveCustomScales(
    Map<String, List<GradeInfo>> customScales,
    Map<String, String> customNames,
  ) async {
    final scalesMap = customScales.map((key, value) {
      final list = value
          .map(
            (g) => {
              'minMarks': g.minMarks,
              'maxMarks': g.maxMarks,
              'gradePoint': g.gradePoint,
              'letterGrade': g.letterGrade,
            },
          )
          .toList();
      return MapEntry(key, list);
    });

    await _scaleBox?.put('custom_scales_map', scalesMap);
    await _scaleBox?.put('custom_scales_names', customNames);
  }

  /// Load custom scales maps
  (Map<String, List<GradeInfo>>, Map<String, String>) loadCustomScales() {
    final Map<String, List<GradeInfo>> loadedScales = {};
    final Map<String, String> loadedNames = {};

    if (_scaleBox == null) return (loadedScales, loadedNames);

    final customScalesData = _scaleBox!.get('custom_scales_map');
    final customNamesData = _scaleBox!.get('custom_scales_names');

    if (customScalesData != null && customNamesData != null) {
      try {
        final scalesMap = Map<String, dynamic>.from(customScalesData);

        scalesMap.forEach((key, value) {
          final list = (value as List).map((item) {
            return GradeInfo(
              minMarks: item['minMarks'] as int,
              maxMarks: item['maxMarks'] as int,
              gradePoint: (item['gradePoint'] as num).toDouble(),
              letterGrade: item['letterGrade'] as String,
            );
          }).toList();
          loadedScales[key] = list;
        });

        loadedNames.addAll(Map<String, String>.from(customNamesData));
      } catch (e) {
        debugPrint('Error loading custom scales map: $e');
      }
    }

    return (loadedScales, loadedNames);
  }
}

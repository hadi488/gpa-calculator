import 'package:flutter/material.dart';
import 'package:cgpacalculator/data/services/grade_scale_service.dart';
import 'package:cgpacalculator/features/settings/data/grade_presets.dart';
import 'package:cgpacalculator/features/settings/data/grade_scale_repository.dart';

/// Provider for managing grade scales
class GradeScaleProvider extends ChangeNotifier {
  final GradeScaleRepository _repository = GradeScaleRepository();

  /// Map of custom scales (ID -> List<GradeInfo>)
  Map<String, List<GradeInfo>> _customScales = {};

  /// Map of custom scale names (ID -> Name)
  Map<String, String> _customScaleNames = {};

  /// Current Grade Scale List
  List<GradeInfo> _currentScale = List.from(GradeScaleService.gradeScale);

  /// Current scale identifier
  String _currentScaleId = 'default';

  /// Current scale name
  String _currentScaleName = 'COMSATS (Default)';

  /// Whether using a custom modified scale
  bool _isCustomScale = false;

  /// Getters
  List<GradeInfo> get currentScale => _currentScale;
  String get currentScaleId => _currentScaleId;
  String get currentScaleName => _currentScaleName;
  bool get isCustomScale => _isCustomScale;
  Map<String, String> get customScaleNames => _customScaleNames;

  /// Initialize the provider and load saved scale
  Future<void> init() async {
    await _repository.init();
    await _loadSavedCustomScales();
    await _loadSavedScale();
  }

  /// Load all custom scales from storage
  Future<void> _loadSavedCustomScales() async {
    final (scales, names) = _repository.loadCustomScales();
    _customScales = scales;
    _customScaleNames = names;
    notifyListeners();
  }

  /// Load saved scale from storage
  Future<void> _loadSavedScale() async {
    final savedScaleId = _repository.loadCurrentScaleId();
    selectScale(savedScaleId);
  }

  /// Get list of all available scales (presets + custom)
  List<({String id, String name, bool isCustom})> get availableScales {
    final list = <({String id, String name, bool isCustom})>[];

    // Add Presets
    GradePresets.names.forEach((k, v) {
      list.add((id: k, name: v, isCustom: false));
    });

    // Add Custom Scales
    _customScaleNames.forEach((k, v) {
      list.add((id: k, name: v, isCustom: true));
    });

    return list;
  }

  /// Get details of a specific scale by ID (without activating it)
  List<GradeInfo> getScaleById(String id) {
    if (_customScales.containsKey(id)) {
      return _customScales[id]!;
    }
    return GradePresets.getScaleData(id);
  }

  /// Get name of a specific scale by ID
  String getScaleName(String id) {
    if (_customScales.containsKey(id)) {
      return _customScaleNames[id]!;
    }
    return GradePresets.names[id] ?? 'Unknown Scale';
  }

  /// Create a new custom scale
  void createCustomScale(String name) {
    // Generate a unique ID
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    // Start with default values (clone)
    final newScale = List<GradeInfo>.from(GradePresets.getScaleData('default'));

    _customScales[id] = newScale;
    _customScaleNames[id] = name;

    _saveAllCustomScales();

    // Switch to this new scale
    selectScale(id);
  }

  /// Reset a custom scale to default values (retaining ID and Name)
  void resetCustomScale(String id) {
    if (_customScales.containsKey(id)) {
      // Re-clone default scale
      final defaultScale = List<GradeInfo>.from(
        GradePresets.getScaleData('default'),
      );
      _customScales[id] = defaultScale;
      _saveAllCustomScales();

      // If active, refresh
      if (_currentScaleId == id) {
        selectScale(id);
      } else {
        notifyListeners();
      }
    }
  }

  /// Delete a custom scale
  void deleteCustomScale(String id) {
    if (_customScales.containsKey(id)) {
      _customScales.remove(id);
      _customScaleNames.remove(id);
      _saveAllCustomScales();

      // If we deleted the current scale, revert to default
      if (_currentScaleId == id) {
        resetToDefault();
      } else {
        notifyListeners();
      }
    }
  }

  /// Load a scale (preset or custom)
  void selectScale(String scaleId) {
    if (_customScales.containsKey(scaleId)) {
      _currentScale = List.from(_customScales[scaleId]!);
      _currentScaleId = scaleId;
      _currentScaleName = _customScaleNames[scaleId]!;
      _isCustomScale = true;
    } else {
      // Load preset data
      _currentScale = List.from(GradePresets.getScaleData(scaleId));
      _currentScaleId = scaleId;
      _currentScaleName = GradePresets.names[scaleId] ?? 'Unknown Scale';
      _isCustomScale = false;
    }

    _saveCurrentScaleId();
    notifyListeners();
  }

  /// Load a preset scale (legacy method wrapper)
  void loadPresetScale(String scaleId) {
    selectScale(scaleId);
  }

  /// Reset to default scale
  void resetToDefault() {
    selectScale('default');
  }

  /// Update a specific grade entry in a custom scale
  void updateGrade(String scaleId, int index, GradeInfo newGrade) {
    if (!_customScales.containsKey(scaleId)) return;

    final scale = _customScales[scaleId]!;
    if (index < 0 || index >= scale.length) return;

    scale[index] = newGrade;

    // Sort logic
    scale.sort((a, b) => b.maxMarks.compareTo(a.maxMarks));

    // Update map and save
    _customScales[scaleId] = List.from(scale);
    _saveAllCustomScales();

    // If this is the active scale, update _currentScale too
    if (_currentScaleId == scaleId) {
      _currentScale = List.from(scale);
    }

    notifyListeners();
  }

  /// Add/Edit a custom grade entry for the current scale
  void addCustomGrade(
    String scaleId, {
    required int minMarks,
    required int maxMarks,
    required double gpa,
    required String letterGrade,
  }) {
    if (!_customScales.containsKey(scaleId)) return;

    final scale = _customScales[scaleId]!;

    scale.add(
      GradeInfo(
        minMarks: minMarks,
        maxMarks: maxMarks,
        gradePoint: gpa,
        letterGrade: letterGrade,
      ),
    );

    // Sort by maxMarks descending
    scale.sort((a, b) => b.maxMarks.compareTo(a.maxMarks));

    // Update the map entry for this custom scale
    _customScales[scaleId] = List.from(scale);
    _saveAllCustomScales();

    // If this is the active scale, update _currentScale too
    if (_currentScaleId == scaleId) {
      _currentScale = List.from(scale);
    }

    notifyListeners();
  }

  /// Remove a grade entry at index
  void removeGradeAt(String scaleId, int index) {
    if (!_customScales.containsKey(scaleId)) return;

    final scale = _customScales[scaleId]!;

    if (index >= 0 && index < scale.length) {
      scale.removeAt(index);

      // Update the map entry for this custom scale
      _customScales[scaleId] = List.from(scale);
      _saveAllCustomScales();

      // If this is the active scale, update _currentScale too
      if (_currentScaleId == scaleId) {
        _currentScale = List.from(scale);
      }

      notifyListeners();
    }
  }

  /// Save current scale ID
  void _saveCurrentScaleId() {
    _repository.saveCurrentScaleId(_currentScaleId);
  }

  /// Save all custom scales to storage
  void _saveAllCustomScales() {
    _repository.saveCustomScales(_customScales, _customScaleNames);
  }

  /// Get GPA for marks using current scale
  double marksToGpa(int marks) {
    for (final grade in _currentScale) {
      if (marks >= grade.minMarks && marks <= grade.maxMarks) {
        return grade.gradePoint;
      }
    }
    return 0.0;
  }

  /// Get letter grade for marks using current scale
  String marksToLetterGrade(int marks) {
    for (final grade in _currentScale) {
      if (marks >= grade.minMarks && marks <= grade.maxMarks) {
        return grade.letterGrade;
      }
    }
    return 'F';
  }

  /// Get letter grade for a GPA value (approximate)
  /// Used for displaying GPA on subject cards
  String getLetterGrade(double gpa) {
    // Sort logic: entries are usually sorted by maxMarks desc, which correlates to GPA desc.
    // We want to find the lowest threshold that the GPA meets.
    // e.g. 4.0 >= 4.0 (A), 3.5 >= 3.67 (No), 3.5 >= 3.33 (B+)

    // Sort a temporary list by GradePoint DESC to ensure correct threshold checking
    final sortedScale = List<GradeInfo>.from(_currentScale)
      ..sort((a, b) => b.gradePoint.compareTo(a.gradePoint));

    for (final grade in sortedScale) {
      if (gpa >= grade.gradePoint) {
        return grade.letterGrade;
      }
    }
    return 'F';
  }

  /// Get GPA for marks using a specific scale ID
  /// useful for per-student grading criteria
  double marksToGpaForScale(int marks, String scaleId) {
    final scale = getScaleById(scaleId);
    for (final grade in scale) {
      if (marks >= grade.minMarks && marks <= grade.maxMarks) {
        return grade.gradePoint;
      }
    }
    return 0.0;
  }

  /// Get letter grade for marks using a specific scale ID
  String marksToLetterGradeForScale(int marks, String scaleId) {
    final scale = getScaleById(scaleId);
    for (final grade in scale) {
      if (marks >= grade.minMarks && marks <= grade.maxMarks) {
        return grade.letterGrade;
      }
    }
    return 'F';
  }

  /// Get letter grade for GPA using a specific scale ID
  String getLetterGradeForScale(double gpa, String scaleId) {
    final scale = List<GradeInfo>.from(getScaleById(scaleId))
      ..sort((a, b) => b.gradePoint.compareTo(a.gradePoint));

    for (final grade in scale) {
      if (gpa >= grade.gradePoint) {
        return grade.letterGrade;
      }
    }
    return 'F';
  }
}

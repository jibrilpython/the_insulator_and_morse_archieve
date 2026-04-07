import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insulator_and_morse_archieve/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  // Identity
  String _gridIdentifier = '';
  HardwareCategory _itemCategory = HardwareCategory.glassInsulator;
  String _cdOrStyleNumber = '';
  String _manufacturerAndShopMark = '';

  // Appearance
  String _glassColorOrGlazeType = '';

  // Historical
  String _eraOfProduction = '';
  String _provenance = '';

  // Technical specs
  String _operatingVoltage = '';
  String _baseAndThreadDesign = '';
  String _materials = '';
  String _dimensionsAndWeight = '';

  // Condition & Accessories
  ConditionState _conditionState = ConditionState.unknown;
  String _includedAccessories = '';
  String _markingsAndPatentDates = '';

  // Extra
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get gridIdentifier => _gridIdentifier;
  HardwareCategory get itemCategory => _itemCategory;
  String get cdOrStyleNumber => _cdOrStyleNumber;
  String get manufacturerAndShopMark => _manufacturerAndShopMark;
  String get glassColorOrGlazeType => _glassColorOrGlazeType;
  String get eraOfProduction => _eraOfProduction;
  String get provenance => _provenance;
  String get operatingVoltage => _operatingVoltage;
  String get baseAndThreadDesign => _baseAndThreadDesign;
  String get materials => _materials;
  String get dimensionsAndWeight => _dimensionsAndWeight;
  ConditionState get conditionState => _conditionState;
  String get includedAccessories => _includedAccessories;
  String get markingsAndPatentDates => _markingsAndPatentDates;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set gridIdentifier(String v) { _gridIdentifier = v; notifyListeners(); }
  set itemCategory(HardwareCategory v) { _itemCategory = v; notifyListeners(); }
  set cdOrStyleNumber(String v) { _cdOrStyleNumber = v; notifyListeners(); }
  set manufacturerAndShopMark(String v) { _manufacturerAndShopMark = v; notifyListeners(); }
  set glassColorOrGlazeType(String v) { _glassColorOrGlazeType = v; notifyListeners(); }
  set eraOfProduction(String v) { _eraOfProduction = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set operatingVoltage(String v) { _operatingVoltage = v; notifyListeners(); }
  set baseAndThreadDesign(String v) { _baseAndThreadDesign = v; notifyListeners(); }
  set materials(String v) { _materials = v; notifyListeners(); }
  set dimensionsAndWeight(String v) { _dimensionsAndWeight = v; notifyListeners(); }
  set conditionState(ConditionState v) { _conditionState = v; notifyListeners(); }
  set includedAccessories(String v) { _includedAccessories = v; notifyListeners(); }
  set markingsAndPatentDates(String v) { _markingsAndPatentDates = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _gridIdentifier = '';
    _itemCategory = HardwareCategory.glassInsulator;
    _cdOrStyleNumber = '';
    _manufacturerAndShopMark = '';
    _glassColorOrGlazeType = '';
    _eraOfProduction = '';
    _provenance = '';
    _operatingVoltage = '';
    _baseAndThreadDesign = '';
    _materials = '';
    _dimensionsAndWeight = '';
    _conditionState = ConditionState.unknown;
    _includedAccessories = '';
    _markingsAndPatentDates = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);

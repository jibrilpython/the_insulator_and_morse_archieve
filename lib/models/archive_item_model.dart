import 'package:insulator_and_morse_archieve/enum/my_enums.dart';

class ArchiveItemModel {
  String id;

  // Identity & Classification
  String gridIdentifier;
  HardwareCategory itemCategory;
  String cdOrStyleNumber;
  String manufacturerAndShopMark;

  // Appearance
  String glassColorOrGlazeType;

  // Historical
  String eraOfProduction;
  String provenance;

  // Technical specs
  String operatingVoltage;
  String baseAndThreadDesign;
  String materials;
  String dimensionsAndWeight;

  // Condition & Accessories
  ConditionState conditionState;
  String includedAccessories;
  String markingsAndPatentDates;

  // Extra
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  ArchiveItemModel({
    required this.id,
    required this.gridIdentifier,
    required this.itemCategory,
    required this.cdOrStyleNumber,
    required this.manufacturerAndShopMark,
    required this.glassColorOrGlazeType,
    required this.eraOfProduction,
    required this.provenance,
    required this.operatingVoltage,
    required this.baseAndThreadDesign,
    required this.materials,
    required this.dimensionsAndWeight,
    required this.conditionState,
    required this.includedAccessories,
    required this.markingsAndPatentDates,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gridIdentifier': gridIdentifier,
        'itemCategory': itemCategory.name,
        'cdOrStyleNumber': cdOrStyleNumber,
        'manufacturerAndShopMark': manufacturerAndShopMark,
        'glassColorOrGlazeType': glassColorOrGlazeType,
        'eraOfProduction': eraOfProduction,
        'provenance': provenance,
        'operatingVoltage': operatingVoltage,
        'baseAndThreadDesign': baseAndThreadDesign,
        'materials': materials,
        'dimensionsAndWeight': dimensionsAndWeight,
        'conditionState': conditionState.name,
        'includedAccessories': includedAccessories,
        'markingsAndPatentDates': markingsAndPatentDates,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory ArchiveItemModel.fromJson(Map<String, dynamic> json) =>
      ArchiveItemModel(
        id: json['id'] ?? '',
        gridIdentifier: json['gridIdentifier'] ?? '',
        itemCategory: HardwareCategory.values.asNameMap()[json['itemCategory']] ??
            HardwareCategory.glassInsulator,
        cdOrStyleNumber: json['cdOrStyleNumber'] ?? '',
        manufacturerAndShopMark: json['manufacturerAndShopMark'] ?? '',
        glassColorOrGlazeType: json['glassColorOrGlazeType'] ?? '',
        eraOfProduction: json['eraOfProduction'] ?? '',
        provenance: json['provenance'] ?? '',
        operatingVoltage: json['operatingVoltage'] ?? '',
        baseAndThreadDesign: json['baseAndThreadDesign'] ?? '',
        materials: json['materials'] ?? '',
        dimensionsAndWeight: json['dimensionsAndWeight'] ?? '',
        conditionState: ConditionState.values.asNameMap()[json['conditionState']] ??
            ConditionState.unknown,
        includedAccessories: json['includedAccessories'] ?? '',
        markingsAndPatentDates: json['markingsAndPatentDates'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}

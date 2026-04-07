import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:insulator_and_morse_archieve/models/archive_item_model.dart';
import 'package:insulator_and_morse_archieve/providers/image_provider.dart';
import 'package:insulator_and_morse_archieve/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<ArchiveItemModel> entries = [];
  bool isLoading = true;
  static const String _storageKey = 'ima_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => ArchiveItemModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    entries.add(
      ArchiveItemModel(
        id: _uuid.v4(),
        gridIdentifier: p.gridIdentifier,
        itemCategory: p.itemCategory,
        cdOrStyleNumber: p.cdOrStyleNumber,
        manufacturerAndShopMark: p.manufacturerAndShopMark,
        glassColorOrGlazeType: p.glassColorOrGlazeType,
        eraOfProduction: p.eraOfProduction,
        provenance: p.provenance,
        operatingVoltage: p.operatingVoltage,
        baseAndThreadDesign: p.baseAndThreadDesign,
        materials: p.materials,
        dimensionsAndWeight: p.dimensionsAndWeight,
        conditionState: p.conditionState,
        includedAccessories: p.includedAccessories,
        markingsAndPatentDates: p.markingsAndPatentDates,
        notes: p.notes,
        photoPath: imgProv.resultImage.isNotEmpty
            ? imgProv.resultImage
            : p.photoPath,
        tags: List<String>.from(p.tags),
        dateAdded: p.dateAdded,
      ),
    );

    _save();
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    entries[index] = ArchiveItemModel(
      id: existing.id,
      gridIdentifier: p.gridIdentifier,
      itemCategory: p.itemCategory,
      cdOrStyleNumber: p.cdOrStyleNumber,
      manufacturerAndShopMark: p.manufacturerAndShopMark,
      glassColorOrGlazeType: p.glassColorOrGlazeType,
      eraOfProduction: p.eraOfProduction,
      provenance: p.provenance,
      operatingVoltage: p.operatingVoltage,
      baseAndThreadDesign: p.baseAndThreadDesign,
      materials: p.materials,
      dimensionsAndWeight: p.dimensionsAndWeight,
      conditionState: p.conditionState,
      includedAccessories: p.includedAccessories,
      markingsAndPatentDates: p.markingsAndPatentDates,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    _save();
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    _save();
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.gridIdentifier = entry.gridIdentifier;
    p.itemCategory = entry.itemCategory;
    p.cdOrStyleNumber = entry.cdOrStyleNumber;
    p.manufacturerAndShopMark = entry.manufacturerAndShopMark;
    p.glassColorOrGlazeType = entry.glassColorOrGlazeType;
    p.eraOfProduction = entry.eraOfProduction;
    p.provenance = entry.provenance;
    p.operatingVoltage = entry.operatingVoltage;
    p.baseAndThreadDesign = entry.baseAndThreadDesign;
    p.materials = entry.materials;
    p.dimensionsAndWeight = entry.dimensionsAndWeight;
    p.conditionState = entry.conditionState;
    p.includedAccessories = entry.includedAccessories;
    p.markingsAndPatentDates = entry.markingsAndPatentDates;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);

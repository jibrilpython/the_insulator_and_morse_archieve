import 'package:insulator_and_morse_archieve/models/archive_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<ArchiveItemModel> filteredList(List<ArchiveItemModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.gridIdentifier.toLowerCase().contains(query) ||
              item.manufacturerAndShopMark.toLowerCase().contains(query) ||
              item.cdOrStyleNumber.toLowerCase().contains(query) ||
              item.glassColorOrGlazeType.toLowerCase().contains(query) ||
              item.materials.toLowerCase().contains(query) ||
              item.provenance.toLowerCase().contains(query) ||
              item.eraOfProduction.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());

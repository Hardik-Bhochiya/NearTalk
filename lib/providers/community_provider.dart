import 'package:flutter/material.dart';
import '../models/region.dart';
import '../models/community.dart';
import '../services/mock_data_service.dart';

class CommunityProvider extends ChangeNotifier {
  List<Region> _regions = [];
  List<Community> _communities = [];
  Region? _selectedRegion;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Region> get regions => _regions;
  List<Community> get communities => _communities;
  Region? get selectedRegion => _selectedRegion;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  CommunityProvider() {
    _regions = List.from(MockDataService.initialRegions);
    _communities = List.from(MockDataService.initialCommunities);
    if (_regions.isNotEmpty) {
      _selectedRegion = _regions.first;
    }
  }

  void selectRegion(Region region) {
    _selectedRegion = region;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Community> get joinedCommunities {
    return _communities.where((c) => c.isJoined).toList();
  }

  List<Community> get filteredCommunities {
    return _communities.where((c) {
      final matchesRegion = _selectedRegion == null || c.regionId == _selectedRegion!.id;
      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesRegion && matchesCategory && matchesSearch;
    }).toList();
  }

  Community? getCommunityById(String id) {
    try {
      return _communities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void toggleJoinCommunity(String communityId) {
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final current = _communities[index];
      final newJoined = !current.isJoined;
      final newCount = newJoined ? current.memberCount + 1 : current.memberCount - 1;
      _communities[index] = current.copyWith(
        isJoined: newJoined,
        memberCount: newCount < 0 ? 0 : newCount,
      );
      notifyListeners();
    }
  }

  void createCommunity({
    required String name,
    required String description,
    required String category,
    required String iconEmoji,
    required int bannerColorHex,
  }) {
    final newCommunity = Community(
      id: MockDataService.generateId(),
      name: name,
      description: description,
      regionId: _selectedRegion?.id ?? 'region-1',
      regionName: _selectedRegion?.name ?? 'Silicon Valley Campus',
      category: category,
      memberCount: 1,
      questionCount: 0,
      iconEmoji: iconEmoji,
      bannerColorHex: bannerColorHex,
      isJoined: true,
    );

    _communities.insert(0, newCommunity);
    notifyListeners();
  }
}

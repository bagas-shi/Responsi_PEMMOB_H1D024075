import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/location_tile_card.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/pill_button.dart';
import '../widgets/state_feedback_view.dart';

/// Screen Pencarian & Lokasi Favorit menggunakan `StatefulWidget` untuk
/// mengelola lifecycle `TextEditingController` dan `FocusNode` input pencarian.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Menjalankan HTTP GET ke Geocoding API melalui `LocationViewModel`.
  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nama kota terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _searchFocusNode.unfocus();
    await context.read<LocationViewModel>().searchCity(query);
  }

  /// Mereset input pencarian atau menutup halaman jika input sudah kosong.
  void _handleCancel() {
    final locationVM = context.read<LocationViewModel>();
    if (_searchController.text.isNotEmpty ||
        locationVM.searchState != SearchLoadState.idle) {
      _searchController.clear();
      locationVM.clearSearch();
      setState(() {});
    } else {
      Navigator.of(context).maybePop();
    }
  }

  /// Memilih kota untuk ditampilkan cuacanya di Home Screen sekaligus
  /// mencatatnya pada riwayat pencarian Local Storage.
  Future<void> _selectCity(LocationModel location) async {
    final weatherVM = context.read<WeatherViewModel>();
    final locationVM = context.read<LocationViewModel>();

    await locationVM.recordSelectedLocation(location);
    // Memulai pemuatan cuaca kota terpilih secara asinkron & kembali ke Home
    weatherVM.selectLocation(location);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _toggleFavoriteWithFeedback(LocationModel location) async {
    final added =
        await context.read<LocationViewModel>().toggleFavorite(location);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${location.name} disimpan ke Lokasi Favorit'
                : '${location.name} dihapus dari Lokasi Favorit',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final locationVM = context.watch<LocationViewModel>();
    final activeLocation = context.watch<WeatherViewModel>().selectedLocation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Header Navigasi Search Screen
                        Row(
                          children: [
                            NeumorphicIconButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              tooltip: 'Kembali',
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi & Pencarian Kota',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Cari kota dunia via Open-Meteo Geocoding API',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // 2. Search Bar Soft UI + Pill Buttons (SEARCH & CANCEL)
                        _buildSearchBox(locationVM),
                        const SizedBox(height: 24),

                        // 3. Hasil Pencarian Lokasi dari Geocoding API
                        if (locationVM.searchState != SearchLoadState.idle) ...[
                          _buildSearchResultsSection(
                            locationVM,
                            activeLocation,
                          ),
                          const SizedBox(height: 26),
                        ],

                        // 4. Section Saved / Favorite Locations (Local Storage)
                        _buildFavoritesSection(locationVM, activeLocation),

                        // 5. Section Riwayat Pencarian Terakhir (Local Storage)
                        if (locationVM.recentLocations.isNotEmpty) ...[
                          const SizedBox(height: 26),
                          _buildRecentSection(locationVM),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(LocationViewModel locationVM) {
    final isSearching = locationVM.searchState == SearchLoadState.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Field putih bersih dengan sudut melengkung & shadow lembut
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softCardShadows,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _handleSearch(),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Find a city (e.g. Yogyakarta, Jakarta, Tokyo)',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppTheme.textSecondary,
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Bersihkan teks',
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Baris Tombol Pill: SEARCH (Gradasi Biru) & CANCEL (Gradasi Kuning)
        Row(
          children: [
            Expanded(
              flex: 3,
              child: PillButton(
                label: 'SEARCH',
                icon: Icons.travel_explore_rounded,
                isLoading: isSearching,
                onPressed: _handleSearch,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PillButton(
                label: 'CANCEL',
                icon: Icons.close_rounded,
                variant: PillButtonVariant.secondary,
                onPressed: _handleCancel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchResultsSection(
    LocationViewModel locationVM,
    LocationModel? activeLocation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Hasil Pencarian "${locationVM.lastQuery}"',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (locationVM.searchState == SearchLoadState.loaded)
              Text(
                '${locationVM.searchResults.length} lokasi',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        switch (locationVM.searchState) {
          SearchLoadState.idle => const SizedBox.shrink(),
          SearchLoadState.loading => StateFeedbackView.loading(
              title: 'Mencari Kota...',
              message: 'Mengambil daftar lokasi dari Geocoding API Open-Meteo',
            ),
          SearchLoadState.empty => StateFeedbackView.empty(
              title: 'Lokasi Tidak Ditemukan',
              message:
                  'Tidak ditemukan kota dengan nama "${locationVM.lastQuery}". Periksa ejaan dan coba lagi.',
            ),
          SearchLoadState.error => StateFeedbackView.error(
              title: 'Pencarian Gagal',
              message: locationVM.errorMessage ??
                  'Gagal mengambil daftar kota dari server.',
              onRetry: () => locationVM.retryLastSearch(),
            ),
          SearchLoadState.loaded => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locationVM.searchResults.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = locationVM.searchResults[index];
                final isActive = activeLocation != null &&
                    activeLocation.uniqueKey == item.uniqueKey;

                return LocationTileCard(
                  location: item,
                  isFavorite: locationVM.isFavorite(item),
                  isActive: isActive,
                  onSelect: () => _selectCity(item),
                  onToggleFavorite: () => _toggleFavoriteWithFeedback(item),
                );
              },
            ),
        },
      ],
    );
  }

  Widget _buildFavoritesSection(
    LocationViewModel locationVM,
    LocationModel? activeLocation,
  ) {
    final favorites = locationVM.favorites;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: AppTheme.secondaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.secondaryGlowShadows,
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Lokasi Favorit Tersimpan',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.recessedSurface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${favorites.length}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (favorites.isEmpty)
          NeumorphicCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.recessedSurface,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.softSmallShadows,
                  ),
                  child: const Icon(
                    Icons.star_border_rounded,
                    color: AppTheme.secondaryEnd,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada kota favorit',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Cari nama kota di atas lalu tekan ikon bintang untuk menyimpannya secara permanen di perangkat.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = favorites[index];
              final isActive = activeLocation != null &&
                  activeLocation.uniqueKey == item.uniqueKey;

              return LocationTileCard(
                location: item,
                isFavorite: true,
                isActive: isActive,
                onSelect: () => _selectCity(item),
                onToggleFavorite: () => _toggleFavoriteWithFeedback(item),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecentSection(LocationViewModel locationVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Riwayat Lokasi Terakhir',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () =>
                  context.read<LocationViewModel>().clearRecentHistory(),
              child: const Text(
                'Hapus Riwayat',
                style: TextStyle(
                  color: AppTheme.primaryEnd,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: locationVM.recentLocations.map((location) {
            return InkWell(
              onTap: () => _selectCity(location),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: AppTheme.softSmallShadows,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.north_west_rounded,
                      size: 14,
                      color: AppTheme.primaryEnd,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      location.headerLabel,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

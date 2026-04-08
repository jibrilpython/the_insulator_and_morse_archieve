import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/models/archive_item_model.dart';
import 'package:insulator_and_morse_archieve/providers/image_provider.dart';
import 'package:insulator_and_morse_archieve/providers/project_provider.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

class InfoScreen extends ConsumerStatefulWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bloomController;

  @override
  void initState() {
    super.initState();
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _bloomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProv = ref.watch(projectProvider);
    if (widget.index < 0 || widget.index >= projectProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            'SPECIMEN NOT FOUND',
            style: GoogleFonts.jetBrainsMono(color: kSecondaryText),
          ),
        ),
      );
    }

    final entry = projectProv.entries[widget.index];
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final catColor = getCategoryColor(entry.itemCategory);

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, projectProv, widget.index),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Full-Bleed Spotlight Image
          SliverToBoxAdapter(child: _buildSpotlightImage(imagePath, entry)),

          // 2. Technical Panels (Staggered Bloom)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _bloomItem(
                  index: 0,
                  child: _buildIdentityHeader(entry, catColor),
                ),
                SizedBox(height: 32.h),
                _bloomItem(index: 1, child: _buildTechnicalGrid(entry)),
                SizedBox(height: 24.h),
                if (entry.markingsAndPatentDates.isNotEmpty) ...[
                  _bloomItem(
                    index: 2,
                    child: _buildGlassCard(
                      'Markings & Patents',
                      entry.markingsAndPatentDates,
                      isMono: true,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
                if (entry.provenance.isNotEmpty) ...[
                  _bloomItem(
                    index: 3,
                    child: _buildGlassCard('Provenance', entry.provenance),
                  ),
                  SizedBox(height: 20.h),
                ],
                if (entry.notes.isNotEmpty) ...[
                  _bloomItem(
                    index: 4,
                    child: _buildGlassCard('Archival Notes', entry.notes),
                  ),
                  SizedBox(height: 20.h),
                ],
                if (entry.tags.isNotEmpty)
                  _bloomItem(index: 5, child: _buildTags(entry)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ProjectNotifier projectProv,
    int idx,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 80.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: _boxBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        _boxBtn(
          icon: Icons.edit_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            projectProv.fillInput(ref, idx);
            Navigator.pushNamed(
              context,
              '/add_screen',
              arguments: {'isEdit': true, 'currentIndex': idx},
            );
          },
        ),
        SizedBox(width: 12.w),
        _boxBtn(
          icon: Icons.delete_outline_rounded,
          iconColor: kError,
          onTap: () => _showDeleteDialog(context, projectProv, idx),
        ),
        SizedBox(width: 20.w),
      ],
    );
  }

  Widget _boxBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kPrimaryText,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: kPanelBg.withAlpha(200),
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildSpotlightImage(String? imagePath, ArchiveItemModel entry) {
    return Container(
      width: double.infinity,
      height: 440.h,
      decoration: const BoxDecoration(color: Color(0xFF050505)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null &&
              entry.photoPath.isNotEmpty &&
              File(imagePath).existsSync())
            Image.file(File(imagePath), fit: BoxFit.cover)
          else
            Center(
              child: Icon(
                Icons.water_drop_outlined,
                color: kOutline,
                size: 64.sp,
              ),
            ),
          // Vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(150),
                  Colors.black,
                ],
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
          ),
          // Bottom Gradient Mask
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 100.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, kBackground],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityHeader(ArchiveItemModel entry, Color catColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: catColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: catColor.withAlpha(100)),
                ),
                child: Text(
                  entry.itemCategory.label,
                  style: GoogleFonts.dmSans(
                    color: catColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Flexible(
              child: Text(
                entry.gridIdentifier.isEmpty
                    ? 'SPECIMEN #---'
                    : entry.gridIdentifier,
                textAlign: TextAlign.right,
                style: GoogleFonts.jetBrainsMono(
                  color: kSecondaryText,
                  fontSize: 11.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          entry.manufacturerAndShopMark.isEmpty
              ? 'Unknown Origin'
              : entry.manufacturerAndShopMark,
          style: Theme.of(context).textTheme.displayLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (entry.cdOrStyleNumber.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            entry.cdOrStyleNumber,
            style: GoogleFonts.dmSans(
              color: kAccent,
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTechnicalGrid(ArchiveItemModel entry) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(120),
        borderRadius: BorderRadius.circular(kRadiusLarge),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        children: [
          _techRow(
            'Condition',
            entry.conditionState.label,
            icon: Icons.verified_user_outlined,
          ),
          _divider(),
          _techRow(
            'Glass/Glaze',
            entry.glassColorOrGlazeType.isEmpty
                ? 'Not Specified'
                : entry.glassColorOrGlazeType,
            icon: Icons.lens_blur_rounded,
          ),
          _divider(),
          _techRow(
            'Era',
            entry.eraOfProduction.isEmpty ? 'Unknown' : entry.eraOfProduction,
            icon: Icons.history_rounded,
          ),
          _divider(),
          _techRow(
            'Materials',
            entry.materials.isEmpty ? 'Mixed Hardware' : entry.materials,
            icon: Icons.category_outlined,
          ),
        ],
      ),
    );
  }

  Widget _techRow(String label, String value, {required IconData icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: kSecondaryText, size: 18.sp),
          SizedBox(width: 12.w),
          Text(
            label,
            style: GoogleFonts.inter(color: kSecondaryText, fontSize: 13.sp),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: kOutline, thickness: 1.0, height: 1);

  Widget _buildGlassCard(String title, String content, {bool isMono = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(100),
        borderRadius: BorderRadius.circular(kRadiusLarge),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: kSecondaryText,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: isMono
                ? GoogleFonts.jetBrainsMono(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                    height: 1.5,
                  )
                : GoogleFonts.inter(
                    color: kPrimaryText,
                    fontSize: 15.sp,
                    height: 1.6,
                    fontWeight: FontWeight.w300,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(ArchiveItemModel entry) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: entry.tags
          .map(
            (t) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: kPanelBg.withAlpha(150),
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kOutline),
              ),
              child: Text(
                '#$t',
                style: GoogleFonts.jetBrainsMono(
                  color: kAccent,
                  fontSize: 11.sp,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _bloomItem({required int index, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _bloomController,
      curve: Interval(
        (index * 0.1).clamp(0.0, 1.0),
        (index * 0.1 + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutQuart,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProjectNotifier projectProv,
    int idx,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kPanelBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusLarge),
          side: const BorderSide(color: kOutline),
        ),
        title: Text(
          'Delete Specimen?',
          style: GoogleFonts.dmSans(
            color: kPrimaryText,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Text(
          'This action will permanently remove the item from the archive.',
          style: GoogleFonts.inter(color: kSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.jetBrainsMono(color: kSecondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              projectProv.deleteEntry(idx);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.jetBrainsMono(color: kError),
            ),
          ),
        ],
      ),
    );
  }
}

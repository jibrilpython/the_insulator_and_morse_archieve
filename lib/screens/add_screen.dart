import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/common/photo_bottom_sheet.dart';
import 'package:insulator_and_morse_archieve/enum/my_enums.dart';
import 'package:insulator_and_morse_archieve/providers/image_provider.dart';
import 'package:insulator_and_morse_archieve/providers/input_provider.dart';
import 'package:insulator_and_morse_archieve/providers/project_provider.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  // Text controllers
  late TextEditingController _idCtrl;
  late TextEditingController _cdCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _glassCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _voltCtrl;
  late TextEditingController _baseCtrl;
  late TextEditingController _matCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _accCtrl;
  late TextEditingController _markCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.gridIdentifier);
    _cdCtrl = TextEditingController(text: p.cdOrStyleNumber);
    _manCtrl = TextEditingController(text: p.manufacturerAndShopMark);
    _glassCtrl = TextEditingController(text: p.glassColorOrGlazeType);
    _eraCtrl = TextEditingController(text: p.eraOfProduction);
    _voltCtrl = TextEditingController(text: p.operatingVoltage);
    _baseCtrl = TextEditingController(text: p.baseAndThreadDesign);
    _matCtrl = TextEditingController(text: p.materials);
    _dimCtrl = TextEditingController(text: p.dimensionsAndWeight);
    _provCtrl = TextEditingController(text: p.provenance);
    _accCtrl = TextEditingController(text: p.includedAccessories);
    _markCtrl = TextEditingController(text: p.markingsAndPatentDates);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    for (final c in [
      _idCtrl,
      _cdCtrl,
      _manCtrl,
      _glassCtrl,
      _eraCtrl,
      _voltCtrl,
      _baseCtrl,
      _matCtrl,
      _dimCtrl,
      _provCtrl,
      _accCtrl,
      _markCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() async {
    final p = ref.read(inputProvider);
    if (p.gridIdentifier.trim().isEmpty ||
        p.manufacturerAndShopMark.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Identifier and Manufacturer are required.',
            style: GoogleFonts.inter(color: kPrimaryText),
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 800));

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context); // dismiss dialog
      Navigator.pop(context); // pop add screen
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kSecondaryText, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.isEdit ? 'Edit Specimen' : 'New Specimen'),
      ),
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
            children: [
              _buildPhotoModule(),
              SizedBox(height: 32.h),
              _sectionHeader('Identity Details'),
              _buildModule([
                _field(
                  label: 'Grid Identifier',
                  ctrl: _idCtrl,
                  hint: 'e.g. TIMA-001',
                  isMono: true,
                  onChanged: (v) => ref.read(inputProvider).gridIdentifier = v,
                ),
                _field(
                  label: 'Manufacturer',
                  ctrl: _manCtrl,
                  hint: 'e.g. Hemingray Glass Co.',
                  onChanged: (v) =>
                      ref.read(inputProvider).manufacturerAndShopMark = v,
                ),
                _field(
                  label: 'CD / Style Number',
                  ctrl: _cdCtrl,
                  hint: 'e.g. CD 154',
                  isMono: true,
                  onChanged: (v) => ref.read(inputProvider).cdOrStyleNumber = v,
                ),
                _categoryPicker(),
              ]),
              SizedBox(height: 32.h),
              _sectionHeader('Visual Attributes'),
              _buildModule([
                _field(
                  label: 'Glass Color / Glaze',
                  ctrl: _glassCtrl,
                  hint: 'e.g. Aqua, Cobalt',
                  onChanged: (v) =>
                      ref.read(inputProvider).glassColorOrGlazeType = v,
                ),
                _field(
                  label: 'Production Era',
                  ctrl: _eraCtrl,
                  hint: 'e.g. 1894',
                  isMono: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (v) => ref.read(inputProvider).eraOfProduction = v,
                ),
                _conditionPicker(),
              ]),
              SizedBox(height: 32.h),
              _sectionHeader('Technical Specifications'),
              _buildModule([
                _field(
                  label: 'Operating Voltage',
                  ctrl: _voltCtrl,
                  hint: 'e.g. 5000V',
                  isMono: true,
                  onChanged: (v) =>
                      ref.read(inputProvider).operatingVoltage = v,
                ),
                _field(
                  label: 'Base & Thread',
                  ctrl: _baseCtrl,
                  hint: 'e.g. SDP, Threadless',
                  onChanged: (v) =>
                      ref.read(inputProvider).baseAndThreadDesign = v,
                ),
                _field(
                  label: 'Dimensions',
                  ctrl: _dimCtrl,
                  hint: 'e.g. 4" x 3"',
                  isMono: true,
                  onChanged: (v) =>
                      ref.read(inputProvider).dimensionsAndWeight = v,
                ),
              ]),
              SizedBox(height: 32.h),
              _sectionHeader('Archival Records'),
              _buildModule([
                _field(
                  label: 'Markings',
                  ctrl: _markCtrl,
                  hint: 'Patent dates, shop marks...',
                  maxLines: 2,
                  isMono: true,
                  onChanged: (v) =>
                      ref.read(inputProvider).markingsAndPatentDates = v,
                ),
                _field(
                  label: 'Provenance',
                  ctrl: _provCtrl,
                  hint: 'Discovery location, history...',
                  maxLines: 3,
                  onChanged: (v) => ref.read(inputProvider).provenance = v,
                ),
                _field(
                  label: 'Archival Notes',
                  ctrl: _notesCtrl,
                  hint: 'General observations...',
                  maxLines: 4,
                  onChanged: (v) => ref.read(inputProvider).notes = v,
                ),
              ]),
            ],
          ),

          // Floating Action Button Hub
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 30.h,
            child: GestureDetector(
              onTap: _save,
              child: Container(
                height: 64.h,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(kRadiusXLarge),
                  boxShadow: const [kShadowCyan],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, color: kBackground, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text(
                        widget.isEdit ? 'SAVE CHANGES' : 'COMMIT TO ARCHIVE',
                        style: GoogleFonts.jetBrainsMono(
                          color: kBackground,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoModule() {
    final imageProv = ref.watch(imageProvider);
    final displayPath = imageProv.getImagePath(imageProv.resultImage);

    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        height: 220.h,
        decoration: BoxDecoration(
          color: kPanelBg.withAlpha(150),
          borderRadius: BorderRadius.circular(kRadiusLarge),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: displayPath != null && File(displayPath).existsSync()
            ? Image.file(File(displayPath), fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_enhance_outlined,
                    color: kSecondaryText,
                    size: 40.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Capture Specimen',
                    style: GoogleFonts.dmSans(
                      color: kPrimaryText,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    'High-fidelity photograph recommended',
                    style: GoogleFonts.inter(
                      color: kSecondaryText.withAlpha(120),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          color: kSecondaryText,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.0,
        ),
      ),
    );
  }

  Widget _buildModule(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(100),
        borderRadius: BorderRadius.circular(kRadiusLarge),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    bool isMono = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: isMono
                ? GoogleFonts.jetBrainsMono(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                  )
                : GoogleFonts.inter(color: kPrimaryText, fontSize: 15.sp),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kAccent),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryPicker() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: HardwareCategory.values
              .map(
                (c) => GestureDetector(
                  onTap: () => p.itemCategory = c,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: p.itemCategory == c
                          ? kAccent.withAlpha(40)
                          : kBackground.withAlpha(100),
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                      border: Border.all(
                        color: p.itemCategory == c ? kAccent : kOutline,
                      ),
                    ),
                    child: Text(
                      c.label,
                      style: GoogleFonts.inter(
                        color: p.itemCategory == c ? kAccent : kSecondaryText,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _conditionPicker() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 40.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ConditionState.values
                .map(
                  (s) => GestureDetector(
                    onTap: () => p.conditionState = s,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: p.conditionState == s
                              ? getConditionColor(s).withAlpha(40)
                              : kBackground.withAlpha(100),
                          borderRadius: BorderRadius.circular(kRadiusStandard),
                          border: Border.all(
                            color: p.conditionState == s
                                ? getConditionColor(s)
                                : kOutline,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.label,
                          style: GoogleFonts.inter(
                            color: p.conditionState == s
                                ? kPrimaryText
                                : kSecondaryText,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusLarge),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: kAccent),
            SizedBox(height: 20.h),
            Text(
              'ARCHIVING SPECIMEN...',
              style: GoogleFonts.jetBrainsMono(
                color: kPrimaryText,
                fontSize: 12.sp,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

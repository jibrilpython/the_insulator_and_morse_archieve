import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/models/archive_item_model.dart';
import 'package:insulator_and_morse_archieve/providers/image_provider.dart';
import 'package:insulator_and_morse_archieve/providers/project_provider.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _atmosphereController;
  String? _focusedId;
  bool _isScrollLocked = false;

  @override
  void initState() {
    super.initState();
    _atmosphereController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _atmosphereController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(projectProvider).entries;

    final focusedItem = _focusedId != null
        ? allEntries.firstWhereOrNull((e) => e.id == _focusedId)
        : null;

    // Group entries into lines of 4
    final List<List<ArchiveItemModel>> wireGroups = [];
    for (var i = 0; i < allEntries.length; i += 4) {
      wireGroups.add(allEntries.sublist(i, math.min(i + 4, allEntries.length)));
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // 1. Telegraph Atmosphere (Deep sunset / schematic)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _atmosphereController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _TelegraphAtmospherePainter(
                    _atmosphereController.value,
                  ),
                );
              },
            ),
          ),

          // 2. High-Tension Web
          Positioned.fill(
            child: allEntries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.only(top: 12.h, bottom: 200.h),
                    physics: _isScrollLocked
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    itemCount: wireGroups.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildHeader();
                      return _TelegraphWireWidget(
                        nodes: wireGroups[index - 1],
                        isFocusDimmed:
                            focusedItem != null &&
                            !wireGroups[index - 1].any(
                              (e) => e.id == focusedItem.id,
                            ),
                        onDragStateChanged: (locked) {
                          setState(() => _isScrollLocked = locked);
                        },
                        onFocus: (item) {
                          setState(() => _focusedId = item.id);
                        },
                      );
                    },
                  ),
          ),

          // 3. Dark Overlay when Focused
          if (focusedItem != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _focusedId = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Colors.black.withAlpha(200),
                ),
              ),
            ),

          // 4. Focus Slider (Bottom Sheet)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            bottom: focusedItem != null ? 0 : -600.h,
            left: 0,
            right: 0,
            height: 480.h,
            child: _buildFocusSlider(focusedItem),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 64.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TELEGAPH WEB // DISPLAY',
                    style: GoogleFonts.jetBrainsMono(
                      color: kAccent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'THE\nSHOWCASE',
                    style: GoogleFonts.dmSans(
                      color: kPrimaryText,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: -2.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kPanelBg.withAlpha(150),
                  shape: BoxShape.circle,
                  border: Border.all(color: kOutline),
                ),
                child: Icon(
                  Icons.bubble_chart_rounded,
                  color: kAccent,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Status Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: kPanelBg.withAlpha(150),
              borderRadius: BorderRadius.circular(kRadiusPill),
              border: Border.all(color: kOutline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusPulseDot(),
                SizedBox(width: 10.w),
                Text(
                  'ACTIVE MAPPING',
                  style: GoogleFonts.jetBrainsMono(
                    color: kPrimaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSlider(ArchiveItemModel? item) {
    if (item == null) return const SizedBox();
    final imagePath = ref.watch(imageProvider).getImagePath(item.photoPath);
    final glassColor = item.glassColorOrGlazeType.isNotEmpty
        ? getGlassSwatchColor(item.glassColorOrGlazeType)
        : kSecondaryText;

    final allEntries = ref.read(projectProvider).entries;
    final index = allEntries.indexOf(item);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(kRadiusXLarge),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: GestureDetector(
          onTap: () {
            if (index != -1) {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(
                context,
                '/info_screen',
                arguments: {'index': index},
              );
            }
          },
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: kPanelBg.withAlpha(200),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(kRadiusXLarge),
              ),
              border: Border(
                top: BorderSide(color: glassColor.withAlpha(100), width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(150),
                  blurRadius: 40,
                  spreadRadius: 10,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Keep GestureDetector here for the close icon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: glassColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(kRadiusPill),
                          border: Border.all(color: glassColor.withAlpha(80)),
                        ),
                        child: Text(
                          item.gridIdentifier.isEmpty
                              ? 'UNK-ID'
                              : item.gridIdentifier,
                          style: GoogleFonts.jetBrainsMono(
                            color: glassColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 40.w),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _focusedId = null);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: kPrimaryText,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Content Body
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Glass Node / Image Hub
                      Container(
                        width: 140.w,
                        height: 260.h,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(kRadiusLarge),
                          border: Border.all(color: kOutline),
                          boxShadow: [
                            BoxShadow(
                              color: glassColor.withAlpha(30),
                              blurRadius: 40,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            (imagePath != null && File(imagePath).existsSync())
                            ? Image.file(File(imagePath), fit: BoxFit.cover)
                            : Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: kOutline.withAlpha(150),
                                  size: 32.sp,
                                ),
                              ),
                      ),
                      SizedBox(width: 24.w),

                      // Typographic Details
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MANUFACTURER',
                                style: GoogleFonts.jetBrainsMono(
                                  color: kSecondaryText,
                                  fontSize: 9.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.manufacturerAndShopMark.isEmpty
                                    ? 'Unknown'
                                    : item.manufacturerAndShopMark,
                                style: GoogleFonts.dmSans(
                                  color: kPrimaryText,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'PROFILE / STYLE',
                                style: GoogleFonts.jetBrainsMono(
                                  color: kSecondaryText,
                                  fontSize: 9.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.cdOrStyleNumber.isEmpty
                                    ? '---'
                                    : item.cdOrStyleNumber,
                                style: GoogleFonts.jetBrainsMono(
                                  color: glassColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'PRODUCTION ERA',
                                style: GoogleFonts.jetBrainsMono(
                                  color: kSecondaryText,
                                  fontSize: 9.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.eraOfProduction.isEmpty
                                    ? 'Unknown'
                                    : item.eraOfProduction,
                                style: GoogleFonts.inter(
                                  color: kPrimaryText,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, color: kOutline, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'NO NODES DETECTED',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 12.sp,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HIGH-TENSION WIRE ENGINE
// ─────────────────────────────────────────────────────────────────────────────

class _TelegraphWireWidget extends StatefulWidget {
  final List<ArchiveItemModel> nodes;
  final bool isFocusDimmed;
  final Function(bool) onDragStateChanged;
  final Function(ArchiveItemModel) onFocus;

  const _TelegraphWireWidget({
    required this.nodes,
    required this.isFocusDimmed,
    required this.onDragStateChanged,
    required this.onFocus,
  });

  @override
  State<_TelegraphWireWidget> createState() => _TelegraphWireWidgetState();
}

class _TelegraphWireWidgetState extends State<_TelegraphWireWidget>
    with TickerProviderStateMixin {
  int? _activeNode;
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;

  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  late AnimationController _sparkController;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  Offset _getBasePosition(int index, double width, double height) {
    final spacing = width / (widget.nodes.length + 1);
    return Offset(spacing * (index + 1), height / 2);
  }

  void _handlePanStart(
    DragStartDetails details,
    BoxConstraints constraints,
    int index,
  ) {
    if (widget.isFocusDimmed) return;

    _activeNode = index;
    _isDragging = true;
    _dragOffset = Offset.zero;
    widget.onDragStateChanged(true); // LOCK SCROLLING
    _springController.stop();
    setState(() {});
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging || _activeNode == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);

    final constraints = renderBox.size;
    final basePos = _getBasePosition(
      _activeNode!,
      constraints.width,
      constraints.height,
    );

    setState(() {
      _dragOffset = localPos - basePos;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging || _activeNode == null) return;

    widget.onDragStateChanged(false); // RELEASE SCROLLING
    _isDragging = false;

    // TAP DETECTION FALLBACK
    if (_dragOffset.distance < 8.0) {
      widget.onFocus(widget.nodes[_activeNode!]);
      HapticFeedback.lightImpact();
      setState(() {
        _activeNode = null;
        _dragOffset = Offset.zero;
      });
      return;
    }

    // SNAP PHYSICS
    HapticFeedback.heavyImpact();

    _springAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
        );

    _springController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _activeNode = null;
          _dragOffset = Offset.zero;
        });
      }
    });

    _sparkController.forward(from: 0.0);
  }

  void _handlePanCancel() {
    if (_isDragging) {
      widget.onDragStateChanged(false); // RELEASE SCROLLING
      setState(() {
        _activeNode = null;
        _isDragging = false;
        _dragOffset = Offset.zero;
      });
    }
  }

  void _handleTapUp(
    TapUpDetails details,
    BoxConstraints constraints,
    int index,
  ) {
    if (widget.isFocusDimmed) return;
    widget.onDragStateChanged(false);
    widget.onFocus(widget.nodes[index]);
    HapticFeedback.lightImpact();
    setState(() {
      _activeNode = null;
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
  }

  Widget _buildNodeHitTarget(int index, BoxConstraints constraints) {
    final pos = _getBasePosition(
      index,
      constraints.maxWidth,
      constraints.maxHeight,
    );

    return Positioned(
      left: pos.dx - 50.w,
      top: pos.dy - 50.w,
      width: 100.w,
      height: 100.w,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) => _handlePanStart(details, constraints, index),
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onPanCancel: _handlePanCancel,
        onTapUp: (details) => _handleTapUp(details, constraints, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.isFocusDimmed ? 0.3 : 1.0,
      child: Container(
        height: 180.h,
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 24.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. The Physics Painter (Always behind)
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _springController,
                    _sparkController,
                  ]),
                  builder: (context, child) {
                    Offset currentAnimationOffset = Offset.zero;
                    if (!_isDragging &&
                        _activeNode != null &&
                        _springController.isAnimating) {
                      currentAnimationOffset = _springAnimation.value;
                    }

                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _WirePainter(
                        nodes: widget.nodes,
                        activeNode: _activeNode,
                        isDragging: _isDragging,
                        dragOffset: _dragOffset,
                        springOffset: currentAnimationOffset,
                        sparkProgress: _sparkController.value,
                      ),
                    );
                  },
                ),

                // 2. Precision Hit Targets (Over each node)
                for (int i = 0; i < widget.nodes.length; i++)
                  _buildNodeHitTarget(i, constraints),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WirePainter extends CustomPainter {
  final List<ArchiveItemModel> nodes;
  final int? activeNode;
  final bool isDragging;
  final Offset dragOffset;
  final Offset springOffset;
  final double sparkProgress;

  _WirePainter({
    required this.nodes,
    required this.activeNode,
    required this.isDragging,
    required this.dragOffset,
    required this.springOffset,
    required this.sparkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Wire Path
    final wirePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = Colors.white.withAlpha(isDragging ? 40 : 15)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    path.moveTo(0, size.height / 2);

    final nodeCount = nodes.length;
    final spacing = size.width / (nodeCount + 1);
    List<Offset> nodePositions = [];

    for (int i = 0; i < nodeCount; i++) {
      Offset base = Offset(spacing * (i + 1), size.height / 2);
      Offset current = base;

      if (i == activeNode) {
        if (isDragging) {
          current += dragOffset;
        } else {
          current += springOffset;
        }
      }

      nodePositions.add(current);
      path.lineTo(current.dx, current.dy);
    }
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, wirePaint);

    // 2. Draw Sparks (if snapping)
    if (sparkProgress > 0 && sparkProgress < 1.0 && activeNode != null) {
      final origin = nodePositions[activeNode!];
      final sparkLength = 60.0;
      final traveled = sparkProgress * size.width;

      final sparkPaint = Paint()
        ..color = Colors.white.withAlpha(200)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      final sparkGlow = Paint()
        ..color = kAccent.withAlpha(150)
        ..strokeWidth = 8.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Left Spark
      if (origin.dx - traveled > -sparkLength) {
        final leftEnd = Offset(origin.dx - traveled, origin.dy);
        final leftStart = Offset(leftEnd.dx + sparkLength, origin.dy);
        canvas.drawLine(leftStart, leftEnd, sparkGlow);
        canvas.drawLine(leftStart, leftEnd, sparkPaint);
      }

      // Right Spark
      if (origin.dx + traveled < size.width + sparkLength) {
        final rightEnd = Offset(origin.dx + traveled, origin.dy);
        final rightStart = Offset(rightEnd.dx - sparkLength, origin.dy);
        canvas.drawLine(rightStart, rightEnd, sparkGlow);
        canvas.drawLine(rightStart, rightEnd, sparkPaint);
      }
    }

    // 3. Draw Beautiful Glass Nodes
    for (int i = 0; i < nodeCount; i++) {
      final pos = nodePositions[i];
      final item = nodes[i];
      final baseColor = item.glassColorOrGlazeType.isNotEmpty
          ? getGlassSwatchColor(item.glassColorOrGlazeType)
          : kSecondaryText;
      final isFocus = i == activeNode && !isDragging;

      // Glow behind the glass
      final glowSize = isDragging && i == activeNode ? 36.w : 28.w;
      final ambientGlow = Paint()
        ..color = baseColor.withAlpha(isFocus ? 80 : 30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(pos, glowSize, ambientGlow);

      // Physical glass body (Radial Gradient)
      final bodyRadius = isDragging && i == activeNode ? 22.w : 20.w;
      final glassShader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Colors.white.withAlpha(180), // Specular highlight
          baseColor.withAlpha(220), // Core color
          baseColor.withAlpha(100), // Deep edge
          Colors.black.withAlpha(150), // Shadow
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: bodyRadius));

      final fillPaint = Paint()..shader = glassShader;
      canvas.drawCircle(pos, bodyRadius, fillPaint);

      // Sharp inner reflection rim
      final rimPaint = Paint()
        ..color = Colors.white.withAlpha(isFocus ? 150 : 50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(pos, bodyRadius - 1, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) {
    return oldDelegate.dragOffset != dragOffset ||
        oldDelegate.springOffset != springOffset ||
        oldDelegate.sparkProgress != sparkProgress ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.activeNode != activeNode ||
        oldDelegate.nodes != nodes;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CINEMATIC ATMOSPHERE
// ─────────────────────────────────────────────────────────────────────────────

class _TelegraphAtmospherePainter extends CustomPainter {
  final double animationValue;
  _TelegraphAtmospherePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Deep Space Pulsing Cyan Gradient
    final y = math.sin(animationValue * 2 * math.pi) * 0.15;
    final x = math.cos(animationValue * 2 * math.pi) * 0.1;

    final gradient = RadialGradient(
      center: Alignment(x, 1.2 + y),
      radius: 1.8,
      colors: [kAccent.withAlpha(25), kBackground],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // 2. Cinematic Cross Mesh
    final meshPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    final offsetX = (animationValue * spacing) % spacing;
    final offsetY = (animationValue * 0.5 * spacing) % spacing;

    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      for (double j = -spacing; j < size.height + spacing; j += spacing) {
        final center = Offset(i + offsetX, j + offsetY);

        // Draw a tiny cross
        canvas.drawLine(
          center - const Offset(2, 0),
          center + const Offset(2, 0),
          meshPaint,
        );
        canvas.drawLine(
          center - const Offset(0, 2),
          center + const Offset(0, 2),
          meshPaint,
        );
      }
    }

    // 3. Ambient Dust (Static but flickering based on animation)
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final pos = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final opacity = (math.sin(animationValue * 4 * math.pi + i) + 1) / 2;
      canvas.drawCircle(
        pos,
        0.8,
        Paint()..color = Colors.white.withOpacity(opacity * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatusPulseDot extends StatefulWidget {
  const _StatusPulseDot();

  @override
  State<_StatusPulseDot> createState() => _StatusPulseDotState();
}

class _StatusPulseDotState extends State<_StatusPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: kAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kAccent.withAlpha((_controller.value * 150).toInt()),
                blurRadius: 8 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

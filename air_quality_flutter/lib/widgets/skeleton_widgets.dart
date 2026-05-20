import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON LOADERS — Pure Flutter shimmer effect (no external dependencies)
// Respects theme tokens from lib/theme.dart for dark/light compatibility.
// ─────────────────────────────────────────────────────────────────────────────

/// Base shimmer widget. Uses AnimatedBuilder + LinearGradient sweep animation.
class _ShimmerBase extends StatefulWidget {
  final Widget child;
  const _ShimmerBase({required this.child});

  @override
  State<_ShimmerBase> createState() => _ShimmerBaseState();
}

class _ShimmerBaseState extends State<_ShimmerBase>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8E8E8);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.5).clamp(0.0, 1.0),
                (_animation.value).clamp(0.0, 1.0),
                (_animation.value + 0.15).clamp(0.0, 1.0),
                (_animation.value + 0.5).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// A single skeleton line — rectangular with rounded corners.
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8E8E8);

    return _ShimmerBase(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius ?? height / 2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// A skeleton card — mimics the app's Card widget structure.
class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF222222) : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5E5);

    return _ShimmerBase(
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonLine(width: 140, height: 16),
            const SizedBox(height: 10),
            SkeletonLine(height: 12),
            const SizedBox(height: 6),
            SkeletonLine(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton for the map bottom sheet data panel.
class SkeletonMapSheet extends StatelessWidget {
  const SkeletonMapSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF222222) : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5E5);

    Widget sectionCard({List<double> lineWidths = const []}) {
      return _ShimmerBase(
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(width: 120, height: 18),
              const SizedBox(height: 12),
              ...lineWidths.asMap().entries.map((e) => Padding(
                    padding: EdgeInsets.only(
                        top: e.key == 0 ? 0 : 8),
                    child: SkeletonLine(
                      width: e.value == -1
                          ? double.infinity
                          : e.value,
                      height: 13,
                    ),
                  )),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weather card
        sectionCard(lineWidths: [-1, 180, -1]),
        // Air quality card
        sectionCard(lineWidths: [-1, 220, 160, -1]),
        // Forecast row
        _ShimmerBase(
          child: SizedBox(
            height: 130,
            child: Row(
              children: List.generate(
                5,
                (i) => Container(
                  width: 88,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton for the history screen list.
class SkeletonHistoryList extends StatelessWidget {
  const SkeletonHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        // Section header
        _SkeletonSectionHeader(),
        const SizedBox(height: 8),
        const SkeletonCard(),
        const SkeletonCard(),
        const SizedBox(height: 16),
        _SkeletonSectionHeader(),
        const SizedBox(height: 8),
        const SkeletonCard(),
        const SkeletonCard(),
        const SkeletonCard(),
      ],
    );
  }
}

class _SkeletonSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Row(
        children: [
          _ShimmerBase(
            child: Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3A3A3C)
                    : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SkeletonLine(width: 120, height: 14),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton for a single list item tile (used in saved locations / history).
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF222222) : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5E5);

    return _ShimmerBase(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: borderColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 140, height: 14),
                  const SizedBox(height: 6),
                  SkeletonLine(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

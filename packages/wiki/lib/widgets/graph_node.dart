import 'package:flutter/material.dart';

import 'graph_canvas.dart';

// ---------------------------------------------------------------------------
// GraphNodeWidget
// ---------------------------------------------------------------------------

/// A Flutter widget that renders a single knowledge-graph node as a
/// rounded-rectangle chip overlaid on the [GraphCanvas].
///
/// Supports two visual states:
/// - **Compact** (unselected) — shows a truncated title in a small card.
/// - **Expanded** (selected) — scales up, centres itself on the canvas via
///   [GraphController], and reveals a summary-card overlay below the node.
///
/// Tap behaviour:
/// 1. First tap → selects the node (scale-up + centre + summary overlay).
/// 2. Second tap on an already-selected node → invokes [onNavigate].
class GraphNodeWidget extends StatefulWidget {
  const GraphNodeWidget({
    super.key,
    required this.nodeId,
    required this.title,
    this.isSelected = false,
    this.position = Offset.zero,
    this.onTap,
    this.onNavigate,
    this.controller,
    this.summary,
    this.maxTitleLength = 20,
    this.compactWidth = 160.0,
    this.compactHeight = 48.0,
    this.expandedWidth = 220.0,
    this.expandedHeight = 56.0,
    this.nodeColor = const Color(0xFF37474F),
    this.selectedColor = const Color(0xFF1E88E5),
    this.textColor = Colors.white,
    this.borderColor = const Color(0xFF263238),
    this.selectedBorderColor = const Color(0xFF1565C0),
    this.borderRadius = 12.0,
    this.animationDuration = const Duration(milliseconds: 250),
    this.summaryCardMaxWidth = 280.0,
  });

  // -------------------------------------------------------------------------
  // Required parameters
  // -------------------------------------------------------------------------

  /// Unique identifier that matches the corresponding [GraphNode.id] on the
  /// canvas so that hit-testing and controller operations stay in sync.
  final String nodeId;

  /// The document / note title displayed inside the node chip.
  final String title;

  // -------------------------------------------------------------------------
  // Interaction
  // -------------------------------------------------------------------------

  /// Whether this node is currently the *selected* node on the canvas.
  /// Drives the compact ↔ expanded visual transition.
  final bool isSelected;

  /// Centre position of the node in graph-space. Used to position the widget
  /// as an overlay on top of the [GraphCanvas].
  final Offset position;

  /// Called on the first tap (when the node is not yet selected).
  final VoidCallback? onTap;

  /// Called on the second tap when the node is already selected, signalling
  /// that the user wants to navigate to the full reading view.
  final VoidCallback? onNavigate;

  /// Optional [GraphController] used to centre the canvas on this node when
  /// it becomes selected.
  final GraphController? controller;

  // -------------------------------------------------------------------------
  // Content
  // -------------------------------------------------------------------------

  /// Optional one-liner summary shown inside the expanded overlay card.
  final String? summary;

  /// Maximum number of characters for the displayed title before truncation.
  final int maxTitleLength;

  // -------------------------------------------------------------------------
  // Dimensions
  // -------------------------------------------------------------------------

  final double compactWidth;
  final double compactHeight;
  final double expandedWidth;
  final double expandedHeight;

  // -------------------------------------------------------------------------
  // Appearance
  // -------------------------------------------------------------------------

  final Color nodeColor;
  final Color selectedColor;
  final Color textColor;
  final Color borderColor;
  final Color selectedBorderColor;
  final double borderRadius;

  // -------------------------------------------------------------------------
  // Animation
  // -------------------------------------------------------------------------

  final Duration animationDuration;
  final double summaryCardMaxWidth;

  @override
  State<GraphNodeWidget> createState() => _GraphNodeWidgetState();
}

// ---------------------------------------------------------------------------
// _GraphNodeWidgetState
// ---------------------------------------------------------------------------

class _GraphNodeWidgetState extends State<GraphNodeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Color?> _colorAnimation;
  late final Animation<Color?> _borderColorAnimation;
  late final Animation<double> _widthAnimation;
  late final Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    if (widget.isSelected) {
      _scaleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant GraphNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
        _centerOnCanvas();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Animation setup
  // -------------------------------------------------------------------------

  void _initAnimations() {
    _scaleController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _colorAnimation = ColorTween(
      begin: widget.nodeColor,
      end: widget.selectedColor,
    ).animate(_scaleController);

    _borderColorAnimation = ColorTween(
      begin: widget.borderColor,
      end: widget.selectedBorderColor,
    ).animate(_scaleController);

    _widthAnimation = Tween<double>(
      begin: widget.compactWidth,
      end: widget.expandedWidth,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _heightAnimation = Tween<double>(
      begin: widget.compactHeight,
      end: widget.expandedHeight,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
  }

  // -------------------------------------------------------------------------
  // Canvas centreing
  // -------------------------------------------------------------------------

  /// Instructs the [GraphController] to pan so that this node sits in the
  /// centre of the visible canvas area.
  void _centerOnCanvas() {
    final controller = widget.controller;
    if (controller == null) return;

    // We translate the canvas by the *inverse* of the node position so that
    // the node ends up at the origin of screen-space (centre).
    controller.applyTranslation(
      -widget.position.dx,
      -widget.position.dy,
    );
  }

  // -------------------------------------------------------------------------
  // Tap handling
  // -------------------------------------------------------------------------

  void _handleTap() {
    if (widget.isSelected) {
      widget.onNavigate?.call();
    } else {
      widget.onTap?.call();
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  String _truncateTitle(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    if (maxLength <= 3) return text.substring(0, maxLength);
    return '${text.substring(0, maxLength - 1)}…';
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        final currentWidth = _widthAnimation.value;
        final currentHeight = _heightAnimation.value;
        final currentColor = _colorAnimation.value ?? widget.nodeColor;
        final currentBorder =
            _borderColorAnimation.value ?? widget.borderColor;

        // ScaleTransition gives a smooth pop-in effect on top of the
        // size tween so the visual feels organic.
        return ScaleTransition(
          scale: _scaleAnimation.drive(
            Tween<double>(begin: 1.0, end: 1.08).chain(
              CurveTween(curve: Curves.easeOutBack),
            ),
          ),
          child: GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // ---- Node chip ----
                AnimatedContainer(
                  duration: widget.animationDuration,
                  width: currentWidth,
                  height: currentHeight,
                  decoration: BoxDecoration(
                    color: currentColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: currentBorder,
                      width: widget.isSelected ? 2.0 : 1.5,
                    ),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: currentBorder.withValues(alpha: 0.35),
                              blurRadius: 12.0,
                              spreadRadius: 2.0,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        _truncateTitle(widget.title, widget.maxTitleLength),
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: widget.isSelected ? 15.0 : 14.0,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                // ---- Summary card overlay (visible only when selected) ----
                if (widget.isSelected && widget.summary != null)
                  Positioned(
                    top: currentHeight + 8.0,
                    child: _SummaryCard(
                      summary: widget.summary!,
                      maxWidth: widget.summaryCardMaxWidth,
                      borderColor: currentBorder,
                      animationDuration: widget.animationDuration,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _SummaryCard
// ---------------------------------------------------------------------------

/// A small floating card that appears beneath a selected node, showing a
/// brief document summary.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.maxWidth,
    required this.borderColor,
    required this.animationDuration,
  });

  final String summary;
  final double maxWidth;
  final Color borderColor;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: animationDuration,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          elevation: 4.0,
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

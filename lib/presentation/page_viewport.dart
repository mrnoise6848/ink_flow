import 'dart:math';

import 'package:flutter/material.dart';

class PageViewport extends StatefulWidget {
  const PageViewport({
    super.key,
    required this.pageSize,
    required this.pan,
    required this.child,
  });
  final Size pageSize;
  final bool pan;
  final Widget child;
  @override
  State<PageViewport> createState() => _PageViewportState();
}

class _PageViewportState extends State<PageViewport> {
  final controller = TransformationController();
  Size? viewport;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      final fit = min(
        (size.width - 24) / widget.pageSize.width,
        (size.height - 24) / widget.pageSize.height,
      ).clamp(0.01, 2.0);
      if (viewport != size) {
        viewport = size;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final x = (size.width - widget.pageSize.width * fit) / 2;
          final y = (size.height - widget.pageSize.height * fit) / 2;
          controller.value = Matrix4.identity()
            ..translateByDouble(x, y, 0, 1)
            ..scaleByDouble(fit, fit, 1, 1);
        });
      }
      return ClipRect(
        child: InteractiveViewer(
          transformationController: controller,
          constrained: false,
          alignment: Alignment.topLeft,
          boundaryMargin: const EdgeInsets.all(300),
          minScale: fit * 0.5,
          maxScale: max(5, fit * 5),
          panEnabled: widget.pan,
          scaleEnabled: widget.pan,
          child: widget.child,
        ),
      );
    },
  );
}

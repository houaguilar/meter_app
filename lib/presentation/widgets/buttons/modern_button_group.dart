import 'package:flutter/material.dart';

import '../../../config/theme/theme.dart';

/// Contenedor de botones con layout mejorado
class ModernButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double spacing;
  final bool isStacked;

  const ModernButtonGroup({
    super.key,
    required this.children,
    this.padding,
    this.spacing = 12,
    this.isStacked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: isStacked
            ? Column(
          children: _buildStackedChildren(),
        )
            : Row(
          children: _buildRowChildren(),
        ),
      ),
    );
  }

  List<Widget> _buildStackedChildren() {
    final List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      if (i < children.length - 1) {
        widgets.add(SizedBox(height: spacing));
      }
    }
    return widgets;
  }

  List<Widget> _buildRowChildren() {
    final List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        widgets.add(SizedBox(width: spacing));
      }
      widgets.add(Expanded(child: children[i]));
    }
    return widgets;
  }
}

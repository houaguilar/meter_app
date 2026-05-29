import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ShareUtils {
  ShareUtils._();

  /// Returns a valid [sharePositionOrigin] for iOS share sheet.
  /// iOS 16+ on newer iPhones rejects a zero rect — this provides the
  /// screen widget's bounds as the anchor. On iPhone the sheet always
  /// appears from the bottom regardless of the rect, but the rect must
  /// be non-zero and within the view's coordinate space.
  static Rect? getOrigin(BuildContext context) {
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize && box.size.width > 0 && box.size.height > 0) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }
}

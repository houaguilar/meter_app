import 'package:flutter/material.dart';

import 'package:meter_app/core/utils/profile_security_utils.dart';

extension ProfileCompletenessUI on ProfileCompleteness {
  Color get levelColor {
    switch (level) {
      case ProfileCompletenessLevel.excellent:
        return Colors.green;
      case ProfileCompletenessLevel.good:
        return Colors.lightGreen;
      case ProfileCompletenessLevel.fair:
        return Colors.orange;
      case ProfileCompletenessLevel.poor:
        return Colors.red;
    }
  }

  IconData get levelIcon {
    switch (level) {
      case ProfileCompletenessLevel.excellent:
        return Icons.check_circle;
      case ProfileCompletenessLevel.good:
        return Icons.thumb_up;
      case ProfileCompletenessLevel.fair:
        return Icons.info;
      case ProfileCompletenessLevel.poor:
        return Icons.warning;
    }
  }
}

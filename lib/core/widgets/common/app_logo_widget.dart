import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_sizes.dart';

/// App logo widget displaying the main application logo.
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({
    super.key,
    this.size = AppSizes.thumbnailSm,
    this.heroTag, required int height,
  });

  final double size;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      AppAssets.appLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: logo,
      );
    }

    return logo;
  }
}


import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const SmartImage(this.path, {super.key, this.width, this.height, this.fit, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return const SizedBox();
    if (path.startsWith("http") || path.startsWith("https")) {
      return Image.network(path, width: width, height: height, fit: fit, errorBuilder: errorBuilder);
    } else {
      return Image.asset(path, width: width, height: height, fit: fit, errorBuilder: errorBuilder);
    }
  }
}

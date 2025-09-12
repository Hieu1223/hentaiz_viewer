import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class NativeImage extends StatelessWidget {
  final String src;
  final String? alt;
  final String? title;
  final double height;
  final double? width;
  const NativeImage(
    this.src, {
    super.key,
    this.alt,
    this.title,
    required this.height,
    this.width,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: HtmlElementView.fromTagName(
        tagName: 'img',
        onElementCreated: (imgElement) {
          imgElement as web.HTMLElement;
          imgElement.setAttribute('src', src);
          if (alt != null) {
            imgElement.setAttribute('alt', alt!);
          }
          if (title != null) {
            imgElement.setAttribute('title', title!);
          }
          imgElement.style.height = "${height}px";
          if (width != null) {
            imgElement.style.width = "${width}px";
          } else {
            imgElement.style.width = "auto";
          }
          imgElement.style.objectFit = "cover";
        },
      ),
    );
  }
}

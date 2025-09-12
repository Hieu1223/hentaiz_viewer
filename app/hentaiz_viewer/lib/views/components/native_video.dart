import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class NativeVideo extends StatelessWidget {
  final String embedUrl;
  final double height;
  final double? width;
  final String? title;

  const NativeVideo({
    super.key,
    required this.embedUrl,
    required this.height,
    this.width,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: HtmlElementView.fromTagName(
        tagName: 'iframe',
        onElementCreated: (iframe) {
          iframe as web.HTMLElement;

          iframe.setAttribute('src', embedUrl);
          iframe.setAttribute('frameborder', '0');
          iframe.setAttribute('allow',
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share');
          iframe.setAttribute('allowfullscreen', 'true');

          if (title != null) {
            iframe.setAttribute('title', title!);
          }

          // Style
          iframe.style.border = "none";
          iframe.style.height = "${height}px";
          iframe.style.width = width != null ? "${width}px" : "100%";
        },
      ),
    );
  }
}

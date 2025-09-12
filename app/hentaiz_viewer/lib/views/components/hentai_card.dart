import 'package:flutter/material.dart';
import 'package:hentaiz_viewer/models/hentai_display_model.dart';

class HentaiCard extends StatelessWidget {
  final HentaiDisplayModel item;
  final VoidCallback onTap;

  const HentaiCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  /// Build proxied image URL using Resource.baseUrl
  String get proxiedThumbnail {
    return item.thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Flex(
          direction: Axis.vertical,
          children: [
            // Ảnh qua proxy
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  proxiedThumbnail,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),
            // Tiêu đề
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/errors.dart';
import '../data/supabase_service.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'photo_placeholder.dart';

/// Let the person pick an image, upload it to the public photos bucket, and
/// return its URL. Returns null if they cancel or it fails (a snackbar shows
/// the error). [folder] groups uploads, e.g. 'horses' or 'products'.
Future<String?> pickAndUploadPhoto(
    BuildContext context, String folder) async {
  try {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = picked?.files.firstOrNull;
    final bytes = file?.bytes;
    if (bytes == null) return null;
    return await SupabaseService.uploadPhoto(
      folder: folder,
      fileName: file!.name,
      bytes: bytes,
    );
  } catch (e) {
    AppErrors.report(e);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Couldn't upload photo: $e")));
    }
    return null;
  }
}

/// A tappable photo slot with a "Change photo" affordance. Shows [url] when set.
/// Calls [onPick] which should do the upload and update state with the new URL.
class PhotoField extends StatelessWidget {
  const PhotoField({
    super.key,
    required this.url,
    required this.onPick,
    this.size = 88,
    this.circle = true,
    this.busy = false,
    this.label = 'Add photo',
  });

  final String? url;
  final Future<void> Function() onPick;
  final double size;
  final bool circle;
  final bool busy;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhotoPlaceholder(size: size, circle: circle, url: url),
        const SizedBox(width: 16),
        if (busy)
          const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4))
        else
          GestureDetector(
            onTap: onPick,
            child: Text(url != null && url!.isNotEmpty ? 'Change photo' : label,
                style: AppText.body(16, color: AppColors.accent700)),
          ),
      ],
    );
  }
}

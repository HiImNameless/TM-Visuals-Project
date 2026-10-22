import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '/viewmodels/portfolio_view_model.dart';

const Color yellowColor = Color(0xFFFFB900);

// DIALOG WIDGET
class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key, required this.maxLength});

  final int maxLength;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Please enter a category name.');
      return;
    }

    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF202020),
      title: const Text('Add Category', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter category name',
          hintStyle: const TextStyle(color: Colors.white54),
          errorText: _error,
          counterText: '',
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: yellowColor),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: yellowColor,
            foregroundColor: Colors.black,
          ),
          onPressed: _submit,
          child: const Text('Save Category'),
        ),
      ],
    );
  }
}

// FULLSCREEN MEDIA PREVIEW WIDGET
class FullscreenMediaPreview extends StatelessWidget {
  const FullscreenMediaPreview({
    super.key,
    required this.isVideo,
    this.controller,
    this.imageBytes,
  });

  final bool isVideo;
  final VideoPlayerController? controller;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(isVideo ? 'Video Preview' : 'Photo Preview'),
      ),
      body: Center(
        child: isVideo ? _buildVideoPreview() : _buildImagePreview(),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (imageBytes == null) {
      return const Icon(
        Icons.broken_image,
        color: Colors.white54,
        size: 60,
      );
    }

    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      child: Image.memory(
        imageBytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildVideoPreview() {
    final videoController = controller;

    if (videoController == null || !videoController.value.isInitialized) {
      return const CircularProgressIndicator(
        color: yellowColor,
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(videoController),
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: videoController,
              builder: (context, value, _) {
                return IconButton(
                  tooltip: value.isPlaying ? 'Pause video' : 'Play video',
                  iconSize: 70,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  onPressed: () {
                    value.isPlaying
                        ? videoController.pause()
                        : videoController.play();
                  },
                );
              },
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: VideoProgressIndicator(
                videoController,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: yellowColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// INLINE MEDIA PREVIEW WIDGET
class MediaPreviewWidget extends StatelessWidget {
  const MediaPreviewWidget({
    super.key,
    required this.file,
    required this.fileData,
    required this.videoController,
    required this.isVideoLoading,
    required this.onReturnFromFullscreen,
  });

  final XFile file;
  final Uint8List? fileData;
  final VideoPlayerController? videoController;
  final bool isVideoLoading;
  final Future<void> Function() onReturnFromFullscreen;

  @override
  Widget build(BuildContext context) {
    if (!PortfolioViewModel.isVideo(file)) {
      if (fileData == null) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 42),
        );
      }
      return Image.memory(
        fileData!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 42),
        ),
      );
    }

    if (isVideoLoading) {
      return const Center(child: CircularProgressIndicator(color: yellowColor));
    }

    if (videoController == null || !videoController!.value.isInitialized) {
      return const Center(
        child: Icon(Icons.video_file, color: yellowColor, size: 45),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          child: VideoPlayer(videoController!),
        ),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: videoController!,
          builder: (context, value, _) {
            return Center(
              child: IconButton(
                tooltip: value.isPlaying ? 'Pause video' : 'Play video',
                iconSize: 55,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                ),
                onPressed: () {
                  value.isPlaying
                      ? videoController!.pause()
                      : videoController!.play();
                },
              ),
            );
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: IconButton(
            tooltip: 'View full screen',
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.fullscreen),
            onPressed: () async {
              if (PortfolioViewModel.isVideo(file)) {
                await videoController!.pause();
              }

              if (context.mounted) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullscreenMediaPreview(
                      isVideo: PortfolioViewModel.isVideo(file),
                      controller:
                          PortfolioViewModel.isVideo(file) ? videoController : null,
                      imageBytes:
                          PortfolioViewModel.isVideo(file) ? null : fileData,
                    ),
                  ),
                );
              }

              await onReturnFromFullscreen();
            },
          ),
        ),
      ],
    );
  }
}


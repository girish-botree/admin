import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/exercise_dialogs.dart';
import '../exercise_controller.dart';
import '../../../meal/shared/widgets/common_widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart' show MissingPluginException;

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final dynamic exercise;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _videoInitialized = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoUrl = widget.exercise['videoUrl'] as String?;
    if (videoUrl == null || videoUrl.isEmpty) return;

    // Debug logging for video URL
    debugPrint('Attempting to load video from URL: $videoUrl');

    try {
      // Check if the URL is well-formed
      bool validURL = Uri.tryParse(videoUrl)?.hasScheme ?? false;

      // Check if this is a YouTube URL
      bool isYouTubeUrl = videoUrl.contains('youtube.com') ||
          videoUrl.contains('youtu.be');

      if (isYouTubeUrl) {
        debugPrint(
            '⚠️ YouTube URLs not directly supported - requires youtube_player_flutter package');
        // The video_player package doesn't support YouTube URLs directly
        // For YouTube URLs, you'd need to use youtube_player_flutter or similar package
        setState(() {
          _videoError = true;
        });
        return;
      }

      // Use a test video URL if the provided one is invalid
      final videoSourceUrl = validURL ? videoUrl :
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

      if (!validURL) {
        debugPrint('Invalid URL detected, falling back to test video URL');
      }

      _videoPlayerController = VideoPlayerController.network(videoSourceUrl);
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: false,
        looping: false,
        placeholder: Center(
          child: CircularProgressIndicator(
            color: Get.theme.colorScheme.primary,
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Get.theme.colorScheme.error,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error loading video',
                  style: TextStyle(
                    color: Get.theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _videoInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoError = true;
        });
      }
      debugPrint('Video player error: $e');
      // More detailed error information
      if (e is MissingPluginException) {
        debugPrint('MissingPluginException: ${e}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExerciseController>();

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      appBar: StandardAppBar.detail(
        title: (widget.exercise['name'] as String?) ?? 'Exercise Details',
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 12,
            color: context.theme.colorScheme.surface,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  ExerciseDialogs.showEditExerciseDialog(
                      context, controller, widget.exercise);
                  break;
                case 'delete':
                  ExerciseDialogs.showDeleteConfirmation(
                      context, widget.exercise, controller);
                  break;
              }
            },
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withValues(
                            alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Exercise',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Delete Exercise',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise image
            _buildExerciseImage(context),
            const SizedBox(height: 24),

            // Exercise basic info
            _buildBasicInfo(context),
            const SizedBox(height: 24),

            // Exercise details
            _buildExerciseDetails(context),
            const SizedBox(height: 24),

            // Description
            _buildDescription(context),
            const SizedBox(height: 24),

            // Instructions
            _buildInstructions(context),

            // Video section (if available)
            if (widget.exercise['videoUrl'] != null &&
                (widget.exercise['videoUrl'] as String).isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildVideoSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseImage(BuildContext context) {
    final imageUrl = widget.exercise['imageUrl'] as String?;

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
          const SizedBox.shrink(),
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (widget.exercise['name'] as String?) ?? 'Unknown Exercise',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDifficultyChip(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyChip(BuildContext context) {
    final difficulty = (widget.exercise['difficulty'] as num?)?.toInt() ?? 1;
    final difficultyText = _getDifficultyText(difficulty);
    final difficultyColor = _getDifficultyColor(difficulty, context.theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: difficultyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: difficultyColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_cellular_alt,
            size: 14,
            color: difficultyColor,
          ),
          const SizedBox(width: 4),
          Text(
            difficultyText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: difficultyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercise Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.fitness_center_rounded,
            label: 'Muscle Group',
            value: (widget.exercise['muscleGroup'] as String?) ?? 'Unknown',
            context: context,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.sports_gymnastics_rounded,
            label: 'Equipment',
            value: (widget.exercise['equipment'] as String?) ?? 'Unknown',
            context: context,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.signal_cellular_alt,
            label: 'Difficulty Level',
            value: '${widget.exercise['difficulty'] ??
                1}/5 (${_getDifficultyText(
                (widget.exercise['difficulty'] as num?)?.toInt() ?? 1)})',
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final description = widget.exercise['description'] as String?;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                color: context.theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final instructionData = widget.exercise['instructionData'];
    if (instructionData == null) {
      return const SizedBox.shrink();
    }

    List<MapEntry<String, String>> instructions = [];

    if (instructionData is Map<String, dynamic>) {
      instructions = instructionData.entries
          .map((entry) => MapEntry(entry.key, entry.value.toString()))
          .toList();
    } else if (instructionData is String) {
      // Handle string format
      final lines = instructionData.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isNotEmpty) {
          instructions.add(MapEntry('Step${i + 1}', line));
        }
      }
    }

    if (instructions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                color: context.theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...instructions
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < instructions.length - 1 ? 16 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instruction.value,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    final videoUrl = widget.exercise['videoUrl'] as String;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                color: context.theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Video Tutorial',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildVideoPlayer(context),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    if (_videoError) {
      final videoUrl = widget.exercise['videoUrl'] as String? ?? '';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: context.theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load video',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (videoUrl.isNotEmpty) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                videoUrl,
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Support info text
            if (videoUrl.contains('youtube.com') ||
                videoUrl.contains('youtu.be'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'YouTube links require special handling',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: context.theme.colorScheme.error.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _videoError = false;
                  _videoInitialized = false;
                });
                _initializeVideoPlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (!_videoInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: context.theme.colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading video...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (_chewieController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Chewie(
          controller: _chewieController!,
        ),
      );
    }

    // Fallback to display URL only if video player failed to initialize
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_rounded,
            size: 40,
            color: context.theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Video Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.exercise['videoUrl'] as String,
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: context.theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Moderate';
      case 4:
        return 'Hard';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  Color _getDifficultyColor(int difficulty, ThemeData theme) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }
}
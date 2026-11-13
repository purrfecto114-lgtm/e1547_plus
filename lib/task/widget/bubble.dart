import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

class TaskBubble extends StatelessWidget {
  const TaskBubble({super.key, this.onTap});

  final VoidCallback? onTap;

  static const double size = 64;
  static const double _innerSize = 56;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TasksController>();
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, controller.currentProgress]),
      builder: (context, _) {
        final TaskKind kind = controller.kind;
        final bool isDone = kind == TaskKind.done;
        // Transfers without a length and the saving phase have no
        // meaningful percentage; they show the same indeterminate ring a
        // single thumbnail without a length uses, instead of pretending to
        // sit at 0% or 100%.
        final bool indeterminate =
            !isDone &&
            (controller.runningTotal == 0 || controller.runningIndeterminate);
        final double progress = isDone ? 1 : controller.progress;
        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: indeterminate ? null : progress,
                      strokeWidth: 3,
                      trackGap: 0,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                  Material(
                    color: scheme.surfaceContainerHigh,
                    elevation: 6,
                    shape: const CircleBorder(),
                    child: SizedBox(
                      width: _innerSize,
                      height: _innerSize,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                        child: TaskBubbleContent(
                          key: ValueKey<Object>(
                            _contentKey(controller, kind, isDone),
                          ),
                          controller: controller,
                          kind: kind,
                          isDone: isDone,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Distinguishes the content states that swap on their own, like a batch
  /// that finishes with failures, so the switcher animates between them.
  static Object _contentKey(
    TasksController controller,
    TaskKind kind,
    bool isDone,
  ) {
    if (isDone) {
      if (controller.runningFailed > 0) return 'done-failed';
      if (controller.runningCanceled > 0 && controller.runningSucceeded == 0) {
        return 'done-canceled';
      }
      return TaskKind.done;
    }
    if (controller.runningSaving) return 'saving';
    if (controller.runningIndeterminate) return 'indeterminate-$kind';
    return kind;
  }
}

/// What the bubble's inner circle shows: the current phase while a batch
/// runs, and its outcome once it finished.
class TaskBubbleContent extends StatelessWidget {
  const TaskBubbleContent({
    super.key,
    required this.controller,
    required this.kind,
    required this.isDone,
  });

  final TasksController controller;
  final TaskKind kind;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final String? text = statusText(controller, isDone);
    // The bubble's content swaps on its own while a batch runs and again
    // when it settles; a live region announces those changes with the
    // same text the bubble shows, so assistive technologies stay in sync.
    return Semantics(
      liveRegion: true,
      label: text,
      child: _content(scheme, text),
    );
  }

  Widget _content(ColorScheme scheme, String? text) {
    if (isDone) {
      if (controller.runningFailed > 0) {
        // A failed batch must not look like a success; tapping through
        // opens the task list, where the failures wait for retry.
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 16, color: scheme.error),
            const SizedBox(height: 2),
            _bubbleText(text!),
          ],
        );
      }
      if (controller.runningCanceled > 0 && controller.runningSucceeded == 0) {
        return Icon(Icons.block, color: scheme.primary);
      }
      return Icon(Icons.check, color: scheme.primary);
    }
    if (controller.runningSaving) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save_outlined, size: 16, color: scheme.primary),
          const SizedBox(height: 2),
          _bubbleText(text!),
        ],
      );
    }
    if (controller.runningIndeterminate) {
      // No length was announced; show the bytes that did arrive.
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(kind), size: 16, color: scheme.primary),
          const SizedBox(height: 2),
          _bubbleText(text!),
        ],
      );
    }
    return Icon(_iconFor(kind), color: scheme.primary);
  }

  /// The text the bubble currently shows, if any; it doubles as the
  /// bubble's semantic label.
  static String? statusText(TasksController controller, bool isDone) {
    if (isDone) {
      if (controller.runningFailed > 0) {
        // TODO(l10n): extract
        return '${controller.runningSucceeded} completed, '
            '${controller.runningFailed} failed';
      }
      return null;
    }
    if (controller.runningSaving) {
      return 'Saving'; // TODO(l10n): extract
    }
    if (controller.runningIndeterminate) {
      // No length was announced; report the bytes that did arrive.
      return filesize(controller.runningTransferred, 1);
    }
    return null;
  }

  static IconData _iconFor(TaskKind kind) => switch (kind) {
    TaskKind.none || TaskKind.download => Icons.download,
    TaskKind.favorite => Icons.favorite,
    TaskKind.unfavorite => Icons.heart_broken,
    TaskKind.mixed => Icons.layers,
    TaskKind.done => Icons.check,
  };
}

/// A single line of text that shrinks to fit the bubble's inner circle.
Widget _bubbleText(String text) => FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(
    text,
    maxLines: 1,
    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
  ),
);

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:relative_time/relative_time.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.controller,
    required this.layoutData,
  });

  final Task task;
  final TasksController controller;
  final SelectionLayoutData<Task> layoutData;

  @override
  Widget build(BuildContext context) {
    final bool isRunning = controller.isRunning(task.id);
    final bool selecting = layoutData.selections.isNotEmpty;
    final bool selected = layoutData.selections.contains(task);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // Failed tasks carry the reason of their failure; the raw exception is
    // kept behind an expandable, so it cannot dominate the list.
    final bool hasDetails =
        task.status == TaskStatus.failed &&
        task.error != null &&
        task.error!.isNotEmpty;

    return MouseCursorRegion(
      onSecondaryTap: () => layoutData.toggleSelection(task),
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        child: ExpandableNotifier(
          child: Builder(
            builder: (context) {
              final ExpandableController expandable =
                  ExpandableController.of(context, required: true)!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: selecting
                        ? () => layoutData.toggleSelection(task)
                        : const E621LinkParser().parseOnTap(
                            context,
                            PostLinking.getPostLink(task.postId),
                          ),
                    onLongPress: () => layoutData.toggleSelection(task),
                    leading: TaskThumbnail(
                      task: task,
                      controller: controller,
                      isRunning: isRunning,
                    ),
                    title: Text(
                      AppLocalizations.of(context).taskTileTitle(
                        taskActionLabel(context, task.action, task.status),
                        task.postId,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          RelativeTime.locale(
                            Localizations.localeOf(context),
                          ).format(task.completedAt ?? task.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.status == TaskStatus.failed)
                          Text(
                            taskErrorHint(
                              context,
                              categorizeTaskError(task.error),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: scheme.error),
                          ),
                      ],
                    ),
                    trailing: InkResponse(
                      onTap: () => layoutData.toggleSelection(task),
                      radius: 24,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: selecting
                              ? TaskSelectionCheck(selected: selected)
                              : Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Center(
                                      child: TaskStateIndicator(
                                        status: task.status,
                                        isRunning: isRunning,
                                      ),
                                    ),
                                    if (hasDetails)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: MouseCursorRegion(
                                          onTap: expandable.toggle,
                                          child: Container(
                                            color: scheme.surfaceContainerHigh,
                                            padding: const EdgeInsets.all(2),
                                            child: Icon(
                                              expandable.expanded
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              size: 14,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (hasDetails)
                    ClipRect(
                      child: AnimatedAlign(
                        alignment: Alignment.topLeft,
                        heightFactor: expandable.expanded ? 1 : 0,
                        duration: defaultAnimationDuration,
                        curve: Curves.easeOut,
                        child: TaskErrorDetails(task: task),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The technical failure details of a task, kept behind an expandable so
/// the raw exception cannot dominate the list.
class TaskErrorDetails extends StatelessWidget {
  const TaskErrorDetails({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            task.error ?? '',
            style: logTextStyle.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            // TODO(l10n): extract
            'Failed tasks are kept for '
            '${TaskRepository.failedRetention.inDays} days '
            'before they are cleaned up.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// The user-facing hint for a failed task, suggesting the next step that
/// matches why it failed.
String taskErrorHint(BuildContext context, TaskErrorCategory category) =>
    switch (category) {
      // TODO(l10n): extract
      TaskErrorCategory.directory =>
        'The save folder is missing or read-only. Pick the download folder again.',
      TaskErrorCategory.auth =>
        'The server rejected this account. Check your login, then retry.',
      TaskErrorCategory.network =>
        'The transfer failed. Retry once the network is back.',
      TaskErrorCategory.saving =>
        'Saving to the gallery failed. Check free space, then retry.',
      TaskErrorCategory.unknown =>
        'This task failed. Retry it, or open its details.',
    };

String taskActionLabel(
  BuildContext context,
  TaskAction action,
  TaskStatus status,
) {
  final l10n = AppLocalizations.of(context);
  final String present = switch (action) {
    TaskAction.download => l10n.taskActionDownload,
    TaskAction.favorite => l10n.taskActionFavorite,
    TaskAction.unfavorite => l10n.taskActionUnfavorite,
  };
  return switch (status) {
    TaskStatus.pending => l10n.taskQueuedTo(present),
    TaskStatus.running => switch (action) {
      TaskAction.download => l10n.taskDownloadRunning,
      TaskAction.favorite => l10n.taskFavoriteRunning,
      TaskAction.unfavorite => l10n.taskUnfavoriteRunning,
    },
    TaskStatus.completed => switch (action) {
      TaskAction.download => l10n.taskDownloadCompleted,
      TaskAction.favorite => l10n.taskFavoriteCompleted,
      TaskAction.unfavorite => l10n.taskUnfavoriteCompleted,
    },
    TaskStatus.failed => l10n.taskFailedTo(present),
    TaskStatus.canceled => l10n.taskCanceledAction(present),
  };
}

IconData taskActionIcon(TaskAction action) => switch (action) {
  TaskAction.download => Icons.download,
  TaskAction.favorite => Icons.favorite,
  TaskAction.unfavorite => Icons.heart_broken,
};

class TaskThumbnail extends StatelessWidget {
  const TaskThumbnail({
    super.key,
    required this.task,
    required this.controller,
    required this.isRunning,
  });

  final Task task;
  final TasksController controller;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final previewUrl = task.metadata?.previewUrl;
    final placeholder = Container(
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        taskActionIcon(task.action),
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
    );
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: previewUrl != null
          ? CachedNetworkImage(
              imageUrl: previewUrl,
              cacheManager: context.read<BaseCacheManager>(),
              fit: BoxFit.cover,
              placeholder: (context, url) => placeholder,
              errorWidget: (context, url, error) => placeholder,
            )
          : placeholder,
    );

    final ValueListenable<TaskDownloadProgress>? progress = controller
        .progressOf(task.id);
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (isRunning && progress != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ValueListenableBuilder<TaskDownloadProgress>(
                valueListenable: progress,
                builder: (context, value, _) => LinearProgressIndicator(
                  // an unknown length or the saving phase shows the same
                  // indeterminate bar a single thumbnail without a length
                  // uses, instead of pretending to be at 0%
                  value: value.fraction,
                  minHeight: 3,
                  backgroundColor: Colors.black38,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TaskStateIndicator extends StatelessWidget {
  const TaskStateIndicator({
    super.key,
    required this.status,
    required this.isRunning,
  });

  final TaskStatus status;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color color) = switch (status) {
      TaskStatus.pending => (Icons.schedule, scheme.onSurfaceVariant),
      TaskStatus.running => (Icons.sync, scheme.primary),
      TaskStatus.completed => (Icons.check_circle, Colors.green),
      TaskStatus.failed => (Icons.error, scheme.error),
      TaskStatus.canceled => (Icons.block, scheme.onSurfaceVariant),
    };
    return Icon(icon, color: color, size: 22);
  }
}

class TaskSelectionCheck extends StatelessWidget {
  const TaskSelectionCheck({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Icon(
      selected ? Icons.check_circle : Icons.radio_button_unchecked,
      color: selected ? scheme.primary : scheme.onSurfaceVariant,
      size: 22,
    );
  }
}

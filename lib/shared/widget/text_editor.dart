import 'dart:async';

import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

typedef TextEditorSubmit = FutureOr<String?> Function(String value);
typedef TextEditorBuilder =
    Widget Function(BuildContext context, TextEditingController controller);

/// Asks the user to confirm discarding unsaved editor changes.
///
/// Returns whether the changes may be discarded. Every other exit from
/// the dialog, like declining or dismissing it, keeps the editor open.
Future<bool> confirmDiscardText(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(AppLocalizations.of(context).editorDiscardTitle),
    content: Text(AppLocalizations.of(context).editorDiscardBody),
    actions: [
      TextButton(
        onPressed: () => popDialog(context, false),
        child: Text(AppLocalizations.of(context).editorContinueEditing),
      ),
      TextButton(
        onPressed: () => popDialog(context, true),
        child: Text(AppLocalizations.of(context).editorDiscardConfirm),
      ),
    ],
  ),
).then((value) => value ?? false);

class TextEditor extends StatelessWidget {
  const TextEditor({
    super.key,
    this.content,
    required this.onSubmitted,
    this.onClosed,
    this.title,
    this.actions,
    this.preview,
    this.toolbar,
  });

  final String? content;
  final TextEditorSubmit onSubmitted;
  final VoidCallback? onClosed;

  final Widget? title;
  final List<Widget>? actions;
  final TextEditorBuilder? preview;
  final TextEditorBuilder? toolbar;

  static const String _contentKey = 'content';

  @override
  Widget build(BuildContext context) {
    return MultiTextEditor(
      content: [TextEditorContent(key: _contentKey, value: content)],
      onSubmitted: (values) => onSubmitted.call(values.first.value!),
      onClosed: onClosed,
      title: title,
      actions: actions,
      preview: preview != null
          ? (context, controllers) =>
                preview!.call(context, controllers[_contentKey]!)
          : null,
      toolbar: toolbar != null
          ? (context, controllers) =>
                toolbar!.call(context, controllers[_contentKey]!)
          : null,
    );
  }
}

class TextEditorContent {
  const TextEditorContent({required this.key, this.title, this.value});

  final String key;
  final String? title;
  final String? value;
}

typedef MultiTextEditorSubmit =
    FutureOr<String?> Function(List<TextEditorContent> values);
typedef MultiTextEditorBuilder =
    Widget Function(
      BuildContext context,
      Map<String, TextEditingController> controllers,
    );

/// An editor page for one or more texts.
///
/// The editors keep their texts in page-local controllers, which closing
/// the page drops. Changes that no successful submit carried home are
/// confirmed first, through the close button or the system back button.
class MultiTextEditor extends StatefulWidget {
  const MultiTextEditor({
    super.key,
    required this.content,
    required this.onSubmitted,
    this.onClosed,
    this.title,
    this.actions,
    this.preview,
    this.toolbar,
  });

  final List<TextEditorContent> content;
  final MultiTextEditorSubmit onSubmitted;
  final VoidCallback? onClosed;

  final Widget? title;
  final List<Widget>? actions;
  final MultiTextEditorBuilder? preview;
  final MultiTextEditorBuilder? toolbar;

  @override
  State<MultiTextEditor> createState() => _MultiTextEditorState();
}

class _MultiTextEditorState extends State<MultiTextEditor> {
  late Map<TextEditorContent, TextEditingController> textControllers = {
    for (final content in widget.content)
      content: TextEditingController(text: content.value),
  };
  Map<String, TextEditingController> get textControllerMap {
    return {
      for (final content in textControllers.keys)
        content.key: textControllers[content]!,
    };
  }

  /// The texts the editors started out with, by content key.
  ///
  /// Closing an editor drops whatever it holds, so texts that no longer
  /// equal these are confirmed before they are lost.
  late final Map<String, String> _initialTexts = {
    for (final content in widget.content) content.key: content.value ?? '',
  };

  late LoadingDialogActionController actionController =
      LoadingDialogActionController();

  /// Whether any editor holds text that closing would lose.
  bool get _isDirty {
    for (final content in textControllers.keys) {
      if (textControllers[content]!.text != _initialTexts[content.key]) {
        return true;
      }
    }
    return false;
  }

  /// Treats the current texts as saved.
  ///
  /// A successful submit carried them home, so closing afterwards needs
  /// no confirmation.
  void _markClean() {
    for (final content in textControllers.keys) {
      _initialTexts[content.key] = textControllers[content]!.text;
    }
  }

  /// Whether a discard confirmation is already on screen.
  ///
  /// The close button and the back gesture both route through [close];
  /// without the guard a rapid double-tap stacks two dialogs, and
  /// confirming the top one pops the other dialog instead of the editor,
  /// which looks like the discard did nothing.
  bool _confirmingDiscard = false;

  /// Closes the editor, confirming first when edits would be lost.
  ///
  /// The close button and the system back button both route through here.
  /// A clean editor closes right away.
  Future<void> close() async {
    if (_confirmingDiscard) return;
    if (_isDirty) {
      _confirmingDiscard = true;
      try {
        if (!await confirmDiscardText(context)) {
          return;
        }
      } finally {
        _confirmingDiscard = false;
      }
    }
    if (!mounted) {
      return;
    }
    // The pop goes straight to the navigator instead of through maybePop:
    // the pop scope blocks maybePop while edits look pending, and a
    // successful submit clears that state without a rebuild, which would
    // leave a maybePop spinning in the scope's handler.
    Navigator.of(context).pop();
  }

  Future<void> submit() async {
    String? error = await widget.onSubmitted([
      for (final content in textControllers.keys)
        TextEditorContent(
          key: content.key,
          title: content.title,
          value: textControllers[content]!.text.trim(),
        ),
    ]);
    if (error != null) {
      throw ActionControllerException(message: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      // The pop scope has to follow the editors' dirty state, which only
      // their controllers know about.
      listenable: Listenable.merge(textControllers.values.toList()),
      builder: (context, child) => PopScope(
        canPop: !_isDirty,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            close();
          }
        },
        child: child!,
      ),
      child: ListenableBuilder(
        listenable: actionController,
        builder: (context, child) {
          Widget scrollView(Widget child) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: defaultActionListPadding.add(
                    const EdgeInsets.all(8),
                  ),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: child,
                  ),
                ),
              ],
            );
          }

          Widget editor() {
            return scrollView(
              Column(
                children: [
                  for (final content in textControllers.keys)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (content.title != null)
                          Text(
                            content.title!,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        TextField(
                          controller: textControllers[content],
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(
                              context,
                            ).editorTypeHere,
                          ),
                          maxLines: null,
                          enabled: !actionController.isLoading,
                          enableIMEPersonalizedLearning: !PrivateTextFields.of(
                            context,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }

          Widget fab() {
            return Builder(
              builder: (context) => FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                onPressed: actionController.isLoading
                    ? null
                    : () async {
                        await actionController.showAndAction(context, submit);
                        if (!actionController.isError) {
                          _markClean();
                          widget.onClosed?.call();
                        }
                      },
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            );
          }

          Map<Widget, Widget>? tabs = {
            Tab(text: AppLocalizations.of(context).editorWrite): editor(),
            if (widget.preview case final preview?)
              Tab(text: AppLocalizations.of(context).editorPreview): scrollView(
                preview(context, textControllerMap),
              ),
          };

          return DefaultTabController(
            length: tabs.length,
            child: Builder(
              builder: (context) {
                TabController tabController = DefaultTabController.of(context);
                return ListenableBuilder(
                  listenable: tabController,
                  builder: (context, child) => Scaffold(
                    floatingActionButtonLocation: Handedness.of(
                      context,
                    ).floatingActionButtonLocation,
                    floatingActionButton: fab(),
                    bottomSheet: tabController.index == 0
                        ? widget.toolbar?.call(context, textControllerMap)
                        : null,
                    body: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                context,
                              ),
                          sliver: DefaultSliverAppBar(
                            pinned: true,
                            leading: ModalRoute.of(context)!.canPop
                                ? CloseButton(onPressed: close)
                                : null,
                            title: widget.title,
                            actions: widget.actions,
                            bottom: tabs.length > 1
                                ? TabBar(
                                    tabs: tabs.keys.toList(),
                                    labelColor: Theme.of(
                                      context,
                                    ).iconTheme.color,
                                    indicatorColor: Theme.of(
                                      context,
                                    ).iconTheme.color,
                                  )
                                : null,
                          ),
                        ),
                      ],
                      body: TabBarView(children: tabs.values.toList()),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

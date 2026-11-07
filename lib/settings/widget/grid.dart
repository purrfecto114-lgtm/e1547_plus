import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

extension GridQuiltDescription on GridQuilt {
  IconData get icon {
    switch (this) {
      case GridQuilt.square:
        return Icons.view_module;
      case GridQuilt.vertical:
        return Icons.view_column;
    }
  }
}

class GridSettingsTile extends StatelessWidget {
  const GridSettingsTile({super.key, required this.state, this.onChange});

  final GridQuilt state;
  final void Function(GridQuilt state)? onChange;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).settingsQuilt),
      subtitle: Text(quiltDescription(context, state)),
      leading: Icon(state.icon),
      onTap: () => showPickerDialog<GridQuilt>(
        context: context,
        title: AppLocalizations.of(context).gridTitle,
        // the icons carry the state, so no check mark is drawn
        options: [
          for (final state in GridQuilt.values)
            PickerOption(
              value: state,
              label: quiltDescription(context, state),
              trailing: Icon(state.icon),
            ),
        ],
        onSelected: (state) => onChange?.call(state),
      ),
    );
  }
}

/// Localized descriptions of grid quilt modes.
String quiltDescription(BuildContext context, GridQuilt quilt) =>
    switch (quilt) {
      GridQuilt.square => AppLocalizations.of(context).quiltSquare,
      GridQuilt.vertical => AppLocalizations.of(context).quiltVertical,
    };

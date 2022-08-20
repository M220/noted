import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:noted/providers/preferences.dart';
import 'package:provider/provider.dart';

/// The route widget of the Settings page
class SettingsPage extends StatefulWidget {
  /// The name of this route that gets used in navigation
  static const routeName = '/settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// The localization instance containing tranlations
  late AppLocalizations _localizations;

  /// Sets the [_localization] variable as it needs context and therefore
  /// can't be initalized in the [initState] method.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizations.settings),
        centerTitle: true,
      ),
      body: ListView(children: [
        // The theme preferences ListTile
        ListTile(
          title: Text(_localizations.theme),
          onTap: () {
            showDialog(
              context: context,
              builder: ((context) {
                ThemeMode? themeMode = context.read<Preferences>().themeMode;

                return AlertDialog(
                  title: Text(_localizations.themeDialogTitle),
                  actions: [
                    TextButton(
                        onPressed: (() => Navigator.pop(context)),
                        child: Text(_localizations.cancelButtonText)),
                    TextButton(
                        onPressed: () {
                          context.read<Preferences>().setTheme(themeMode!);
                          Navigator.pop(context);
                        },
                        child: Text(_localizations.okButtonText))
                  ],
                  content: StatefulBuilder(
                    builder: (context, setStateDialog) => SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<ThemeMode>(
                              title: Text(_localizations.lightTheme),
                              value: ThemeMode.light,
                              groupValue: themeMode,
                              onChanged: ((value) => setStateDialog(() {
                                    themeMode = value;
                                  }))),
                          RadioListTile<ThemeMode>(
                              title: Text(_localizations.darkTheme),
                              value: ThemeMode.dark,
                              groupValue: themeMode,
                              onChanged: ((value) => setStateDialog(() {
                                    themeMode = value;
                                  }))),
                          RadioListTile<ThemeMode>(
                              title: Text(_localizations.systemTheme),
                              value: ThemeMode.system,
                              groupValue: themeMode,
                              onChanged: ((value) => setStateDialog(() {
                                    themeMode = value;
                                  }))),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        const Divider(),
        // The localization preferences ListTile
        ListTile(
          title: Text(_localizations.language),
          onTap: () {
            showDialog(
              context: context,
              builder: ((context) {
                Locale? locale = context.read<Preferences>().locale;

                return AlertDialog(
                  title: Text(_localizations.languageDialogTitle),
                  actions: [
                    TextButton(
                        onPressed: (() => Navigator.pop(context)),
                        child: Text(_localizations.cancelButtonText)),
                    TextButton(
                        onPressed: () {
                          context.read<Preferences>().setLocale(locale!);
                          Navigator.pop(context);
                        },
                        child: Text(_localizations.okButtonText))
                  ],
                  content: StatefulBuilder(
                    builder: (context, setStateDialog) => SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<Locale>(
                              title: Text(_localizations.english),
                              value: const Locale('en'),
                              groupValue: locale,
                              onChanged: ((value) => setStateDialog(() {
                                    locale = value;
                                  }))),
                          RadioListTile<Locale>(
                              title: Text(_localizations.persian),
                              value: const Locale('fa'),
                              groupValue: locale,
                              onChanged: ((value) => setStateDialog(() {
                                    locale = value;
                                  }))),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ]),
    );
  }
}

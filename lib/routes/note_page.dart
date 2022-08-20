import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:noted/data/note.dart';

/// The route widget of the Note page. Awaiting this route may result in a new or modified instance
/// of [Note]. The [note] parameter can be set if an existing note is being modified.
class NotePage extends StatefulWidget {
  /// The name of this route that gets used in navigation
  static const routeName = '/NotePage';

  /// The [Note] instance that is getting modified. Set to null for new Todos.
  final Note? note;

  const NotePage({super.key, this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  /// The [Note] instance received from the widget
  Note? note;

  /// The localization instance containing tranlations
  late AppLocalizations _localizations;

  /// The title of the note
  late String _title;

  /// The details of the note
  late String _details;

  /// The textController for the title's TextField
  late TextEditingController titleController;

  /// The textController for the details' TextField
  late TextEditingController detailsController;

  /// Initializes the needed instance variables
  ///
  /// if [Note] is given to the widget and is thus, not null, [_title] and [_details]
  /// will be assigned to the Note instance variables. If not, defaults will be given.
  /// [_title] will be set as the title TextField's starting text and [_details] will
  /// be set to the detials' TextField. The [note] variable will be set to the given
  /// Note instance.
  @override
  void initState() {
    super.initState();
    _title = widget.note?.title ?? '';
    _details = widget.note?.details ?? '';
    titleController = TextEditingController(text: _title);
    detailsController = TextEditingController(text: _details);
    note = widget.note;
  }

  /// Sets the [_localization] variable as it needs context and therefore
  /// can't be initalized in the [initState] method.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope is used so that when the user pop's the route and returns,
    // the result can be processed and returned. It also supports the Android's back button.
    return WillPopScope(
      onWillPop: () async {
        if (note == null) {
          if (_title.trim().isEmpty && _details.trim().isEmpty) {
            Navigator.pop(context, null);
          } else if (_title.trim().isEmpty) {
            var firstDetailsLine = LineSplitter.split(_details).first;
            if (firstDetailsLine.length <= 36) {
              _title = firstDetailsLine;
            } else {
              _title = firstDetailsLine.substring(0, 36);
            }
            Navigator.pop(context, Note(_title, _details));
          } else {
            Navigator.pop(context, Note(_title, _details));
          }
        } else {
          if (_title.trim().isEmpty && _details.trim().isEmpty) {
            Navigator.pop(context, null);
          } else {
            note?.title = _title;
            note?.details = _details;
            Navigator.pop(context, note);
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: titleController,
                onChanged: (value) => _title = value,
                decoration: InputDecoration(
                  labelText: _localizations.titleTextFieldLabel,
                  hintText: _localizations.titleTextFieldHint,
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                child: TextField(
                  controller: detailsController,
                  onChanged: (value) => _details = value,
                  decoration: InputDecoration(
                    labelText: _localizations.detailsTextFieldLabel,
                    hintText: _localizations.detailsTextFieldHint,
                  ),
                  autofocus: true,
                  maxLines: null,
                  minLines: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dispose of the TextControllers so that memory leak doesn't happen.
  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    super.dispose();
  }
}

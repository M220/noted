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
  /// The textController for the title's TextField
  late TextEditingController _titleController;

  /// The textController for the details' TextField
  late TextEditingController _detailsController;

  /// Initializes the needed instance variables
  ///
  /// if [note] is given to the widget, the default values
  /// of the TextControllers will be assigned to the given values.
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _detailsController = TextEditingController(text: widget.note?.details);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // WillPopScope is used so that when the user pop's the route and returns,
    // the result can be processed and returned. It also supports the Android's back button.
    return WillPopScope(
      onWillPop: () async {
        var title = _titleController.text;
        var details = _detailsController.text;
        final note = widget.note;

        if (title.trim().isEmpty && details.trim().isEmpty) {
          Navigator.pop(context, null);
          return true;
        }

        if (note == null) {
          if (title.trim().isEmpty) {
            final firstDetailsLine = LineSplitter.split(details).first;
            if (firstDetailsLine.length <= 36) {
              title = firstDetailsLine;
            } else {
              title = firstDetailsLine.substring(0, 36);
            }
          }
          Navigator.pop(context, Note(title, details));
        } else {
          note.title = title;
          note.details = details;
          Navigator.pop(context, note);
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
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: localizations.titleTextFieldLabel,
                  hintText: localizations.titleTextFieldHint,
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                child: TextField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    labelText: localizations.detailsTextFieldLabel,
                    hintText: localizations.detailsTextFieldHint,
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
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:noted/constants.dart';
import 'package:noted/data/todo.dart';
import 'package:noted/routes/note_page.dart';
import 'package:noted/routes/settings_page.dart';
import 'package:noted/providers/database.dart';
import 'package:noted/widgets/todo_sheet.dart';
import 'package:provider/provider.dart';

/// The route widget of the Main page.
class MainPage extends StatefulWidget {
  /// The name of this route that gets used in navigation
  static const routeName = '/';

  /// The tab that this page will launch on
  final int tab;

  /// The search input that this page will launch with
  final String query;

  /// Creates a new Main route for the Noted! app.
  const MainPage({
    super.key,
    this.tab = 0,
    this.query = '',
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  /// The TabController that manages the tabs and it's animations
  late TabController _tabController;

  /// The current tab that is being shown. Will be used for FAB's functionality
  late int _currentTabIndex;

  /// The TextController for the notes' search TextField
  final _notesSearchController = TextEditingController();

  /// The TextController for the Todos' search TextField
  final _todosSearchController = TextEditingController();

  /// Set to true when user taps the FAB and false when the user finishes doing so.
  /// Is used for animations
  bool _newEntryBeingMade = false;

  /// Initializes the needed instance variables and sets animation listeners.
  ///
  /// A listener will be added to the [_tabController]'s animation to set the
  /// [_currentTabIndex] to a different index and clear the search fields
  /// if the user is swiping between the tabs, since flutter doesn't change
  /// the TabIndex unless the user taps the TabBar or the swiping animation completes,
  /// which makes the FAB functionality that depends on the current tab, misbehave.
  @override
  void initState() {
    super.initState();
    // Setup the TabController and it's listener.
    _tabController =
        TabController(initialIndex: widget.tab, length: 2, vsync: this);
    _currentTabIndex = _tabController.index;
    _tabController.animation!.addListener(
      () {
        final value = _tabController.animation!.value.round();
        if (value != _currentTabIndex) {
          setState(
              () => _currentTabIndex = _tabController.animation!.value.round());
          switch (_currentTabIndex) {
            case 0:
              context.read<Database>().filterTodos(null);
              _todosSearchController.clear();
              break;
            default:
              context.read<Database>().filterNotes(null);
              _notesSearchController.clear();
          }
        }
      },
    );

    // Fill in the search fields with the query data.
    switch (_currentTabIndex) {
      case 0:
        _notesSearchController.text = widget.query;
        context.read<Database>().filterNotes(widget.query);
        break;
      case 1:
        _todosSearchController.text = widget.query;
        context.read<Database>().filterTodos(widget.query);
    }
  }

  /// Precaches the icon of the app that will be used on the about dialog so that
  /// it doesn't 'pop up' when the dialog gets built for the first time.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(iconAssetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Listener is used so that the search field can unfocus when the user taps
    // outside of the TextField
    return Listener(
      onPointerDown: (_) {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(localizations.title),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(
                localizations.notesTabTitle,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              )),
              Tab(
                  child: Text(
                localizations.todoTabTitle,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              )),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNotesTabView(),
            _buildTodoTabView(),
          ],
        ),
        drawer: Drawer(
          child: ListView(children: [
            DrawerHeader(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary),
                child: Center(
                  child: Text(
                    localizations.title,
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                )),
            ListTile(
              title: Text(localizations.settings),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(SettingsPage.routeName);
              },
              style: ListTileStyle.drawer,
            ),
            const Divider(
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
            ),
            AboutListTile(
              applicationIcon: Image.asset(
                iconAssetPath,
                height: 50,
              ),
              applicationName: localizations.title,
              applicationVersion: localizations.appVersion,
              icon: const Icon(Icons.info),
              aboutBoxChildren: [Text(localizations.aboutDescription)],
            )
          ]),
        ),
        // Wrapped the FAB in an AnimatedPadding instance with bottom viewInsets
        // so that the FAB can animate to the top of the keyboard instead of getting
        // covered by it.
        floatingActionButton: AnimatedPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 150),
          child: FloatingActionButton(
            onPressed: () async {
              setState(() {
                _newEntryBeingMade = true;
              });
              if (_currentTabIndex == 0) {
                context.goNamed(NotePage.routeName);
                setState(() {
                  _notesSearchController.clear();
                  context.read<Database>().filterNotes('');
                  _newEntryBeingMade = false;
                });
              } else if (_currentTabIndex == 1) {
                final todo = await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => const TodoSheet()) as Todo?;
                if (!mounted) return;
                setState(() {
                  _todosSearchController.clear();
                  context.read<Database>().filterTodos('');
                  _newEntryBeingMade = false;
                });
                if (todo == null) return;
                context.read<Database>().addTodo(todo);
              }
            },
            tooltip: localizations.fabTooltip,
            child: const Icon(Icons.mode_edit_rounded),
          ),
        ),
      ),
    );
  }

  /// The notes tab widget
  Consumer<Database> _buildNotesTabView() {
    final localizations = AppLocalizations.of(context);

    return Consumer<Database>(builder: (context, value, child) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _notesSearchController,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                labelText: localizations.searchFieldLabel,
              ),
              onTap: () {
                value.filterNotes(_notesSearchController.text);
              },
              onChanged: (searchValue) {
                value.filterNotes(searchValue);
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _newEntryBeingMade || value.notes.isNotEmpty
                            ? 0
                            : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.event_note_outlined, size: 48),
                              Text(
                                localizations.emptyNoteListText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: value.notes.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: UniqueKey(),
                        startActionPane: ActionPane(
                          dismissible: DismissiblePane(onDismissed: () {
                            value.deleteNote(value.notes[index]);
                          }),
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  value.deleteNote(value.notes[index]),
                              autoClose: true,
                              label: 'Delete',
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              icon: Icons.delete_outline_rounded,
                            )
                          ],
                        ),
                        child: ListTile(
                          shape: const StadiumBorder(),
                          title: Text(value.notes[index].title),
                          subtitle: Text(
                            value.notes[index].details,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onTap: () async {
                            context.goNamed(NotePage.routeName,
                                extra: value.notes[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// The todos tab widget
  Consumer<Database> _buildTodoTabView() {
    final localizations = AppLocalizations.of(context);

    return Consumer<Database>(builder: (context, value, child) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _todosSearchController,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                labelText: localizations.searchFieldLabel,
              ),
              onChanged: (searchValue) {
                value.filterTodos(searchValue);
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _newEntryBeingMade || value.todos.isNotEmpty
                            ? 0
                            : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.checklist_rounded, size: 48),
                              Text(
                                localizations.emptyTodoListText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: value.todos.length,
                    itemBuilder: (context, index) {
                      final checked = value.todos[index].checked;

                      return Slidable(
                        key: ValueKey(value.todos[index].id),
                        startActionPane: ActionPane(
                          dismissible: DismissiblePane(onDismissed: () {
                            value.deleteTodo(value.todos[index]);
                          }),
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  value.deleteTodo(value.todos[index]),
                              autoClose: true,
                              label: 'Delete',
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              icon: Icons.delete_outline_rounded,
                            )
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final todo = await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        TodoSheet(todo: value.todos[index]))
                                as Todo?;
                            if (!mounted) return;
                            if (todo == null) return;
                            context.read<Database>().modifyTodo(todo);
                          },
                          child: CheckboxListTile(
                            value: checked,
                            onChanged: (isChecked) {
                              value.todos[index].checked = isChecked ?? checked;
                              context
                                  .read<Database>()
                                  .modifyTodo(value.todos[index]);
                            },
                            shape: const StadiumBorder(),
                            title: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeOut,
                              style: checked
                                  ? DefaultTextStyle.of(context).style.copyWith(
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.grey,
                                      )
                                  : DefaultTextStyle.of(context).style,
                              child: Text(
                                value.todos[index].title,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// Dispose of the TextControllers and the TabController to avoid memory leak.
  @override
  void dispose() {
    _notesSearchController.dispose();
    _todosSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

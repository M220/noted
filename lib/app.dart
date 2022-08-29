import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noted/data/note.dart';
import 'package:noted/providers/preferences.dart';
import 'package:noted/routes/main_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:noted/routes/note_page.dart';
import 'package:noted/routes/settings_page.dart';
import 'package:noted/app_theme.dart';
import 'package:provider/provider.dart';

/// This class defines the general outline of the app, it's themes, locales, routes
/// and other settings that are related to the class containing the [MaterialApp] instance
class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Preferences>(
      builder: ((_, value, __) {
        // This [AnimatedBuilder} helps gradually change the theme and locales
        // when requested by the user instead of suddenly shifting everything around.
        // it listens to the values provided by the Preferences provider.
        return AnimatedBuilder(
          animation: value,
          builder: (context, _) {
            return MaterialApp.router(
              routeInformationProvider: _router.routeInformationProvider,
              routeInformationParser: _router.routeInformationParser,
              routerDelegate: _router.routerDelegate,
              locale: value.locale,
              onGenerateTitle: (context) => AppLocalizations.of(context).title,
              // These two lines are needed for localizations. They set the supported
              // languages for this app and make the AppLocalizations.of callback available.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: value.themeMode,
            );
          },
        );
      }),
    );
  }

  /// The GoRouter instance that will be used for this app's declarative navigation
  final _router = GoRouter(
    initialLocation: MainPage.routeName,
    urlPathStrategy: UrlPathStrategy.path,
    routes: [
      GoRoute(
          path: MainPage.routeName,
          name: MainPage.routeName,
          pageBuilder: (context, state) =>
              customPageTransition(const MainPage(), state),
          routes: [
            GoRoute(
                path: NotePage.routeName,
                name: NotePage.routeName,
                pageBuilder: (context, state) => customPageTransition(
                    NotePage(note: state.extra as Note?), state)),
            // Use like this: context.goNamed('newNoteWithParams',
            // params: {'title' : 'Example Title', 'details' : 'Example details'});
            GoRoute(
                path: '${NotePage.routeName}/:title&:details',
                name: 'newNoteWithParams',
                pageBuilder: (context, state) {
                  return customPageTransition(
                      NotePage(
                          note: Note(state.params['title']!,
                              state.params['details']!)),
                      state);
                }),
            GoRoute(
              path: SettingsPage.routeName,
              name: SettingsPage.routeName,
              pageBuilder: (context, state) =>
                  customPageTransition(const SettingsPage(), state),
            ),
            // Use like this: context.goNamed('homeWithParams',
            // params: {'tab' : '1'}, queryParams: {'q' : 'query'});
            // Or like this: context.go('/1?q=query');
            GoRoute(
                path: ':tab',
                name: 'homeWithParams',
                builder: (context, state) {
                  final int tab;
                  final String query;
                  tab = state.params.containsKey('tab')
                      ? int.parse(state.params['tab']!)
                      : 0;
                  query = state.queryParams.containsKey('q')
                      ? state.queryParams['q']!
                      : '';
                  return MainPage(
                    tab: tab,
                    query: query,
                  );
                })
          ]),
    ],
  );

  /// Makes a route with a custom slide animation.
  ///
  /// [route] : The route widget that gets animated
  static CustomTransitionPage customPageTransition(
      Widget route, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      restorationId: state.pageKey.value,
      child: route,
      transitionDuration: const Duration(milliseconds: 250),
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
                .animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  }
}

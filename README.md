# Noted!

A simple notes and todo app, written with Flutter. This app is written mostly with Android platform in mind as I don't have access to a Mac, and I also only use windows for testing purposes. Although the app should at least compile for other platforms as well, including Linux, Mac OS, Windows, Web and IOS.

TODO:
- ~~Change the settings page's Dropdowns to Material Alert Dialogs~~
- ~~Add state restoration~~
- Add state restoration tests
- Add sharing functionality
- Complete the widget tests
- Add Undo/Redo

Design and overall suggestions are welcome!

## Branch Specific

This branch will have the functionalities of the base + state restoraion. It will use Navigator 1 functionalities for state restoration.

To test state restoration on Android:

1- Turn on "Don't keep activities", which destroys the Android activity as soon as the user leaves it. This option should become available when Developer Options are turned on for the device.

2- Run the code sample on an Android device.

3- Create some in-memory state in the app on the phone, e.g. by navigating to a different screen.

4- Background the Flutter app, then return to it. It will restart and restore its state.

Note: ModalBottomSheets are currently not supported when it comes to state restoration, so the Todo sheet dialog will not restore it's state. Other parts of the app should restore their state without issue. Dialogs (apparently) also can't restore their content to the previous state. For example if you choose an option in the theme dialog, and then kill the app and restore it, the Dialog Route itself will restore, but your choice will be lost. I have messed around with the API to be able to restore it's state, but it seems like it can also be an API limitation.

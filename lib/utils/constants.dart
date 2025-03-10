import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

const preloader = Center(
  child: CupertinoActivityIndicator(
    radius: 16.0,
  ),
);

const formSpacer = SizedBox(width: 16, height: 16);

const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

const unexpectedErrorMessage = 'Unexpected error occurred.';

final appTheme = CupertinoThemeData(
  primaryColor: CupertinoColors.activeBlue,
  barBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(
      color: CupertinoColors.black,
      fontSize: 16,
    ),
    actionTextStyle: TextStyle(
      color: CupertinoColors.activeBlue,
      fontSize: 16,
    ),
  ),
);

extension ShowCupertinoDialog on BuildContext {
  void showCupertinoDialogMessage({
    required String message,
    Color backgroundColor = const Color.fromARGB(255, 0, 0, 0),
  }) {
    showCupertinoDialog(
      context: this,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Message'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void showErrorCupertinoDialog({required String message}) {
    showCupertinoDialogMessage(
      message: message,
      backgroundColor: CupertinoColors.destructiveRed,
    );
  }
}

class MyCupertinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: appTheme,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Home Page'),
      ),
      child: Padding(
        padding: formPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            preloader,
            formSpacer,
            CupertinoTextField(
              placeholder: 'Enter your message',
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            formSpacer,
            CupertinoButton(
              child: Text('Show Message'),
              color: CupertinoColors.activeBlue,
              onPressed: () {
                context.showCupertinoDialogMessage(
                  message: 'This is a message!',
                );
              },
            ),
            CupertinoButton(
              child: Text('Show Error'),
              color: CupertinoColors.destructiveRed,
              onPressed: () {
                context.showErrorCupertinoDialog(
                  message: 'An error occurred!',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

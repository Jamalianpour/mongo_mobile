import 'package:flutter/material.dart';
import '../Widget/BlinkAnimatedIcon.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationHelper {
  static void showErrorNotification(
      String title, String subTitle, IconData icon,
      {double? size, Alignment? alignment}) {
    alignment ??= const Alignment(-1, 0);
    showOverlayNotification((context) {
      return Align(
        alignment: alignment!,
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      subtitle: Text(subTitle),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          OverlaySupportEntry.of(context)?.dismiss();
                        },
                      ),
                      leading: BlinkAnimatedIcon(
                        icon: icon,
                        startColor: Colors.red[700]!,
                        endColor: Colors.red[100]!,
                        size: size ?? 24,
                      ),
                    ),
                    Container(
                      height: 4,
                      width: 400,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
        duration: const Duration(seconds: 5),
        position: alignment.y == 0
            ? NotificationPosition.top
            : NotificationPosition.bottom);
  }

  static void showWarningNotification(
      String title, String subTitle, IconData icon,
      {double? size, Alignment? alignment}) {
    alignment ??= const Alignment(-1, 0);
    showOverlayNotification((context) {
      return Align(
        alignment: alignment!,
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(color: Colors.amber, fontSize: 18),
                      ),
                      subtitle: Text(subTitle),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          OverlaySupportEntry.of(context)?.dismiss();
                        },
                      ),
                      leading: BlinkAnimatedIcon(
                        icon: icon,
                        startColor: Colors.amber[700]!,
                        endColor: Colors.red[100]!,
                        size: size ?? 24,
                      ),
                    ),
                    Container(
                      height: 4,
                      width: 400,
                      color: Colors.amber,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
        duration: const Duration(seconds: 5),
        position: alignment.y == 0
            ? NotificationPosition.top
            : NotificationPosition.bottom);
  }

  static void showSuccessfulNotification(
      String title, String subTitle, IconData icon,
      {double? size, Alignment? alignment}) {
    alignment ??= const Alignment(-1, 0);
    showOverlayNotification((context) {
      return Align(
        alignment: alignment!,
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        title,
                        style:
                            TextStyle(color: Colors.green[600], fontSize: 18),
                      ),
                      subtitle: Text(subTitle),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          OverlaySupportEntry.of(context)?.dismiss();
                        },
                      ),
                      leading: BlinkAnimatedIcon(
                        icon: icon,
                        startColor: Colors.green[700]!,
                        endColor: Colors.green[100]!,
                        size: size ?? 24,
                      ),
                    ),
                    Container(
                      height: 4,
                      width: 400,
                      color: Colors.green[600],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
        duration: const Duration(seconds: 5),
        position: alignment.y == 0
            ? NotificationPosition.top
            : NotificationPosition.bottom);
  }
}

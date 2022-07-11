import 'package:flutter/material.dart';
import 'package:json_editor/json_editor.dart';
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/Service/Notification.dart';

class InsertDocumentBottomSheet extends StatefulWidget {
  final Function refresh;
  const InsertDocumentBottomSheet({
    Key? key,
    required this.refresh,
  }) : super(key: key);

  @override
  _InsertDocumentBottomSheetState createState() =>
      _InsertDocumentBottomSheetState();
}

class _InsertDocumentBottomSheetState extends State<InsertDocumentBottomSheet> {
  bool isLoading = false;
  JsonElement? document;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: const BorderRadius.all(Radius.circular(35)),
              ),
            ),
          ),
          const Text(
            'Insert document',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Image.asset(
            'assets/images/add_doc.png',
            height: 70,
            width: 70,
          ),
          const Text('Write or paste one or more documents here'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: JsonEditor.string(
                // object: {},
                openDebug: false,
                jsonString: '''
                {
                  // Insert your data here
                  "key":"value"
                }
                ''',
                enabled: true,
                onValueChanged: (value) {
                  document = value;
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 8.0, left: 12.0, right: 12.0),
            child: SizedBox(
              height: 50,
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0)),
                elevation: 5,
                color: Colors.green,
                clipBehavior: Clip.antiAlias,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 50,
                  color: Colors.green,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Insert',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                  onPressed: () {
                    if (document == null) {
                      NotificationHelper.showErrorNotification(
                          'Error', 'document is null', Icons.warning,
                          size: 35, alignment: Alignment.bottomCenter);
                    } else {
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        if (Cache.openCollection.isNotEmpty) {
                          var json = document!.toObject() as Map;
                          var dataMap = Map<String, dynamic>.from(json);
                          Cache.db
                              ?.collection(Cache.openCollection)
                              .insert(dataMap)
                              .then((value) {
                            widget.refresh();
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pop(context);
                          }).onError((e, stackTrace) {
                            setState(() {
                              isLoading = false;
                            });
                            if (e is Map) {
                              NotificationHelper.showErrorNotification(
                                  'Error', e['err'], Icons.warning,
                                  size: 35, alignment: Alignment.bottomCenter);
                            } else {
                              NotificationHelper.showErrorNotification('Error',
                                  (e as dynamic).message, Icons.warning,
                                  size: 35, alignment: Alignment.bottomCenter);
                            }
                          });
                        } else {
                          NotificationHelper.showErrorNotification(
                              'Error', 'No collection selected', Icons.warning,
                              size: 35, alignment: Alignment.bottomCenter);
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        if (e is Map) {
                          NotificationHelper.showErrorNotification(
                              'Error', e['err'], Icons.warning,
                              size: 35, alignment: Alignment.bottomCenter);
                        } else {
                          NotificationHelper.showErrorNotification(
                              'Error', (e as dynamic).message, Icons.warning,
                              size: 35, alignment: Alignment.bottomCenter);
                        }
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

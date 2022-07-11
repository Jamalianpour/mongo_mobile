import 'package:flutter/material.dart';
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/Service/Notification.dart';

class CreateCollectionBottomSheet extends StatefulWidget {
  final Function refresh;
  const CreateCollectionBottomSheet({
    Key? key,
    required this.refresh,
  }) : super(key: key);

  @override
  _CreateCollectionBottomSheetState createState() =>
      _CreateCollectionBottomSheetState();
}

class _CreateCollectionBottomSheetState
    extends State<CreateCollectionBottomSheet> {
  final TextEditingController _name = TextEditingController();
  bool isLoading = false;

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
            'Create new Collection',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Image.asset(
            'assets/images/add_database.png',
            height: 150,
            width: 150,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _name,
              decoration: const InputDecoration(hintText: 'Collection name'),
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
                          'Create',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                  onPressed: () {
                    if (_name.text.isEmpty) {
                      NotificationHelper.showErrorNotification('Error',
                          'Insert a name for collection', Icons.warning,
                          size: 35, alignment: Alignment.bottomCenter);
                    } else {
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        Cache.db?.createCollection(_name.text).then((value) {
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
                            NotificationHelper.showErrorNotification(
                                'Error', (e as dynamic).message, Icons.warning,
                                size: 35, alignment: Alignment.bottomCenter);
                          }
                        });
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

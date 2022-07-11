import 'package:flutter/material.dart';
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/Service/Notification.dart';

class DropCollectionBottomSheet extends StatefulWidget {
  final String name;
  final Function refresh;
  const DropCollectionBottomSheet({
    Key? key,
    required this.name,
    required this.refresh,
  }) : super(key: key);

  @override
  _DropCollectionBottomSheetState createState() =>
      _DropCollectionBottomSheetState();
}

class _DropCollectionBottomSheetState extends State<DropCollectionBottomSheet> {
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
            'Drop Collection',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Image.asset(
            'assets/images/drop_database.png',
            height: 150,
            width: 150,
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'To drop '),
                    TextSpan(
                      text: widget.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' type the collection name '),
                    TextSpan(
                      text: widget.name + '.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              )
              // 'To drop ${widget.name} the database name ${widget.name}.',),
              ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _name,
              decoration: const InputDecoration(hintText: 'Collection name'),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              height: 55,
              elevation: 5,
              disabledColor: Colors.grey[400],
              color: Colors.red[600],
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Drop',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
              onPressed: widget.name != _name.text
                  ? null
                  : () {
                      setState(() {
                        isLoading = true;
                      });
                      Cache.db?.dropCollection(_name.text).then((value) {
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
                    },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionHistoryWidget extends StatefulWidget {
  final Function connectToDb;
  const ConnectionHistoryWidget({
    Key? key,
    required this.history,
    required this.connectToDb,
  }) : super(key: key);

  final List<String> history;

  @override
  State<ConnectionHistoryWidget> createState() =>
      _ConnectionHistoryWidgetState();
}

class _ConnectionHistoryWidgetState extends State<ConnectionHistoryWidget> {
  late SharedPreferences _sharedPreferences;

  void _removeItem(String item) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      widget.history.remove(item);
    });
    _sharedPreferences.setStringList('history', widget.history);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Material(
        elevation: 3,
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/history_database.png',
                    height: 40,
                  ),
                ],
              ),
              widget.history.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/cloud_database.png',
                              height: 150,
                            ),
                            Text(
                              'No history found',
                              style: Theme.of(context).textTheme.subtitle2,
                            )
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.history.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(onDismissed: () {}),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    _removeItem(widget.history[index]);
                                  },
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                widget.history[index],
                                // maxLines: 1,
                                // overflow: TextOverflow.ellipsis,
                                style: const TextStyle(height: 1.4),
                              ),
                              leading: const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.access_time_rounded),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              onTap: () {
                                widget.connectToDb(widget.history[index]);
                              },
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            height: 10,
                            indent: 12,
                            endIndent: 8,
                          );
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/View/CollectionDataPageView.dart';
import 'package:mongo_mobile/Widget/BottomSheet/CreateCollectionBottomSheet.dart';
import 'package:mongo_mobile/Widget/BottomSheet/DropCollectionBottomSheet.dart';

class CollectionsListPageView extends StatefulWidget {
  final List<Map<String, dynamic>> collections;

  const CollectionsListPageView({
    Key? key,
    required this.collections,
  }) : super(key: key);

  @override
  _CollectionsListPageViewState createState() =>
      _CollectionsListPageViewState();
}

class _CollectionsListPageViewState extends State<CollectionsListPageView> {
  late List<Map<String, dynamic>> collections;

  @override
  void initState() {
    super.initState();
    collections = widget.collections;
  }

  void _refreshCollectionsList() {
    Cache.db?.getCollectionInfos().then((value) {
      setState(() {
        collections = value;
      });
    });
  }

  Future<int> _getCollectionCount(String collectionName) async {
    int? count = await Cache.db?.collection(collectionName).count();
    return count ?? 0;
  }

  Future<int> _getCollectionIndexes(String collectionName) async {
    var indexes = await Cache.db?.collection(collectionName).getIndexes();
    if (indexes != null) return indexes.length;
    return 0;
  }

  Future<String> _getCollectionInfo(String collectionName) async {
    String info = '';
    info = 'count: ${await _getCollectionCount(collectionName)}\n';
    info += 'indexes: ${await _getCollectionIndexes(collectionName)}';
    return info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        centerTitle: true,
        leading: Tooltip(
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Cache.db?.close();
              },
              child: Image.asset('assets/images/disconnected.png', height: 24)),
          message: 'disconnect',
        ),
        actions: [
          IconButton(
              icon: const FaIcon(FontAwesomeIcons.infoCircle),
              onPressed: () async {
                Map<String, dynamic>? buildInfo =
                    await Cache.db?.getBuildInfo();
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text('MongoMobile'),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      children: [
                        Text('MongoDB Version: ${buildInfo!['version']}'),
                        const SizedBox(height: 4),
                        Text('Database Name: ${Cache.db?.databaseName}'),
                        const SizedBox(height: 4),
                        Text(
                            'Host Url: ${Cache.db?.masterConnection.serverConfig.hostUrl}'),
                        const SizedBox(height: 4),
                        Text(
                            'Is Standalone: ${Cache.db?.masterConnection.serverCapabilities.isStandalone}'),
                        const SizedBox(height: 4),
                        Text('Is connected: ${Cache.db?.isConnected}'),
                        const SizedBox(
                          height: 12,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Ok'))
                      ],
                    );
                  },
                );
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15.0),
              ),
            ),
            builder: (context) {
              return CreateCollectionBottomSheet(
                refresh: _refreshCollectionsList,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return Slidable(
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(onDismissed: () {}),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15.0),
                        ),
                      ),
                      builder: (context) {
                        return DropCollectionBottomSheet(
                          name: collections[index]['name'],
                          refresh: _refreshCollectionsList,
                        );
                      },
                    );
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Drop',
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                collections[index]['name'],
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.green[800]),
              ),
              // subtitle: Text('readOnly : ' + collections[index]['info']['readOnly'].toString()),
              subtitle: FutureBuilder(
                future: _getCollectionInfo(collections[index]['name']),
                builder: (buildContext, asyncSnapshot) {
                  if (asyncSnapshot.hasData) {
                    // return Text('count: ${asyncSnapshot.data}');
                    return Text('${asyncSnapshot.data}');
                  }
                  return const SizedBox();
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectionDataPageView(
                        collectionName: collections[index]['name']),
                  ),
                );
              },
              leading: const FaIcon(FontAwesomeIcons.database),
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15.0),
                    ),
                  ),
                  builder: (context) {
                    return DropCollectionBottomSheet(
                      name: collections[index]['name'],
                      refresh: _refreshCollectionsList,
                    );
                  },
                );
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 12,
            indent: 60,
            endIndent: 12,
          );
        },
        itemCount: collections.length,
      ),
    );
  }
}

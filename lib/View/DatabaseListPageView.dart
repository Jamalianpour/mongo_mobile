import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/View/CollectionsListPageView.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class DatabaseListPageView extends StatefulWidget {
  final List<dynamic> databases;

  const DatabaseListPageView({
    Key? key,
    required this.databases,
  }) : super(key: key);

  @override
  _DatabaseListPageViewState createState() => _DatabaseListPageViewState();
}

class _DatabaseListPageViewState extends State<DatabaseListPageView> {
  late List<dynamic> databases;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    databases = widget.databases;
    Cache.mongoBaseUri = Cache.mongoUri;
  }

  Future<List<Map<String, dynamic>>?> _getCollectionInfo(
      String databaseName) async {
    setState(() {
      isLoading = true;
    });
    Cache.mongoUri = Cache.mongoBaseUri;
    Cache.db?.close();
    if (Cache.mongoUri.contains('?')) {
      Cache.mongoUri = Cache.mongoUri.replaceFirst('?', databaseName + '?');
    } else {
      Cache.mongoUri += '/$databaseName';
    }
    Cache.db = Mongo.Db(Cache.mongoUri);
    await Cache.db?.open();
    setState(() {
      isLoading = false;
    });
    return await Cache.db?.getCollectionInfos();
  }

  Future _connectToDb() async {
    Cache.mongoUri = Cache.mongoBaseUri;
    Cache.db = Mongo.Db(Cache.mongoUri);
    await Cache.db?.open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Databases'),
        centerTitle: true,
        elevation: 0,
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
                setState(() {
                  isLoading = true;
                });
                await _connectToDb();
                Map<String, dynamic>? buildInfo =
                    await Cache.db?.getBuildInfo();
                setState(() {
                  isLoading = false;
                });
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
      backgroundColor: Colors.green,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(
            top: Radius.elliptical(20, 16),
          ),
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return Slidable(
              child: ListTile(
                title: Text(databases[index]),
                // subtitle: Text('readOnly : ' + collections[index]['info']['readOnly'].toString()),
                onTap: () async {
                  var list = await _getCollectionInfo(databases[index]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionsListPageView(
                        collections: list!,
                      ),
                    ),
                  );
                },
                leading: const FaIcon(FontAwesomeIcons.database),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              height: 12,
              indent: 50,
              endIndent: 8,
            );
          },
          itemCount: databases.length,
        ),
      ),
      floatingActionButton: isLoading
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            )
          : null,
    );
  }
}

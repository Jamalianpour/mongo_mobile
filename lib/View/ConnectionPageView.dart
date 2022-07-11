import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:mongo_mobile/View/DatabaseListPageView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/Service/Notification.dart';
import 'package:mongo_mobile/View/CollectionsListPageView.dart';
import 'package:mongo_mobile/Widget/ConnectionHistoryWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectionPageView extends StatefulWidget {
  const ConnectionPageView({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _ConnectionPageViewState createState() => _ConnectionPageViewState();
}

class _ConnectionPageViewState extends State<ConnectionPageView> {
  bool isLoading = false;
  TextEditingController mongoUri = TextEditingController();
  List<String> history = [];
  late SharedPreferences _sharedPreferences;

  @override
  void initState() {
    _readData();
    super.initState();
  }

  void _readData() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      history = _sharedPreferences.getStringList('history') ?? [];
    });
  }

  void _aboutMe() async {
    await launchUrl(Uri.parse('https://github.com/Jamalianpour/mongo_mobile'));
  }

  void _connectToMongo(String uri) async {
    if (uri.isEmpty) {
      NotificationHelper.showErrorNotification(
          'Error', 'Connection string should be empty', Icons.warning,
          size: 35, alignment: Alignment.bottomCenter);
    } else {
      try {
        setState(() {
          isLoading = true;
        });
        Cache.db = Mongo.Db(uri);
        Cache.mongoUri = uri;
        await Cache.db?.open().timeout(const Duration(seconds: 20),
            onTimeout: () {
          NotificationHelper.showErrorNotification(
              'Error', 'Connection time out!!!', Icons.warning,
              size: 35, alignment: Alignment.bottomCenter);
          setState(() {
            isLoading = false;
          });
        }).onError((error, stackTrace) {
          NotificationHelper.showErrorNotification(
              'Error', stackTrace.toString(), Icons.warning,
              size: 35, alignment: Alignment.bottomCenter);
          setState(() {
            isLoading = false;
          });
        });
        if (Cache.db?.databaseName == "test") {
          List<dynamic>? databases = await Cache.db?.listDatabases();
          if (databases != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DatabaseListPageView(
                  databases: databases,
                ),
              ),
            );
          }
        } else {
          List<Map<String, dynamic>>? colInfo =
              await Cache.db?.getCollectionInfos();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollectionsListPageView(
                collections: colInfo!,
              ),
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
        List<String> history =
            _sharedPreferences.getStringList('history') ?? [];
        if (history.contains(uri)) {
          history.remove(uri);
        }
        history.insert(0, uri);
        _sharedPreferences.setStringList('history', history);
        _readData();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ''),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.green,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(
            top: Radius.elliptical(20, 16),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Material(
                        color: Colors.white,
                        elevation: 3,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'New connection',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    'assets/images/add_database.png',
                                    height: 40,
                                  ),
                                ],
                              ),
                              TextField(
                                controller: mongoUri,
                                decoration: const InputDecoration(
                                    hintText: 'Connection string'),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _connectToMongo(mongoUri.text),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('connect'),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    ConnectionHistoryWidget(
                      history: history,
                      connectToDb: _connectToMongo,
                    )
                  ],
                ),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 8,
                            ),
                            Text('please wait...')
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _aboutMe,
        child: const Icon(Icons.question_mark),
      ),
    );
  }
}

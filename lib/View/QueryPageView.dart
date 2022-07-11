import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/Service/Notification.dart';
import 'package:mongo_mobile/Widget/JsonViewerWidget.dart';
import 'package:mongo_mobile/Widget/PaginationWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class QueryPageView extends StatefulWidget {
  const QueryPageView({Key? key}) : super(key: key);

  @override
  State<QueryPageView> createState() => _QueryPageViewState();
}

class _QueryPageViewState extends State<QueryPageView> {
  final TextEditingController query = TextEditingController();
  List<Map<String, dynamic>> data = [];
  bool isLoading = false;
  int limit = 10;
  int page = 1;
  int totalDocument = 1;

  void _executeQuery(String query) async {
    try {
      if (query.isEmpty) {
        NotificationHelper.showWarningNotification(
            'Warning', 'query can not be empty!', Icons.warning,
            size: 33, alignment: Alignment.bottomCenter);
      } else {
        setState(() {
          isLoading = true;
        });
        Map valueMap = json.decode(query);
        Cache.db
            ?.collection(Cache.openCollection)
            .find(valueMap
                // {
                //   'id': '60576c1068bf14c6620fa8ce',
                //   // 'rating': {r'$gt': 10}
                // },
                )
            .toList()
            .then((value) {
          setState(() {
            data = value;
            isLoading = false;
          });
        }).onError((error, stackTrace) {
          setState(() {
            isLoading = false;
          });
          NotificationHelper.showErrorNotification(
              'Error', stackTrace.toString(), Icons.error,
              size: 33, alignment: Alignment.bottomCenter);
        });
      }
    } catch (exception) {
      setState(() {
        isLoading = false;
      });
      NotificationHelper.showErrorNotification(
          'Error', exception.toString(), Icons.error,
          size: 33, alignment: Alignment.bottomCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Search'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 75),
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: query,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: '{"field": "value"}',
                  labelText: "Write your query here",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _executeQuery(query.text);
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _dataBody(context))
        ],
      ),
    );
  }

  Widget _dataBody(BuildContext context) {
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [CircularProgressIndicator(), Text('Please wait...')],
      );
    } else if (!isLoading && data.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Image.asset(
              'assets/images/search.png',
              height: 300,
              width: 300,
            ),
          ),
          Text(
            'No data found to display here',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
                onPressed: () async {
                  await launchUrl(Uri.parse(
                      'https://www.mongodb.com/docs/manual/tutorial/query-documents/#specify-equality-condition'));
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Query Guide'),
                )),
          ),
          const SizedBox(
            height: 80,
          ),
        ],
      );
    } else if (!isLoading && data.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: JsonViewerWidget(data[index], false),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  // height: 12,
                  indent: 8,
                  endIndent: 8,
                );
              },
              itemCount: data.length,
            ),
          ),
          const Divider(
            height: 0,
            color: Colors.grey,
            thickness: 0.6,
          ),
          SizedBox(
            height: 45,
            child: PaginationWidget(
              itemsCount: data.length,
              totalDocument: totalDocument,
              nextButton: () {
                setState(() {
                  isLoading = true;
                  page++;
                });
                // _readData();
              },
              previousButton: () {
                setState(() {
                  isLoading = true;
                  page--;
                });
                // _readData();
              },
              refreshButton: () {
                // _readData();
              },
              currentPage: page,
              pageSize: limit,
              goto: () {},
              showButtons: false,
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Error',
            style: TextStyle(
                fontSize: 30,
                color: Colors.red[600],
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}

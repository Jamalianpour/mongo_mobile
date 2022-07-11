import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:mongo_mobile/Global/Cache.dart';
import 'package:mongo_mobile/Service/Notification.dart';
import 'package:mongo_mobile/Widget/JsonViewerWidget.dart';
import 'package:mongo_mobile/Widget/PaginationWidget.dart';

class CollectionDataPageView extends StatefulWidget {
  final String collectionName;

  const CollectionDataPageView({
    Key? key,
    required this.collectionName,
  }) : super(key: key);
  @override
  _CollectionDataPageViewState createState() => _CollectionDataPageViewState();
}

class _CollectionDataPageViewState extends State<CollectionDataPageView> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;
  int limit = 10;
  int page = 1;
  int totalDocument = 1;

  @override
  void initState() {
    _readData();
    Cache.openCollection = widget.collectionName;
    super.initState();
  }

  void _readData() async {
    Cache.db
        ?.collection(widget.collectionName)
        .find(Mongo.where.limit(limit).skip((page - 1) * limit))
        .toList()
        .then((value) {
      setState(() {
        isLoading = false;
        data = value;
      });
    });
    _getCollectionCount(widget.collectionName);
  }

  void _goto({required int page}) {
    if (page > (totalDocument / limit).ceil()) {
      NotificationHelper.showErrorNotification(
        'Error',
        'This page does not exist. Enter a number lower than ${(totalDocument / limit).ceil()}',
        Icons.warning,
        size: 35,
        alignment: Alignment.bottomCenter,
      );
    } else {
      setState(() {
        isLoading = true;
      });
      this.page = page;
      _readData();
    }
  }

  Future _getCollectionCount(String collectionName) async {
    int? count = await Cache.db?.collection(collectionName).count();
    setState(() {
      totalDocument = count ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.collectionName),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Column(
                children: const [CircularProgressIndicator(), Text('Please wait...')],
              ),
            )
          : Column(
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
                      _readData();
                    },
                    previousButton: () {
                      setState(() {
                        isLoading = true;
                        page--;
                      });
                      _readData();
                    },
                    refreshButton: () {
                      _readData();
                    },
                    currentPage: page,
                    pageSize: limit,
                    goto: _goto,
                    showButtons: true,
                  ),
                ),
              ],
            ),
    );
  }
}

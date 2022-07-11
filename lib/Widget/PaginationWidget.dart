import 'package:flutter/material.dart';
import 'package:mongo_mobile/View/QueryPageView.dart';
import 'package:mongo_mobile/Widget/BottomSheet/InsertDocumentBottomSheet.dart';
import 'package:mongo_mobile/Widget/Dialog/GotoDialog.dart';

class PaginationWidget extends StatelessWidget {
  final Function nextButton;
  final Function previousButton;
  final Function refreshButton;
  final Function goto;
  final int currentPage;
  final int itemsCount;
  final int pageSize;
  final int totalDocument;
  final bool showButtons;
  const PaginationWidget({
    Key? key,
    required this.nextButton,
    required this.previousButton,
    required this.refreshButton,
    required this.goto,
    required this.currentPage,
    required this.itemsCount,
    required this.pageSize,
    required this.totalDocument,
    required this.showButtons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showButtons) ...[
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QueryPageView(),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                tooltip: 'search',
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return GotoDialog(
                        goto: goto,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.arrow_upward),
                tooltip: 'go to',
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
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
                      return InsertDocumentBottomSheet(
                        refresh: refreshButton,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add),
                tooltip: 'insert',
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                onPressed: () => refreshButton(),
                icon: const Icon(Icons.refresh),
                tooltip: 'refresh',
                padding: const EdgeInsets.all(0),
              ),
            ],
            const Spacer(),
            IconButton(
              onPressed: currentPage <= 1 ? null : () => previousButton(),
              icon: const Icon(Icons.navigate_before),
              padding: const EdgeInsets.all(0),
              tooltip: 'previous',
              disabledColor: Colors.grey,
            ),
            Text(
                '${(totalDocument / pageSize).ceil()} / ${currentPage.toString()}'),
            IconButton(
              onPressed: itemsCount == 10 ? () => nextButton() : null,
              icon: const Icon(Icons.navigate_next),
              tooltip: 'next',
              padding: const EdgeInsets.all(0),
            ),
          ],
        ),
      ),
    );
  }
}

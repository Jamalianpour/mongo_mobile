import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GotoDialog extends StatelessWidget {
  final Function goto;
  const GotoDialog({
    Key? key,
    required this.goto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController pageNumber = TextEditingController();
    return AlertDialog(
      title: const Text('Go to'),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      elevation: 30,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/goto.png',
            color: Colors.green[700],
            height: 80,
            width: 80,
          ),
          TextField(
            controller: pageNumber,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            goto(page: int.parse(pageNumber.text));
            Navigator.pop(context);
          },
          child: const Text('GO'),
        ),
      ],
    );
  }
}

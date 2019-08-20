import 'package:flutter/material.dart';

class NotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const Text('oops not found'),
      ),
    );
  }
}

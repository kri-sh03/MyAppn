import 'package:flutter/material.dart';

/// Flutter code sample for [Scrollbar].

void main() => runApp(const ScrollbarExampleApp());

class ScrollbarExampleApp extends StatelessWidget {
  const ScrollbarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Scrollbar Sample')),
        body: const ScrollbarExample(),
      ),
    );
  }
}

class ScrollbarExample extends StatelessWidget {
  const ScrollbarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          itemCount: 9,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    color: Colors.red,
                    height: 30,
                  ),
                  Container(
                    color: Colors.amber,
                    height: 30,
                  ),
                ],
              ),
            );
          },
        ));
  }
}

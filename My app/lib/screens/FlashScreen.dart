// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/screens/loginwithpass.dart';
import 'package:page_transition/page_transition.dart';

class FlashSCreenPage extends StatefulWidget {
  const FlashSCreenPage({super.key});
  @override
  State<FlashSCreenPage> createState() => _FlashSCreenPageState();
}

class _FlashSCreenPageState extends State<FlashSCreenPage> {
  animation() async {
    await Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: const LoginPage(), type: PageTransitionType.fade));
    });
  }

  @override
  void initState() {
    super.initState();
    animation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/Novo_Animation .gif",
            ),
          )
        ],
      ),
    );
  }
}

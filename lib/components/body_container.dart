import 'package:flutter/material.dart';

class BodyContainer extends StatelessWidget {
  final Widget bodyContent;
  final double size;
  const BodyContainer({Key? key, required this.bodyContent, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 12, left: 12, top: 20, bottom: 10),
      height: size,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50), topRight: Radius.circular(50)),
        color: Colors.white,
      ),
      child: bodyContent,
    );
  }
}

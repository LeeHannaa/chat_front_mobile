import 'package:flutter/material.dart';

void moveScroll(ScrollController controller) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    }
  });
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../gen/assets.gen.dart';
import '../modules/screens/settings_screen.dart';
import '../utils/page_transitions.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          RightToLeftFadeTransition(page: SettingsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
        ),
        child:Assets.icons.icSettings.svg(
          colorFilter: ColorFilter.mode(context.theme.colorScheme.onSurface, BlendMode.srcIn)
        )
      ),
    );
  }
}
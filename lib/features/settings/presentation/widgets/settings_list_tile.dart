import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Function()? onTap;

  const SettingsListTile({
    Key? key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 35,
              child: leading,
            ),
          ],
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onTap,
      ),
    );
  }
}
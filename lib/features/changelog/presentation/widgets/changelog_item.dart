import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'change_type_tag.dart';

class ChangelogItem extends StatelessWidget {
  final Map release;
  final bool bottomPadding;

  const ChangelogItem(
    this.release, {
    Key? key,
    this.bottomPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding ? 8 : 0),
      child: Card(
        margin: const EdgeInsets.all(0),
        color: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    release['version'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    release['date'],
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
              const Divider(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: release['changes']
                    .map<Widget>(
                      (change) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ChangeTypeTag(change['type']),
                            const Gap(8),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(change['detail']),
                                  if (change['additional'] != null)
                                    Text(
                                      change['additional'],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .color,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
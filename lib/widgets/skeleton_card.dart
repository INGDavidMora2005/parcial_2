import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;

  const SkeletonCard({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.business)),
          title: const Text('Nombre del establecimiento'),
          subtitle: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NIT: 0000000000'),
              Text('Dirección: Calle ejemplo 123'),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

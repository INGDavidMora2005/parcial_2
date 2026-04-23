import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;

  const SkeletonCard({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SizedBox(
        height: height,
        child: Skeletonizer(
          enabled: true,
          child: height != null
              ? const SizedBox.expand()
              : const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.business)),
                  title: Text('Nombre del establecimiento'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NIT: 0000000000'),
                      Text('Dirección: Calle ejemplo 123'),
                    ],
                  ),
                  isThreeLine: true,
                ),
        ),
      ),
    );
  }
}

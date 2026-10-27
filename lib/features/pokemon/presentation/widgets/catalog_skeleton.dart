import r'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CatalogSkeleton extends StatelessWidget {
  const CatalogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Skeletonizer(
      enabled: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 290 * textScale,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Bone.square(size: 150),
                      const SizedBox(height: 8),
                      Bone.text(words: 1),
                      const SizedBox(height: 6),
                      Bone.text(words: 2),
                      const SizedBox(height: 8),
                      const Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Bone.button(width: 56, height: 22),
                          Bone.button(width: 56, height: 22),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

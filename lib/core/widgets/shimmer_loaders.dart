import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/responsive_config.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}

class ShimmerListLoading extends StatelessWidget {
  final int itemCount;
  const ShimmerListLoading({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: EdgeInsets.all(16.rw),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 16.rh),
        child: ShimmerLoading(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60.rw,
                height: 60.rh,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              SizedBox(width: 16.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.rh,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.rh),
                    Container(
                      width: 150.rw,
                      height: 12.rh,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.rh),
                    Container(
                      width: 100.rw,
                      height: 12.rh,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerCardLoading extends StatelessWidget {
  const ShimmerCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: double.infinity,
        height: 150.rh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

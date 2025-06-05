import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyCleanSlidableAction extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const MyCleanSlidableAction({
    Key? key,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final state = Slidable.of(context);
          state?.close();
          await Future.delayed(const Duration(milliseconds: 250));
          onTap();
        },
        child: child,
      ),
    );
  }
}

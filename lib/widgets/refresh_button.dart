import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isRefreshing;
  
  const RefreshButton({
    super.key,
    required this.onRefresh,
    required this.isRefreshing,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: isRefreshing 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.refresh),
      onPressed: isRefreshing ? null : onRefresh,
    );
  }
}
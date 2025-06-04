import 'package:flutter/material.dart';

class TaskProgressCard extends StatefulWidget {
  const TaskProgressCard({super.key});

  @override
  _TaskProgressCardState createState() => _TaskProgressCardState();
}

class _TaskProgressCardState extends State<TaskProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of the animation
    );
    _animation = Tween<double>(
      begin: 0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Text(
                'Snapchat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                ),
              ),
              Spacer(),
              Icon(Icons.more_horiz, color: Colors.black),
            ],
          ),
          const Text(
            'TASK APP DESIGN',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const Text(
            'Lorem ipsum dolor sit amet,',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w100,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _animation.value,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                borderRadius: BorderRadius.circular(10),
              );
            },
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                '10/11/2024 - 14/11/2024',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w100,
                ),
              ),
              Spacer(),
              Text(
                '82%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

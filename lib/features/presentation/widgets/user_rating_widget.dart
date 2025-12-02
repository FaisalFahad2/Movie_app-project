import 'package:flutter/material.dart';

class UserRatingWidget extends StatefulWidget {
  final double? currentUserRating;
  final Function(double) onRate;

  const UserRatingWidget({
    super.key,
    this.currentUserRating,
    required this.onRate,
  });

  @override
  State<UserRatingWidget> createState() => _UserRatingWidgetState();
}

class _UserRatingWidgetState extends State<UserRatingWidget> {
  double _selectedRating = 5.0;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.currentUserRating ?? 5.0;
  }

  @override
  void didUpdateWidget(UserRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUserRating != widget.currentUserRating) {
      setState(() {
        _selectedRating = widget.currentUserRating ?? 5.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Rating",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _selectedRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _selectedRating,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            activeColor: const Color(0xFF1F6FEB),
            inactiveColor: Colors.grey[700],
            onChanged: (value) {
              setState(() {
                _selectedRating = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onRate(_selectedRating);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F6FEB),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.currentUserRating == null ? "Submit Rating" : "Update Rating",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

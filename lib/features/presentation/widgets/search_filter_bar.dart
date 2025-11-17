import 'package:flutter/material.dart';

class SearchAndFilterBar extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<int?>? onGenreSelected;
  final ValueChanged<double>? onRatingChanged;

  const SearchAndFilterBar({
    Key? key,
    this.onSearchChanged,
    this.onGenreSelected,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  double _rating = 0;
  int? _selectedGenre;

  final Map<int, String> genresMap = {
    28: "Action",
    12: "Adventure",
    16: "Animation",
    35: "Comedy",
    18: "Drama",
    14: "Fantasy",
    27: "Horror",
    878: "Sci-Fi",
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔎 Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search movies...",
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF161B22),
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        // 🎭 Genre Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<int>(
            dropdownColor: const Color(0xFF161B22),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF161B22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            value: _selectedGenre,
            hint: const Text(
              "Filter by Genre",
              style: TextStyle(color: Colors.white54),
            ),
            items: genresMap.entries.map((e) {
              return DropdownMenuItem<int>(
                value: e.key,
                child: Text(
                  e.value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGenre = value;
              });
              widget.onGenreSelected?.call(value);
            },
          ),
        ),

        const SizedBox(height: 12),

        // ⭐ Rating slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Minimum Rating",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Slider(
              value: _rating,
              min: 0,
              max: 10,
              divisions: 10,
              label: "${_rating.toStringAsFixed(1)}⭐",
              activeColor: Colors.blueAccent,
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
                widget.onRatingChanged?.call(value);
              },
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../services/location_search_service.dart';
import 'package:flutter/services.dart';

class LocationSearchField extends StatefulWidget {
  final Function(String city, double? lat, double? lon) onLocationSelected;
  final TextEditingController controller;

  const LocationSearchField({
    super.key,
    required this.onLocationSelected,
    required this.controller,
  });

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final LocationSearchService _searchService = LocationSearchService();
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text;
    if (query.length >= 2) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults = [];
      });
      _removeOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay to allow tap on suggestion
      Future.delayed(const Duration(milliseconds: 200), () {
        _removeOverlay();
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);

    final results = await _searchService.searchLocations(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      if (results.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 20,
        right: 20,
        top: _getOverlayTop(),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.black87,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 20,
                  ),
                  title: Text(
                    result.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: Text(
                    result.state != null
                        ? '${result.state}, ${result.country}'
                        : result.country,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.controller.text = result.name;
                    widget.onLocationSelected(
                      result.name,
                      result.lat,
                      result.lon,
                    );
                    _removeOverlay();
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getOverlayTop() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return 100;
    final position = renderBox.localToGlobal(Offset.zero);
    return position.dy + renderBox.size.height + 4;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Search city (e.g., Abidjan)",
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 15,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        suffixIcon: _isSearching
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

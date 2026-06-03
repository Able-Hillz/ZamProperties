import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SimpleLocationPicker extends StatefulWidget {
  final Function(String address, String? mapsLink) onLocationSelected;
  final String? initialAddress;

  const SimpleLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialAddress,
  });

  @override
  State<SimpleLocationPicker> createState() => _SimpleLocationPickerState();
}

class _SimpleLocationPickerState extends State<SimpleLocationPicker> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  bool _addMapsLink = false;
  final TextEditingController _mapsLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _addressController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _mapsLinkController.dispose();
    super.dispose();
  }

  void _confirmLocation() {
    String fullAddress = _addressController.text.trim();
    
    if (_landmarkController.text.isNotEmpty) {
      fullAddress += ' (Near: ${_landmarkController.text})';
    }
    
    String? mapsLink = _addMapsLink && _mapsLinkController.text.isNotEmpty
        ? _mapsLinkController.text.trim()
        : null;
    
    widget.onLocationSelected(fullAddress, mapsLink);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Location'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'e.g., Plot 123, Woodlands, Lusaka',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Nearby Landmark (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _landmarkController,
              decoration: InputDecoration(
                hintText: 'e.g., Near Shoprite, Opposite Post Office',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
               // prefixIcon: const Icon(Icons.landmark),
              ),
            ),
            const SizedBox(height: 16),
            
            const Divider(),
            
            CheckboxListTile(
              title: const Text('Add Google Maps Link'),
              subtitle: const Text('Share exact location via Google Maps'),
              value: _addMapsLink,
              onChanged: (value) {
                setState(() {
                  _addMapsLink = value ?? false;
                });
              },
            ),
            
            if (_addMapsLink) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _mapsLinkController,
                decoration: InputDecoration(
                  hintText: 'https://maps.app.goo.gl/...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'How to get Google Maps link: Open Google Maps, tap and hold on location, tap "Share" or "Copy link"',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Tips for good location description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Include street name or plot number'),
                  Text('• Mention nearby landmarks'),
                  Text('• Be specific but respect privacy'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
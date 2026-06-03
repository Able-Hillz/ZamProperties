import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class LocationDisplay extends StatelessWidget {
  final String? address;
  final String? googleMapsLink;

  const LocationDisplay({
    super.key,
    this.address,
    this.googleMapsLink,
  });

  Future<void> _openMaps() async {
    if (googleMapsLink != null && googleMapsLink!.isNotEmpty) {
      final Uri url = Uri.parse(googleMapsLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback: search address on Google Maps
        final searchUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address ?? '')}');
        if (await canLaunchUrl(searchUrl)) {
          await launchUrl(searchUrl);
        }
      }
    } else if (address != null && address!.isNotEmpty) {
      // Search address on Google Maps
      final searchUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address!)}');
      if (await canLaunchUrl(searchUrl)) {
        await launchUrl(searchUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (address == null || address!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _openMaps,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          googleMapsLink != null ? 'Tap to open in Google Maps' : 'Tap to view on map',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
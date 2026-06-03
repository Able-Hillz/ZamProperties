import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DataSaverService {
  static const String _key = 'data_saver_enabled';
  static const String _imageQualityKey = 'image_quality';
  
  // Quality levels (1-100, where 1 is lowest quality)
  static const Map<String, int> qualityLevels = {
    'Low (Save Data)': 30,
    'Medium (Balanced)': 60,
    'High (Best Quality)': 100,
  };
  
  // Image cache limits
  static const int maxCacheSizeMB = 50;
  
  static get FlutterImageCompress => null;
  
  // Check if data saver is enabled
  static Future<bool> isDataSaverEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
  
  // Toggle data saver mode
  static Future<void> setDataSaverEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
  
  // Get image quality setting
  static Future<int> getImageQuality() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_imageQualityKey) ?? 60;
  }
  
  // Set image quality
  static Future<void> setImageQuality(int quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_imageQualityKey, quality);
  }
  
  // Compress image for upload/download
  static Future<File?> compressImage(File file, {int? quality}) async {
    if (!await isDataSaverEnabled()) return file;
    
    final qualityValue = quality ?? await getImageQuality();
    
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.absolute.path}_compressed.jpg',
      quality: qualityValue,
      minWidth: 800, // Resize for mobile
      minHeight: 600,
    );
    
    return result;
  }
  
  // Compress network image URL (add quality parameter)
  static String getOptimizedImageUrl(String originalUrl, {int? quality}) {
    if (!originalUrl.startsWith('http')) return originalUrl;
    
    // For services like Cloudinary, Firebase, etc.
    // Add quality parameter if supported
    final hasQuery = originalUrl.contains('?');
    final qualityValue = quality ?? 60;
    
    return '$originalUrl${hasQuery ? '&' : '?'}q=$qualityValue&w=800';
  }
  
  // Estimate data saved
  static Future<int> estimateDataSaved(int originalSize) async {
    if (!await isDataSaverEnabled()) return 0;
    
    final quality = await getImageQuality();
    // Rough estimation based on quality
    double reduction = (100 - quality) / 100;
    return (originalSize * reduction).toInt();
  }
}

// Data saver settings widget
class DataSaverSettings extends StatefulWidget {
  const DataSaverSettings({super.key});

  @override
  State<DataSaverSettings> createState() => _DataSaverSettingsState();
}

class _DataSaverSettingsState extends State<DataSaverSettings> {
  bool _dataSaverEnabled = false;
  int _imageQuality = 60;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _dataSaverEnabled = await DataSaverService.isDataSaverEnabled();
    _imageQuality = await DataSaverService.getImageQuality();
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    await DataSaverService.setDataSaverEnabled(_dataSaverEnabled);
    await DataSaverService.setImageQuality(_imageQuality);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Data Saver Mode'),
          subtitle: const Text('Reduce image quality to save data'),
          value: _dataSaverEnabled,
          onChanged: (value) {
            setState(() {
              _dataSaverEnabled = value;
            });
          },
          secondary: const Icon(Icons.data_saver_on),
        ),
        
        if (_dataSaverEnabled) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Image Quality',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...DataSaverService.qualityLevels.entries.map((entry) {
            return RadioListTile<int>(
              title: Text(entry.key),
              subtitle: Text('${entry.value}% quality'),
              value: entry.value,
              groupValue: _imageQuality,
              onChanged: (value) {
                setState(() {
                  _imageQuality = value!;
                });
              },
            );
          }),
          
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Savings:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Images: ~${100 - _imageQuality}% less data',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '• Page loads: ~${(100 - _imageQuality) * 0.7}% faster',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Settings'),
          ),
        ),
      ],
    );
  }
}
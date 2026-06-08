import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/property.dart';
import '../utils/constants.dart';
import '../utils/zambia_areas.dart';
import '../services/supabase_service.dart';
import '../services/mock_data_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _landSizeController = TextEditingController();
  final _locationAddressController = TextEditingController();
  final _googleMapsLinkController = TextEditingController();
  
  // Car-specific controllers
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carYearController = TextEditingController();
  final _carMileageController = TextEditingController();
  final _carColorController = TextEditingController();
  
  // Dropdown values
  PropertyType _selectedType = PropertyType.rent;
  String? _selectedArea;
  String? _carFuelType;
  String? _carTransmission;
  String? _carCondition;
  
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _addMapsLink = false;
  
  // Video walkthrough
  XFile? _videoFile;
  String? _videoThumbnail;
  bool _isUploadingVideo = false;
  bool _hasVideo = false;
  
  // 360° Photo Tour
  final List<XFile> _threeSixtyImages = [];
  bool _hasThreeSixtyTour = false;

  // Fuel type options
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'LPG'];
  
  // Transmission options
  final List<String> _transmissions = ['Manual', 'Automatic', 'CVT', 'Semi-Automatic'];
  
  // Condition options
  final List<String> _conditions = ['Brand New', 'Like New', 'Very Good', 'Good', 'Fair', 'Needs Work'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: const Text('Add New Listing'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitProperty,
            child: const Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property type selector
              const Text(
                'Listing Type *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PropertyType>(
                segments: const [
                  ButtonSegment(value: PropertyType.rent, label: Text('For Rent')),
                  ButtonSegment(value: PropertyType.buy, label: Text('For Sale')),
                  ButtonSegment(value: PropertyType.land, label: Text('Land')),
                  ButtonSegment(value: PropertyType.car, label: Text('Car')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<PropertyType> selection) {
                  setState(() {
                    _selectedType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _selectedType == PropertyType.car 
                      ? 'Car Title *' 
                      : 'Property Title *',
                  hintText: _selectedType == PropertyType.car 
                      ? 'e.g., Toyota Hilux 2022, 4x4'
                      : 'e.g., Modern 3-Bedroom House in Woodlands',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the features, condition, benefits, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _selectedType == PropertyType.rent 
                      ? 'Monthly Rent (ZMW) *' 
                      : _selectedType == PropertyType.car
                          ? 'Price (ZMW) *'
                          : 'Price (ZMW) *',
                  prefixText: 'ZMW ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Area (for all types, cars also have location)
              DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration: const InputDecoration(
                  labelText: 'Area *',
                  border: OutlineInputBorder(),
                ),
                items: ZambiaAreas.getAllAreas().map((area) {
                  return DropdownMenuItem(value: area, child: Text(area));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedArea = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Property-specific fields (not for cars)
              if (_selectedType != PropertyType.car && _selectedType != PropertyType.land) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bedroomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bedrooms *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bathrooms *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Land size (for land only)
              if (_selectedType == PropertyType.land) ...[
                TextFormField(
                  controller: _landSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Land Size (sqm) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter land size';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // Car-specific fields
              if (_selectedType == PropertyType.car) ...[
                const Text(
                  'Vehicle Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carMakeController,
                        decoration: const InputDecoration(
                          labelText: 'Make *',
                          hintText: 'Toyota, Honda, Ford...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _carModelController,
                        decoration: const InputDecoration(
                          labelText: 'Model *',
                          hintText: 'Hilux, Civic, Ranger...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carYearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Year *',
                          hintText: '2022',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final year = int.tryParse(value);
                          if (year == null || year < 1980 || year > DateTime.now().year + 1) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _carMileageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mileage (km) *',
                          hintText: '50000',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _carFuelType,
                  decoration: const InputDecoration(
                    labelText: 'Fuel Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: _fuelTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _carFuelType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _carTransmission,
                  decoration: const InputDecoration(
                    labelText: 'Transmission *',
                    border: OutlineInputBorder(),
                  ),
                  items: _transmissions.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _carTransmission = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _carColorController,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    hintText: 'White, Black, Silver...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _carCondition,
                  decoration: const InputDecoration(
                    labelText: 'Condition *',
                    border: OutlineInputBorder(),
                  ),
                  items: _conditions.map((condition) {
                    return DropdownMenuItem(value: condition, child: Text(condition));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _carCondition = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // Location Address
              const Text(
                'Location Address *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationAddressController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Plot 123, Woodlands, Lusaka',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Google Maps Link (Optional)
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
                TextFormField(
                  controller: _googleMapsLinkController,
                  decoration: const InputDecoration(
                    hintText: 'https://maps.app.goo.gl/...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
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
                          'How to get link: Open Google Maps, tap and hold on location, tap "Share"',
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              
              // Photos
              const Text(
                'Photos *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40),
                              SizedBox(height: 8),
                              Text('Add Photos'),
                            ],
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(_selectedImages[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Video Walkthrough
              const SizedBox(height: 24),
              const Text(
                'Video Walkthrough (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    if (!_hasVideo)
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isUploadingVideo ? null : _pickVideo,
                            icon: const Icon(Icons.videocam),
                            label: const Text('Record or Upload Video Tour'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload a 30-second walkthrough video',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                          if (_isUploadingVideo) ...[
                            const SizedBox(height: 12),
                            const LinearProgressIndicator(),
                            const SizedBox(height: 4),
                            const Text('Processing video...', style: TextStyle(fontSize: 12)),
                          ],
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Video uploaded successfully!')),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _videoFile = null;
                                  _videoThumbnail = null;
                                  _hasVideo = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // 360° Photo Tour
              const SizedBox(height: 16),
              const Text(
                '360° Photo Tour (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    if (!_hasThreeSixtyTour)
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickThreeSixtyImages,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Select 360° Photos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Take photos around the room/car for 360° view',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('${_threeSixtyImages.length} 360° photos uploaded'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _threeSixtyImages.clear();
                                      _hasThreeSixtyTour = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _threeSixtyImages.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 60,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(_threeSixtyImages[index].path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _pickVideo() async {
    setState(() => _isUploadingVideo = true);
    
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      
      if (video != null) {
        setState(() {
          _videoFile = video;
          _hasVideo = true;
        });
        
        // Thumbnail generation commented out for now
        setState(() {
          _videoThumbnail = null;
        });
      }
    } catch (e) {
      print('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isUploadingVideo = false);
    }
  }

  Future<void> _pickThreeSixtyImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _threeSixtyImages.addAll(images);
        _hasThreeSixtyTour = true;
      });
    }
  }

  Future<void> _submitProperty() async {
    if (_formKey.currentState!.validate() && _selectedArea != null) {
      setState(() => _isSubmitting = true);
      
      final propertyId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Upload images to Supabase
      List<String> uploadedImageUrls = [];
      List<File> imageFiles = _selectedImages.map((xfile) => File(xfile.path)).toList();
      
      if (imageFiles.isNotEmpty) {
        uploadedImageUrls = await SupabaseService.uploadImages(imageFiles, propertyId);
      }
      
      if (uploadedImageUrls.isEmpty) {
        uploadedImageUrls.add('https://picsum.photos/id/106/400/300');
      }
      
      // Upload video if exists
      String? uploadedVideoUrl;
      if (_videoFile != null) {
        uploadedVideoUrl = await SupabaseService.uploadVideo(File(_videoFile!.path), propertyId);
      }
      
      final newProperty = Property(
        id: propertyId,
        agentId: 'agent1',
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        area: _selectedArea!,
        type: _selectedType,
        status: PropertyStatus.available,
        imageUrls: uploadedImageUrls,
        bedrooms: _selectedType == PropertyType.land || _selectedType == PropertyType.car ? 0 : int.parse(_bedroomsController.text),
        bathrooms: _selectedType == PropertyType.land || _selectedType == PropertyType.car ? 0 : int.parse(_bathroomsController.text),
        landSize: _selectedType == PropertyType.land ? double.parse(_landSizeController.text) : null,
        createdAt: DateTime.now(),
        views: 0,
        locationAddress: _locationAddressController.text,
        googleMapsLink: _addMapsLink && _googleMapsLinkController.text.isNotEmpty 
            ? _googleMapsLinkController.text 
            : null,
        videoUrl: uploadedVideoUrl,
        videoThumbnailUrl: _videoThumbnail,
        threeSixtyImageUrls: _threeSixtyImages.map((img) => img.path).toList(),
        // Car fields
        carMake: _selectedType == PropertyType.car ? _carMakeController.text : null,
        carModel: _selectedType == PropertyType.car ? _carModelController.text : null,
        carYear: _selectedType == PropertyType.car ? int.tryParse(_carYearController.text) : null,
        carFuelType: _selectedType == PropertyType.car ? _carFuelType : null,
        carTransmission: _selectedType == PropertyType.car ? _carTransmission : null,
        carMileage: _selectedType == PropertyType.car ? int.tryParse(_carMileageController.text) : null,
        carColor: _selectedType == PropertyType.car ? _carColorController.text : null,
        carCondition: _selectedType == PropertyType.car ? _carCondition : null,
      );
      
      await MockDataService.addProperty(newProperty);
      
      if (SupabaseService.isAvailable) {
        await SupabaseService.syncLocalToCloud();
      }
      
      Navigator.pop(context, newProperty);
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _landSizeController.dispose();
    _locationAddressController.dispose();
    _googleMapsLinkController.dispose();
    _carMakeController.dispose();
    _carModelController.dispose();
    _carYearController.dispose();
    _carMileageController.dispose();
    _carColorController.dispose();
    super.dispose();
  }
}
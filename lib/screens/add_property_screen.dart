import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property.dart';
import '../utils/constants.dart';
import '../utils/zambia_areas.dart';
import '../services/supabase_service.dart';
import '../services/mock_data_service.dart';

/// Screen for adding new properties or editing existing ones
class AddPropertyScreen extends StatefulWidget {
  final Property? propertyToEdit; // If provided, we're in edit mode

  const AddPropertyScreen({super.key, this.propertyToEdit});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
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
  
  // Images and media
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _addMapsLink = false;
  
  // Edit mode flags
  bool _isEditing = false;
  String _editingPropertyId = '';
  
  // Video walkthrough
  XFile? _videoFile;
  String? _videoThumbnail;
  bool _isUploadingVideo = false;
  bool _hasVideo = false;
  
  // 360° Photo Tour
  List<XFile> _threeSixtyImages = [];
  bool _hasThreeSixtyTour = false;

  // Dropdown options
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'LPG'];
  final List<String> _transmissions = ['Manual', 'Automatic', 'CVT', 'Semi-Automatic'];
  final List<String> _conditions = ['Brand New', 'Like New', 'Very Good', 'Good', 'Fair', 'Needs Work'];

  @override
  void initState() {
    super.initState();
    // Check if we're editing an existing property
    _isEditing = widget.propertyToEdit != null;
    if (_isEditing) {
      _loadPropertyData();
    }
  }

  /// Load existing property data into form fields for editing
  void _loadPropertyData() {
    final property = widget.propertyToEdit!;
    _titleController.text = property.title;
    _descriptionController.text = property.description;
    _priceController.text = property.price.toString();
    _selectedArea = property.area;
    _selectedType = property.type;
    _bedroomsController.text = property.bedrooms.toString();
    _bathroomsController.text = property.bathrooms.toString();
    if (property.landSize != null) {
      _landSizeController.text = property.landSize!.toString();
    }
    _locationAddressController.text = property.locationAddress ?? '';
    _googleMapsLinkController.text = property.googleMapsLink ?? '';
    _editingPropertyId = property.id;
    
    // Load car-specific fields if applicable
    if (property.type == PropertyType.car) {
      _carMakeController.text = property.carMake ?? '';
      _carModelController.text = property.carModel ?? '';
      _carYearController.text = property.carYear?.toString() ?? '';
      _carMileageController.text = property.carMileage?.toString() ?? '';
      _carColorController.text = property.carColor ?? '';
      _carFuelType = property.carFuelType;
      _carTransmission = property.carTransmission;
      _carCondition = property.carCondition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: Text(_isEditing ? 'Edit Listing' : 'Add New Listing'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitProperty,
            child: Text(_isEditing ? 'Update' : 'Post', style: const TextStyle(color: Colors.white)),
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
              const Text('Listing Type *', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  setState(() => _selectedType = selection.first);
                },
              ),
              const SizedBox(height: 16),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _selectedType == PropertyType.car ? 'Car Title *' : 'Property Title *',
                  hintText: _selectedType == PropertyType.car 
                      ? 'e.g., Toyota Hilux 2022, 4x4'
                      : 'e.g., Modern 3-Bedroom House in Woodlands',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a title';
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
                  if (value == null || value.isEmpty) return 'Please enter a description';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _selectedType == PropertyType.rent ? 'Monthly Rent (ZMW) *' : 'Price (ZMW) *',
                  prefixText: 'ZMW ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a price';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Area (for all types)
              DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration: const InputDecoration(
                  labelText: 'Area *',
                  border: OutlineInputBorder(),
                ),
                items: ZambiaAreas.getAllAreas().map((area) {
                  return DropdownMenuItem(value: area, child: Text(area));
                }).toList(),
                onChanged: (value) => setState(() => _selectedArea = value),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please select an area';
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
                const Text('Vehicle Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  items: _fuelTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => _carFuelType = value),
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
                  items: _transmissions.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => _carTransmission = value),
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
                  items: _conditions.map((condition) => DropdownMenuItem(value: condition, child: Text(condition))).toList(),
                  onChanged: (value) => setState(() => _carCondition = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // Location Address
              const Text('Location Address *', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  if (value == null || value.isEmpty) return 'Please enter location address';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Google Maps Link (Optional)
              CheckboxListTile(
                title: const Text('Add Google Maps Link'),
                subtitle: const Text('Share exact location via Google Maps'),
                value: _addMapsLink,
                onChanged: (value) => setState(() => _addMapsLink = value ?? false),
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
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
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
              const Text('Photos *', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            onTap: () => setState(() => _selectedImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick multiple images from gallery
  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) setState(() => _selectedImages.addAll(images));
  }

  /// Submit property - handles both add and edit
  Future<void> _submitProperty() async {
    if (_formKey.currentState!.validate() && _selectedArea != null) {
      setState(() => _isSubmitting = true);
      
      final propertyId = _isEditing 
          ? _editingPropertyId 
          : DateTime.now().millisecondsSinceEpoch.toString();
      
      List<String> uploadedImageUrls = [];
      
      // Only upload new images if adding new property
      if (!_isEditing && _selectedImages.isNotEmpty) {
        uploadedImageUrls = await SupabaseService.uploadImages(_selectedImages, propertyId);
      } else if (_isEditing) {
        uploadedImageUrls = widget.propertyToEdit!.imageUrls;
      }
      
      if (uploadedImageUrls.isEmpty && !_isEditing) {
        uploadedImageUrls.add('https://picsum.photos/id/106/400/300');
      }
      
      final property = Property(
        id: propertyId,
        agentId: 'agent1',
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        area: _selectedArea!,
        type: _selectedType,
        status: _isEditing ? widget.propertyToEdit!.status : PropertyStatus.available,
        imageUrls: uploadedImageUrls,
        bedrooms: _selectedType == PropertyType.land || _selectedType == PropertyType.car ? 0 : int.parse(_bedroomsController.text),
        bathrooms: _selectedType == PropertyType.land || _selectedType == PropertyType.car ? 0 : int.parse(_bathroomsController.text),
        landSize: _selectedType == PropertyType.land ? double.parse(_landSizeController.text) : null,
        createdAt: _isEditing ? widget.propertyToEdit!.createdAt : DateTime.now(),
        views: _isEditing ? widget.propertyToEdit!.views : 0,
        locationAddress: _locationAddressController.text,
        googleMapsLink: _addMapsLink && _googleMapsLinkController.text.isNotEmpty ? _googleMapsLinkController.text : null,
        videoUrl: _videoFile?.path,
        videoThumbnailUrl: _videoThumbnail,
        threeSixtyImageUrls: _threeSixtyImages.map((img) => img.path).toList(),
        carMake: _selectedType == PropertyType.car ? _carMakeController.text : null,
        carModel: _selectedType == PropertyType.car ? _carModelController.text : null,
        carYear: _selectedType == PropertyType.car ? int.tryParse(_carYearController.text) : null,
        carFuelType: _selectedType == PropertyType.car ? _carFuelType : null,
        carTransmission: _selectedType == PropertyType.car ? _carTransmission : null,
        carMileage: _selectedType == PropertyType.car ? int.tryParse(_carMileageController.text) : null,
        carColor: _selectedType == PropertyType.car ? _carColorController.text : null,
        carCondition: _selectedType == PropertyType.car ? _carCondition : null,
      );
      
      if (_isEditing) {
        await MockDataService.updateProperty(property);
        if (SupabaseService.isAvailable) await SupabaseService.uploadProperty(property);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property updated successfully!')),
        );
      } else {
        await MockDataService.addProperty(property);
        if (SupabaseService.isAvailable) await SupabaseService.syncLocalToCloud();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully!')),
        );
      }
      
      Navigator.pop(context, true);
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

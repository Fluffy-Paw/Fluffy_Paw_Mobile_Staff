import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

const MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoiaG9hcTEzOSIsImEiOiJjbTRvMmlmdGowZTllMnFwbXo3ZXhqYmI0In0.PMRUp1yMQmKBJkEMGtswLg';
const MAPBOX_STYLE = 'mapbox/streets-v12';

class AddressPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  
  const AddressPickerScreen({
    Key? key,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  
  List<dynamic> _searchResults = [];
  LatLng _selectedLocation = LatLng(10.850211, 106.7260669);
  String _currentAddress = '';
  Map<String, String> _addressComponents = {
    'street': '',
    'ward': '',
    'district': '',
    'city': '',
  };
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
      Future.delayed(Duration.zero, () {
        _mapController.move(_selectedLocation, 17);
        _reverseGeocode(_selectedLocation);
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = location);
      _mapController.move(location, 17);
      _reverseGeocode(location);
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json',
        queryParameters: {
          'access_token': MAPBOX_ACCESS_TOKEN,
          'language': 'vi',
          'country': 'VN',
          'types': 'address,place,locality,neighborhood',
          'limit': 5,
        },
      );

      if (mounted) {
        setState(() {
          _searchResults = response.data['features'] ?? [];
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error in address search: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _reverseGeocode(LatLng location) async {
    try {
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${location.longitude},${location.latitude}.json',
        queryParameters: {
          'access_token': MAPBOX_ACCESS_TOKEN,
          'language': 'vi',
          'types': 'address,poi,neighborhood,locality,place,district',
          'limit': 1,
          'radius': 50,
        },
      );

      if (mounted && response.data['features'].isNotEmpty) {
        final feature = response.data['features'][0];
        final context = feature['context'] ?? [];
        
        String street = feature['text_vi'] ?? feature['text'] ?? '';
        String ward = '';
        String district = '';
        String city = '';
        String postcode = '';
        
        // Parse từ context
        for (var item in context) {
          final id = item['id'] ?? '';
          final text = item['text_vi'] ?? item['text'] ?? '';
          
          if (id.startsWith('postcode')) {
            postcode = text;
          } else if (id.startsWith('neighborhood')) {
            if (ward.isEmpty) ward = text;
          } else if (id.startsWith('locality')) {
            district = text;
          } else if (id.startsWith('place')) {
            city = text;
          }
        }

        // Nếu địa chỉ hiện tại là neighborhood, 
        // chuyển nó thành ward và lấy lại district từ locality
        if (feature['place_type'][0] == 'neighborhood') {
          ward = street;
          street = '';
          // Tìm district trong context
          for (var item in context) {
            if (item['id']?.startsWith('locality')) {
              district = item['text_vi'] ?? item['text'] ?? '';
              break;
            }
          }
        }

        // Parse full place_name nếu có
        if (feature['place_name_vi'] != null) {
          final placeNameParts = feature['place_name_vi'].toString().split(', ');
          if (placeNameParts.length > 1) {
            if (street.isEmpty && !placeNameParts[0].contains(ward)) {
              street = placeNameParts[0];
            }
          }
        }

        setState(() {
          _selectedLocation = location;
          _addressComponents = {
            'street': street,
            'ward': ward,
            'district': district,
            'city': city,
          };
          
          // Tạo địa chỉ đầy đủ
          List<String> addressParts = [];
          if (street.isNotEmpty) addressParts.add(street);
          if (ward.isNotEmpty) addressParts.add(ward);
          if (district.isNotEmpty) addressParts.add(district);
          if (city.isNotEmpty) addressParts.add(city);
          if (postcode.isNotEmpty) addressParts.add(postcode);
          
          _currentAddress = addressParts.join(', ');
        });

        // Debug logs
        debugPrint('Raw Feature: ${feature.toString()}');
        debugPrint('Place Name VI: ${feature['place_name_vi']}');
        debugPrint('Text VI: ${feature['text_vi']}');
        debugPrint('Place Type: ${feature['place_type']}');
        debugPrint('Address Components: $_addressComponents');
        debugPrint('Current Address: $_currentAddress');
      }
    } catch (e) {
      debugPrint('Error in reverse geocoding: $e');
    }
}

  void _selectSearchResult(dynamic result) {
    final coordinates = result['center'];
    final location = LatLng(coordinates[1], coordinates[0]);
    
    setState(() {
      _searchResults = [];
      _searchController.clear();
    });

    _mapController.move(location, 17);
    _reverseGeocode(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn địa chỉ'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 17.0,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _reverseGeocode(event.camera.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: {
                  'accessToken': MAPBOX_ACCESS_TOKEN,
                  'id': MAPBOX_STYLE,
                },
              ),
              Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),

          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa chỉ...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _searchAddress,
                  ),
                ),

                if (_searchResults.isNotEmpty)
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          title: Text(result['place_name'] ?? ''),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Current address indicator
          if (_currentAddress.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Địa chỉ hiện tại:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _currentAddress,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'address': _currentAddress,
                'location': _selectedLocation,
                'addressDetails': {
                  'street': _addressComponents['street'] ?? '',
                  'ward': _addressComponents['ward'] ?? '',
                  'district': _addressComponents['district'] ?? '',
                  'city': _addressComponents['city'] ?? '',
                }
              });
            },
            child: Text('Xác nhận địa chỉ'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
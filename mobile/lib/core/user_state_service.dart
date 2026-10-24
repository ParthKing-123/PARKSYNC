import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// Supported user roles in ParkSync
enum UserRole {
  seeker,
  provider,
}

/// Verification status state machine for providers
enum VerificationStatus {
  draft,
  submitted,
  underReview,
  actionRequired,
  approved,
  rejected,
  suspended,
}

extension VerificationStatusExtension on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.draft:
        return 'Draft';
      case VerificationStatus.submitted:
        return 'Submitted';
      case VerificationStatus.underReview:
        return 'Under Review';
      case VerificationStatus.actionRequired:
        return 'Action Required';
      case VerificationStatus.approved:
        return 'Approved ✓';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.suspended:
        return 'Suspended';
    }
  }

  String get code {
    switch (this) {
      case VerificationStatus.draft:
        return 'DRAFT';
      case VerificationStatus.submitted:
        return 'SUBMITTED';
      case VerificationStatus.underReview:
        return 'UNDER_REVIEW';
      case VerificationStatus.actionRequired:
        return 'ACTION_REQUIRED';
      case VerificationStatus.approved:
        return 'APPROVED';
      case VerificationStatus.rejected:
        return 'REJECTED';
      case VerificationStatus.suspended:
        return 'SUSPENDED';
    }
  }

  static VerificationStatus fromCode(String? code) {
    switch (code) {
      case 'SUBMITTED':
        return VerificationStatus.submitted;
      case 'UNDER_REVIEW':
        return VerificationStatus.underReview;
      case 'ACTION_REQUIRED':
        return VerificationStatus.actionRequired;
      case 'APPROVED':
        return VerificationStatus.approved;
      case 'REJECTED':
        return VerificationStatus.rejected;
      case 'SUSPENDED':
        return VerificationStatus.suspended;
      case 'DRAFT':
      default:
        return VerificationStatus.draft;
    }
  }
}

/// Seeker Vehicle Data Model
class UserVehicle {
  final String id;
  final String make;
  final String model;
  final String year;
  final String variant;
  final String plateNumber;
  final String type; // Hatchback, Sedan, SUV, Compact SUV, 2-Wheeler
  final bool isDefault;

  const UserVehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.variant,
    required this.plateNumber,
    required this.type,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'year': year,
        'variant': variant,
        'plateNumber': plateNumber,
        'type': type,
        'isDefault': isDefault,
      };

  factory UserVehicle.fromJson(Map<String, dynamic> map) => UserVehicle(
        id: map['id'] ?? 'v_01',
        make: map['make'] ?? 'Hyundai',
        model: map['model'] ?? 'Creta',
        year: map['year'] ?? '2023',
        variant: map['variant'] ?? 'Petrol SX(O)',
        plateNumber: map['plateNumber'] ?? 'MH 12 AB 1234',
        type: map['type'] ?? 'Compact SUV',
        isDefault: map['isDefault'] ?? false,
      );
}

/// Provider Facility Data Model
class ProviderFacility {
  final String id;
  final String category; // INDIVIDUAL, RESTAURANT, OFFICE, OPERATOR, HOTEL_MALL, OTHER
  final String businessName;
  final String contactPerson;
  final String contactPhone;
  final String contactEmail;
  final String facilityName;
  final String address;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final int totalBays;
  final int availableBays;
  final String slotType; // Covered, Open, Basement, Multi-level
  final String heightClearance;
  final List<String> allowedVehicles;
  final List<String> amenities;
  final double hourlyRate;
  final String operatingHours;
  final String operatingDays;
  final bool isInstantBooking;
  final VerificationStatus verificationStatus;

  const ProviderFacility({
    required this.id,
    required this.category,
    required this.businessName,
    required this.contactPerson,
    required this.contactPhone,
    required this.contactEmail,
    required this.facilityName,
    required this.address,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.totalBays,
    required this.availableBays,
    required this.slotType,
    required this.heightClearance,
    required this.allowedVehicles,
    required this.amenities,
    required this.hourlyRate,
    required this.operatingHours,
    required this.operatingDays,
    this.isInstantBooking = true,
    this.verificationStatus = VerificationStatus.underReview,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'businessName': businessName,
        'contactPerson': contactPerson,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'facilityName': facilityName,
        'address': address,
        'city': city,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'totalBays': totalBays,
        'availableBays': availableBays,
        'slotType': slotType,
        'heightClearance': heightClearance,
        'allowedVehicles': allowedVehicles,
        'amenities': amenities,
        'hourlyRate': hourlyRate,
        'operatingHours': operatingHours,
        'operatingDays': operatingDays,
        'isInstantBooking': isInstantBooking,
        'verificationStatus': verificationStatus.code,
      };

  factory ProviderFacility.fromJson(Map<String, dynamic> map) => ProviderFacility(
        id: map['id'] ?? 'fac_01',
        category: map['category'] ?? 'INDIVIDUAL',
        businessName: map['businessName'] ?? 'Personal Bay',
        contactPerson: map['contactPerson'] ?? 'Host Owner',
        contactPhone: map['contactPhone'] ?? '+91 9876543210',
        contactEmail: map['contactEmail'] ?? 'host@parksync.in',
        facilityName: map['facilityName'] ?? 'Prime Parking Slot',
        address: map['address'] ?? '42 Central Avenue',
        city: map['city'] ?? 'Pune',
        pincode: map['pincode'] ?? '411001',
        latitude: (map['latitude'] as num?)?.toDouble() ?? 18.5204,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 73.8567,
        totalBays: map['totalBays'] ?? 4,
        availableBays: map['availableBays'] ?? 3,
        slotType: map['slotType'] ?? 'Covered',
        heightClearance: map['heightClearance'] ?? '2.4 m',
        allowedVehicles: List<String>.from(map['allowedVehicles'] ?? ['Hatchback', 'Sedan', 'SUV']),
        amenities: List<String>.from(map['amenities'] ?? ['CCTV 24/7', 'Security Guard', 'EV Charging']),
        hourlyRate: (map['hourlyRate'] as num?)?.toDouble() ?? 40.0,
        operatingHours: map['operatingHours'] ?? '24 Hours',
        operatingDays: map['operatingDays'] ?? 'All Days',
        isInstantBooking: map['isInstantBooking'] ?? true,
        verificationStatus: VerificationStatusExtension.fromCode(map['verificationStatus']),
      );

  ProviderFacility copyWith({
    String? id,
    String? category,
    String? businessName,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    String? facilityName,
    String? address,
    String? city,
    String? pincode,
    double? latitude,
    double? longitude,
    int? totalBays,
    int? availableBays,
    String? slotType,
    String? heightClearance,
    List<String>? allowedVehicles,
    List<String>? amenities,
    double? hourlyRate,
    String? operatingHours,
    String? operatingDays,
    bool? isInstantBooking,
    VerificationStatus? verificationStatus,
  }) {
    return ProviderFacility(
      id: id ?? this.id,
      category: category ?? this.category,
      businessName: businessName ?? this.businessName,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      facilityName: facilityName ?? this.facilityName,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalBays: totalBays ?? this.totalBays,
      availableBays: availableBays ?? this.availableBays,
      slotType: slotType ?? this.slotType,
      heightClearance: heightClearance ?? this.heightClearance,
      allowedVehicles: allowedVehicles ?? this.allowedVehicles,
      amenities: amenities ?? this.amenities,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      operatingHours: operatingHours ?? this.operatingHours,
      operatingDays: operatingDays ?? this.operatingDays,
      isInstantBooking: isInstantBooking ?? this.isInstantBooking,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

/// Central State and Authentication Service for ParkSync
/// Supports persistent local mock storage and seamless adapter hooks for backend/Firebase.
class UserStateService extends ChangeNotifier {
  static final UserStateService instance = UserStateService._internal();
  UserStateService._internal();

  bool _initialized = false;
  bool _isLoggedIn = false;
  String _phoneNumber = '';
  String _userName = '';
  String _userEmail = '';
  UserRole _activeRole = UserRole.seeker;

  // Seeker Vehicles
  final List<UserVehicle> _vehicles = [];
  UserVehicle? _activeVehicle;

  // Provider Facility
  ProviderFacility? _providerFacility;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get phoneNumber => _phoneNumber;
  String get userName => _userName.isEmpty ? (_isLoggedIn ? 'Verified Driver' : 'Guest Driver') : _userName;
  String get userEmail => _userEmail;
  UserRole get activeRole => _activeRole;
  List<UserVehicle> get vehicles => List.unmodifiable(_vehicles);
  UserVehicle? get activeVehicle => _activeVehicle ?? (_vehicles.isNotEmpty ? _vehicles.first : null);
  ProviderFacility? get providerFacility => _providerFacility;

  bool get hasVehicles => _vehicles.isNotEmpty;
  bool get isProviderRegistered => _providerFacility != null;

  /// Initialize state from SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('auth_logged_in') ?? false;
      _phoneNumber = prefs.getString('auth_phone') ?? '';
      _userName = prefs.getString('auth_name') ?? '';
      _userEmail = prefs.getString('auth_email') ?? '';
      final roleStr = prefs.getString('auth_active_role');
      if (roleStr == 'provider') {
        _activeRole = UserRole.provider;
      } else {
        _activeRole = UserRole.seeker;
      }

      // Default demo vehicle if empty
      _vehicles.clear();
      _vehicles.add(const UserVehicle(
        id: 'v_default_01',
        make: 'Hyundai',
        model: 'Creta',
        year: '2023',
        variant: 'Petrol SX',
        plateNumber: 'MH 12 AB 8921',
        type: 'Compact SUV',
        isDefault: true,
      ));
      _activeVehicle = _vehicles.first;

      // Restore provider facility from storage if explicitly registered by user
      final facilityJson = prefs.getString('provider_facility_data');
      if (facilityJson != null && facilityJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(facilityJson) as Map<String, dynamic>;
          _providerFacility = ProviderFacility.fromJson(decoded);
        } catch (_) {
          _providerFacility = null;
        }
      } else {
        _providerFacility = null;
      }

      _initialized = true;
      notifyListeners();

      // If logged in as provider, sync from backend in case local cache was cleared
      if (_isLoggedIn && _activeRole == UserRole.provider) {
        syncProviderProfileFromBackend();
      }
    } catch (_) {
      _initialized = true;
    }
  }

  /// Log in as Seeker or Provider
  Future<void> login({
    required String phone,
    required UserRole role,
    String? name,
    String? email,
  }) async {
    _isLoggedIn = true;
    _phoneNumber = phone;
    _activeRole = role;
    if (name != null && name.isNotEmpty) _userName = name;
    if (email != null && email.isNotEmpty) _userEmail = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_logged_in', true);
    await prefs.setString('auth_phone', phone);
    await prefs.setString('auth_active_role', role == UserRole.provider ? 'provider' : 'seeker');
    if (_userName.isNotEmpty) await prefs.setString('auth_name', _userName);
    if (_userEmail.isNotEmpty) await prefs.setString('auth_email', _userEmail);

    notifyListeners();
  }

  /// Switch active role
  Future<void> switchRole(UserRole newRole) async {
    _activeRole = newRole;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_active_role', newRole == UserRole.provider ? 'provider' : 'seeker');
    notifyListeners();
  }

  /// Update Seeker profile
  Future<void> updateProfile({
    required String name,
    String? email,
  }) async {
    _userName = name;
    if (email != null) _userEmail = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_name', _userName);
    if (email != null) await prefs.setString('auth_email', _userEmail);

    notifyListeners();
  }

  /// Add a new vehicle to seeker garage
  Future<void> addVehicle(UserVehicle vehicle) async {
    _vehicles.add(vehicle);
    _activeVehicle = vehicle;
    notifyListeners();
  }

  /// Set the active selected vehicle
  void setActiveVehicle(UserVehicle vehicle) {
    _activeVehicle = vehicle;
    notifyListeners();
  }

  /// Register or update Provider facility
  Future<void> saveProviderFacility(ProviderFacility facility) async {
    _providerFacility = facility;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('provider_facility_data', jsonEncode(facility.toJson()));
    notifyListeners();
  }

  /// Update verification status of current facility (e.g., when approved by Super Admin)
  Future<void> updateFacilityVerificationStatus(VerificationStatus status) async {
    if (_providerFacility != null) {
      _providerFacility = _providerFacility!.copyWith(verificationStatus: status);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('provider_facility_data', jsonEncode(_providerFacility!.toJson()));
      notifyListeners();
    }
  }

  /// Log in directly using phone/username/email + password (0 OTPs needed)
  Future<Map<String, dynamic>> loginWithPassword({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    final cleanIdentifier = identifier.trim();
    final cleanPwd = password.trim();
    final roleStr = role == UserRole.provider ? 'PROVIDER' : 'SEEKER';

    // 1. Attempt backend authentication
    try {
      final response = await ApiClient().dio.post('/auth/login-password', data: {
        'identifier': cleanIdentifier,
        'password': cleanPwd,
        'role': roleStr,
      });

      if (response.data != null && response.data['success'] == true) {
        final userData = response.data['user'];
        final token = response.data['token']?.toString();
        final providerProfile = response.data['providerProfile'];

        final phone = userData?['phone']?.toString() ?? cleanIdentifier;
        final name = userData?['name']?.toString() ?? '';
        final email = userData?['email']?.toString() ?? '';

        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString('jwt_token', token);
        }

        await login(
          phone: phone,
          role: role,
          name: name.isNotEmpty ? name : null,
          email: email.isNotEmpty ? email : null,
        );

        await prefs.setString('user_pwd_${_sanitizePhone(phone)}', cleanPwd);
        await prefs.setBool('user_has_password', true);

        // Auto-restore provider facility from backend if registered
        if (role == UserRole.provider) {
          if (providerProfile != null && providerProfile is Map<String, dynamic>) {
            _restoreFacilityFromBackendData(providerProfile, phone: phone, name: name, email: email);
          } else {
            await syncProviderProfileFromBackend();
          }
        }

        return {'success': true, 'user': userData};
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        final errorMsg = data is Map && data['error'] != null
            ? data['error'].toString()
            : 'Authentication failed. Please check credentials.';
        throw Exception(errorMsg);
      }
      debugPrint('[Auth] Backend offline, checking local password fallback: $e');
    }

    // 2. Offline fallback: check locally saved password for this user
    final prefs = await SharedPreferences.getInstance();
    final sanitized = _sanitizePhone(cleanIdentifier);
    final savedPwd = prefs.getString('user_pwd_$sanitized') ?? prefs.getString('user_pwd_generic');

    if (savedPwd != null && savedPwd == cleanPwd) {
      final savedPhone = prefs.getString('auth_phone') ?? cleanIdentifier;
      final savedName = prefs.getString('auth_name');
      final savedEmail = prefs.getString('auth_email');

      await login(
        phone: savedPhone,
        role: role,
        name: savedName,
        email: savedEmail,
      );
      return {'success': true, 'offline': true};
    }

    // If no password matched
    throw Exception('Incorrect mobile/username or password. If this is your first time, please Sign Up.');
  }

  /// Store or update password for user locally
  Future<void> savePassword(String phone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final sanitized = _sanitizePhone(phone);
    await prefs.setString('user_pwd_$sanitized', password.trim());
    await prefs.setString('user_pwd_generic', password.trim());
    await prefs.setBool('user_has_password', true);
  }

  static String _sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Sync provider profile and listed spaces from backend
  Future<void> syncProviderProfileFromBackend() async {
    try {
      final res = await ApiClient().dio.get('/providers/dashboard');
      if (res.data != null && res.data['profile'] != null) {
        final profile = res.data['profile'] as Map<String, dynamic>;
        final user = profile['user'] as Map<String, dynamic>?;
        final phone = user?['phone']?.toString() ?? _phoneNumber;
        final name = user?['name']?.toString() ?? _userName;
        final email = user?['email']?.toString() ?? _userEmail;
        _restoreFacilityFromBackendData(profile, phone: phone, name: name, email: email);
      }
    } catch (e) {
      debugPrint('[UserState] syncProviderProfileFromBackend error: $e');
    }
  }

  void _restoreFacilityFromBackendData(
    Map<String, dynamic> profileData, {
    required String phone,
    String? name,
    String? email,
  }) {
    try {
      final spaces = profileData['parkingSpaces'] as List<dynamic>?;
      final space = (spaces != null && spaces.isNotEmpty) ? spaces.first as Map<String, dynamic> : null;

      final displayName = profileData['displayName']?.toString() ?? (name?.isNotEmpty == true ? name! : 'My Parking Bay');
      final category = profileData['providerType']?.toString() ?? 'INDIVIDUAL';
      final vStatusStr = space != null ? space['verificationStatus']?.toString() : profileData['verificationStatus']?.toString();

      final facility = ProviderFacility(
        id: space?['id']?.toString() ?? profileData['id']?.toString() ?? 'fac_${DateTime.now().millisecondsSinceEpoch}',
        category: category,
        businessName: displayName,
        contactPerson: name?.isNotEmpty == true ? name! : displayName,
        contactPhone: phone,
        contactEmail: (email != null && email.isNotEmpty) ? email : 'host@parksync.in',
        facilityName: space?['title']?.toString() ?? '$displayName Parking',
        address: space?['address']?.toString() ?? 'Main Street',
        city: space?['city']?.toString() ?? 'Pune',
        pincode: space?['pincode']?.toString() ?? '411001',
        latitude: (space?['latitude'] as num?)?.toDouble() ?? 18.5204,
        longitude: (space?['longitude'] as num?)?.toDouble() ?? 73.8567,
        totalBays: space?['totalBays'] ?? 4,
        availableBays: space?['availableBays'] ?? 4,
        slotType: space?['spaceType']?.toString() ?? 'Covered',
        heightClearance: '2.4 m',
        allowedVehicles: const ['Hatchback', 'Sedan', 'SUV'],
        amenities: [
          if (space?['cctv'] == true) 'CCTV 24/7',
          if (space?['security'] == true) 'Security Guard',
          if (space?['covered'] == true) 'Covered',
        ],
        hourlyRate: (space?['pricePerHour'] as num?)?.toDouble() ?? 40.0,
        operatingHours: '24 Hours',
        operatingDays: 'All Days',
        isInstantBooking: true,
        verificationStatus: VerificationStatusExtension.fromCode(vStatusStr),
      );

      saveProviderFacility(facility);
    } catch (e) {
      debugPrint('[UserState] Error restoring facility from backend: $e');
    }
  }

  /// Log out
  Future<void> logout() async {
    _isLoggedIn = false;
    _phoneNumber = '';
    _userName = '';
    _userEmail = '';
    _activeRole = UserRole.seeker;
    _providerFacility = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_logged_in', false);
    await prefs.remove('jwt_token');
    await prefs.remove('auth_phone');
    await prefs.remove('auth_name');
    await prefs.remove('auth_email');
    await prefs.remove('auth_active_role');
    await prefs.remove('provider_facility_data');

    notifyListeners();
  }
}

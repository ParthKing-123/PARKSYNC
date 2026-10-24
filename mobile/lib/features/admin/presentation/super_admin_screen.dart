import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_client.dart';
import '../../../core/user_state_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/car_loading_indicator.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  // Stats
  int _totalSpaces = 0;
  int _pendingSpaces = 0;
  int _activeSpaces = 0;
  int _totalBookings = 0;

  // Facilities list
  List<Map<String, dynamic>> _pendingList = [];
  List<Map<String, dynamic>> _allList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch Stats
      try {
        final statsRes = await ApiClient().dio.get('/admin/stats');
        if (statsRes.data != null && statsRes.data is Map) {
          final data = statsRes.data as Map<String, dynamic>;
          _totalSpaces = data['totalSpaces'] ?? 0;
          _pendingSpaces = data['pendingSpaces'] ?? 0;
          _activeSpaces = data['activeSpaces'] ?? 0;
          _totalBookings = data['totalBookings'] ?? 0;
        }
      } catch (e) {
        debugPrint('[SuperAdmin] Stats API fallback: $e');
      }

      // 2. Fetch Pending Spaces
      List<Map<String, dynamic>> backendPending = [];
      try {
        final pendingRes = await ApiClient().dio.get('/admin/spaces/pending');
        if (pendingRes.data != null && pendingRes.data is List) {
          backendPending = (pendingRes.data as List).cast<Map<String, dynamic>>();
        }
      } catch (e) {
        debugPrint('[SuperAdmin] Pending spaces fetch: $e');
      }

      // 3. Fetch All Spaces
      List<Map<String, dynamic>> backendAll = [];
      try {
        final allRes = await ApiClient().dio.get('/admin/spaces/all');
        if (allRes.data != null && allRes.data is List) {
          backendAll = (allRes.data as List).cast<Map<String, dynamic>>();
        }
      } catch (e) {
        debugPrint('[SuperAdmin] All spaces fetch: $e');
      }

      // 4. Merge Local Facility if underReview
      final localFacility = UserStateService.instance.providerFacility;
      if (localFacility != null) {
        final bool existsInPending = backendPending.any((s) => s['id'] == localFacility.id);
        final bool existsInAll = backendAll.any((s) => s['id'] == localFacility.id);

        if (localFacility.verificationStatus != VerificationStatus.approved && !existsInPending) {
          backendPending.insert(0, {
            'id': localFacility.id,
            'title': localFacility.facilityName,
            'spaceType': localFacility.slotType,
            'address': localFacility.address,
            'city': localFacility.city,
            'area': localFacility.city,
            'pincode': localFacility.pincode,
            'latitude': localFacility.latitude,
            'longitude': localFacility.longitude,
            'pricePerHour': localFacility.hourlyRate,
            'totalBays': localFacility.totalBays,
            'availableBays': localFacility.availableBays,
            'status': 'PENDING_VERIFICATION',
            'verificationStatus': localFacility.verificationStatus.code,
            'provider': {
              'displayName': localFacility.businessName,
              'providerType': localFacility.category,
              'documentType': 'Aadhaar / Government ID',
              'documentName': 'facility_proof.pdf',
              'documentSize': 1850000,
              'user': {
                'name': localFacility.contactPerson,
                'phone': localFacility.contactPhone,
                'email': localFacility.contactEmail,
              }
            }
          });
        }

        if (!existsInAll) {
          backendAll.insert(0, {
            'id': localFacility.id,
            'title': localFacility.facilityName,
            'spaceType': localFacility.slotType,
            'address': localFacility.address,
            'city': localFacility.city,
            'area': localFacility.city,
            'pincode': localFacility.pincode,
            'latitude': localFacility.latitude,
            'longitude': localFacility.longitude,
            'pricePerHour': localFacility.hourlyRate,
            'totalBays': localFacility.totalBays,
            'availableBays': localFacility.availableBays,
            'status': localFacility.verificationStatus == VerificationStatus.approved ? 'ACTIVE' : 'PENDING_VERIFICATION',
            'verificationStatus': localFacility.verificationStatus.code,
            'provider': {
              'displayName': localFacility.businessName,
              'providerType': localFacility.category,
              'user': {
                'name': localFacility.contactPerson,
                'phone': localFacility.contactPhone,
                'email': localFacility.contactEmail,
              }
            }
          });
        }
      }

      setState(() {
        _pendingList = backendPending;
        _allList = backendAll;
        _pendingSpaces = _pendingList.length;
        _totalSpaces = _allList.length;
        _activeSpaces = _allList.where((s) => s['verificationStatus'] == 'VERIFIED' || s['verificationStatus'] == 'APPROVED').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleDecision(String spaceId, String action) async {
    final bool isApprove = action == 'APPROVE';

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CarLoadingIndicator()),
    );

    try {
      // 1. Backend update
      try {
        await ApiClient().dio.post('/admin/spaces/$spaceId/verify', data: {
          'action': action,
        });
      } catch (e) {
        debugPrint('[SuperAdmin] verifySpace network error: $e');
      }

      // 2. If it's the currently logged-in provider's facility, update client state
      final currentLocal = UserStateService.instance.providerFacility;
      if (currentLocal != null && currentLocal.id == spaceId) {
        await UserStateService.instance.updateFacilityVerificationStatus(
          isApprove ? VerificationStatus.approved : VerificationStatus.rejected,
        );
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        SweetPopup.show(
          context,
          title: isApprove ? 'Listing Approved & Live!' : 'Listing Rejected',
          message: isApprove
              ? 'Facility has been verified. Seekers across the platform can now search, navigate, and book slots.'
              : 'The facility submission was marked as rejected.',
          icon: isApprove ? Icons.verified_rounded : Icons.cancel_outlined,
          iconColor: isApprove ? AppTheme.success : AppTheme.error,
        );

        // Reload data
        _loadAdminData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        SweetPopup.show(
          context,
          title: 'Action Error',
          message: e.toString(),
          icon: Icons.error_outline_rounded,
          iconColor: AppTheme.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Super Admin Console',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEVELOPER',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            Text(
              'Real-Time Facility Approvals & DB Verification',
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Queue',
            onPressed: _loadAdminData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppTheme.butter : AppTheme.forestGreen,
          unselectedLabelColor: Theme.of(context).colorScheme.outline,
          indicatorColor: isDark ? AppTheme.butter : AppTheme.forestGreen,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending Approvals', style: TextStyle(fontWeight: FontWeight.w700)),
                  if (_pendingSpaces > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_pendingSpaces',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('All Facilities', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_totalSpaces',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.forestGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CarLoadingIndicator())
          : RefreshIndicator(
              onRefresh: _loadAdminData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error banner if any
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sync Notice: $_errorMessage',
                                style: const TextStyle(fontSize: 11, color: AppTheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // KPI Row
                    _buildKpiMetrics(isDark),
                    const SizedBox(height: 20),

                    // Quick Super Admin Guidance
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.forestGreen.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppTheme.forestGreen, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'When a provider completes onboarding, their parking space stays "Under Review" until you approve it here. Approving immediately pushes the listing into live search.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: isDark ? Colors.white70 : AppTheme.forestGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tabs Content
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildListSection(_pendingList, isPendingTab: true, isDark: isDark),
                          _buildListSection(_allList, isPendingTab: false, isDark: isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKpiMetrics(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Pending Review',
                value: '$_pendingSpaces',
                icon: Icons.pending_actions_rounded,
                color: AppTheme.amber,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'Active Live',
                value: '$_activeSpaces',
                icon: Icons.check_circle_rounded,
                color: AppTheme.success,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Total Spaces',
                value: '$_totalSpaces',
                icon: Icons.local_parking_rounded,
                color: AppTheme.forestGreen,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'Total Bookings',
                value: '$_totalBookings',
                icon: Icons.receipt_long_rounded,
                color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return NeumorphicCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(List<Map<String, dynamic>> list, {required bool isPendingTab, required bool isDark}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPendingTab ? Icons.done_all_rounded : Icons.folder_open_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                isPendingTab ? 'No Pending Approvals!' : 'No Facilities Found',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                isPendingTab
                    ? 'All provider submissions have been processed.'
                    : 'Registered facilities will appear here.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final space = list[index];
        final id = space['id']?.toString() ?? '';
        final title = space['title']?.toString() ?? 'Unnamed Facility';
        final address = space['address']?.toString() ?? 'Address not specified';
        final city = space['city']?.toString() ?? 'Pune';
        final pincode = space['pincode']?.toString() ?? '';
        final lat = (space['latitude'] as num?)?.toDouble() ?? 18.5204;
        final lng = (space['longitude'] as num?)?.toDouble() ?? 73.8567;
        final price = (space['pricePerHour'] as num?)?.toDouble() ?? 40.0;
        final totalBays = space['totalBays'] ?? 1;
        final spaceType = space['spaceType']?.toString() ?? 'Covered';
        final vStatus = space['verificationStatus']?.toString() ?? 'PENDING';

        final provider = space['provider'] as Map<String, dynamic>?;
        final displayName = provider?['displayName']?.toString() ?? 'Host';
        final category = provider?['providerType']?.toString() ?? 'INDIVIDUAL';
        final docType = provider?['documentType']?.toString() ?? 'Aadhaar / Government ID';
        final docName = provider?['documentName']?.toString() ?? 'identity_document.pdf';
        final docSize = provider?['documentSize'] as num?;

        final user = provider?['user'] as Map<String, dynamic>?;
        final ownerName = user?['name']?.toString() ?? displayName;
        final ownerPhone = user?['phone']?.toString() ?? '+91 (Host)';
        final ownerEmail = user?['email']?.toString() ?? 'host@parksync.in';

        final isPending = vStatus == 'PENDING' || vStatus == 'UNDER_REVIEW' || vStatus == 'DRAFT' || vStatus == 'PENDING_VERIFICATION';

        return NeumorphicCard(
          radius: 18,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Category & Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isPending ? AppTheme.amber : (vStatus == 'VERIFIED' || vStatus == 'APPROVED' ? AppTheme.success : AppTheme.error))
                          .withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isPending ? 'UNDER REVIEW' : (vStatus == 'VERIFIED' ? 'APPROVED' : vStatus),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isPending ? AppTheme.amber : (vStatus == 'VERIFIED' || vStatus == 'APPROVED' ? AppTheme.success : AppTheme.error),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title & Business
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'By $ownerName ($displayName) • $ownerPhone',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.butter : AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 10),

              // Location with Pin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$address, $city ${pincode.isNotEmpty ? "- $pincode" : ""}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded, size: 15, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'GPS: ${lat.toStringAsFixed(4)}°N, ${lng.toStringAsFixed(4)}°E',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),

              const Divider(height: 20),

              // Capacity & Rate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoBadge('Total Bays', '$totalBays Bays ($spaceType)'),
                  _infoBadge('Hourly Rate', '₹${price.toInt()}/hr'),
                  _infoBadge('Contact Email', ownerEmail),
                ],
              ),

              const SizedBox(height: 12),

              // Document Inspection Container (Strict 5MB check)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description_rounded, size: 20, color: AppTheme.forestGreen),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                docType,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '≤ 5 MB Valid',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.success),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            docSize != null
                                ? '$docName • ${(docSize / (1024 * 1024)).toStringAsFixed(2)} MB'
                                : '$docName • Verified on Onboarding',
                            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons for Pending items
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _handleDecision(id, 'REJECT'),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.forestGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => _handleDecision(id, 'APPROVE'),
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Approve & Make Live', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _infoBadge(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

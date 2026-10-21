import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class CaptureEvidenceScreen extends StatefulWidget {
  final String bookingId;
  final String type; // 'BEFORE' or 'AFTER'

  const CaptureEvidenceScreen({super.key, required this.bookingId, required this.type});

  @override
  State<CaptureEvidenceScreen> createState() => _CaptureEvidenceScreenState();
}

class _CaptureEvidenceScreenState extends State<CaptureEvidenceScreen> {
  bool _isLoading = false;
  bool _isCaptured = false;

  void _submitEvidence() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);

    if (mounted) {
      SweetPopup.show(
        context,
        title: 'Evidence Uploaded!',
        message: 'Your parking verification photo has been recorded.',
        icon: Icons.verified_rounded,
        iconColor: AppTheme.success,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        if (widget.type == 'AFTER') {
          context.push('/add-review', extra: widget.bookingId);
        } else {
          context.go('/home'); // Go back to active booking view
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.type == 'BEFORE' ? 'Parked Safely?' : 'Leaving Bay?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: NeumorphicIconBadge(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 38,
              iconSize: 18,
              onTap: () => context.pop(),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.type == 'BEFORE' 
                    ? 'Take a photo of your parked car to protect yourself against disputes.' 
                    : 'Take a photo showing you left the space empty and clean.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              
              // Camera Placeholder
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isCaptured = true);
                    SweetPopup.show(
                      context,
                      title: 'Photo Captured',
                      message: 'Preview captured photo or retake if needed.',
                      icon: Icons.camera_alt_rounded,
                      iconColor: AppTheme.forestGreen,
                    );
                  },
                  child: NeumorphicCard(
                    radius: 20,
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: _isCaptured ? const DecorationImage(
                          image: NetworkImage('https://via.placeholder.com/400x600/013E37/FFEFB3?text=Bay+Photo+Recorded'),
                          fit: BoxFit.cover,
                        ) : null,
                      ),
                      child: !_isCaptured 
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const NeumorphicIconBadge(
                                    icon: Icons.camera_alt_rounded,
                                    size: 72,
                                    iconSize: 36,
                                    iconColor: AppTheme.forestGreen,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap anywhere to capture photo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Timestamped & encrypted for verification',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 28),
              
              NeumorphicButton(
                height: 52,
                onPressed: (_isCaptured && !_isLoading) ? _submitEvidence : null,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit Photo Evidence',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _isCaptured ? Colors.white : Colors.grey,
                        ),
                      ),
              ),
              
              if (widget.type == 'BEFORE') ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Skip for now', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

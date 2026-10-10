import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      if (widget.type == 'AFTER') {
        context.push('/add-review', extra: widget.bookingId);
      } else {
        context.go('/home'); // Go back to active booking view
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'BEFORE' ? 'Parked Safely?' : 'Leaving?'),
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
              const SizedBox(height: 32),
              
              // Camera Placeholder
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isCaptured = true);
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      image: _isCaptured ? const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/400x600/141416/00FF87?text=Photo+Captured'),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    child: !_isCaptured 
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                const Text('Tap to open camera'),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: (_isCaptured && !_isLoading) ? _submitEvidence : null,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Submit Photo'),
              ),
              
              if (widget.type == 'BEFORE') ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Skip for now'),
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

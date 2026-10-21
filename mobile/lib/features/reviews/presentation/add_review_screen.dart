import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/sweet_popup.dart';

class AddReviewScreen extends StatefulWidget {
  final String bookingId;
  const AddReviewScreen({super.key, required this.bookingId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _rating = 5; // Default 5 stars
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_rating == 0) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);

    if (mounted) {
      SweetPopup.show(
        context,
        title: 'Review Submitted!',
        message: 'Thank you for helping the ParkSync community.',
        icon: Icons.star_rounded,
        iconColor: AppTheme.amber,
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Rate your experience',
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
                'How was your parking experience?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Your rating helps hosts maintain verified quality standards across India.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              
              // Star Rating Row inside Neumorphic Card
              NeumorphicCard(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                radius: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    final isFilled = starIndex <= _rating;
                    return IconButton(
                      iconSize: 42,
                      icon: Icon(
                        isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isFilled ? AppTheme.amber : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        setState(() => _rating = starIndex);
                      },
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 24),
              
              NeumorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                radius: 18,
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Write a public review for this parking bay (optional)...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              
              const Spacer(),
              
              NeumorphicButton(
                height: 52,
                onPressed: (_rating > 0 && !_isLoading) ? _submitReview : null,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

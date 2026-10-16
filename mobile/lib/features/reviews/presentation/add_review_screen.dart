import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddReviewScreen extends StatefulWidget {
  final String bookingId;
  const AddReviewScreen({super.key, required this.bookingId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  void _submitReview() async {
    if (_rating == 0) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/home'); // Return to home after review
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate your experience'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How was your parking experience?', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24)),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 48,
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: index < _rating ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _rating = index + 1);
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a public review (optional)',
                ),
              ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: (_rating > 0 && !_isLoading) ? _submitReview : null,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

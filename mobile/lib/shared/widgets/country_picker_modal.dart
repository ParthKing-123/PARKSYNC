import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

const List<Country> kCountries = [
  Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
  Country(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
  Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
  Country(name: 'United Arab Emirates', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
  Country(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
  Country(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
  Country(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
  Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
  Country(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
  Country(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
  Country(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
  Country(name: 'Malaysia', code: 'MY', dialCode: '+60', flag: '🇲🇾'),
  Country(name: 'Qatar', code: 'QA', dialCode: '+974', flag: '🇶🇦'),
  Country(name: 'Kuwait', code: 'KW', dialCode: '+965', flag: '🇰🇼'),
  Country(name: 'Oman', code: 'OM', dialCode: '+968', flag: '🇴🇲'),
  Country(name: 'Bahrain', code: 'BH', dialCode: '+973', flag: '🇧🇭'),
  Country(name: 'New Zealand', code: 'NZ', dialCode: '+64', flag: '🇳🇿'),
  Country(name: 'South Africa', code: 'ZA', dialCode: '+27', flag: '🇿🇦'),
  Country(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
  Country(name: 'Sweden', code: 'SE', dialCode: '+46', flag: '🇸🇪'),
  Country(name: 'Switzerland', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
  Country(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
  Country(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
  Country(name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
  Country(name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
  Country(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
  Country(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭'),
  Country(name: 'Thailand', code: 'TH', dialCode: '+66', flag: '🇹🇭'),
  Country(name: 'Vietnam', code: 'VN', dialCode: '+84', flag: '🇻🇳'),
  Country(name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
  Country(name: 'Nepal', code: 'NP', dialCode: '+977', flag: '🇳🇵'),
  Country(name: 'Sri Lanka', code: 'LK', dialCode: '+94', flag: '🇱🇰'),
  Country(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩'),
  Country(name: 'Ireland', code: 'IE', dialCode: '+353', flag: '🇮🇪'),
  Country(name: 'Norway', code: 'NO', dialCode: '+47', flag: '🇳🇴'),
  Country(name: 'Denmark', code: 'DK', dialCode: '+45', flag: '🇩🇰'),
  Country(name: 'Finland', code: 'FI', dialCode: '+358', flag: '🇫🇮'),
  Country(name: 'Poland', code: 'PL', dialCode: '+48', flag: '🇵🇱'),
  Country(name: 'Portugal', code: 'PT', dialCode: '+351', flag: '🇵🇹'),
  Country(name: 'Greece', code: 'GR', dialCode: '+30', flag: '🇬🇷'),
  Country(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
  Country(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬'),
  Country(name: 'Nigeria', code: 'NG', dialCode: '+234', flag: '🇳🇬'),
  Country(name: 'Kenya', code: 'KE', dialCode: '+254', flag: '🇰🇪'),
];

Future<Country?> showCountryPickerDialog({
  required BuildContext context,
  Country initialCountry = const Country(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    flag: '🇮🇳',
  ),
}) async {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _CountryPickerSheet(selected: initialCountry),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  final Country selected;
  const _CountryPickerSheet({required this.selected});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Country> _filtered = kCountries;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = kCountries;
      } else {
        _filtered = kCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query) ||
              c.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Country / Region',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          // Search box
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search country or code...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.cyan, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Color(0xFF1C2A42),
              ),
              itemBuilder: (context, i) {
                final country = _filtered[i];
                final isSelected = country.code == widget.selected.code;

                return InkWell(
                  onTap: () => Navigator.pop(context, country),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Row(
                      children: [
                        Text(country.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            country.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? AppTheme.cyan
                                      : AppTheme.textPrimary,
                                ),
                          ),
                        ),
                        Text(
                          country.dialCode,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppTheme.cyan
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check, color: AppTheme.cyan, size: 18),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

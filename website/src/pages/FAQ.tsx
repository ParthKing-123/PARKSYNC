import { useState, useMemo } from 'react';
import { Link } from 'react-router-dom';
import { Search, HelpCircle, ArrowRight, Sparkles, MessageCircle } from 'lucide-react';
import { Accordion, type FAQItem } from '../components/UI/Accordion';
import { Reveal } from '../components/Reveal';

const categories = [
  'All',
  'Using ParkSync',
  'Vehicle Compatibility',
  'Booking & Payments',
  'Listing Parking',
  'Verification & Authorization',
  'Privacy & Support',
];

const allFaqs: FAQItem[] = [
    // Category: Using ParkSync
    {
      id: 'use-1',
      category: 'Using ParkSync',
      question: 'Where is ParkSync currently operational?',
      answer: 'ParkSync is currently operating in an invite-only pilot phase across key Pune urban zones including Baner, Balewadi High Street, Koregaon Park, and Viman Nagar. We are progressively unlocking new localities as partner parking capacity is verified.',
    },
    {
      id: 'use-2',
      category: 'Using ParkSync',
      question: 'Do I need to download the mobile app to book parking?',
      answer: 'Yes. All active marketplace operations—including live availability checks, turn-by-turn navigation to private gates, digital QR access passes, and payments—occur exclusively within the ParkSync mobile application for Android and iOS.',
    },
    {
      id: 'use-3',
      category: 'Using ParkSync',
      question: 'How do I know my reserved spot is guaranteed?',
      answer: 'When you book a spot on ParkSync, that specific demarkated parking bay is locked in the provider\'s system for your selected timeframe. Providers cannot double-book that slot during your reservation.',
    },

    // Category: Vehicle Compatibility
    {
      id: 'comp-1',
      category: 'Vehicle Compatibility',
      question: 'How does ParkSync know my car\'s dimensions?',
      answer: 'We maintain an extensive, continuously updated technical database of over 200 Indian vehicle models—including exact bumper-to-bumper length, width with folded mirrors, ground clearance, and vehicle height. You simply select your vehicle from the dropdown once.',
    },
    {
      id: 'comp-2',
      category: 'Vehicle Compatibility',
      question: 'What if my car has aftermarket roof carriers or bullbars?',
      answer: 'Aftermarket modifications can alter vehicle dimensions. In our mobile app settings, you can easily toggle "Roof Carrier Equipped" or adjust clearance preferences to ensure the compatibility algorithm factors in additional height.',
    },
    {
      id: 'comp-3',
      category: 'Vehicle Compatibility',
      question: 'Does compatibility guarantee zero chance of scraping?',
      answer: 'The vehicle compatibility check compares manufacturer dimensions with verified bay measurements to identify suitable spaces. While it provides calculated margins for length, width, and overhead clearance, drivers remain responsible for careful driving and navigating real-world architectural features such as steep ramps or adjacent pillars.',
    },

    // Category: Booking & Payments
    {
      id: 'pay-1',
      category: 'Booking & Payments',
      question: 'What payment methods are supported?',
      answer: 'Through our secure Indian payment gateway integration, we support UPI (Google Pay, PhonePe, Paytm, BHIM), Net Banking, and all major Credit and Debit Cards. Zero cash handling at the gate.',
    },
    {
      id: 'pay-2',
      category: 'Booking & Payments',
      question: 'Can I extend my parking reservation if I run late?',
      answer: 'Yes, provided the bay is not pre-booked by another driver immediately following your slot. You will receive an in-app reminder 15 minutes before expiry allowing you to extend your reservation in 30-minute increments.',
    },
    {
      id: 'pay-3',
      category: 'Booking & Payments',
      question: 'What is the cancellation and refund policy?',
      answer: 'Cancellations made at least 1 hour prior to your reserved arrival time receive a 100% instant refund. For cancellations within the hour, a nominal fee may apply to compensate the provider who held the slot vacant.',
    },

    // Category: Listing Parking
    {
      id: 'list-1',
      category: 'Listing Parking',
      question: 'Can I list an unused driveway or commercial basement in Pune?',
      answer: 'Yes! Authorized property owners, restaurants, cafés, corporate towers, and retail venues with dedicated, accessible bays can apply to list capacity on ParkSync. Use our "For Providers" page to submit your details.',
    },
    {
      id: 'list-2',
      category: 'Listing Parking',
      question: 'How much can I earn by listing parking spaces?',
      answer: 'Earnings depend on your property locality, bay count, and available hours. High-demand areas like Baner High Street or Koregaon Park command higher hourly rates. Providers receive direct bank payouts on a regular schedule.',
    },
    {
      id: 'list-3',
      category: 'Listing Parking',
      question: 'Do I have to monitor the parking gate myself?',
      answer: 'No. Drivers scan a digital QR gate pass or show an active booking badge to your existing security guard. For private independent bays, visual bay numbers and arrival check-ins keep the process hands-off.',
    },

    // Category: Verification & Authorization
    {
      id: 'ver-1',
      category: 'Verification & Authorization',
      question: 'Can I list a parking bay in my housing society?',
      answer: 'Only if the parking space is an officially allotted, demarkated private bay under your ownership, and society bylaws or management permit visitor parking arrangements. Common-area visitor bays require formal managing committee authorization.',
    },
    {
      id: 'ver-2',
      category: 'Verification & Authorization',
      question: 'What documents are required to approve a listing?',
      answer: 'We request government identity verification (PAN / Aadhaar) for individuals, or business registration (GST / Shop Act) for commercial enterprises, alongside clear photos showing entrance clearance and demarcated bay lines.',
    },

    // Category: Privacy & Support
    {
      id: 'priv-1',
      category: 'Privacy & Support',
      question: 'Is my phone number shared with parking hosts?',
      answer: 'No. All communication and booking records are managed securely within the ParkSync platform. Your personal mobile number is never exposed publicly or shared without consent.',
    },
    {
      id: 'priv-2',
      category: 'Privacy & Support',
      question: 'How do I reach the ParkSync Pune support team?',
      answer: 'You can contact our team via the in-app Help Center or reach out directly through our Contact page for partnership or general pilot inquiries.',
    },
  ];

export const FAQ: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  // Filtered FAQs based on category & search term
  const filteredFaqs = useMemo(() => {
    return allFaqs.filter((item) => {
      const matchesCategory =
        selectedCategory === 'All' || item.category === selectedCategory;
      const matchesSearch =
        item.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.answer.toLowerCase().includes(searchTerm.toLowerCase());
      return matchesCategory && matchesSearch;
    });
  }, [selectedCategory, searchTerm]);

  return (
    <div className="w-full bg-[#08090D] text-[#F7F7FC] pt-32 pb-24 px-6 sm:px-8 lg:px-12">
      <div className="max-w-4xl mx-auto space-y-16">
        {/* Header */}
        <div className="text-center space-y-4">
          <Reveal>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#121520] border border-white/10 text-xs font-subheading text-[#C7A1FF]">
              <Sparkles size={12} className="text-[#A020F0]" />
              HELP & DOCUMENTATION
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <h1 className="text-4xl sm:text-5xl font-extrabold font-heading text-white tracking-tight">
              Frequently Asked Questions
            </h1>
          </Reveal>

          <Reveal delay={0.2}>
            <p className="text-base text-[#A7ADBD] max-w-xl mx-auto font-body">
              Clear, transparent answers about using ParkSync, vehicle compatibility, hosting spaces, and our Pune pilot.
            </p>
          </Reveal>
        </div>

        {/* Real-time Search Box */}
        <div className="relative">
          <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-[#747C90]" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search by keyword (e.g. Creta, refund, society, pricing)..."
            className="w-full pl-11 pr-4 py-3.5 rounded-2xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0] transition-colors"
          />
        </div>

        {/* Category Filter Pills */}
        <div className="flex flex-wrap gap-2 justify-center">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-subheading transition-all ${
                selectedCategory === cat
                  ? 'bg-[#A020F0] text-white font-semibold shadow-md shadow-[#A020F0]/25'
                  : 'bg-[#0D0F16] border border-white/5 text-[#A7ADBD] hover:border-white/15 hover:text-white'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Accordion Results */}
        {filteredFaqs.length > 0 ? (
          <Accordion items={filteredFaqs} allowMultiple />
        ) : (
          <div className="p-12 text-center bg-[#0D0F16] rounded-2xl border border-white/5 space-y-3">
            <HelpCircle size={32} className="mx-auto text-[#747C90]" />
            <div className="text-base font-bold text-white font-heading">No matching questions found</div>
            <p className="text-xs text-[#A7ADBD]">
              Try searching for terms like "compatibility", "Pune", "pricing", or clear your filter.
            </p>
          </div>
        )}

        {/* Unanswered Question CTA */}
        <div className="p-8 rounded-3xl bg-[#121520] border border-white/10 text-center space-y-4">
          <MessageCircle size={28} className="mx-auto text-[#A020F0]" />
          <h3 className="text-xl font-bold font-heading text-white">Still have questions?</h3>
          <p className="text-xs text-[#A7ADBD] max-w-md mx-auto">
            Our Pune pilot team is here to help with specific vehicle inquiries or partnership proposals.
          </p>
          <Link
            to="/contact"
            className="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-[#A020F0] hover:bg-[#8e1cd6] text-white text-xs font-semibold transition-all shadow-md shadow-[#A020F0]/20"
          >
            <span>Contact the Team</span>
            <ArrowRight size={14} />
          </Link>
        </div>
      </div>
    </div>
  );
};

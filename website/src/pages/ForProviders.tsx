import { useState } from 'react';
import { 
  Building2, Store, ShieldCheck, CheckCircle2, 
  ArrowRight, Sparkles, Loader2, Check, Clock
} from 'lucide-react';
import { Reveal } from '../components/Reveal';

export const ForProviders: React.FC = () => {
  const [name, setName] = useState('');
  const [propertyType, setPropertyType] = useState('Restaurant / Café');
  const [propertyName, setPropertyName] = useState('');
  const [locality, setLocality] = useState('');
  const [contact, setContact] = useState('');
  const [capacity, setCapacity] = useState('');
  const [consent, setConsent] = useState(true);

  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!name.trim()) {
      setError('Please provide your name');
      return;
    }
    if (!contact.trim()) {
      setError('Please provide a valid phone or email');
      return;
    }
    if (!locality.trim()) {
      setError('Please provide the area or locality in Pune');
      return;
    }
    if (!consent) {
      setError('Please acknowledge permission for our team to contact you');
      return;
    }

    setLoading(true);

    setTimeout(() => {
      try {
        const existing = JSON.parse(localStorage.getItem('parksync_provider_inquiries') || '[]');
        existing.push({
          name,
          propertyType,
          propertyName,
          locality,
          contact,
          capacity,
          date: new Date().toISOString(),
        });
        localStorage.setItem('parksync_provider_inquiries', JSON.stringify(existing));
      } catch (err) {
        console.warn('Storage error:', err);
      }

      setLoading(false);
      setSubmitted(true);
    }, 700);
  };

  return (
    <div className="w-full bg-[#08090D] text-[#F7F7FC] pt-32 pb-24 px-6 sm:px-8 lg:px-12">
      <div className="max-w-6xl mx-auto space-y-24">
        {/* Hero */}
        <div className="max-w-3xl space-y-6">
          <Reveal>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#121520] border border-white/10 text-xs font-subheading text-[#C7A1FF]">
              <Sparkles size={12} className="text-[#A020F0]" />
              PARKING MONETIZATION FOR AUTHORIZED SPACES
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold font-heading text-white tracking-tight leading-[1.1]">
              Put unused parking capacity <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-white via-[#F7F7FC] to-[#C7A1FF]">
                to better use.
              </span>
            </h1>
          </Reveal>

          <Reveal delay={0.2}>
            <p className="text-base sm:text-lg text-[#A7ADBD] leading-relaxed font-body">
              Monetize empty bays during off-peak hours without sacrificing security or operational control. Built for restaurants, offices, tech parks, and verified private space owners in Pune.
            </p>
          </Reveal>
        </div>

        {/* 4 Provider Archetypes */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-6 space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#A020F0]/15 text-[#A020F0] flex items-center justify-center">
              <Store size={20} />
            </div>
            <h3 className="text-lg font-bold font-heading text-white">Restaurants & Cafés</h3>
            <p className="text-xs text-[#A7ADBD] leading-relaxed font-body">
              Your parking bays are vacant between 11 AM and 5 PM on weekdays. Open them to corporate seekers and turn empty real estate into recurring income.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-6 space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#C7A1FF]/15 text-[#C7A1FF] flex items-center justify-center">
              <Building2 size={20} />
            </div>
            <h3 className="text-lg font-bold font-heading text-white">Offices & Tech Parks</h3>
            <p className="text-xs text-[#A7ADBD] leading-relaxed font-body">
              Commercial towers in Hinjewadi or Baner sit empty on weekends. Monetize visitor bays for shoppers and event attendees nearby.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-6 space-y-3">
            <div className="w-10 h-10 rounded-xl bg-[#10B981]/15 text-[#10B981] flex items-center justify-center">
              <ShieldCheck size={20} />
            </div>
            <h3 className="text-lg font-bold font-heading text-white">Private Owners</h3>
            <p className="text-xs text-[#A7ADBD] leading-relaxed font-body">
              If you own an independent driveway or demarkated private bay in a compliant gated layout, monetize it while you're away at work.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-6 space-y-3">
            <div className="w-10 h-10 rounded-xl bg-white/10 text-white flex items-center justify-center">
              <Clock size={20} />
            </div>
            <h3 className="text-lg font-bold font-heading text-white">Parking Operators</h3>
            <p className="text-xs text-[#A7ADBD] leading-relaxed font-body">
              Operators with authorized vacant lots can increase digital occupancy by accepting pre-booked reservations through the ParkSync network.
            </p>
          </div>
        </div>

        {/* Onboarding Form Section */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-start bg-[#121520] border border-white/10 rounded-3xl p-8 sm:p-12 shadow-2xl">
          <div className="lg:col-span-5 space-y-6">
            <span className="text-xs font-subheading uppercase tracking-wider text-[#A020F0] font-semibold">
              JOIN THE PILOT AS A HOST
            </span>
            <h2 className="text-3xl font-bold font-heading text-white">
              Tell us about your parking capacity
            </h2>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              Submit your property overview. Our Pune team will conduct a rapid dimension and authorization check before scheduling a walkthrough.
            </p>

            <div className="space-y-3 pt-2 text-xs text-[#A7ADBD]">
              <div className="flex items-center gap-2">
                <Check size={16} className="text-[#10B981]" />
                <span>Zero listing fees during the Pune pilot phase</span>
              </div>
              <div className="flex items-center gap-2">
                <Check size={16} className="text-[#10B981]" />
                <span>Automated monthly direct bank transfers</span>
              </div>
              <div className="flex items-center gap-2">
                <Check size={16} className="text-[#10B981]" />
                <span>Full control over hourly rates & operating windows</span>
              </div>
            </div>
          </div>

          {/* Real Working Form */}
          <div className="lg:col-span-7 bg-[#0D0F16] border border-white/5 rounded-2xl p-6 sm:p-8">
            {!submitted ? (
              <form onSubmit={handleSubmit} className="space-y-4 font-body">
                {error && (
                  <div className="p-3 bg-red-500/10 border border-red-500/30 text-red-300 text-xs rounded-lg">
                    {error}
                  </div>
                )}

                <div>
                  <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                    Your Name *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Vikram Joshi"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                      Property Category *
                    </label>
                    <select
                      value={propertyType}
                      onChange={(e) => setPropertyType(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white text-sm focus:outline-none focus:border-[#A020F0]"
                    >
                      <option value="Restaurant / Café">Restaurant / Café</option>
                      <option value="Office / Tech Park">Office / Tech Park</option>
                      <option value="Private Owner">Private Owner</option>
                      <option value="Commercial Lot">Commercial Parking Lot</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                      Property / Venue Name
                    </label>
                    <input
                      type="text"
                      placeholder="e.g. The Green Door Café"
                      value={propertyName}
                      onChange={(e) => setPropertyName(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                      Phone Number or Email *
                    </label>
                    <input
                      type="text"
                      required
                      placeholder="+91 98220 00000"
                      value={contact}
                      onChange={(e) => setContact(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                      Locality in Pune *
                    </label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. Baner, Pune"
                      value={locality}
                      onChange={(e) => setLocality(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                    Approximate Parking Capacity (Optional)
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. 6 car bays and 10 bike spots"
                    value={capacity}
                    onChange={(e) => setCapacity(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                  />
                </div>

                <div className="flex items-start gap-2 pt-2">
                  <input
                    type="checkbox"
                    id="consent"
                    checked={consent}
                    onChange={(e) => setConsent(e.target.checked)}
                    className="mt-1 accent-[#A020F0]"
                  />
                  <label htmlFor="consent" className="text-[11px] text-[#A7ADBD] leading-relaxed">
                    I confirm I have authorization to discuss listing this parking capacity and agree to be contacted by the ParkSync Pune team.
                  </label>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full py-3.5 px-6 rounded-xl bg-[#A020F0] hover:bg-[#8e1cd6] text-white font-semibold text-sm transition-all shadow-lg shadow-[#A020F0]/25 flex items-center justify-center gap-2 disabled:opacity-60"
                >
                  {loading ? (
                    <>
                      <Loader2 size={16} className="animate-spin" />
                      Submitting Proposal...
                    </>
                  ) : (
                    <>
                      Submit Property for Review <ArrowRight size={16} />
                    </>
                  )}
                </button>
              </form>
            ) : (
              <div className="text-center py-10 space-y-4">
                <div className="w-14 h-14 mx-auto rounded-full bg-[#10B981]/20 text-[#10B981] flex items-center justify-center">
                  <CheckCircle2 size={32} />
                </div>
                <h3 className="text-2xl font-bold font-heading text-white">
                  Submission Received
                </h3>
                <p className="text-sm text-[#A7ADBD] max-w-md mx-auto">
                  Thank you, <strong className="text-white">{name}</strong>. Our Pune onboarding coordinator will review your property details for{' '}
                  <strong className="text-[#C7A1FF]">{locality}</strong> and contact you within 24 hours.
                </p>
                <button
                  onClick={() => setSubmitted(false)}
                  className="py-2 px-6 rounded-xl bg-white/10 text-xs text-white hover:bg-white/15 transition-colors mt-2"
                >
                  Submit Another Space
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

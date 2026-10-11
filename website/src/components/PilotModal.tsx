import React, { useState, useEffect } from 'react';
import { X, CheckCircle2, Shield, ArrowRight, Loader2, Sparkles } from 'lucide-react';

interface PilotModalProps {
  isOpen: boolean;
  onClose: () => void;
  defaultRole?: 'seeker' | 'provider';
}

export const PilotModal: React.FC<PilotModalProps> = ({ isOpen, onClose, defaultRole = 'seeker' }) => {
  const [role, setRole] = useState<'seeker' | 'provider'>(defaultRole);
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [locality, setLocality] = useState('');
  const [extraDetail, setExtraDetail] = useState(''); // Car make/model for seeker, or parking capacity/type for provider
  
  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');
  const [refId, setRefId] = useState('');


  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!fullName.trim()) {
      setError('Please enter your full name');
      return;
    }
    if (!phone.trim() || phone.replace(/\D/g, '').length < 10) {
      setError('Please provide a valid 10-digit mobile number');
      return;
    }
    if (!locality.trim()) {
      setError('Please enter your area or locality in Pune (e.g. Baner, Koregaon Park)');
      return;
    }

    setLoading(true);

    setTimeout(() => {
      const generatedRef = `PUN-${role === 'seeker' ? 'DRV' : 'PRV'}-${Math.floor(1000 + Math.random() * 9000)}`;
      setRefId(generatedRef);
      
      try {
        const existing = JSON.parse(localStorage.getItem('parksync_pilot_registrations') || '[]');
        existing.push({
          ref: generatedRef,
          role,
          fullName,
          phone,
          email,
          locality,
          extraDetail,
          date: new Date().toISOString(),
        });
        localStorage.setItem('parksync_pilot_registrations', JSON.stringify(existing));
      } catch (err) {
        console.warn('LocalStorage save error:', err);
      }

      setLoading(false);
      setSubmitted(true);
    }, 800);
  };

  const handleResetAndClose = () => {
    setSubmitted(false);
    setFullName('');
    setPhone('');
    setEmail('');
    setLocality('');
    setExtraDetail('');
    setError('');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in duration-200">
      <div 
        className="relative w-full max-w-lg bg-[#0D0F16] border border-white/10 rounded-2xl shadow-2xl p-6 sm:p-8 overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Subtle Violet Glow */}
        <div className="absolute top-0 right-0 w-64 h-64 bg-[#A020F0]/10 rounded-full blur-3xl pointer-events-none -mr-20 -mt-20"></div>

        <button
          onClick={handleResetAndClose}
          className="absolute top-5 right-5 text-[#A7ADBD] hover:text-white p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-colors"
          aria-label="Close modal"
        >
          <X size={18} />
        </button>

        {!submitted ? (
          <div>
            <div className="flex items-center gap-2 mb-2">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-[#A020F0]/15 text-[#C7A1FF] border border-[#A020F0]/30 font-subheading">
                <Sparkles size={12} /> Pune Pilot Phase
              </span>
            </div>
            
            <h2 className="text-2xl sm:text-3xl font-bold text-[#F7F7FC] font-heading tracking-tight mb-2">
              Join the ParkSync Pilot
            </h2>
            <p className="text-sm text-[#A7ADBD] mb-6 font-body">
              Early access rolling out across high-demand Pune hubs including Baner, Koregaon Park, and Viman Nagar.
            </p>

            {/* Role Switcher */}
            <div className="grid grid-cols-2 p-1 bg-[#121520] rounded-xl border border-white/5 mb-6">
              <button
                type="button"
                onClick={() => setRole('seeker')}
                className={`py-2 px-3 text-xs sm:text-sm font-medium rounded-lg transition-all font-subheading ${
                  role === 'seeker'
                    ? 'bg-[#A020F0] text-white shadow-md'
                    : 'text-[#A7ADBD] hover:text-white'
                }`}
              >
                I am a Driver / Seeker
              </button>
              <button
                type="button"
                onClick={() => setRole('provider')}
                className={`py-2 px-3 text-xs sm:text-sm font-medium rounded-lg transition-all font-subheading ${
                  role === 'provider'
                    ? 'bg-[#A020F0] text-white shadow-md'
                    : 'text-[#A7ADBD] hover:text-white'
                }`}
              >
                I Offer Parking Space
              </button>
            </div>

            {error && (
              <div className="mb-4 p-3 bg-red-500/10 border border-red-500/30 text-red-300 text-xs rounded-lg">
                {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4 font-body">
              <div>
                <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                  Full Name *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Rohan Kulkarni"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0] transition-colors"
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                    Mobile Number (+91) *
                  </label>
                  <input
                    type="tel"
                    required
                    placeholder="9876543210"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0] transition-colors"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                    Email Address (Optional)
                  </label>
                  <input
                    type="email"
                    placeholder="rohan@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0] transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                  Primary Pune Locality *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Baner, Balewadi High Street, Viman Nagar"
                  value={locality}
                  onChange={(e) => setLocality(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0] transition-colors"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                  {role === 'seeker'
                    ? 'Your Car Model (e.g. Hyundai Creta, Honda City)'
                    : 'Parking Property Type (e.g. Restaurant, Office, Private Lot)'}
                </label>
                <input
                  type="text"
                  placeholder={
                    role === 'seeker'
                      ? 'e.g. Tata Nexon 2023 or Mahindra XUV700'
                      : 'e.g. Café parking with 8 dedicated bays'
                  }
                  value={extraDetail}
                  onChange={(e) => setExtraDetail(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl bg-[#121520] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0] transition-colors"
                />
              </div>

              <div className="pt-2">
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full flex items-center justify-center gap-2 py-3.5 px-6 rounded-xl bg-[#A020F0] hover:bg-[#8e1cd6] text-white font-semibold text-sm transition-all shadow-lg shadow-[#A020F0]/25 disabled:opacity-60"
                >
                  {loading ? (
                    <>
                      <Loader2 size={16} className="animate-spin" />
                      Registering Interest...
                    </>
                  ) : (
                    <>
                      Confirm Pilot Reservation <ArrowRight size={16} />
                    </>
                  )}
                </button>
              </div>

              <div className="flex items-center justify-center gap-1.5 text-[11px] text-[#747C90]">
                <Shield size={12} className="text-[#A020F0]" />
                Zero spam. You will only receive early test invites for Pune spots.
              </div>
            </form>
          </div>
        ) : (
          <div className="text-center py-6">
            <div className="w-14 h-14 mx-auto rounded-full bg-[#10B981]/15 border border-[#10B981]/30 flex items-center justify-center text-[#10B981] mb-4">
              <CheckCircle2 size={32} />
            </div>

            <h3 className="text-2xl font-bold text-white font-heading mb-2">
              You're on the Priority List
            </h3>
            <p className="text-sm text-[#A7ADBD] mb-6 font-body max-w-sm mx-auto">
              Thank you, <strong className="text-white">{fullName}</strong>. Your pilot registration for{' '}
              <strong className="text-[#C7A1FF]">{locality}</strong> has been secured.
            </p>

            <div className="bg-[#121520] border border-white/10 rounded-xl p-4 mb-6 max-w-xs mx-auto">
              <div className="text-xs text-[#747C90] mb-1 uppercase tracking-wider font-subheading">Pilot Priority Pass</div>
              <div className="text-lg font-mono font-bold text-[#F7F7FC] tracking-wider">{refId}</div>
            </div>

            <p className="text-xs text-[#747C90] mb-6">
              Our Pune team will notify you via WhatsApp / SMS once your locality is unlocked in our pilot release.
            </p>

            <button
              onClick={handleResetAndClose}
              className="py-3 px-8 rounded-xl bg-white/10 hover:bg-white/15 text-white text-sm font-semibold transition-colors"
            >
              Done
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

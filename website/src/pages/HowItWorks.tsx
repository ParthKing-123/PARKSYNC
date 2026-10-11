import { 
  MapPin, CheckCircle2, ShieldCheck, QrCode, 
  Car, Camera, Sparkles
} from 'lucide-react';
import { Reveal } from '../components/Reveal';
import { EngineeringCompatibilityVisual } from '../components/UI/EngineeringCompatibilityVisual';

interface HowItWorksProps {
  onOpenPilot: (role?: 'seeker' | 'provider') => void;
}

export const HowItWorks: React.FC<HowItWorksProps> = ({ onOpenPilot }) => {
  return (
    <div className="w-full bg-[#08090D] text-[#F7F7FC] pt-32 pb-24 px-6 sm:px-8 lg:px-12">
      <div className="max-w-6xl mx-auto space-y-28">
        {/* Dedicated Hero */}
        <div className="max-w-3xl space-y-6">
          <Reveal>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#121520] border border-white/10 text-xs font-subheading text-[#C7A1FF]">
              <Sparkles size={12} className="text-[#A020F0]" />
              PRODUCT DEEP DIVE
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold font-heading text-white tracking-tight leading-[1.1]">
              From searching to parking. <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-white via-[#F7F7FC] to-[#C7A1FF]">
                One clear journey.
              </span>
            </h1>
          </Reveal>

          <Reveal delay={0.2}>
            <p className="text-base sm:text-lg text-[#A7ADBD] leading-relaxed font-body">
              ParkSync brings destination, vehicle compatibility, parking details, and booking into one simple mobile experience. Here is exactly how the system operates from start to finish.
            </p>
          </Reveal>
        </div>

        {/* =========================================================================
            DETAILED DRIVER JOURNEY (4 STEPS WITH VISUALS)
           ========================================================================= */}
        <div className="space-y-16">
          <div className="border-b border-white/10 pb-6">
            <h2 className="text-2xl sm:text-3xl font-bold font-heading text-white">
              The Driver Experience
            </h2>
            <p className="text-sm text-[#A7ADBD] mt-1 font-body">
              How you reserve, navigate, and park via the mobile application.
            </p>
          </div>

          <div className="space-y-12">
            {/* Step 1 */}
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center bg-[#0D0F16] border border-white/5 rounded-3xl p-6 sm:p-8">
              <div className="lg:col-span-5 space-y-4">
                <div className="text-xs font-mono font-bold text-[#A020F0]">STEP 01</div>
                <h3 className="text-2xl font-bold font-heading text-white">
                  Tell us where you're going
                </h3>
                <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
                  Instead of driving aimlessly toward your venue and hoping for street parking, open the ParkSync app and set your target destination and estimated hours in Pune.
                </p>
                <div className="flex items-center gap-2 text-xs text-[#C7A1FF]">
                  <MapPin size={14} className="text-[#A020F0]" />
                  <span>Supports pinpoint landmarks, restaurants, and business complexes.</span>
                </div>
              </div>

              <div className="lg:col-span-7 bg-[#121520] border border-white/10 rounded-2xl p-6 flex flex-col justify-center">
                <div className="text-xs font-subheading text-[#747C90] uppercase tracking-wider mb-3">
                  Illustrative Destination Search
                </div>
                <div className="p-3 bg-[#08090D] border border-white/10 rounded-xl flex items-center justify-between text-sm text-white">
                  <div className="flex items-center gap-2">
                    <MapPin size={16} className="text-[#A020F0]" />
                    <span>Effingut Brewhouse, Baner, Pune</span>
                  </div>
                  <span className="text-xs text-[#10B981] font-semibold">3 partner spots nearby</span>
                </div>
              </div>
            </div>

            {/* Step 2 */}
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center bg-[#0D0F16] border border-white/5 rounded-3xl p-6 sm:p-8">
              <div className="lg:col-span-5 space-y-4">
                <div className="text-xs font-mono font-bold text-[#A020F0]">STEP 02</div>
                <h3 className="text-2xl font-bold font-heading text-white">
                  Find a space that fits
                </h3>
                <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
                  No measuring tape needed. Select your car make and model from our catalog of 200+ Indian vehicle profiles. The engine filters out bays that are too narrow, too short, or have low ceiling clearance.
                </p>
                <div className="flex items-center gap-2 text-xs text-[#10B981]">
                  <CheckCircle2 size={14} />
                  <span>Door swing clearance and bumper buffers verified.</span>
                </div>
              </div>

              <div className="lg:col-span-7 bg-[#121520] border border-white/10 rounded-2xl p-6">
                <div className="text-xs font-subheading text-[#747C90] uppercase tracking-wider mb-3">
                  Illustrative Compatibility Match
                </div>
                <div className="p-4 bg-[#08090D] border border-[#10B981]/30 rounded-xl flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-[#10B981]/15 text-[#10B981] flex items-center justify-center">
                      <Car size={20} />
                    </div>
                    <div>
                      <div className="text-sm font-bold text-white">Tata Nexon EV (2024)</div>
                      <div className="text-xs text-[#A7ADBD]">Length: 3,994mm • Fits Space 02 with +1,006mm buffer</div>
                    </div>
                  </div>
                  <span className="px-2.5 py-1 rounded-full bg-[#10B981]/20 text-[#10B981] text-xs font-bold">
                    PERFECT FIT ✓
                  </span>
                </div>
              </div>
            </div>

            {/* Step 3 */}
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center bg-[#0D0F16] border border-white/5 rounded-3xl p-6 sm:p-8">
              <div className="lg:col-span-5 space-y-4">
                <div className="text-xs font-mono font-bold text-[#A020F0]">STEP 03</div>
                <h3 className="text-2xl font-bold font-heading text-white">
                  Check details & reserve
                </h3>
                <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
                  Review physical photographs of the bay, lighting status, security guards, CCTV surveillance, and covered roofing. Pay securely in seconds inside the app.
                </p>
                <div className="flex items-center gap-2 text-xs text-[#C7A1FF]">
                  <ShieldCheck size={14} className="text-[#A020F0]" />
                  <span>Guaranteed slot reservation held exclusively for you.</span>
                </div>
              </div>

              <div className="lg:col-span-7 bg-[#121520] border border-white/10 rounded-2xl p-6">
                <div className="text-xs font-subheading text-[#747C90] uppercase tracking-wider mb-3">
                  Illustrative Reservation Voucher
                </div>
                <div className="p-4 bg-[#08090D] border border-white/10 rounded-xl flex justify-between items-center text-xs">
                  <div>
                    <div className="text-white font-bold text-sm">Skyline Corporate Basement Bay B3</div>
                    <div className="text-[#A7ADBD] mt-0.5">24/7 Guarded • CCTV • Covered</div>
                  </div>
                  <div className="text-right">
                    <div className="text-sm font-bold text-[#A020F0]">₹40/hr</div>
                    <div className="text-[#10B981] text-[11px]">Instant Confirm</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Step 4 */}
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center bg-[#0D0F16] border border-white/5 rounded-3xl p-6 sm:p-8">
              <div className="lg:col-span-5 space-y-4">
                <div className="text-xs font-mono font-bold text-[#A020F0]">STEP 04</div>
                <h3 className="text-2xl font-bold font-heading text-white">
                  Arrive with confidence & audit
                </h3>
                <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
                  Follow turn-by-turn navigation directly to the private parking entrance. Present your digital QR pass. Capture optional before/after photos upon parking to verify vehicle condition.
                </p>
                <div className="flex items-center gap-2 text-xs text-[#10B981]">
                  <Camera size={14} />
                  <span>Digital condition record securely stored in your booking history.</span>
                </div>
              </div>

              <div className="lg:col-span-7 bg-[#121520] border border-white/10 rounded-2xl p-6">
                <div className="text-xs font-subheading text-[#747C90] uppercase tracking-wider mb-3">
                  Illustrative Arrival Pass
                </div>
                <div className="p-4 bg-[#08090D] border border-white/10 rounded-xl flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-white text-black flex items-center justify-center">
                      <QrCode size={24} />
                    </div>
                    <div>
                      <div className="text-xs font-mono text-white font-bold">PUN-BK-7749</div>
                      <div className="text-[11px] text-[#A7ADBD]">Valid: 10:00 AM – 12:00 PM</div>
                    </div>
                  </div>
                  <span className="text-xs text-[#C7A1FF] font-medium">Gate Pass Active</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* =========================================================================
            WHY COMPATIBILITY MATTERS
           ========================================================================= */}
        <div id="compatibility" className="space-y-8 scroll-mt-24">
          <div className="max-w-2xl space-y-3">
            <span className="text-xs font-subheading uppercase tracking-wider text-[#A020F0] font-semibold">
              SIGNATURE FEATURE IN DEPTH
            </span>
            <h2 className="text-3xl font-bold font-heading text-white">
              Why vehicle compatibility matters
            </h2>
            <p className="text-sm text-[#A7ADBD]">
              In India, vehicle profiles range from 3.7-meter hatchbacks to 4.8-meter 7-seaters. Many commercial bays in older Pune complexes cannot accommodate large SUVs. We solve this mathematically.
            </p>
          </div>

          <EngineeringCompatibilityVisual />
        </div>

        {/* =========================================================================
            PROVIDER ONBOARDING PROCESS
           ========================================================================= */}
        <div className="space-y-8">
          <div className="border-b border-white/10 pb-6">
            <h2 className="text-2xl sm:text-3xl font-bold font-heading text-white">
              The Provider Journey
            </h2>
            <p className="text-sm text-[#A7ADBD] mt-1 font-body">
              How property hosts, restaurants, and offices monetize capacity.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <div className="bg-[#121520] border border-white/5 rounded-2xl p-6">
              <div className="text-xs font-mono font-bold text-[#A020F0] mb-3">STAGE 1</div>
              <h3 className="text-base font-bold font-heading text-white mb-2">Space Survey</h3>
              <p className="text-xs text-[#A7ADBD] leading-relaxed">
                Provide parking bay count, location, entrance clearance, and physical photos of the facility.
              </p>
            </div>

            <div className="bg-[#121520] border border-white/5 rounded-2xl p-6">
              <div className="text-xs font-mono font-bold text-[#A020F0] mb-3">STAGE 2</div>
              <h3 className="text-base font-bold font-heading text-white mb-2">Vetting & Audit</h3>
              <p className="text-xs text-[#A7ADBD] leading-relaxed">
                Our local Pune team verifies business/owner identity, authorization, and parking bay dimensions.
              </p>
            </div>

            <div className="bg-[#121520] border border-white/5 rounded-2xl p-6">
              <div className="text-xs font-mono font-bold text-[#A020F0] mb-3">STAGE 3</div>
              <h3 className="text-base font-bold font-heading text-white mb-2">Schedule Control</h3>
              <p className="text-xs text-[#A7ADBD] leading-relaxed">
                Set hours when bays are available for public booking (e.g. daytime office hours or weekend nights).
              </p>
            </div>

            <div className="bg-[#121520] border border-white/5 rounded-2xl p-6">
              <div className="text-xs font-mono font-bold text-[#A020F0] mb-3">STAGE 4</div>
              <h3 className="text-base font-bold font-heading text-white mb-2">Earning & Payouts</h3>
              <p className="text-xs text-[#A7ADBD] leading-relaxed">
                Receive digital driver bookings automatically. Payouts deposited directly to your bank account.
              </p>
            </div>
          </div>
        </div>

        {/* Final CTA */}
        <div className="p-8 sm:p-12 rounded-3xl bg-[#0D0F16] border border-white/10 text-center space-y-6">
          <h2 className="text-2xl sm:text-3xl font-bold font-heading text-white">
            Ready to experience smarter parking in Pune?
          </h2>
          <p className="text-sm text-[#A7ADBD] max-w-lg mx-auto">
            Join our pilot program as an early driver or list your parking capacity.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button
              onClick={() => onOpenPilot('seeker')}
              className="px-6 py-3.5 rounded-xl bg-[#A020F0] hover:bg-[#8e1cd6] text-white font-semibold text-sm transition-all shadow-lg shadow-[#A020F0]/25"
            >
              Join Driver Pilot
            </button>
            <button
              onClick={() => onOpenPilot('provider')}
              className="px-6 py-3.5 rounded-xl bg-[#121520] hover:bg-[#181C29] text-white border border-white/10 font-semibold text-sm transition-all"
            >
              List Your Parking Space
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

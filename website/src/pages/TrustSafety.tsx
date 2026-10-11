import { 
  ShieldCheck, Camera, FileCheck, Layers, 
  AlertCircle, Lock
} from 'lucide-react';
import { Reveal } from '../components/Reveal';

export const TrustSafety: React.FC = () => {
  return (
    <div className="w-full bg-[#08090D] text-[#F7F7FC] pt-32 pb-24 px-6 sm:px-8 lg:px-12">
      <div className="max-w-6xl mx-auto space-y-24">
        {/* Hero */}
        <div className="max-w-3xl space-y-6">
          <Reveal>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#121520] border border-white/10 text-xs font-subheading text-[#C7A1FF]">
              <ShieldCheck size={12} className="text-[#A020F0]" />
              INTEGRITY & VERIFICATION
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold font-heading text-white tracking-tight leading-[1.1]">
              Trust starts with <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-white via-[#F7F7FC] to-[#C7A1FF]">
                clear, audited information.
              </span>
            </h1>
          </Reveal>

          <Reveal delay={0.2}>
            <p className="text-base sm:text-lg text-[#A7ADBD] leading-relaxed font-body">
              A parking marketplace is only as reliable as the data behind its listings. Here is our exact verification framework, how we audit physical bays, and how we resolve issues in our Pune pilot.
            </p>
          </Reveal>
        </div>

        {/* 4 Pillars of Platform Verification */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-8 space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-[#A020F0]/15 flex items-center justify-center text-[#A020F0]">
              <FileCheck size={24} />
            </div>
            <h3 className="text-xl font-bold font-heading text-white">1. Identity & Business Checks</h3>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              Every host on ParkSync provides government-issued ID (Aadhaar / PAN) or formal business registration (Shop Act / GST for commercial and restaurant operators). Anonymous listings are strictly prohibited.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-8 space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-[#C7A1FF]/15 flex items-center justify-center text-[#C7A1FF]">
              <Lock size={24} />
            </div>
            <h3 className="text-xl font-bold font-heading text-white">2. Authorization Requirements</h3>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              Listing a parking bay requires legal authority. Society common areas require formal Society Managing Committee resolutions. Corporate bays require facility manager clearance.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-8 space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-[#10B981]/15 flex items-center justify-center text-[#10B981]">
              <Layers size={24} />
            </div>
            <h3 className="text-xl font-bold font-heading text-white">3. Physical Audits & Dimensions</h3>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              We catalog real photographic evidence, ramp angle, entry clearance height, gate width, and individual bay boundaries so drivers never face unexpected height or door obstacles.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-8 space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-white/10 flex items-center justify-center text-white">
              <Camera size={24} />
            </div>
            <h3 className="text-xl font-bold font-heading text-white">4. Timestamped Condition Audit</h3>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              Upon gate arrival, drivers have the option to snap quick photos of their parked car. These are timestamped and encrypted, forming an objective record should any scratch or dispute arise.
            </p>
          </div>
        </div>

        {/* Dispute & Issue Handling */}
        <div className="bg-[#121520] border border-white/10 rounded-3xl p-8 sm:p-12 space-y-6">
          <div className="flex items-center gap-2 text-xs font-subheading text-[#C7A1FF] font-semibold uppercase tracking-wider">
            <AlertCircle size={14} className="text-[#A020F0]" /> Resolution Protocol
          </div>
          <h2 className="text-2xl sm:text-3xl font-bold font-heading text-white">
            What happens if a reserved spot is blocked?
          </h2>
          <p className="text-sm text-[#A7ADBD] leading-relaxed font-body max-w-2xl">
            While our real-time inventory and partner gate passes minimize unauthorized parking, real-world hiccups can occur. If an unauthorized car is parked in your reserved bay upon arrival:
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-2">
            <div className="p-4 bg-[#08090D] rounded-2xl border border-white/5">
              <div className="text-xs font-mono font-bold text-[#A020F0] mb-2">STEP 1</div>
              <div className="text-sm font-semibold text-white mb-1">Instant App Report</div>
              <div className="text-xs text-[#A7ADBD]">Tap "Spot Blocked" in the live booking view to trigger an immediate audit alert.</div>
            </div>
            <div className="p-4 bg-[#08090D] rounded-2xl border border-white/5">
              <div className="text-xs font-mono font-bold text-[#A020F0] mb-2">STEP 2</div>
              <div className="text-sm font-semibold text-white mb-1">Instant Re-routing</div>
              <div className="text-xs text-[#A7ADBD]">The app immediately assigns an alternate nearby bay in the same facility or partner lot.</div>
            </div>
            <div className="p-4 bg-[#08090D] rounded-2xl border border-white/5">
              <div className="text-xs font-mono font-bold text-[#A020F0] mb-2">STEP 3</div>
              <div className="text-sm font-semibold text-white mb-1">Guaranteed Refund</div>
              <div className="text-xs text-[#A7ADBD]">If no alternative fits your vehicle, 100% of your booking fee is credited back immediately.</div>
            </div>
          </div>
        </div>

        {/* Responsible Boundaries Disclaimers */}
        <div className="p-6 rounded-2xl bg-white/5 border border-white/10 text-xs text-[#747C90] space-y-2">
          <div className="font-semibold text-[#A7ADBD]">Transparency Note:</div>
          <p>
            ParkSync operates as a digital technology marketplace connecting drivers with verified independent parking providers. While we conduct rigorous onboarding audits and require valid authorization, ParkSync does not own the real estate and does not provide proprietary insurance coverage unless explicitly stated in individual commercial agreements.
          </p>
        </div>
      </div>
    </div>
  );
};

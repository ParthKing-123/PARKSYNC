import { Link } from 'react-router-dom';
import { 
  Car, ShieldCheck, ArrowRight, 
  Sparkles, Camera, Shield
} from 'lucide-react';
import { Reveal } from '../components/Reveal';

interface ForDriversProps {
  onOpenPilot: (role?: 'seeker' | 'provider') => void;
}

export const ForDrivers: React.FC<ForDriversProps> = ({ onOpenPilot }) => {
  return (
    <div className="w-full bg-[#08090D] text-[#F7F7FC] pt-32 pb-24 px-6 sm:px-8 lg:px-12">
      <div className="max-w-6xl mx-auto space-y-24">
        {/* Hero */}
        <div className="max-w-3xl space-y-6">
          <Reveal>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#121520] border border-white/10 text-xs font-subheading text-[#C7A1FF]">
              <Sparkles size={12} className="text-[#A020F0]" />
              DESIGNED FOR INDIAN MOTORISTS
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold font-heading text-white tracking-tight leading-[1.1]">
              Find parking that fits your plans— <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-white via-[#F7F7FC] to-[#C7A1FF]">
                and your car.
              </span>
            </h1>
          </Reveal>

          <Reveal delay={0.2}>
            <p className="text-base sm:text-lg text-[#A7ADBD] leading-relaxed font-body">
              No more squeezing an SUV into a compact hatchback space, scratching your rims, or circling full commercial streets in Pune. ParkSync matches your car to the right bay.
            </p>
          </Reveal>

          <Reveal delay={0.3}>
            <div className="flex flex-col sm:flex-row gap-4 pt-2">
              <button
                onClick={() => onOpenPilot('seeker')}
                className="px-6 py-3.5 rounded-xl bg-[#A020F0] hover:bg-[#8e1cd6] text-white font-semibold text-sm transition-all shadow-lg shadow-[#A020F0]/25 flex items-center justify-center gap-2"
              >
                <span>Join Driver Pilot in Pune</span>
                <ArrowRight size={16} />
              </button>
              <Link
                to="/how-it-works"
                className="px-6 py-3.5 rounded-xl bg-[#121520] hover:bg-[#181C29] text-white border border-white/10 font-semibold text-sm transition-all flex items-center justify-center gap-2"
              >
                <span>Explore the Process</span>
              </Link>
            </div>
          </Reveal>
        </div>

        {/* Core Value Pillars for Drivers */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-8 space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-[#A020F0]/15 flex items-center justify-center text-[#A020F0]">
              <Car size={24} />
            </div>
            <h3 className="text-xl font-bold font-heading text-white">Dimension Pre-Check</h3>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              We check your vehicle's exact length, width, and overhead clearance against the parking space before you arrive. If your car doesn't fit comfortably, we won't let you book it.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-8 space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-[#C7A1FF]/15 flex items-center justify-center text-[#C7A1FF]">
              <ShieldCheck size={24} />
            </div>
            <h3 className="text-xl font-bold font-heading text-white">Verified Facilities</h3>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              Every listing includes audited photos, CCTV presence, guard presence, and access information. You know exactly what kind of property your car will be resting in.
            </p>
          </div>

          <div className="bg-[#0D0F16] border border-white/5 rounded-3xl p-8 space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-[#10B981]/15 flex items-center justify-center text-[#10B981]">
              <Camera size={24} />
            </div>
            <h3 className="text-xl font-bold font-heading text-white">Condition Documentation</h3>
            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              Our mobile application lets you take timestamped before/after photos upon entry and exit, creating an indisputable audit trail to protect you from spurious parking damage claims.
            </p>
          </div>
        </div>

        {/* Honest Pilot Boundaries Notice */}
        <div className="bg-[#121520] border border-white/10 rounded-2xl p-6 sm:p-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div className="space-y-2 max-w-xl">
            <div className="flex items-center gap-2 text-xs font-subheading text-[#C7A1FF] font-semibold uppercase tracking-wider">
              <Shield size={14} className="text-[#A020F0]" /> Pilot Footprint Transparency
            </div>
            <h4 className="text-lg font-bold text-white font-heading">
              Currently operating in select Pune hubs
            </h4>
            <p className="text-xs text-[#A7ADBD] leading-relaxed font-body">
              During our initial phase, spaces are focused around Baner, Balewadi High Street, Koregaon Park, and Viman Nagar. We are intentionally onboarding high-trust provider facilities before wider city expansion.
            </p>
          </div>
          <button
            onClick={() => onOpenPilot('seeker')}
            className="px-5 py-3 rounded-xl bg-white/10 hover:bg-white/15 text-white text-xs font-semibold shrink-0 transition-colors"
          >
            Request Your Locality
          </button>
        </div>
      </div>
    </div>
  );
};

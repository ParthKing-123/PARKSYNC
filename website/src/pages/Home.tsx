import { lazy, Suspense } from 'react';
import { Link } from 'react-router-dom';
import { 
  ArrowRight, 
  ArrowUpRight, 
  ChevronDown, 
  CheckCircle2, 
  ShieldCheck, 
  Sliders, 
  Zap, 
  IndianRupee, 
  MapPin,
  Sparkles
} from 'lucide-react';
import { EngineeringCompatibilityVisual } from '../components/UI/EngineeringCompatibilityVisual';
import { Reveal } from '../components/Reveal';
import { CarCursorFollower } from '../components/CarCursorFollower';
import { ParkingMarquee } from '../components/UI/ParkingMarquee';
import { SpotlightCard } from '../components/UI/SpotlightCard';
import { InteractiveBackground } from '../components/InteractiveBackground';

const ThreeHeroScene = lazy(() => import('../components/ThreeHeroScene').then((m) => ({ default: m.ThreeHeroScene })));

interface HomeProps {
  onOpenPilot: (role?: 'seeker' | 'provider') => void;
}

export const Home: React.FC<HomeProps> = ({ onOpenPilot }) => {
  const scrollToProduct = () => {
    const el = document.getElementById('product-statement');
    if (el) el.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div className="w-full dynamic-moving-bg text-[#F7F7FA] overflow-hidden relative min-h-screen">
      {/* Sleek Top-Down Car Cursor Follower (Turns smoothly with cursor, no light beams) */}
      <CarCursorFollower />

      {/* Global Interactive Dynamic Background (Reacts 360° to mouse and scroll continuously everywhere) */}
      <InteractiveBackground />

      {/* =========================================================================
          SECTION 1: BRIGHT LANDSCAPE 3D PARKING LOT SCENE (HERO)
         ========================================================================= */}
      <section className="relative min-h-[85vh] pt-24 pb-8 sm:pb-12 px-6 sm:px-10 lg:px-16 flex flex-col justify-center">
        {/* Subtle Ambient Vignette */}
        <div className="absolute inset-0 bg-radial-gradient from-transparent via-[#07080b]/30 to-[#07080b] pointer-events-none z-10" />

        <div className="w-full max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-6 items-center relative z-20 my-auto">
          {/* Left Editorial Text Column (5 cols) */}
          <div className="lg:col-span-5 space-y-6 z-30 pt-4 lg:pt-0">
            <Reveal delay={0.05}>
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#A020F0]/15 border border-[#A020F0]/35 text-[11px] font-subheading tracking-[0.16em] uppercase text-[#C5A3FF] font-semibold">
                <span className="w-2 h-2 rounded-full bg-[#00E5FF] animate-pulse" />
                <span>A SMARTER WAY TO PARK</span>
              </div>
            </Reveal>

            <Reveal delay={0.1}>
              <h1 className="text-4xl sm:text-6xl lg:text-[4.75rem] font-extrabold font-heading tracking-[-0.035em] leading-[1.04] text-white">
                Parking, <br />
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-white via-[#F7F7FA] to-[#C5A3FF]">
                  Reimagined.
                </span>
              </h1>
            </Reveal>

            <Reveal delay={0.15}>
              <p className="text-sm sm:text-base text-[#9899A8] leading-[1.68] max-w-lg font-body">
                Find a space that fits your car. Compare available parking slots, review clearances, and arrive with confidence.
              </p>
            </Reveal>

            {/* Clean Hero Primary CTA Buttons */}
            <Reveal delay={0.2}>
              <div className="flex flex-wrap items-center gap-4 pt-1">
                <button
                  onClick={scrollToProduct}
                  className="px-6 py-3.5 rounded-full bg-[#A020F0] hover:bg-[#8e1cd6] text-white font-semibold font-body text-xs sm:text-sm tracking-wide transition-all shadow-lg shadow-[#A020F0]/35 hover:shadow-xl hover:shadow-[#A020F0]/45 hover:scale-[1.02] active:scale-[0.98] flex items-center gap-2"
                >
                  <span>Discover ParkSync</span>
                  <ArrowRight size={15} />
                </button>

                <Link
                  to="/for-providers"
                  className="px-5 py-3.5 rounded-full bg-white/5 hover:bg-white/10 text-xs sm:text-sm font-medium text-[#C5A3FF] hover:text-white transition-all border border-white/10 flex items-center gap-1.5 group font-body"
                >
                  <span>For parking providers</span>
                  <ArrowUpRight size={14} className="group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
                </Link>
              </div>
            </Reveal>
          </div>

          {/* Right Visual: Bright Landscape 3D Parking Lot Scene */}
          <div className="lg:col-span-7 relative flex items-center justify-center">
            <Suspense fallback={
              <div className="w-full h-[340px] sm:h-[400px] flex items-center justify-center">
                <div className="w-8 h-8 rounded-full border-2 border-[#A020F0]/30 border-t-[#A020F0] animate-spin" />
              </div>
            }>
              <ThreeHeroScene className="w-full" />
            </Suspense>
          </div>
        </div>

        {/* Scroll Guide Indicator */}
        <div className="w-full flex flex-col items-center justify-center pt-6 pb-1 text-[10px] text-[#747C90] uppercase tracking-widest font-subheading z-20">
          <button 
            onClick={scrollToProduct} 
            className="flex flex-col items-center gap-1 hover:text-[#C5A3FF] transition-colors focus:outline-none"
            aria-label="Scroll to learn more"
          >
            <span>Scroll</span>
            <ChevronDown size={14} className="animate-bounce text-[#A020F0]" />
          </button>
        </div>
      </section>

      {/* =========================================================================
          INFINITE TICKER: LIVE PUNE PARKING HUBS MARQUEE
         ========================================================================= */}
      <ParkingMarquee />

      {/* =========================================================================
          SECTION 2: ONE STRONG PRODUCT STATEMENT
         ========================================================================= */}
      <section id="product-statement" className="py-20 sm:py-24 px-6 sm:px-10 lg:px-16 max-w-5xl mx-auto text-center relative scroll-mt-12">
        <div className="w-px h-12 bg-gradient-to-b from-[#A020F0] to-transparent mx-auto mb-8 opacity-70" />

        <Reveal>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold font-heading text-white tracking-[-0.03em] leading-[1.12] max-w-4xl mx-auto">
            Your car knows its size. <br />
            <span className="text-[#C5A3FF]">Your parking should too.</span>
          </h2>
        </Reveal>

        <Reveal delay={0.1}>
          <p className="mt-6 text-sm sm:text-base text-[#9899A8] max-w-2xl mx-auto font-body leading-[1.7]">
            ParkSync indexes exact manufacturer dimensions, approach angles, and door clearances against measured parking bays. No more surprises when pulling into steep basements or narrow pillars.
          </p>
        </Reveal>
      </section>

      {/* =========================================================================
          SECTION 3: SHOW, DON'T EXPLAIN (ENGINEERING COMPATIBILITY VISUAL)
         ========================================================================= */}
      <section className="py-20 sm:py-24 px-6 sm:px-10 lg:px-16 max-w-6xl mx-auto space-y-10">
        <div className="max-w-2xl space-y-2.5">
          <Reveal>
            <div className="text-[11px] font-subheading tracking-[0.18em] uppercase text-[#A020F0] font-semibold">
              COMPATIBILITY ENGINE
            </div>
          </Reveal>
          <Reveal delay={0.1}>
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold font-heading text-white tracking-[-0.025em]">
              A guaranteed fit. Before you arrive.
            </h2>
          </Reveal>
          <Reveal delay={0.15}>
            <p className="text-sm text-[#9899A8] font-body leading-[1.6]">
              Choose your vehicle make and model. Review bay width, door swing clearance, and ramp angles before booking.
            </p>
          </Reveal>
        </div>

        <Reveal delay={0.2}>
          <EngineeringCompatibilityVisual />
        </Reveal>
      </section>

      {/* =========================================================================
          SECTION 4: THE JOURNEY IN THREE STEPS (SPOTLIGHT CARDS)
         ========================================================================= */}
      <section className="py-20 sm:py-24 px-6 sm:px-10 lg:px-16 max-w-6xl mx-auto border-t border-white/5">
        <div className="max-w-xl mb-14 space-y-2.5">
          <Reveal>
            <div className="text-[11px] font-subheading tracking-[0.18em] uppercase text-[#A020F0] font-semibold">
              THE DRIVER PROCESS
            </div>
          </Reveal>
          <Reveal delay={0.1}>
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold font-heading text-white tracking-[-0.025em]">
              Three clear steps to guaranteed parking.
            </h2>
          </Reveal>
        </div>

        {/* Horizontal Sequence Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8">
          {/* Step 1 */}
          <Reveal delay={0.08}>
            <SpotlightCard className="p-6 h-full" spotlightColor="rgba(160, 32, 240, 0.2)">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono font-bold text-[#A020F0] px-2.5 py-1 rounded bg-[#A020F0]/15 border border-[#A020F0]/30">
                    STEP 01
                  </span>
                  <MapPin size={18} className="text-[#C5A3FF]" />
                </div>
                <h3 className="text-lg sm:text-xl font-bold font-heading text-white">
                  Choose your destination
                </h3>
                <p className="text-xs sm:text-sm text-[#9899A8] leading-[1.65] font-body">
                  Select your destination in Pune (Koregaon Park, Baner, SB Road, etc.) and specify your parking window.
                </p>
                <div className="pt-2 text-[11px] font-mono text-[#00E5FF]">
                  ✓ Geo-fenced parking clusters
                </div>
              </div>
            </SpotlightCard>
          </Reveal>

          {/* Step 2 */}
          <Reveal delay={0.14}>
            <SpotlightCard className="p-6 h-full" spotlightColor="rgba(0, 229, 255, 0.18)">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono font-bold text-[#A020F0] px-2.5 py-1 rounded bg-[#A020F0]/15 border border-[#A020F0]/30">
                    STEP 02
                  </span>
                  <Sliders size={18} className="text-[#C5A3FF]" />
                </div>
                <h3 className="text-lg sm:text-xl font-bold font-heading text-white">
                  Review compatibility match
                </h3>
                <p className="text-xs sm:text-sm text-[#9899A8] leading-[1.65] font-body">
                  Verify that width, height clearance, and turn radius match your car with 100% green-check certainty.
                </p>
                <div className="pt-2 text-[11px] font-mono text-[#00E5FF]">
                  ✓ 3D bay envelope calculation
                </div>
              </div>
            </SpotlightCard>
          </Reveal>

          {/* Step 3 */}
          <Reveal delay={0.2}>
            <SpotlightCard className="p-6 h-full" spotlightColor="rgba(192, 132, 252, 0.2)">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono font-bold text-[#A020F0] px-2.5 py-1 rounded bg-[#A020F0]/15 border border-[#A020F0]/30">
                    STEP 03
                  </span>
                  <Zap size={18} className="text-[#C5A3FF]" />
                </div>
                <h3 className="text-lg sm:text-xl font-bold font-heading text-white">
                  Instant digital gate access
                </h3>
                <p className="text-xs sm:text-sm text-[#9899A8] leading-[1.65] font-body">
                  Follow turn-by-turn navigation directly to the private bay. Show your digital pass for friction-free ingress.
                </p>
                <div className="pt-2 text-[11px] font-mono text-[#00E5FF]">
                  ✓ Zero physical paper tickets
                </div>
              </div>
            </SpotlightCard>
          </Reveal>
        </div>

        <div className="mt-12 pt-6 border-t border-white/5 flex items-center justify-between">
          <Link
            to="/how-it-works"
            className="text-xs sm:text-sm text-[#C5A3FF] hover:text-white transition-colors flex items-center gap-1.5 group font-body"
          >
            <span>See detailed driver walkthrough</span>
            <ArrowRight size={14} className="group-hover:translate-x-1 transition-transform" />
          </Link>
        </div>
      </section>

      {/* =========================================================================
          SECTION 5: FOR PARKING PROVIDERS (PUNE YIELD CALCULATOR)
         ========================================================================= */}
      <section className="py-20 sm:py-24 px-6 sm:px-10 lg:px-16 bg-[#0a0c12]/90 border-y border-white/5 relative">
        <div className="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
          <div className="lg:col-span-6 space-y-5">
            <Reveal>
              <div className="text-[11px] font-subheading tracking-[0.18em] uppercase text-[#A020F0] font-semibold">
                PROPERTY MONETIZATION
              </div>
            </Reveal>

            <Reveal delay={0.1}>
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold font-heading text-white tracking-[-0.03em] leading-tight">
                Unused parking bays. <br />
                <span className="text-[#C5A3FF]">Automated recurring revenue.</span>
              </h2>
            </Reveal>

            <Reveal delay={0.15}>
              <p className="text-sm text-[#9899A8] leading-[1.68] font-body">
                Monetize authorized parking slots during off-peak hours. Built for restaurants, tech parks, hotels, and verified private society bay owners across Pune.
              </p>
            </Reveal>

            {/* Pune Host Revenue Calculator Card */}
            <Reveal delay={0.18}>
              <SpotlightCard className="p-5" spotlightColor="rgba(0, 229, 255, 0.18)">
                <div className="space-y-3">
                  <div className="flex items-center justify-between text-xs font-mono">
                    <span className="text-[#9899A8]">Estimated Host Revenue (2 Bays):</span>
                    <span className="text-emerald-400 font-bold flex items-center">
                      <IndianRupee size={12} />
                      18,000 - 32,000 / month
                    </span>
                  </div>
                  <div className="w-full bg-white/5 h-2 rounded-full overflow-hidden">
                    <div className="bg-gradient-to-r from-[#A020F0] to-[#00E5FF] h-full w-[78%]" />
                  </div>
                  <div className="flex items-center justify-between text-[11px] text-[#747C90] font-body">
                    <span>Based on Pune prime business hub demand</span>
                    <span className="text-[#C5A3FF]">Direct weekly bank payouts</span>
                  </div>
                </div>
              </SpotlightCard>
            </Reveal>

            <Reveal delay={0.2}>
              <div className="pt-2">
                <button
                  onClick={() => onOpenPilot('provider')}
                  className="px-6 py-3.5 rounded-full bg-[#A020F0] hover:bg-[#8e1cd6] text-white text-xs sm:text-sm font-semibold transition-all shadow-lg shadow-[#A020F0]/30 hover:scale-[1.02]"
                >
                  Join Pune Pilot Provider Network
                </button>
              </div>
            </Reveal>
          </div>

          {/* Right: Three Clear Benefit Cards */}
          <div className="lg:col-span-6 space-y-4 lg:pl-6">
            <SpotlightCard className="p-5">
              <div className="space-y-1.5">
                <div className="text-white font-bold font-heading text-sm sm:text-base flex items-center gap-2">
                  <CheckCircle2 size={16} className="text-[#00E5FF]" />
                  Complete schedule control
                </div>
                <div className="text-xs text-[#9899A8] leading-relaxed font-body">
                  Open slots only during specific hours, weekends, or vacant office days. You decide when slots are live.
                </div>
              </div>
            </SpotlightCard>

            <SpotlightCard className="p-5">
              <div className="space-y-1.5">
                <div className="text-white font-bold font-heading text-sm sm:text-base flex items-center gap-2">
                  <CheckCircle2 size={16} className="text-[#00E5FF]" />
                  Dynamic rate setting
                </div>
                <div className="text-xs text-[#9899A8] leading-relaxed font-body">
                  Maintain complete ownership over your hourly and daily parking pricing or enable smart market pricing.
                </div>
              </div>
            </SpotlightCard>

            <SpotlightCard className="p-5">
              <div className="space-y-1.5">
                <div className="text-white font-bold font-heading text-sm sm:text-base flex items-center gap-2">
                  <CheckCircle2 size={16} className="text-[#00E5FF]" />
                  Automated gate verification
                </div>
                <div className="text-xs text-[#9899A8] leading-relaxed font-body">
                  Drivers verify at the barrier via digital token pass. No physical attendants or ticket dispensing required.
                </div>
              </div>
            </SpotlightCard>
          </div>
        </div>
      </section>

      {/* =========================================================================
          SECTION 6: TRUST & AUDITING (HIGH-TECH VERIFICATION MATRIX)
         ========================================================================= */}
      <section className="py-20 sm:py-24 px-6 sm:px-10 lg:px-16 max-w-6xl mx-auto space-y-10">
        <div className="max-w-2xl space-y-2.5">
          <Reveal>
            <div className="text-[11px] font-subheading tracking-[0.18em] uppercase text-[#A020F0] font-semibold">
              TRANSPARENCY & ASSURANCE
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold font-heading text-white tracking-[-0.025em]">
              Verified spaces. Guaranteed peace of mind.
            </h2>
          </Reveal>

          <Reveal delay={0.15}>
            <p className="text-sm text-[#9899A8] font-body leading-[1.6]">
              Every parking bay listed on ParkSync undergoes dimension auditing and identity validation before appearing in search.
            </p>
          </Reveal>
        </div>

        {/* 5-Column Audit Matrix with Status Indicators */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 pt-2">
          <SpotlightCard className="p-4">
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-mono text-emerald-400">AUDITED</span>
                <ShieldCheck size={14} className="text-emerald-400" />
              </div>
              <div className="text-white font-semibold font-heading text-sm">Provider Identity</div>
              <div className="text-xs text-[#9899A8] font-body">Government ID and phone verified hosts.</div>
            </div>
          </SpotlightCard>

          <SpotlightCard className="p-4">
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-mono text-emerald-400">VALIDATED</span>
                <ShieldCheck size={14} className="text-emerald-400" />
              </div>
              <div className="text-white font-semibold font-heading text-sm">Commercial Title</div>
              <div className="text-xs text-[#9899A8] font-body">Validated commercial property records.</div>
            </div>
          </SpotlightCard>

          <SpotlightCard className="p-4">
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-mono text-[#00E5FF]">MEASURED</span>
                <ShieldCheck size={14} className="text-[#00E5FF]" />
              </div>
              <div className="text-white font-semibold font-heading text-sm">Bay Geometry</div>
              <div className="text-xs text-[#9899A8] font-body">Audited length, width, and ramp clearances.</div>
            </div>
          </SpotlightCard>

          <SpotlightCard className="p-4">
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-mono text-emerald-400">AUTHORIZED</span>
                <ShieldCheck size={14} className="text-emerald-400" />
              </div>
              <div className="text-white font-semibold font-heading text-sm">Host Authorization</div>
              <div className="text-xs text-[#9899A8] font-body">Formal permission to monetize space.</div>
            </div>
          </SpotlightCard>

          <SpotlightCard className="p-4">
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-mono text-[#C5A3FF]">LOGGED</span>
                <ShieldCheck size={14} className="text-[#C5A3FF]" />
              </div>
              <div className="text-white font-semibold font-heading text-sm">Condition Audit</div>
              <div className="text-xs text-[#9899A8] font-body">Digital check-in timestamps and photo records.</div>
            </div>
          </SpotlightCard>
        </div>

        <div className="pt-2">
          <Link
            to="/trust-and-safety"
            className="text-xs sm:text-sm text-[#C5A3FF] hover:text-white transition-colors inline-flex items-center gap-1 group font-body"
          >
            <span>Learn how our trust protocol works</span>
            <ArrowUpRight size={14} className="group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
          </Link>
        </div>
      </section>

      {/* =========================================================================
          SECTION 7: FINAL CINEMATIC CALL TO ACTION
         ========================================================================= */}
      <section className="py-24 sm:py-28 px-6 sm:px-10 lg:px-16 text-center border-t border-white/5 relative">
        <div className="max-w-3xl mx-auto space-y-6">
          <Reveal>
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/5 border border-white/10 text-xs text-[#C5A3FF] font-subheading mb-2">
              <Sparkles size={12} className="text-[#A020F0]" />
              <span>PUNE EARLY ACCESS PILOT OPEN</span>
            </div>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold font-heading text-white tracking-[-0.03em] leading-[1.1]">
              Make room for <br />
              <span className="text-[#C5A3FF]">better journeys.</span>
            </h2>
          </Reveal>

          <Reveal delay={0.1}>
            <p className="text-sm sm:text-base text-[#9899A8] max-w-xl mx-auto font-body leading-[1.65]">
              Find parking that fits your exact vehicle—or start earning from authorized unused parking spaces across Pune.
            </p>
          </Reveal>

          <Reveal delay={0.2}>
            <div className="flex flex-wrap items-center justify-center gap-4 pt-2">
              <button
                onClick={() => onOpenPilot('seeker')}
                className="px-7 py-3.5 rounded-full bg-[#A020F0] hover:bg-[#8e1cd6] text-white font-semibold font-body text-xs sm:text-sm tracking-wide transition-all shadow-lg shadow-[#A020F0]/30 hover:scale-[1.02] active:scale-[0.98]"
              >
                Join as Driver (Early Pilot)
              </button>

              <button
                onClick={() => onOpenPilot('provider')}
                className="px-6 py-3.5 rounded-full bg-white/5 hover:bg-white/10 text-xs sm:text-sm font-medium text-[#C5A3FF] hover:text-white transition-colors flex items-center gap-1.5 group font-body border border-white/10"
              >
                <span>Register a Parking Space</span>
                <ArrowUpRight size={14} className="group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
              </button>
            </div>
          </Reveal>
        </div>
      </section>
    </div>
  );
};

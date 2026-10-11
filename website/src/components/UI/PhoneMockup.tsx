import { useState } from 'react';
import { 
  MapPin, CheckCircle2, ShieldCheck, QrCode, 
  Car, Clock, ChevronRight, Check
} from 'lucide-react';

export const PhoneMockup: React.FC = () => {
  const [activeTab, setActiveTab] = useState<0 | 1 | 2 | 3>(0);

  const screens = [
    { title: 'Search', label: '1. Destination' },
    { title: 'Compatibility', label: '2. Vehicle Fit' },
    { title: 'Details', label: '3. Space Review' },
    { title: 'Pass', label: '4. Arrival Pass' },
  ];

  return (
    <div className="flex flex-col items-center">
      {/* Tab Switcher */}
      <div className="flex flex-wrap items-center justify-center gap-1.5 p-1 bg-[#121520] border border-white/10 rounded-xl mb-6">
        {screens.map((s, idx) => (
          <button
            key={idx}
            onClick={() => setActiveTab(idx as any)}
            className={`px-3 py-1.5 text-xs font-subheading rounded-lg transition-all ${
              activeTab === idx
                ? 'bg-[#A020F0] text-white font-semibold shadow-md shadow-[#A020F0]/30'
                : 'text-[#A7ADBD] hover:text-white'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>

      {/* Realistic CSS Smartphone Frame */}
      <div className="relative w-[300px] sm:w-[320px] h-[620px] bg-[#0A0C12] rounded-[48px] p-3 shadow-2xl shadow-[#A020F0]/15 border-[5px] border-[#181C29] relative overflow-hidden">
        {/* Dynamic Island / Speaker notch */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 w-28 h-5 bg-[#121520] rounded-full z-30 flex items-center justify-between px-2.5">
          <div className="w-2.5 h-2.5 rounded-full bg-black/60"></div>
          <div className="w-2.5 h-2.5 rounded-full bg-[#A020F0]/40"></div>
        </div>

        {/* Screen Bezel Content */}
        <div className="w-full h-full bg-[#08090D] rounded-[40px] overflow-hidden flex flex-col pt-8 pb-4 px-4 text-[#F7F7FC] relative font-body select-none">
          {/* Status bar */}
          <div className="flex justify-between items-center text-[10px] text-[#A7ADBD] px-2 mb-3">
            <span>09:41</span>
            <span className="flex items-center gap-1">5G • 98%</span>
          </div>

          {/* SCREEN 0: Destination Search */}
          {activeTab === 0 && (
            <div className="flex-1 flex flex-col animate-in fade-in duration-300">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <div className="text-[11px] text-[#A020F0] font-subheading font-medium">EXPLORE PUNE</div>
                  <div className="text-base font-bold font-heading">Find a spot</div>
                </div>
                <div className="w-7 h-7 rounded-full bg-white/10 flex items-center justify-center">
                  <Car size={14} className="text-[#A020F0]" />
                </div>
              </div>

              {/* Search Bar Input UI */}
              <div className="p-2.5 bg-[#121520] border border-white/10 rounded-xl mb-3 flex items-center gap-2">
                <MapPin size={15} className="text-[#A020F0]" />
                <div className="text-xs text-white">Balewadi High St, Baner</div>
              </div>

              {/* Vehicle Pill */}
              <div className="p-2 bg-[#A020F0]/10 border border-[#A020F0]/30 rounded-xl mb-4 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-5 h-5 rounded-md bg-[#A020F0]/30 flex items-center justify-center text-[#C7A1FF]">
                    <Car size={12} />
                  </div>
                  <div>
                    <div className="text-[11px] font-semibold text-white">Hyundai Creta 2024</div>
                    <div className="text-[9px] text-[#A7ADBD]">SUV • 4,330mm length</div>
                  </div>
                </div>
                <span className="text-[9px] text-[#C7A1FF] font-medium">Active</span>
              </div>

              {/* Sample Nearby Spots list */}
              <div className="text-[11px] font-subheading text-[#747C90] uppercase tracking-wider mb-2">
                Available Nearby
              </div>

              <div className="space-y-2 flex-1 overflow-y-auto pr-1">
                <div className="p-2.5 bg-[#121520] border border-white/10 rounded-xl">
                  <div className="flex justify-between items-start mb-1">
                    <span className="text-xs font-semibold text-white">Skyline Corporate Bay</span>
                    <span className="text-xs font-bold text-[#A020F0]">₹40/hr</span>
                  </div>
                  <div className="text-[10px] text-[#A7ADBD] mb-2">Baner • 250m from High Street</div>
                  <div className="flex items-center gap-1.5 text-[10px] text-[#10B981] font-medium">
                    <CheckCircle2 size={12} /> Space fits your Creta perfectly
                  </div>
                </div>

                <div className="p-2.5 bg-[#121520] border border-white/5 rounded-xl opacity-80">
                  <div className="flex justify-between items-start mb-1">
                    <span className="text-xs font-semibold text-white">The Daily Café Lot</span>
                    <span className="text-xs font-bold text-[#A020F0]">₹35/hr</span>
                  </div>
                  <div className="text-[10px] text-[#A7ADBD] mb-2">Baner Road • 400m away</div>
                  <div className="flex items-center gap-1.5 text-[10px] text-[#10B981] font-medium">
                    <CheckCircle2 size={12} /> Fits width & ceiling clearance
                  </div>
                </div>
              </div>

              <button 
                onClick={() => setActiveTab(1)}
                className="w-full mt-3 py-2 bg-[#A020F0] text-white rounded-xl text-xs font-semibold flex items-center justify-center gap-1"
              >
                Inspect Space Compatibility <ChevronRight size={14} />
              </button>
            </div>
          )}

          {/* SCREEN 1: Vehicle Compatibility Analysis */}
          {activeTab === 1 && (
            <div className="flex-1 flex flex-col animate-in fade-in duration-300">
              <div className="text-[11px] text-[#A020F0] font-subheading font-medium mb-1">COMPATIBILITY ENGINE</div>
              <div className="text-sm font-bold font-heading mb-3">Vehicle vs Space Fit</div>

              <div className="bg-[#121520] border border-white/10 rounded-2xl p-3 mb-3">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-semibold">Hyundai Creta (2024)</span>
                  <span className="px-2 py-0.5 rounded-full bg-[#10B981]/20 text-[#10B981] text-[10px] font-bold">
                    FIT CONFIRMED
                  </span>
                </div>

                {/* Spatial Grid representation */}
                <div className="h-24 bg-black/40 rounded-xl border border-dashed border-[#A020F0]/40 relative flex items-center justify-center overflow-hidden mb-3">
                  {/* Space Outline */}
                  <div className="w-44 h-16 border-2 border-[#A020F0] rounded-lg flex items-center justify-center relative">
                    <span className="absolute -top-3 bg-[#08090D] px-1 text-[8px] text-[#A020F0] font-mono">
                      Bay Length: 5,000mm
                    </span>
                    {/* Vehicle Inside */}
                    <div className="w-36 h-11 bg-[#A020F0]/20 border border-[#C7A1FF] rounded-md flex items-center justify-center">
                      <span className="text-[9px] text-white font-mono font-medium">Car: 4,330mm</span>
                    </div>
                  </div>
                </div>

                {/* Dimension Breakdown table */}
                <div className="space-y-1.5 text-[10px]">
                  <div className="flex justify-between text-[#A7ADBD]">
                    <span>Length Clearance:</span>
                    <span className="text-white font-medium">+670 mm margin</span>
                  </div>
                  <div className="flex justify-between text-[#A7ADBD]">
                    <span>Width Clearance:</span>
                    <span className="text-white font-medium">+420 mm margin</span>
                  </div>
                  <div className="flex justify-between text-[#A7ADBD]">
                    <span>Height Clearance:</span>
                    <span className="text-white font-medium">2.2m (Covered)</span>
                  </div>
                </div>
              </div>

              <div className="p-2.5 bg-[#10B981]/10 border border-[#10B981]/30 rounded-xl text-[10px] text-[#10B981] flex items-center gap-2 mb-auto">
                <CheckCircle2 size={16} className="shrink-0" />
                <span>Zero door-ding risk. Verified bay dimensions.</span>
              </div>

              <button 
                onClick={() => setActiveTab(2)}
                className="w-full mt-3 py-2 bg-[#A020F0] text-white rounded-xl text-xs font-semibold flex items-center justify-center gap-1"
              >
                Review Amenities <ChevronRight size={14} />
              </button>
            </div>
          )}

          {/* SCREEN 2: Space Details & Security */}
          {activeTab === 2 && (
            <div className="flex-1 flex flex-col animate-in fade-in duration-300">
              <div className="text-[11px] text-[#A020F0] font-subheading font-medium mb-1">PARKING VERIFICATION</div>
              <div className="text-sm font-bold font-heading mb-2">Skyline Corporate Bay #4</div>

              <div className="h-28 bg-[#181C29] rounded-xl overflow-hidden relative mb-3">
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent z-10 flex items-end p-2.5">
                  <div className="text-xs font-semibold text-white">Covered Basement - Bay B2</div>
                </div>
                {/* Visual mock of parking space */}
                <div className="w-full h-full bg-[#121520] flex items-center justify-center">
                  <div className="w-20 h-20 border border-white/10 rounded-lg flex items-center justify-center text-[#747C90] text-[10px]">
                    [ Verified Photo ]
                  </div>
                </div>
              </div>

              {/* Verified Trust Badges */}
              <div className="grid grid-cols-2 gap-1.5 mb-3">
                <div className="p-2 bg-[#121520] rounded-lg border border-white/5 flex items-center gap-1.5 text-[10px]">
                  <ShieldCheck size={14} className="text-[#10B981]" />
                  <span>24/7 CCTV</span>
                </div>
                <div className="p-2 bg-[#121520] rounded-lg border border-white/5 flex items-center gap-1.5 text-[10px]">
                  <ShieldCheck size={14} className="text-[#10B981]" />
                  <span>Guard On-site</span>
                </div>
                <div className="p-2 bg-[#121520] rounded-lg border border-white/5 flex items-center gap-1.5 text-[10px]">
                  <Check size={14} className="text-[#10B981]" />
                  <span>Roof Covered</span>
                </div>
                <div className="p-2 bg-[#121520] rounded-lg border border-white/5 flex items-center gap-1.5 text-[10px]">
                  <Check size={14} className="text-[#10B981]" />
                  <span>EV Charger</span>
                </div>
              </div>

              {/* Price Breakdown */}
              <div className="bg-[#121520] p-2.5 rounded-xl border border-white/5 text-[10px] space-y-1 mb-auto">
                <div className="flex justify-between text-[#A7ADBD]">
                  <span>2 Hours (10:00 - 12:00)</span>
                  <span>₹80</span>
                </div>
                <div className="flex justify-between text-[#A7ADBD]">
                  <span>Platform Fee</span>
                  <span>₹0</span>
                </div>
                <div className="flex justify-between text-white font-bold pt-1 border-t border-white/5">
                  <span>Total Payable</span>
                  <span className="text-[#A020F0]">₹80</span>
                </div>
              </div>

              <button 
                onClick={() => setActiveTab(3)}
                className="w-full mt-3 py-2 bg-[#A020F0] text-white rounded-xl text-xs font-semibold flex items-center justify-center gap-1"
              >
                Simulate Arrival Pass <ChevronRight size={14} />
              </button>
            </div>
          )}

          {/* SCREEN 3: Booking Confirmation QR Arrival Pass */}
          {activeTab === 3 && (
            <div className="flex-1 flex flex-col animate-in fade-in duration-300">
              <div className="text-center mb-2">
                <div className="w-8 h-8 rounded-full bg-[#10B981]/20 text-[#10B981] flex items-center justify-center mx-auto mb-1">
                  <Check size={16} />
                </div>
                <div className="text-xs font-bold font-heading text-white">Booking Confirmed</div>
                <div className="text-[10px] text-[#A7ADBD]">Pass #PUN-BK-7749</div>
              </div>

              <div className="bg-[#121520] border border-white/10 rounded-2xl p-3 flex flex-col items-center mb-3">
                {/* QR Code Graphic */}
                <div className="w-28 h-28 bg-white rounded-xl p-2 flex items-center justify-center mb-2">
                  <div className="w-full h-full bg-black/90 rounded flex items-center justify-center text-white">
                    <QrCode size={80} className="text-white" />
                  </div>
                </div>
                <div className="text-[10px] font-mono text-[#A020F0] font-semibold tracking-wider">
                  SCAN AT GATE ENTRANCE
                </div>
              </div>

              {/* Instructions */}
              <div className="bg-[#121520] p-2.5 rounded-xl border border-white/5 text-[10px] space-y-1 mb-auto">
                <div className="flex items-center gap-1 text-[#A7ADBD]">
                  <Clock size={11} className="text-[#C7A1FF]" />
                  <span>Valid Today: 10:00 AM – 12:00 PM</span>
                </div>
                <div className="flex items-center gap-1 text-[#A7ADBD]">
                  <MapPin size={11} className="text-[#C7A1FF]" />
                  <span>Gate 2, Skyline Tower, Baner, Pune</span>
                </div>
                <div className="flex items-center gap-1 text-[#10B981] font-medium pt-1">
                  <ShieldCheck size={11} />
                  <span>Condition photo prompt upon entry</span>
                </div>
              </div>

              <button 
                onClick={() => setActiveTab(0)}
                className="w-full mt-3 py-2 bg-white/10 hover:bg-white/15 text-white rounded-xl text-xs font-medium flex items-center justify-center gap-1"
              >
                Back to Start
              </button>
            </div>
          )}

          {/* Bottom Navigation Indicator Bar */}
          <div className="w-28 h-1 bg-white/20 rounded-full mx-auto mt-2"></div>
        </div>
      </div>
    </div>
  );
};

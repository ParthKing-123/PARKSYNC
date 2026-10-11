import React, { useState } from 'react';
import { Check, ShieldCheck } from 'lucide-react';

interface ModelProfile {
  name: string;
  type: string;
  lengthMm: number;
  widthMm: number;
  heightMm: number;
  slotLength: number;
  slotWidth: number;
}

export const EngineeringCompatibilityVisual: React.FC = () => {
  const models: ModelProfile[] = [
    {
      name: 'Mid SUV',
      type: 'e.g. Hyundai Creta',
      lengthMm: 4330,
      widthMm: 1790,
      heightMm: 1635,
      slotLength: 5000,
      slotWidth: 2400,
    },
    {
      name: 'Compact',
      type: 'e.g. Tata Nexon',
      lengthMm: 3994,
      widthMm: 1804,
      heightMm: 1620,
      slotLength: 5000,
      slotWidth: 2400,
    },
    {
      name: 'Full Sedan',
      type: 'e.g. Honda City',
      lengthMm: 4549,
      widthMm: 1748,
      heightMm: 1489,
      slotLength: 5000,
      slotWidth: 2400,
    },
  ];

  const [activeIdx, setActiveIdx] = useState(0);
  const current = models[activeIdx];

  const lengthClearance = current.slotLength - current.lengthMm;
  const widthClearance = current.slotWidth - current.widthMm;

  return (
    <div className="w-full bg-[#101116] border border-white/5 rounded-3xl p-6 sm:p-10 lg:p-12 relative overflow-hidden">
      {/* Blueprint Grid Atmosphere */}
      <div className="absolute inset-0 bg-[radial-gradient(#1c1e28_1px,transparent_1px)] [background-size:24px_24px] opacity-40 pointer-events-none"></div>

      <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
        {/* Left: Engineering Schematic (7 cols) */}
        <div className="lg:col-span-7 bg-[#08090B] border border-white/10 rounded-2xl p-6 sm:p-8 flex flex-col items-center">
          {/* Schematic Header */}
          <div className="w-full flex justify-between items-center text-[11px] font-mono text-[#9899A8] mb-6 border-b border-white/5 pb-3">
            <span className="flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-[#A020F0]"></span>
              PARKING_BAY_CAD // SPEC-502
            </span>
            <span className="text-[#C5A3FF]">BAY: 5.0m × 2.4m</span>
          </div>

          {/* Top-Down Spatial Alignment Frame */}
          <div className="w-full h-56 sm:h-64 border border-dashed border-[#A020F0]/40 rounded-xl relative flex items-center justify-center p-4 bg-[#0A0C10]">
            {/* Corner Caliper Marks */}
            <div className="absolute top-2 left-2 w-3 h-3 border-t-2 border-l-2 border-[#A020F0]"></div>
            <div className="absolute top-2 right-2 w-3 h-3 border-t-2 border-r-2 border-[#A020F0]"></div>
            <div className="absolute bottom-2 left-2 w-3 h-3 border-b-2 border-l-2 border-[#A020F0]"></div>
            <div className="absolute bottom-2 right-2 w-3 h-3 border-b-2 border-r-2 border-[#A020F0]"></div>

            {/* Vehicle Silhouette Box */}
            <div
              style={{
                width: `${(current.lengthMm / current.slotLength) * 88}%`,
                height: `${(current.widthMm / current.slotWidth) * 78}%`,
              }}
              className="bg-[#141620] border-2 border-[#C5A3FF] rounded-lg relative flex flex-col items-center justify-center transition-all duration-500 shadow-xl shadow-black/80"
            >
              <div className="w-10 h-3 bg-[#A020F0]/30 rounded-t-sm mb-1.5"></div>
              <span className="text-xs font-semibold text-white font-heading tracking-wide">
                {current.name}
              </span>
              <span className="text-[10px] font-mono text-[#9899A8] mt-0.5">
                {current.lengthMm} × {current.widthMm} mm
              </span>

              {/* Laser Center Axis Line */}
              <div className="absolute inset-x-0 top-1/2 h-px bg-[#A020F0]/30"></div>
            </div>

            {/* Dimension Callouts */}
            <div className="absolute bottom-3 left-4 text-[10px] font-mono text-[#10B981]">
              +{lengthClearance}mm longitudinal margin
            </div>
            <div className="absolute top-3 right-4 text-[10px] font-mono text-[#10B981]">
              +{widthClearance}mm door ingress space
            </div>
          </div>

          {/* Model Switcher Buttons */}
          <div className="w-full flex gap-2 mt-6">
            {models.map((m, idx) => (
              <button
                key={m.name}
                onClick={() => setActiveIdx(idx)}
                className={`flex-1 py-2 px-3 rounded-xl text-xs font-subheading transition-all ${
                  activeIdx === idx
                    ? 'bg-[#A020F0]/20 border border-[#A020F0] text-white font-medium'
                    : 'bg-[#101116] border border-white/5 text-[#9899A8] hover:text-white'
                }`}
              >
                <div className="font-semibold truncate">{m.name}</div>
                <div className="text-[9px] text-[#747C90] truncate">{m.type}</div>
              </button>
            ))}
          </div>
        </div>

        {/* Right: Architectural Explanation (5 cols) */}
        <div className="lg:col-span-5 space-y-6">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#10B981]/15 text-[#10B981] border border-[#10B981]/30 text-xs font-subheading font-medium">
            <Check size={14} /> Clear clearance confirmed
          </div>

          <h3 className="text-2xl sm:text-3xl font-bold font-heading text-white tracking-tight leading-snug">
            Precision alignment before you arrive.
          </h3>

          <p className="text-sm text-[#9899A8] leading-relaxed font-body">
            ParkSync cross-references standard manufacturer vehicle dimensions with surveyed bay limits. Drivers know their door-swing buffer and bumper room in advance.
          </p>

          <div className="pt-2 border-t border-white/5 space-y-3 text-xs text-[#9899A8]">
            <div className="flex items-center gap-2">
              <ShieldCheck size={16} className="text-[#A020F0] shrink-0" />
              <span>Protects paint and side panels from tight pillars</span>
            </div>
            <div className="flex items-center gap-2">
              <ShieldCheck size={16} className="text-[#A020F0] shrink-0" />
              <span>Overhead ramp height pre-vetted for SUVs</span>
            </div>
          </div>

          <p className="text-[11px] text-[#747C90] italic font-body">
            *Visual representation is illustrative. Measurements are matched against recorded property data.
          </p>
        </div>
      </div>
    </div>
  );
};

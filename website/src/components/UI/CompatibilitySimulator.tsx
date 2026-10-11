import { useState } from 'react';
import { CheckCircle2, Car, Ruler } from 'lucide-react';

interface VehicleSpec {
  name: string;
  category: string;
  length: number; // in mm
  width: number; // in mm
  height: number; // in mm
  sampleSlotLength: number;
  sampleSlotWidth: number;
  sampleSlotHeight: number;
}

export const CompatibilitySimulator: React.FC = () => {
  const vehicles: VehicleSpec[] = [
    {
      name: 'Hyundai Creta (2024)',
      category: 'Mid-size SUV',
      length: 4330,
      width: 1790,
      height: 1635,
      sampleSlotLength: 5000,
      sampleSlotWidth: 2400,
      sampleSlotHeight: 2200,
    },
    {
      name: 'Mahindra XUV700',
      category: 'Full-size SUV',
      length: 4695,
      width: 1890,
      height: 1755,
      sampleSlotLength: 5000,
      sampleSlotWidth: 2400,
      sampleSlotHeight: 2200,
    },
    {
      name: 'Honda City',
      category: 'Sedan',
      length: 4549,
      width: 1748,
      height: 1489,
      sampleSlotLength: 5000,
      sampleSlotWidth: 2400,
      sampleSlotHeight: 2200,
    },
    {
      name: 'Tata Tiago',
      category: 'Compact Hatchback',
      length: 3765,
      width: 1677,
      height: 1535,
      sampleSlotLength: 5000,
      sampleSlotWidth: 2400,
      sampleSlotHeight: 2200,
    },
  ];

  const [selectedIdx, setSelectedIdx] = useState(0);
  const current = vehicles[selectedIdx];

  const lengthMargin = current.sampleSlotLength - current.length;
  const widthMargin = current.sampleSlotWidth - current.width;
  const heightMargin = current.sampleSlotHeight - current.height;

  // Visual percentages for the diagram
  const lengthRatio = (current.length / current.sampleSlotLength) * 100;
  const widthRatio = (current.width / current.sampleSlotWidth) * 100;

  return (
    <div className="w-full bg-[#121520] border border-white/10 rounded-3xl p-6 sm:p-8 lg:p-10 shadow-2xl relative overflow-hidden">
      {/* Background Violet Glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-[#A020F0]/10 rounded-full blur-3xl pointer-events-none"></div>

      {/* Vehicle Selector Pills */}
      <div className="mb-8">
        <div className="text-xs font-subheading uppercase tracking-wider text-[#A7ADBD] mb-3">
          Select Vehicle Specification
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
          {vehicles.map((v, i) => (
            <button
              key={v.name}
              onClick={() => setSelectedIdx(i)}
              className={`p-3 rounded-xl text-left border transition-all ${
                selectedIdx === i
                  ? 'bg-[#A020F0]/15 border-[#A020F0] text-white shadow-lg shadow-[#A020F0]/15'
                  : 'bg-[#0D0F16] border-white/5 text-[#A7ADBD] hover:border-white/20'
              }`}
            >
              <div className="text-xs font-bold font-heading truncate">{v.name}</div>
              <div className="text-[10px] text-[#747C90]">{v.category}</div>
            </button>
          ))}
        </div>
      </div>

      {/* Split Interactive Visualization */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
        {/* Spatial Slot Diagram (7 cols) */}
        <div className="lg:col-span-7 bg-[#08090D] border border-white/10 rounded-2xl p-6 relative">
          <div className="flex justify-between items-center mb-4 text-xs font-subheading text-[#A7ADBD]">
            <span className="flex items-center gap-1.5">
              <Ruler size={14} className="text-[#A020F0]" />
              Standard Bay: {current.sampleSlotLength}mm × {current.sampleSlotWidth}mm
            </span>
            <span className="text-[#10B981] font-semibold">Overhead clearance: 2.2m</span>
          </div>

          {/* Top-Down Schematic View */}
          <div className="h-56 sm:h-64 border-2 border-dashed border-[#A020F0]/50 rounded-xl relative flex items-center justify-center p-4 bg-[#0B0D14]/80 overflow-hidden">
            {/* Ground markings */}
            <div className="absolute inset-x-8 top-0 h-1 bg-[#A020F0]/30"></div>
            <div className="absolute inset-x-8 bottom-0 h-1 bg-[#A020F0]/30"></div>
            <div className="absolute inset-y-8 left-0 w-1 bg-[#A020F0]/30"></div>
            <div className="absolute inset-y-8 right-0 w-1 bg-[#A020F0]/30"></div>

            {/* Vehicle Outline box */}
            <div
              style={{
                width: `${Math.min(92, Math.max(70, lengthRatio * 0.9))}%`,
                height: `${Math.min(84, Math.max(60, widthRatio * 0.8))}%`,
              }}
              className="bg-[#181C29] border-2 border-[#C7A1FF] rounded-xl flex flex-col items-center justify-center relative shadow-2xl transition-all duration-500 group"
            >
              {/* Windshield styling */}
              <div className="w-12 h-4 bg-[#A020F0]/30 rounded-t-md mb-2"></div>
              <div className="flex items-center gap-1 text-white font-heading text-xs sm:text-sm font-semibold">
                <Car size={16} className="text-[#C7A1FF]" />
                <span>{current.name}</span>
              </div>
              <div className="text-[10px] text-[#A7ADBD] font-mono mt-1">
                {current.length}mm × {current.width}mm
              </div>
            </div>

            {/* Dimension Indicators */}
            <div className="absolute top-2 right-4 text-[10px] font-mono text-[#10B981] bg-black/60 px-2 py-0.5 rounded border border-white/10">
              +{lengthMargin}mm length margin
            </div>
            <div className="absolute bottom-2 left-4 text-[10px] font-mono text-[#10B981] bg-black/60 px-2 py-0.5 rounded border border-white/10">
              +{widthMargin}mm door swing space
            </div>
          </div>
        </div>

        {/* Compatibility Result Card (5 cols) */}
        <div className="lg:col-span-5 flex flex-col justify-between space-y-6">
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#10B981]/15 text-[#10B981] border border-[#10B981]/30 text-xs font-semibold font-subheading mb-3">
              <CheckCircle2 size={14} /> Vehicle compatibility confirmed
            </div>

            <h3 className="text-2xl font-bold font-heading text-white mb-2">
              Looks like a fit.
            </h3>

            <p className="text-sm text-[#A7ADBD] leading-relaxed font-body">
              ParkSync checked <strong>{current.name}</strong> against this space's dimensions. With a{' '}
              <strong>+{lengthMargin}mm</strong> bumper margin and <strong>+{widthMargin}mm</strong> side clearance, you can exit the driver door without squeezing.
            </p>
          </div>

          <div className="space-y-2.5 pt-2 border-t border-white/10 text-xs font-body">
            <div className="flex justify-between items-center text-[#A7ADBD]">
              <span>Length Alignment:</span>
              <span className="text-white font-medium">{current.length}mm / {current.sampleSlotLength}mm</span>
            </div>
            <div className="flex justify-between items-center text-[#A7ADBD]">
              <span>Width Alignment:</span>
              <span className="text-white font-medium">{current.width}mm / {current.sampleSlotWidth}mm</span>
            </div>
            <div className="flex justify-between items-center text-[#A7ADBD]">
              <span>Vertical Clearance:</span>
              <span className="text-white font-medium">Clear ({heightMargin}mm headroom)</span>
            </div>
          </div>

          <p className="text-[11px] text-[#747C90] italic">
            *Results depend on manufacturer vehicle specifications and provider-verified parking bay measurements.
          </p>
        </div>
      </div>
    </div>
  );
};

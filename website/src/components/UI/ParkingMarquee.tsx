import { MapPin } from 'lucide-react';

const LIVE_HUBS = [
  { name: 'Koregaon Park Lane 7', bays: '12 Bays Available', type: 'Valet / Self', status: 'Live' },
  { name: 'Baner High Street Central', bays: '18 Bays Available', type: 'Underground Sensor', status: 'Live' },
  { name: 'Kalyani Nagar Trump Towers', bays: '8 Bays Available', type: 'Multi-Level Stilt', status: 'Live' },
  { name: 'SB Road Pavilion Mall Adjacent', bays: '15 Bays Available', type: 'Wide Bay Access', status: 'Live' },
  { name: 'Viman Nagar Phoenix Corridor', bays: '24 Bays Available', type: 'EV Equipped', status: 'Live' },
  { name: 'FC Road Deccan Gymkhana', bays: '10 Bays Available', type: 'Compact & Sedan', status: 'Live' },
  { name: 'Aundh IT Park Complex', bays: '16 Bays Available', type: 'Corporate Reserved', status: 'Live' },
];

export const ParkingMarquee: React.FC = () => {
  return (
    <div className="w-full overflow-hidden py-4 border-y border-white/10 bg-[#08090E]/60 backdrop-blur-md relative select-none">
      {/* Edge Blur Vignettes */}
      <div className="absolute left-0 top-0 bottom-0 w-24 bg-gradient-to-r from-[#07080b] to-transparent z-10 pointer-events-none" />
      <div className="absolute right-0 top-0 bottom-0 w-24 bg-gradient-to-l from-[#07080b] to-transparent z-10 pointer-events-none" />

      <div className="animate-marquee flex items-center gap-6 whitespace-nowrap">
        {/* Double the list to ensure perfectly seamless continuous loop */}
        {[...LIVE_HUBS, ...LIVE_HUBS].map((hub, idx) => (
          <div
            key={idx}
            className="inline-flex items-center gap-3 px-4 py-2 rounded-full bg-white/[0.03] border border-white/10 hover:border-[#A020F0]/50 transition-colors"
          >
            <div className="flex items-center gap-1.5 text-xs font-semibold text-white font-heading">
              <MapPin size={13} className="text-[#A020F0]" />
              <span>{hub.name}</span>
            </div>
            <span className="text-[11px] font-mono text-[#00E5FF] flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-[#00E5FF] animate-pulse" />
              {hub.bays}
            </span>
            <span className="text-[10px] uppercase font-mono px-2 py-0.5 rounded bg-white/5 text-[#9899A8]">
              {hub.type}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

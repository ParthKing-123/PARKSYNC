import React, { useEffect, useState } from 'react';
import { ArrowUp, Gauge } from 'lucide-react';

export const ScrollCarEmblem: React.FC = () => {
  const [scrollProgress, setScrollProgress] = useState(0);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;
      const totalHeight = document.documentElement.scrollHeight - window.innerHeight;
      const progress = totalHeight > 0 ? (currentScrollY / totalHeight) * 100 : 0;
      
      setScrollProgress(Math.min(100, Math.max(0, progress)));
      setIsVisible(currentScrollY > 120);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();

    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  if (!isVisible) return null;

  return (
    <aside 
      aria-label="Vehicle telemetry and navigation dock"
      className="fixed bottom-6 right-6 z-50 flex items-center gap-3 transition-all duration-500 ease-out"
      style={{
        opacity: isVisible ? 1 : 0,
        transform: isVisible ? 'translateY(0) scale(1)' : 'translateY(20px) scale(0.95)',
      }}
    >
      {/* Dynamic Floating Automotive Badge */}
      <div 
        onClick={scrollToTop}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); scrollToTop(); } }}
        className="group relative cursor-pointer flex items-center gap-3 px-3.5 py-2.5 rounded-2xl bg-[#08090B]/90 backdrop-blur-xl border border-white/10 shadow-2xl shadow-black/80 hover:border-[#A020F0]/60 transition-all duration-300 hover:scale-105 select-none"
        title="Scroll to top — ParkSync Hypercar Telemetry"
      >
        {/* Glow Halo */}
        <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-[#A020F0]/20 to-[#D40000]/20 opacity-0 group-hover:opacity-100 transition-opacity blur-md -z-10"></div>

        {/* Authentic Ferrari-Inspired Prancing Shield SVG */}
        <div className="relative w-9 h-11 flex-shrink-0 flex items-center justify-center filter drop-shadow-[0_2px_8px_rgba(255,215,0,0.35)]">
          <svg viewBox="0 0 60 76" className="w-full h-full" fill="none" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <linearGradient id="shieldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#FFF200" />
                <stop offset="70%" stopColor="#FFD700" />
                <stop offset="100%" stopColor="#D4A000" />
              </linearGradient>
              <linearGradient id="shieldBorder" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#FFFFFF" />
                <stop offset="50%" stopColor="#111111" />
                <stop offset="100%" stopColor="#FFD700" />
              </linearGradient>
              <linearGradient id="horseGrad" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" stopColor="#15171C" />
                <stop offset="100%" stopColor="#050608" />
              </linearGradient>
            </defs>

            {/* Italian Tricolor Top Arc */}
            <path d="M6 8 C15 3, 45 3, 54 8 L54 13 L6 13 Z" fill="#009246" />
            <path d="M22 8 L38 8 L38 13 L22 13 Z" fill="#FFFFFF" />
            <path d="M38 8 L54 8 L54 13 L38 13 Z" fill="#CE2B37" />

            {/* Scuderia Shield Body */}
            <path 
              d="M6 13 L54 13 C54 36, 48 58, 30 72 C12 58, 6 36, 6 13 Z" 
              fill="url(#shieldGrad)" 
              stroke="url(#shieldBorder)" 
              strokeWidth="1.8"
            />

            {/* Prancing Stallion Silhouette (Detailed Stylized Path) */}
            <path
              d="M32 23 C33 21, 35 20, 37 21 C36 23, 35 24, 34 25 C37 26, 38 29, 36 32 C34 31, 32 32, 31 34 C33 35, 34 37, 33 39 C31 38, 30 38, 29 40 C31 43, 30 46, 28 49 C27 47, 26 44, 27 41 C25 43, 23 46, 22 50 C21 53, 20 57, 22 61 C23 61, 24 59, 25 57 C27 58, 28 61, 29 63 C27 64, 25 64, 23 64 C20 62, 19 56, 20 52 C21 47, 24 43, 25 39 C24 37, 23 35, 23 33 C24 30, 27 28, 29 27 C28 25, 29 23, 32 23 Z"
              fill="url(#horseGrad)"
            />

            {/* SF Letters / ParkSync PS Monogram Accent */}
            <text x="18" y="69" fontSize="6" fontWeight="bold" fontFamily="monospace" fill="#111111" opacity="0.85">P</text>
            <text x="37" y="69" fontSize="6" fontWeight="bold" fontFamily="monospace" fill="#111111" opacity="0.85">S</text>
          </svg>
        </div>

        {/* Live Scroll Telemetry Data */}
        <div className="flex flex-col text-left pr-1">
          <div className="flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-[#00E5FF] animate-pulse"></span>
            <span className="text-[10px] font-mono tracking-wider font-bold text-white uppercase group-hover:text-[#C5A3FF] transition-colors">
              FERRARI SPEC
            </span>
          </div>
          <div className="flex items-center gap-2 text-[9px] text-[#9899A8] font-mono mt-0.5">
            <span className="flex items-center gap-0.5 text-[#C5A3FF]">
              <Gauge size={10} />
              {Math.round(scrollProgress)}%
            </span>
            <span className="text-white/20">|</span>
            <span className="text-[#00E5FF]">BAY FIT: 100%</span>
          </div>
        </div>

        {/* Scroll To Top Arrow Button */}
        <div className="w-7 h-7 rounded-full bg-white/5 border border-white/10 flex items-center justify-center group-hover:bg-[#A020F0] group-hover:border-[#A020F0] text-[#9899A8] group-hover:text-white transition-all">
          <ArrowUp size={13} className="group-hover:-translate-y-0.5 transition-transform" />
        </div>
      </div>
    </aside>
  );
};

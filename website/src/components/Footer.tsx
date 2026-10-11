import React from 'react';
import { Link } from 'react-router-dom';

export const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="w-full bg-[#08090B] border-t border-white/5 py-12 px-6 sm:px-10 lg:px-16 font-body text-xs text-[#9899A8]">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
        {/* Wordmark */}
        <div className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-[#A020F0]"></span>
          <span className="text-sm font-bold font-heading text-white tracking-tight">ParkSync</span>
          <span className="text-[11px] text-[#747C90] ml-2">Pune Pilot</span>
        </div>

        {/* Compact Navigation */}
        <div className="flex flex-wrap items-center justify-center gap-6 sm:gap-8">
          <Link to="/how-it-works" className="hover:text-white transition-colors">How It Works</Link>
          <Link to="/for-drivers" className="hover:text-white transition-colors">For Drivers</Link>
          <Link to="/for-providers" className="hover:text-white transition-colors">For Providers</Link>
          <Link to="/trust-and-safety" className="hover:text-white transition-colors">Trust & Safety</Link>
          <Link to="/faq" className="hover:text-white transition-colors">FAQ</Link>
          <Link to="/contact" className="hover:text-white transition-colors">Contact</Link>
        </div>

        {/* Year and Legal */}
        <div className="flex items-center gap-4 text-[#747C90]">
          <span>&copy; {currentYear} ParkSync</span>
          <span>•</span>
          <Link to="/trust-and-safety" className="hover:text-[#9899A8] transition-colors">Privacy & Terms</Link>
        </div>
      </div>
    </footer>
  );
};

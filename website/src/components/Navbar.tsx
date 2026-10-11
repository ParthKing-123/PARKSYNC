import { useState, useEffect } from 'react';
import { Link, NavLink } from 'react-router-dom';
import { Menu, X, ArrowUpRight } from 'lucide-react';

interface NavbarProps {
  onOpenPilot: (defaultRole?: 'seeker' | 'provider') => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onOpenPilot }) => {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 24);
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navLinks = [
    { name: 'How it works', path: '/how-it-works' },
    { name: 'For Providers', path: '/for-providers' },
    { name: 'Trust', path: '/trust-and-safety' },
  ];

  return (
    <header className="fixed top-0 left-0 right-0 z-50 transition-all duration-300">
      <nav
        className={`w-full max-w-7xl mx-auto px-6 sm:px-10 h-20 flex items-center justify-between transition-all duration-300 ${
          scrolled
            ? 'bg-[#08090B]/90 backdrop-blur-md border-b border-white/5'
            : 'bg-transparent'
        }`}
        aria-label="Main Navigation"
      >
        {/* Minimal Wordmark */}
        <Link to="/" className="flex items-center gap-2 group">
          <span className="w-2 h-2 rounded-full bg-[#A020F0] group-hover:scale-125 transition-transform"></span>
          <span className="text-lg font-bold font-heading tracking-tight text-[#F7F7FA] group-hover:text-white transition-colors">
            ParkSync
          </span>
        </Link>

        {/* Compact Right Navigation */}
        <div className="hidden md:flex items-center gap-8 font-body text-xs">
          {navLinks.map((link) => (
            <NavLink
              key={link.path}
              to={link.path}
              className={({ isActive }) =>
                `transition-colors font-medium ${
                  isActive
                    ? 'text-white font-semibold'
                    : 'text-[#9899A8] hover:text-[#F7F7FA]'
                }`
              }
            >
              {link.name}
            </NavLink>
          ))}

          <button
            onClick={() => onOpenPilot('seeker')}
            className="px-4 py-2 rounded-full text-xs font-semibold bg-[#A020F0] hover:bg-[#8e1cd6] text-white transition-all shadow-md shadow-[#A020F0]/20 hover:scale-[1.02] active:scale-[0.98]"
          >
            Join the Pilot
          </button>
        </div>

        {/* Mobile Hamburger */}
        <div className="flex items-center gap-3 md:hidden">
          <button
            onClick={() => onOpenPilot('seeker')}
            className="px-3 py-1.5 rounded-full text-xs font-semibold bg-[#A020F0] text-white"
          >
            Join Pilot
          </button>

          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="p-1.5 text-[#9899A8] hover:text-white transition-colors"
            aria-label={mobileMenuOpen ? 'Close Menu' : 'Open Menu'}
          >
            {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
          </button>
        </div>
      </nav>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-[#08090B]/98 backdrop-blur-2xl border-b border-white/10 px-6 py-6 space-y-4 animate-in slide-in-from-top-2 duration-200">
          <div className="flex flex-col space-y-3 font-body text-sm">
            {navLinks.map((link) => (
              <NavLink
                key={link.path}
                to={link.path}
                onClick={() => setMobileMenuOpen(false)}
                className={({ isActive }) =>
                  `py-2 flex items-center justify-between transition-colors ${
                    isActive ? 'text-white font-semibold' : 'text-[#9899A8] hover:text-white'
                  }`
                }
              >
                <span>{link.name}</span>
                <ArrowUpRight size={14} className="text-[#747C90]" />
              </NavLink>
            ))}

            <div className="pt-4 border-t border-white/5 flex flex-col gap-2">
              <button
                onClick={() => {
                  setMobileMenuOpen(false);
                  onOpenPilot('seeker');
                }}
                className="w-full py-3 rounded-full text-xs font-semibold bg-[#A020F0] text-white text-center"
              >
                Join the Driver Pilot
              </button>
              <button
                onClick={() => {
                  setMobileMenuOpen(false);
                  onOpenPilot('provider');
                }}
                className="w-full py-3 rounded-full text-xs font-semibold bg-white/5 text-[#C5A3FF] text-center"
              >
                Offer Parking Space
              </button>
            </div>
          </div>
        </div>
      )}
    </header>
  );
};

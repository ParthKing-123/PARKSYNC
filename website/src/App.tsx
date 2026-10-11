import { useState, useEffect, Suspense, lazy } from 'react';
import { Routes, Route, useLocation } from 'react-router-dom';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { PilotModal } from './components/PilotModal';

// Route-level code-splitting for performance on mobile
const Home = lazy(() => import('./pages/Home').then((m) => ({ default: m.Home })));
const HowItWorks = lazy(() => import('./pages/HowItWorks').then((m) => ({ default: m.HowItWorks })));
const ForDrivers = lazy(() => import('./pages/ForDrivers').then((m) => ({ default: m.ForDrivers })));
const ForProviders = lazy(() => import('./pages/ForProviders').then((m) => ({ default: m.ForProviders })));
const TrustSafety = lazy(() => import('./pages/TrustSafety').then((m) => ({ default: m.TrustSafety })));
const FAQ = lazy(() => import('./pages/FAQ').then((m) => ({ default: m.FAQ })));
const Contact = lazy(() => import('./pages/Contact').then((m) => ({ default: m.Contact })));

// Scroll to top upon route change or anchor navigation
function ScrollToTop() {
  const { pathname, hash } = useLocation();

  useEffect(() => {
    if (!hash) {
      window.scrollTo(0, 0);
    } else {
      const element = document.getElementById(hash.replace('#', ''));
      if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
      }
    }
  }, [pathname, hash]);

  return null;
}

// Lightweight fallback during route transition
function RouteFallback() {
  return (
    <div className="min-h-[70vh] flex items-center justify-center">
      <div className="w-8 h-8 rounded-full border-2 border-[#A020F0]/20 border-t-[#A020F0] animate-spin"></div>
    </div>
  );
}

function App() {
  const [pilotModalOpen, setPilotModalOpen] = useState(false);
  const [pilotRole, setPilotRole] = useState<'seeker' | 'provider'>('seeker');

  const handleOpenPilot = (role: 'seeker' | 'provider' = 'seeker') => {
    setPilotRole(role);
    setPilotModalOpen(true);
  };

  return (
    <div className="min-h-screen bg-[#08090D] text-[#F7F7FC] flex flex-col selection:bg-[#A020F0]/30 selection:text-white">
      <ScrollToTop />
      
      {/* Shared refined Floating Navbar */}
      <Navbar onOpenPilot={handleOpenPilot} />

      {/* Main Content Area with Suspense */}
      <main className="flex-1">
        <Suspense fallback={<RouteFallback />}>
          <Routes>
            <Route path="/" element={<Home onOpenPilot={handleOpenPilot} />} />
            <Route path="/how-it-works" element={<HowItWorks onOpenPilot={handleOpenPilot} />} />
            <Route path="/for-drivers" element={<ForDrivers onOpenPilot={handleOpenPilot} />} />
            <Route path="/for-providers" element={<ForProviders />} />
            <Route path="/trust-and-safety" element={<TrustSafety />} />
            <Route path="/faq" element={<FAQ />} />
            <Route path="/contact" element={<Contact />} />
            {/* Catch-all fallback */}
            <Route path="*" element={<Home onOpenPilot={handleOpenPilot} />} />
          </Routes>
        </Suspense>
      </main>

      {/* Shared Carbon-Black Footer */}
      <Footer />

      {/* Pilot Registration Modal */}
      <PilotModal
        key={pilotRole}
        isOpen={pilotModalOpen}
        onClose={() => setPilotModalOpen(false)}
        defaultRole={pilotRole}
      />
    </div>
  );
}

export default App;

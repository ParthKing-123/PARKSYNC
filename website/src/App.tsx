import { Car, MapPin, ShieldCheck, Smartphone, CheckCircle, ArrowRight } from 'lucide-react';

function App() {
  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="fixed w-full bg-white/90 backdrop-blur-md z-50 border-b border-gray-100">
        <div className="max-w-6xl mx-auto px-6 h-20 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Car className="text-purple-600" size={32} />
            <span className="text-2xl font-bold text-gray-900 tracking-tight">ParkSync</span>
          </div>
          <div className="hidden md:flex items-center gap-8">
            <a href="#how-it-works" className="text-gray-600 hover:text-gray-900 font-medium transition-colors">How it works</a>
            <a href="#providers" className="text-gray-600 hover:text-gray-900 font-medium transition-colors">List your space</a>
            <button className="bg-gray-900 hover:bg-gray-800 text-white px-6 py-2.5 rounded-full font-medium transition-colors">
              Download App
            </button>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-6">
        <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-12 items-center">
          <div>
            <span className="px-4 py-1.5 bg-purple-100 text-purple-700 rounded-full text-sm font-bold tracking-wide uppercase mb-6 inline-block">
              Now live in Pune
            </span>
            <h1 className="text-5xl md:text-6xl font-extrabold text-gray-900 leading-tight mb-6">
              Find parking.<br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-purple-600 to-blue-600">
                Skip the search.
              </span>
            </h1>
            <p className="text-xl text-gray-600 mb-8 leading-relaxed max-w-lg">
              The smartest way to find guaranteed parking that fits your exact vehicle dimensions. Book in seconds, park with confidence.
            </p>
            <div className="flex flex-col sm:flex-row gap-4">
              <button className="flex items-center justify-center gap-2 bg-gray-900 text-white px-8 py-4 rounded-full font-semibold hover:bg-gray-800 transition-all shadow-lg hover:shadow-xl">
                <Smartphone size={20} />
                Get it on iOS
              </button>
              <button className="flex items-center justify-center gap-2 bg-white text-gray-900 border-2 border-gray-200 px-8 py-4 rounded-full font-semibold hover:border-gray-900 transition-all">
                <Smartphone size={20} />
                Get it on Android
              </button>
            </div>
          </div>
          <div className="relative">
            {/* Abstract Mobile App Mockup */}
            <div className="w-[300px] h-[600px] bg-gray-900 rounded-[3rem] p-4 shadow-2xl mx-auto relative border-8 border-gray-100">
              <div className="w-full h-full bg-[#141416] rounded-[2.2rem] overflow-hidden flex flex-col relative">
                {/* Mock UI */}
                <div className="h-48 bg-purple-900/40 relative">
                  <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-30"></div>
                  <div className="absolute bottom-4 left-4 right-4 bg-white/10 backdrop-blur-md p-4 rounded-xl border border-white/20">
                    <div className="text-white font-medium">Baner Premium Parking</div>
                    <div className="text-purple-300 text-sm mt-1">₹40/hr • 0.4 km away</div>
                  </div>
                </div>
                <div className="p-4 flex-1">
                  <div className="w-full h-12 bg-white/5 rounded-lg mb-4"></div>
                  <div className="w-3/4 h-6 bg-white/10 rounded mb-2"></div>
                  <div className="w-1/2 h-4 bg-white/5 rounded mb-6"></div>
                  
                  <div className="w-full h-16 bg-green-500/20 border border-green-500/50 rounded-xl flex items-center px-4 mb-4">
                    <CheckCircle className="text-green-400 mr-3" size={24} />
                    <div>
                      <div className="text-white text-sm font-medium">Your Hyundai Creta</div>
                      <div className="text-green-400 text-xs">Fits this space ✓</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="how-it-works" className="py-24 bg-gray-50 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">Why ParkSync?</h2>
            <p className="text-xl text-gray-600">Built to solve the real frustrations of city parking.</p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
              <div className="w-14 h-14 bg-purple-100 rounded-xl flex items-center justify-center mb-6">
                <Car className="text-purple-600" size={28} />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Vehicle Compatibility</h3>
              <p className="text-gray-600 leading-relaxed">
                Just tell us what you drive. We cross-reference your vehicle's dimensions against the parking space to guarantee a perfect fit. No more tight squeezes.
              </p>
            </div>
            
            <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
              <div className="w-14 h-14 bg-blue-100 rounded-xl flex items-center justify-center mb-6">
                <MapPin className="text-blue-600" size={28} />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Guaranteed Spots</h3>
              <p className="text-gray-600 leading-relaxed">
                When you book on ParkSync, the spot is yours. Real-time availability ensures you never pay for a space that isn't empty.
              </p>
            </div>
            
            <div className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
              <div className="w-14 h-14 bg-green-100 rounded-xl flex items-center justify-center mb-6">
                <ShieldCheck className="text-green-600" size={28} />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Verified Safety</h3>
              <p className="text-gray-600 leading-relaxed">
                Every parking space is strictly vetted. Filter by CCTV surveillance, covered roofing, or security guard presence.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Provider CTA */}
      <section id="providers" className="py-24 px-6">
        <div className="max-w-6xl mx-auto bg-gray-900 rounded-[3rem] overflow-hidden">
          <div className="grid md:grid-cols-2">
            <div className="p-12 md:p-20 flex flex-col justify-center">
              <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">Have an empty parking space?</h2>
              <p className="text-gray-400 text-lg mb-8 leading-relaxed">
                Whether you're a restaurant, corporate office, or just have a private driveway, turn your unused parking capacity into guaranteed revenue.
              </p>
              <ul className="space-y-4 mb-10">
                <li className="flex items-center text-white"><CheckCircle className="text-purple-400 mr-3" size={20} /> Set your own pricing</li>
                <li className="flex items-center text-white"><CheckCircle className="text-purple-400 mr-3" size={20} /> Choose your availability</li>
                <li className="flex items-center text-white"><CheckCircle className="text-purple-400 mr-3" size={20} /> Zero setup fees</li>
              </ul>
              <div>
                <button className="flex items-center justify-center gap-2 bg-purple-600 text-white px-8 py-4 rounded-full font-semibold hover:bg-purple-700 transition-colors w-max">
                  List Your Space <ArrowRight size={20} />
                </button>
              </div>
            </div>
            <div className="hidden md:block bg-gray-800 bg-[url('https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80')] bg-cover bg-center">
              <div className="w-full h-full bg-gray-900/60 mix-blend-multiply"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-50 border-t border-gray-200 py-12 px-6">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-center">
          <div className="flex items-center gap-2 mb-4 md:mb-0">
            <Car className="text-purple-600" size={24} />
            <span className="text-xl font-bold text-gray-900 tracking-tight">ParkSync</span>
          </div>
          <div className="text-gray-500 text-sm">
            &copy; {new Date().getFullYear()} ParkSync India. All rights reserved. (Pilot Program: Pune, MH)
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;

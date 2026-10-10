import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import PendingVerifications from './pages/PendingVerifications';
import { ShieldCheck, Map, Users, Settings } from 'lucide-react';

function App() {
  return (
    <Router>
      <div className="flex h-screen bg-gray-50 text-gray-900 w-full overflow-hidden !max-w-none text-left" style={{ margin: 0, padding: 0 }}>
        {/* Sidebar */}
        <aside className="w-64 bg-white border-r border-gray-200 flex flex-col h-full">
          <div className="p-6 border-b border-gray-200">
            <h1 className="text-xl font-bold text-gray-900 flex items-center gap-2 m-0 p-0 !text-xl !tracking-normal">
              <ShieldCheck className="text-purple-600" />
              ParkSync Admin
            </h1>
          </div>
          <nav className="flex-1 p-4 space-y-2">
            <Link to="/" className="flex items-center gap-3 px-4 py-3 bg-purple-50 text-purple-700 rounded-lg font-medium">
              <Map size={20} />
              Verifications
            </Link>
            <Link to="#" className="flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 rounded-lg font-medium">
              <Users size={20} />
              Users
            </Link>
            <Link to="#" className="flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 rounded-lg font-medium">
              <Settings size={20} />
              Settings
            </Link>
          </nav>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-auto bg-gray-50">
          <Routes>
            <Route path="/" element={<PendingVerifications />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;

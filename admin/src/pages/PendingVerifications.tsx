import { useState, useEffect } from 'react';
import axios from 'axios';
import { CheckCircle, XCircle, AlertCircle } from 'lucide-react';

export default function PendingVerifications() {
  const [spaces, setSpaces] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchPending = async () => {
    try {
      setLoading(true);
      const res = await axios.get('http://localhost:3000/api/admin/spaces/pending');
      setSpaces(res.data);
    } catch (err) {
      setError('Failed to fetch pending verifications');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPending();
  }, []);

  const handleVerify = async (id: string, action: 'APPROVE' | 'REJECT') => {
    try {
      await axios.post(`http://localhost:3000/api/admin/spaces/${id}/verify`, { action });
      // Remove from list
      setSpaces(spaces.filter(s => s.id !== id));
    } catch (err) {
      alert('Failed to update space');
    }
  };

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <header className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 m-0 !text-3xl">Pending Verifications</h1>
        <p className="text-gray-500 mt-2">Review and approve newly submitted parking spaces.</p>
      </header>

      {error && (
        <div className="bg-red-50 text-red-700 p-4 rounded-lg mb-6 flex items-center gap-2">
          <AlertCircle size={20} />
          {error}
        </div>
      )}

      {loading ? (
        <div className="text-center py-12 text-gray-500">Loading pending spaces...</div>
      ) : spaces.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-xl border border-gray-200">
          <CheckCircle className="mx-auto text-green-500 mb-4" size={48} />
          <h3 className="text-lg font-medium text-gray-900">All caught up!</h3>
          <p className="text-gray-500">There are no pending spaces to verify.</p>
        </div>
      ) : (
        <div className="grid gap-6">
          {spaces.map(space => (
            <div key={space.id} className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm flex flex-col md:flex-row gap-6">
              
              <div className="w-full md:w-64 h-48 bg-gray-100 rounded-lg flex items-center justify-center overflow-hidden border border-gray-200">
                 {/* In real app, render space images here */}
                 <span className="text-gray-400">No Image Provided</span>
              </div>

              <div className="flex-1">
                <div className="flex justify-between items-start">
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900 m-0 !text-xl">{space.title}</h2>
                    <p className="text-gray-500 text-sm mt-1">{space.address}, {space.city}</p>
                  </div>
                  <span className="px-3 py-1 bg-yellow-100 text-yellow-800 text-xs font-bold rounded-full uppercase">
                    Pending
                  </span>
                </div>

                <div className="mt-4 grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-gray-500">Provider Type:</span>
                    <p className="font-medium text-gray-900">{space.provider?.providerType}</p>
                  </div>
                  <div>
                    <span className="text-gray-500">Space Type:</span>
                    <p className="font-medium text-gray-900">{space.spaceType} ({space.covered ? 'Covered' : 'Uncovered'})</p>
                  </div>
                  <div>
                    <span className="text-gray-500">Dimensions:</span>
                    <p className="font-medium text-gray-900">{space.lengthMm}x{space.widthMm} (h: {space.heightClearanceMm || 'N/A'}) mm</p>
                  </div>
                  <div>
                    <span className="text-gray-500">Price:</span>
                    <p className="font-medium text-gray-900">₹{space.pricePerHour} / hr</p>
                  </div>
                </div>
                
                <div className="mt-6 flex gap-3 border-t border-gray-100 pt-6">
                  <button 
                    onClick={() => handleVerify(space.id, 'APPROVE')}
                    className="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition-colors cursor-pointer"
                  >
                    <CheckCircle size={18} /> Approve
                  </button>
                  <button 
                    onClick={() => handleVerify(space.id, 'REJECT')}
                    className="flex items-center gap-2 px-4 py-2 bg-red-50 hover:bg-red-100 text-red-700 rounded-lg font-medium transition-colors cursor-pointer"
                  >
                    <XCircle size={18} /> Reject
                  </button>
                </div>
              </div>

            </div>
          ))}
        </div>
      )}
    </div>
  );
}

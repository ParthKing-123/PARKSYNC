import { useState } from 'react';
import { Mail, MapPin, MessageSquare, Send, CheckCircle2, Loader2, Sparkles } from 'lucide-react';
import { Reveal } from '../components/Reveal';

export const Contact: React.FC = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('General Enquiry');
  const [message, setMessage] = useState('');

  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!name.trim()) {
      setError('Please provide your name');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      setError('Please provide a valid email address');
      return;
    }
    if (!message.trim()) {
      setError('Please write your message');
      return;
    }

    setLoading(true);

    setTimeout(() => {
      try {
        const stored = JSON.parse(localStorage.getItem('parksync_contact_messages') || '[]');
        stored.push({
          name,
          email,
          subject,
          message,
          date: new Date().toISOString(),
        });
        localStorage.setItem('parksync_contact_messages', JSON.stringify(stored));
      } catch (err) {
        console.warn('Storage error:', err);
      }

      setLoading(false);
      setSubmitted(true);
    }, 600);
  };

  return (
    <div className="w-full bg-[#08090D] text-[#F7F7FC] pt-32 pb-24 px-6 sm:px-8 lg:px-12">
      <div className="max-w-6xl mx-auto space-y-20">
        {/* Header */}
        <div className="max-w-3xl space-y-6">
          <Reveal>
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#121520] border border-white/10 text-xs font-subheading text-[#C7A1FF]">
              <Sparkles size={12} className="text-[#A020F0]" />
              GET IN TOUCH
            </div>
          </Reveal>

          <Reveal delay={0.1}>
            <h1 className="text-4xl sm:text-5xl font-extrabold font-heading text-white tracking-tight">
              Contact the ParkSync Team
            </h1>
          </Reveal>

          <Reveal delay={0.2}>
            <p className="text-base sm:text-lg text-[#A7ADBD] leading-relaxed font-body">
              Whether you are an enterprise building owner in Hinjewadi, a restaurant proprietor in Baner, or a driver with feedback on our compatibility engine, we would love to hear from you.
            </p>
          </Reveal>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12">
          {/* Contact Details & Pilot Office Info (5 cols) */}
          <div className="lg:col-span-5 space-y-6">
            <div className="bg-[#121520] border border-white/10 rounded-3xl p-8 space-y-6">
              <h3 className="text-xl font-bold font-heading text-white">Pilot Operations</h3>
              
              <div className="space-y-5 text-xs text-[#A7ADBD] font-body">
                <div className="flex items-start gap-3">
                  <MapPin size={18} className="text-[#A020F0] shrink-0 mt-0.5" />
                  <div>
                    <div className="text-white font-semibold">Pilot Operating Hub</div>
                    <div>Baner & Balewadi High Street Sector, Pune, Maharashtra 411045</div>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <Mail size={18} className="text-[#A020F0] shrink-0 mt-0.5" />
                  <div>
                    <div className="text-white font-semibold">General & Partnerships Email</div>
                    <div>team@parksync.in (Configurable Pilot Desk)</div>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <MessageSquare size={18} className="text-[#A020F0] shrink-0 mt-0.5" />
                  <div>
                    <div className="text-white font-semibold">Response Window</div>
                    <div>Pune local team typically replies within 1 business day.</div>
                  </div>
                </div>
              </div>
            </div>

            <div className="p-6 bg-[#0D0F16] rounded-2xl border border-white/5 text-xs text-[#747C90] space-y-2">
              <div className="font-semibold text-[#A7ADBD]">For Parking Inquiries:</div>
              <p>
                If you are a property host looking to list parking spaces, please consider using our dedicated <strong>For Providers</strong> onboarding form for faster prioritization.
              </p>
            </div>
          </div>

          {/* Contact Form (7 cols) */}
          <div className="lg:col-span-7 bg-[#121520] border border-white/10 rounded-3xl p-8 sm:p-10 shadow-2xl">
            {!submitted ? (
              <form onSubmit={handleSubmit} className="space-y-4 font-body">
                <h3 className="text-2xl font-bold font-heading text-white mb-2">
                  Send a message
                </h3>
                <p className="text-xs text-[#A7ADBD] mb-6">
                  Fill out the form below and we will route your inquiry to the right specialist.
                </p>

                {error && (
                  <div className="p-3 bg-red-500/10 border border-red-500/30 text-red-300 text-xs rounded-lg">
                    {error}
                  </div>
                )}

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                      Full Name *
                    </label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. Sneha Patel"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl bg-[#08090D] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                      Email Address *
                    </label>
                    <input
                      type="email"
                      required
                      placeholder="sneha@example.com"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl bg-[#08090D] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                    Inquiry Subject
                  </label>
                  <select
                    value={subject}
                    onChange={(e) => setSubject(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl bg-[#08090D] border border-white/10 text-white text-sm focus:outline-none focus:border-[#A020F0]"
                  >
                    <option value="General Enquiry">General Enquiry</option>
                    <option value="Provider Partnership">Provider Partnership (Listing Space)</option>
                    <option value="Pilot Driver Feedback">Pilot Driver Feedback</option>
                    <option value="Press / Media">Press / Media Inquiry</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-medium text-[#A7ADBD] mb-1">
                    Your Message *
                  </label>
                  <textarea
                    rows={5}
                    required
                    placeholder="Tell us what's on your mind..."
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl bg-[#08090D] border border-white/10 text-white placeholder-[#747C90] text-sm focus:outline-none focus:border-[#A020F0]"
                  ></textarea>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full py-3.5 px-6 rounded-xl bg-[#A020F0] hover:bg-[#8e1cd6] text-white font-semibold text-sm transition-all shadow-lg shadow-[#A020F0]/25 flex items-center justify-center gap-2 disabled:opacity-60"
                >
                  {loading ? (
                    <>
                      <Loader2 size={16} className="animate-spin" />
                      Sending message...
                    </>
                  ) : (
                    <>
                      <Send size={16} /> Send Message
                    </>
                  )}
                </button>
              </form>
            ) : (
              <div className="text-center py-12 space-y-4">
                <div className="w-14 h-14 mx-auto rounded-full bg-[#10B981]/20 text-[#10B981] flex items-center justify-center">
                  <CheckCircle2 size={32} />
                </div>
                <h3 className="text-2xl font-bold font-heading text-white">Message Dispatched</h3>
                <p className="text-sm text-[#A7ADBD] max-w-sm mx-auto">
                  Thank you, <strong className="text-white">{name}</strong>. Your message regarding{' '}
                  <strong className="text-[#C7A1FF]">{subject}</strong> has been received by our Pune desk.
                </p>
                <button
                  onClick={() => setSubmitted(false)}
                  className="py-2 px-6 rounded-xl bg-white/10 text-xs text-white hover:bg-white/15 transition-colors mt-2"
                >
                  Send Another Message
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

import React, { useState } from 'react';
import { ChevronDown } from 'lucide-react';

export interface FAQItem {
  id: string;
  question: string;
  answer: string;
  category?: string;
}

interface AccordionProps {
  items: FAQItem[];
  allowMultiple?: boolean;
}

export const Accordion: React.FC<AccordionProps> = ({ items, allowMultiple = false }) => {
  const [openIds, setOpenIds] = useState<string[]>([items[0]?.id || '']);

  const toggle = (id: string) => {
    if (allowMultiple) {
      setOpenIds((prev) =>
        prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
      );
    } else {
      setOpenIds((prev) => (prev.includes(id) ? [] : [id]));
    }
  };

  return (
    <div className="space-y-3 font-body">
      {items.map((item) => {
        const isOpen = openIds.includes(item.id);

        return (
          <div
            key={item.id}
            className={`border rounded-2xl transition-all duration-200 overflow-hidden ${
              isOpen
                ? 'bg-[#121520] border-[#A020F0]/40 shadow-lg shadow-[#A020F0]/5'
                : 'bg-[#0D0F16] border-white/5 hover:border-white/15'
            }`}
          >
            <button
              type="button"
              onClick={() => toggle(item.id)}
              aria-expanded={isOpen}
              aria-controls={`faq-answer-${item.id}`}
              className="w-full py-4 sm:py-5 px-5 sm:px-6 flex items-center justify-between text-left gap-4"
            >
              <span className="text-sm sm:text-base font-semibold text-[#F7F7FC] font-subheading">
                {item.question}
              </span>
              <div
                className={`w-7 h-7 rounded-lg bg-white/5 flex items-center justify-center shrink-0 text-[#A7ADBD] transition-transform duration-200 ${
                  isOpen ? 'rotate-180 text-[#C7A1FF] bg-[#A020F0]/20' : ''
                }`}
              >
                <ChevronDown size={16} />
              </div>
            </button>

            {isOpen && (
              <div
                id={`faq-answer-${item.id}`}
                className="px-5 sm:px-6 pb-5 pt-1 text-sm text-[#A7ADBD] leading-relaxed border-t border-white/5 animate-in fade-in duration-200"
              >
                {item.answer}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
};

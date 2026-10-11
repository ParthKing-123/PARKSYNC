import React, { useEffect, useRef, useState } from 'react';

export const CarCursorFollower: React.FC = () => {
  const [mounted] = useState(() => {
    if (typeof window === 'undefined') return false;
    return !window.matchMedia('(pointer: coarse)').matches;
  });

  const posRef = useRef({ x: -100, y: -100, targetX: -100, targetY: -100, angle: 0 });
  const carElRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!mounted) return;

    const handleMouseMove = (e: MouseEvent) => {
      posRef.current.targetX = e.clientX;
      posRef.current.targetY = e.clientY;
    };

    window.addEventListener('mousemove', handleMouseMove, { passive: true });

    let animId: number;
    let prevX = -100;
    let prevY = -100;

    const animate = () => {
      const current = posRef.current;
      // Smooth position interpolation
      current.x += (current.targetX - current.x) * 0.18;
      current.y += (current.targetY - current.y) * 0.18;

      const dx = current.x - prevX;
      const dy = current.y - prevY;
      const dist = Math.hypot(dx, dy);

      if (dist > 1.0) {
        // Calculate heading angle in radians (top of car points UP)
        const targetAngle = Math.atan2(dy, dx) + Math.PI / 2;
        let diff = targetAngle - current.angle;
        while (diff < -Math.PI) diff += Math.PI * 2;
        while (diff > Math.PI) diff -= Math.PI * 2;
        current.angle += diff * 0.25;

        prevX = current.x;
        prevY = current.y;
      }

      if (carElRef.current) {
        carElRef.current.style.transform = `translate3d(${current.x}px, ${current.y}px, 0) translate(-50%, -50%) rotate(${current.angle}rad)`;
      }

      animId = requestAnimationFrame(animate);
    };

    animId = requestAnimationFrame(animate);

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      cancelAnimationFrame(animId);
    };
  }, [mounted]);

  if (!mounted) return null;

  return (
    <div
      ref={carElRef}
      className="fixed top-0 left-0 pointer-events-none z-[9999] will-change-transform select-none"
      style={{
        transform: 'translate3d(-100px, -100px, 0)',
      }}
    >
      {/* Sleek, Realistic Top-Down Modern Sports Car Silhouette (NO light beams) */}
      <div className="relative w-5 h-11 flex items-center justify-center filter drop-shadow-[0_4px_10px_rgba(160,32,240,0.5)]">
        {/* Wheels (4 Black Tires at corners) */}
        <div className="absolute -left-1 top-2 w-1.5 h-2.5 rounded-sm bg-[#0e0f14]" />
        <div className="absolute -right-1 top-2 w-1.5 h-2.5 rounded-sm bg-[#0e0f14]" />
        <div className="absolute -left-1 bottom-2 w-1.5 h-2.5 rounded-sm bg-[#0e0f14]" />
        <div className="absolute -right-1 bottom-2 w-1.5 h-2.5 rounded-sm bg-[#0e0f14]" />

        {/* Main Aerodynamic Car Body */}
        <div className="w-full h-full rounded-[6px] rounded-t-[10px] bg-gradient-to-b from-[#221236] via-[#140b20] to-[#0d0714] border border-[#A020F0]/60 relative flex flex-col items-center justify-between p-0.5 overflow-hidden shadow-[inset_0_1px_2px_rgba(255,255,255,0.3)]">
          {/* Front Hood Contours */}
          <div className="w-3 h-2 rounded-t-md bg-[#2d1847]/80 mt-0.5" />

          {/* Front Curved Windshield */}
          <div className="w-3.5 h-2.5 rounded-[2px] bg-[#07090f] border border-white/20 relative overflow-hidden">
            <div className="absolute top-0 right-0 w-1.5 h-full bg-white/20 skew-x-12" />
          </div>

          {/* Roof & Sunroof */}
          <div className="w-3.5 h-2 rounded-[2px] bg-[#160c24] border-x border-white/10" />

          {/* Rear Window */}
          <div className="w-3 h-1.5 rounded-[1px] bg-[#07090f] border border-white/15" />

          {/* Rear Slim LED Tail Light Bar */}
          <div className="w-3.5 h-0.5 rounded-full bg-red-500 shadow-[0_0_4px_#ef4444] mb-0.5" />

          {/* Subtle Front Headlight Bulbs (Integrated inside bumper, NO beams) */}
          <div className="absolute top-0.5 left-0.5 w-1 h-0.5 rounded-full bg-white/90" />
          <div className="absolute top-0.5 right-0.5 w-1 h-0.5 rounded-full bg-white/90" />
        </div>
      </div>
    </div>
  );
};

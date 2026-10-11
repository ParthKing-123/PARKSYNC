import React, { useEffect, useRef } from 'react';

export const InteractiveBackground: React.FC = () => {
  const glowRef = useRef<HTMLDivElement>(null);
  const targetPos = useRef({ x: window.innerWidth / 2, y: window.innerHeight / 2 });
  const currentPos = useRef({ x: window.innerWidth / 2, y: window.innerHeight / 2 });

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      targetPos.current.x = e.clientX;
      targetPos.current.y = e.clientY;
    };

    window.addEventListener('mousemove', handleMouseMove, { passive: true });

    let animId: number;
    const animate = () => {
      currentPos.current.x += (targetPos.current.x - currentPos.current.x) * 0.08;
      currentPos.current.y += (targetPos.current.y - currentPos.current.y) * 0.08;

      if (glowRef.current) {
        glowRef.current.style.transform = `translate3d(${currentPos.current.x}px, ${currentPos.current.y}px, 0) translate(-50%, -50%)`;
      }
      animId = requestAnimationFrame(animate);
    };

    animId = requestAnimationFrame(animate);

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      cancelAnimationFrame(animId);
    };
  }, []);

  return (
    <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
      {/* 360° Cursor-Follower Dynamic Ambient Light Sphere */}
      <div
        ref={glowRef}
        className="absolute top-0 left-0 w-[600px] h-[600px] rounded-full will-change-transform"
        style={{
          background: 'radial-gradient(circle, rgba(160, 32, 240, 0.22) 0%, rgba(14, 165, 233, 0.14) 40%, rgba(192, 132, 252, 0.08) 60%, transparent 75%)',
          filter: 'blur(60px)',
          transform: 'translate3d(50vw, 50vh, 0) translate(-50%, -50%)',
        }}
      />

      {/* Floating Animated Liquid Gradient Blobs (Continuous everywhere) */}
      <div className="liquid-blob-1 absolute top-[5%] left-[-10%] w-[680px] h-[680px] rounded-full bg-[#A020F0]/22 blur-[140px]" />
      <div className="liquid-blob-2 absolute top-[35%] right-[-10%] w-[750px] h-[750px] rounded-full bg-[#0ea5e9]/18 blur-[150px]" />
      <div className="liquid-blob-1 absolute top-[65%] left-[10%] w-[800px] h-[800px] rounded-full bg-[#c084fc]/18 blur-[160px]" />
      <div className="liquid-blob-2 absolute bottom-[5%] right-[5%] w-[720px] h-[720px] rounded-full bg-[#9333ea]/20 blur-[150px]" />

      {/* Subtle Engineering Grid Overlay */}
      <div className="absolute inset-0 dynamic-mesh-grid opacity-30" />
    </div>
  );
};

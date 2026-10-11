import React, { useEffect, useRef, useState } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

interface ThreeHeroSceneProps {
  className?: string;
}

export const ThreeHeroScene: React.FC<ThreeHeroSceneProps> = ({ 
  className = '',
}) => {
  const mountRef = useRef<HTMLDivElement>(null);
  const [webGLSupported] = useState(() => {
    if (typeof window === 'undefined') return true;
    try {
      const canvas = document.createElement('canvas');
      return !!(canvas.getContext('webgl') || canvas.getContext('experimental-webgl'));
    } catch {
      return false;
    }
  });

  useEffect(() => {
    const container = mountRef.current;
    if (!container || !webGLSupported) return;

    const width = container.clientWidth || 640;
    const height = container.clientHeight || 420;

    // 1. SCENE & CAMERA (BRIGHT LANDSCAPE ISOMETRIC OVERVIEW)
    const scene = new THREE.Scene();

    const camera = new THREE.PerspectiveCamera(36, width / height, 0.1, 100);
    // Elevated landscape camera angle with full view of all parking bays
    camera.position.set(0, 8.5, 9.8);
    camera.lookAt(0, 0.2, 0);

    // 2. RENDERER (HIGH BRIGHTNESS, ACCURATE TONE MAPPING)
    const renderer = new THREE.WebGLRenderer({
      alpha: true,
      antialias: true,
      powerPreference: 'high-performance',
    });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2.0));
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.75; // Bright, crystal clear lighting
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    container.appendChild(renderer.domElement);

    // 3. 360° ORBIT CONTROLS
    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.maxPolarAngle = Math.PI / 2 - 0.05; // Keep camera above floor
    controls.minDistance = 4.0;
    controls.maxDistance = 16.0;
    controls.target.set(0, 0.3, 0);
    controls.autoRotate = true;
    controls.autoRotateSpeed = 0.9;

    const worldGroup = new THREE.Group();
    scene.add(worldGroup);

    // =========================================================================
    // 4. BRIGHT MATERIALS & FINISHES
    // =========================================================================
    // Clean illuminated asphalt floor
    const floorMat = new THREE.MeshStandardMaterial({
      color: 0x222634,
      roughness: 0.4,
      metalness: 0.15,
    });

    // Vivid yellow bay divider lines
    const yellowLineMat = new THREE.MeshBasicMaterial({ color: 0xFFDD00 });
    // Crisp white road lines
    const whiteLineMat = new THREE.MeshBasicMaterial({ color: 0xFFFFFF });

    // Glass material
    const glassMat = new THREE.MeshPhysicalMaterial({
      color: 0x111625,
      metalness: 0.9,
      roughness: 0.05,
      transmission: 0.3,
      transparent: true,
      opacity: 0.85,
    });

    // Tires
    const tireMat = new THREE.MeshStandardMaterial({
      color: 0x18191E,
      roughness: 0.8,
      metalness: 0.1,
    });

    // Silver Alloy Rims
    const rimMat = new THREE.MeshStandardMaterial({
      color: 0xE2E6F0,
      metalness: 0.95,
      roughness: 0.15,
    });

    // Headlight glass
    const headlightMat = new THREE.MeshBasicMaterial({ color: 0xFFFFFF });
    // Taillight glass
    const tailMat = new THREE.MeshBasicMaterial({ color: 0xFF2233 });

    // =========================================================================
    // 5. PARKING LOT FLOOR & BAY MARKINGS (CLEAR LANDSCAPE LAYOUT)
    // =========================================================================
    // Main Parking Ground Platform
    const floorGeo = new THREE.PlaneGeometry(16, 11);
    const floorMesh = new THREE.Mesh(floorGeo, floorMat);
    floorMesh.rotation.x = -Math.PI / 2;
    floorMesh.receiveShadow = true;
    worldGroup.add(floorMesh);

    // Driving lane divider (Dashed white line)
    const laneGeo = new THREE.PlaneGeometry(14, 0.08);
    const laneMesh = new THREE.Mesh(laneGeo, whiteLineMat);
    laneMesh.rotation.x = -Math.PI / 2;
    laneMesh.position.set(0, 0.005, 3.2);
    worldGroup.add(laneMesh);

    // Driving entry arrows
    const arrowShape = new THREE.Shape();
    arrowShape.moveTo(0, 0.45);
    arrowShape.lineTo(0.25, 0);
    arrowShape.lineTo(0.1, 0);
    arrowShape.lineTo(0.1, -0.5);
    arrowShape.lineTo(-0.1, -0.5);
    arrowShape.lineTo(-0.1, 0);
    arrowShape.lineTo(-0.25, 0);
    arrowShape.closePath();
    const arrowGeo = new THREE.ShapeGeometry(arrowShape);
    const arrowMesh = new THREE.Mesh(arrowGeo, whiteLineMat);
    arrowMesh.rotation.x = -Math.PI / 2;
    arrowMesh.rotation.z = Math.PI / 2;
    arrowMesh.position.set(-1.0, 0.006, 3.2);
    worldGroup.add(arrowMesh);

    // 4 PARKING BAYS: A1, A2, A3 (Cars parked), A4 (AVAILABLE)
    const bayWidth = 2.3;
    const bayLength = 4.6;
    const bayXPositions = [-3.45, -1.15, 1.15, 3.45];

    bayXPositions.forEach((x, index) => {
      // Yellow Divider Lines
      const lineGeo = new THREE.PlaneGeometry(0.08, bayLength);
      const leftLine = new THREE.Mesh(lineGeo, yellowLineMat);
      leftLine.rotation.x = -Math.PI / 2;
      leftLine.position.set(x - bayWidth / 2, 0.004, 0);
      worldGroup.add(leftLine);

      const rightLine = new THREE.Mesh(lineGeo, yellowLineMat);
      rightLine.rotation.x = -Math.PI / 2;
      rightLine.position.set(x + bayWidth / 2, 0.004, 0);
      worldGroup.add(rightLine);

      // Back boundary line
      const stopLineGeo = new THREE.PlaneGeometry(bayWidth, 0.08);
      const stopLine = new THREE.Mesh(stopLineGeo, yellowLineMat);
      stopLine.rotation.x = -Math.PI / 2;
      stopLine.position.set(x, 0.004, -bayLength / 2);
      worldGroup.add(stopLine);

      // Rubber Parking Curb Stopper
      const curbGeo = new THREE.BoxGeometry(1.6, 0.09, 0.18);
      const curbMat = new THREE.MeshStandardMaterial({ color: 0x1c1e26, roughness: 0.9 });
      const curb = new THREE.Mesh(curbGeo, curbMat);
      curb.position.set(x, 0.045, -bayLength / 2 + 0.35);
      worldGroup.add(curb);

      // Overhead Bay Sensor LED Indicator
      const isAvailable = index === 3;
      const sensorLedGeo = new THREE.SphereGeometry(0.1, 16, 16);
      const sensorMat = new THREE.MeshBasicMaterial({
        color: isAvailable ? 0x00FF66 : 0xFF2244,
      });
      const sensorLed = new THREE.Mesh(sensorLedGeo, sensorMat);
      sensorLed.position.set(x, 2.8, -0.2);
      worldGroup.add(sensorLed);

      // Light beam from sensor
      const sensorLight = new THREE.PointLight(
        isAvailable ? 0x00FF66 : 0xFF2244,
        1.2,
        3.5
      );
      sensorLight.position.set(x, 2.7, -0.2);
      worldGroup.add(sensorLight);
    });

    // Bay A4 (AVAILABLE) Glowing Green Holographic Guidelines
    const a4OutlineGeo = new THREE.BufferGeometry().setFromPoints([
      new THREE.Vector3(3.45 - bayWidth / 2 + 0.06, 0.012, -bayLength / 2 + 0.06),
      new THREE.Vector3(3.45 + bayWidth / 2 - 0.06, 0.012, -bayLength / 2 + 0.06),
      new THREE.Vector3(3.45 + bayWidth / 2 - 0.06, 0.012, bayLength / 2 - 0.06),
      new THREE.Vector3(3.45 - bayWidth / 2 + 0.06, 0.012, bayLength / 2 - 0.06),
      new THREE.Vector3(3.45 - bayWidth / 2 + 0.06, 0.012, -bayLength / 2 + 0.06),
    ]);
    const a4LineMat = new THREE.LineBasicMaterial({
      color: 0x00FF66,
      transparent: true,
      opacity: 0.9,
    });
    const a4Outline = new THREE.Line(a4OutlineGeo, a4LineMat);
    worldGroup.add(a4Outline);

    // =========================================================================
    // 6. CLEAR, IDENTIFIABLE PARKED CARS
    // =========================================================================
    const addWheels = (carGroup: THREE.Group, widthOffset: number, frontZ: number, rearZ: number, radius = 0.27) => {
      const wheelGeo = new THREE.CylinderGeometry(radius, radius, 0.16, 18);
      wheelGeo.rotateZ(Math.PI / 2);

      const positions = [
        [-widthOffset, radius, frontZ],
        [widthOffset, radius, frontZ],
        [-widthOffset, radius, rearZ],
        [widthOffset, radius, rearZ],
      ];

      positions.forEach(([wx, wy, wz]) => {
        const wheel = new THREE.Mesh(wheelGeo, tireMat);
        wheel.position.set(wx, wy, wz);
        wheel.castShadow = true;
        carGroup.add(wheel);

        const rim = new THREE.Mesh(
          new THREE.CylinderGeometry(radius * 0.65, radius * 0.65, 0.17, 14).rotateZ(Math.PI / 2),
          rimMat
        );
        rim.position.set(wx, wy, wz);
        carGroup.add(rim);
      });
    };

    // -------------------------------------------------------------------------
    // CAR 1 (BAY A1): BRIGHT ALPINE WHITE EXECUTIVE SEDAN
    // -------------------------------------------------------------------------
    const sedanGroup = new THREE.Group();
    sedanGroup.position.set(-3.45, 0, -0.1);

    const whitePaint = new THREE.MeshPhysicalMaterial({
      color: 0xFAFAFC,
      metalness: 0.35,
      roughness: 0.1,
      clearcoat: 1.0,
    });

    // Lower body
    const sedanLower = new THREE.Mesh(new THREE.BoxGeometry(1.65, 0.48, 4.2), whitePaint);
    sedanLower.position.set(0, 0.4, 0);
    sedanLower.castShadow = true;
    sedanGroup.add(sedanLower);

    // Cabin
    const sedanCabin = new THREE.Mesh(new THREE.BoxGeometry(1.42, 0.44, 2.2), whitePaint);
    sedanCabin.position.set(0, 0.82, -0.15);
    sedanCabin.castShadow = true;
    sedanGroup.add(sedanCabin);

    // Glass
    const sedanGlass = new THREE.Mesh(new THREE.BoxGeometry(1.43, 0.4, 2.12), glassMat);
    sedanGlass.position.set(0, 0.82, -0.15);
    sedanGroup.add(sedanGlass);

    // Front headlights
    const hl1 = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.07, 0.05), headlightMat);
    hl1.position.set(-0.6, 0.45, 2.1);
    const hl2 = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.07, 0.05), headlightMat);
    hl2.position.set(0.6, 0.45, 2.1);
    sedanGroup.add(hl1, hl2);

    // Rear taillight
    const tail1 = new THREE.Mesh(new THREE.BoxGeometry(1.45, 0.07, 0.05), tailMat);
    tail1.position.set(0, 0.48, -2.1);
    sedanGroup.add(tail1);

    addWheels(sedanGroup, 0.83, 1.35, -1.35, 0.27);
    worldGroup.add(sedanGroup);

    // -------------------------------------------------------------------------
    // CAR 2 (BAY A2): VIBRANT SAPPHIRE BLUE SUV
    // -------------------------------------------------------------------------
    const suvGroup = new THREE.Group();
    suvGroup.position.set(-1.15, 0, -0.1);

    const bluePaint = new THREE.MeshPhysicalMaterial({
      color: 0x1E56C8,
      metalness: 0.4,
      roughness: 0.15,
      clearcoat: 1.0,
    });

    const suvLower = new THREE.Mesh(new THREE.BoxGeometry(1.78, 0.65, 4.1), bluePaint);
    suvLower.position.set(0, 0.52, 0);
    suvLower.castShadow = true;
    suvGroup.add(suvLower);

    const suvCabin = new THREE.Mesh(new THREE.BoxGeometry(1.58, 0.58, 2.5), bluePaint);
    suvCabin.position.set(0, 1.08, -0.1);
    suvCabin.castShadow = true;
    suvGroup.add(suvCabin);

    const suvGlass = new THREE.Mesh(new THREE.BoxGeometry(1.59, 0.52, 2.42), glassMat);
    suvGlass.position.set(0, 1.08, -0.1);
    suvGroup.add(suvGlass);

    // Roof rails
    const railMat = new THREE.MeshStandardMaterial({ color: 0x0f1118, metalness: 0.8 });
    const r1 = new THREE.Mesh(new THREE.BoxGeometry(0.05, 0.04, 2.2), railMat);
    r1.position.set(-0.68, 1.4, -0.1);
    const r2 = new THREE.Mesh(new THREE.BoxGeometry(0.05, 0.04, 2.2), railMat);
    r2.position.set(0.68, 1.4, -0.1);
    suvGroup.add(r1, r2);

    // SUV Headlights & Tail
    const suvHl1 = new THREE.Mesh(new THREE.BoxGeometry(0.35, 0.08, 0.05), headlightMat);
    suvHl1.position.set(-0.65, 0.55, 2.05);
    const suvHl2 = new THREE.Mesh(new THREE.BoxGeometry(0.35, 0.08, 0.05), headlightMat);
    suvHl2.position.set(0.65, 0.55, 2.05);
    const suvTail = new THREE.Mesh(new THREE.BoxGeometry(1.55, 0.08, 0.05), tailMat);
    suvTail.position.set(0, 0.62, -2.05);
    suvGroup.add(suvHl1, suvHl2, suvTail);

    addWheels(suvGroup, 0.9, 1.3, -1.3, 0.32);
    worldGroup.add(suvGroup);

    // -------------------------------------------------------------------------
    // CAR 3 (BAY A3): ROSSO CORSA RED SPORTS CAR
    // -------------------------------------------------------------------------
    const sportsGroup = new THREE.Group();
    sportsGroup.position.set(1.15, 0, -0.1);

    const redPaint = new THREE.MeshPhysicalMaterial({
      color: 0xE60012, // Bright racing red
      metalness: 0.3,
      roughness: 0.08,
      clearcoat: 1.0,
    });

    const sportsLower = new THREE.Mesh(new THREE.BoxGeometry(1.82, 0.35, 4.3), redPaint);
    sportsLower.position.set(0, 0.3, 0);
    sportsLower.castShadow = true;
    sportsGroup.add(sportsLower);

    const sportsCabin = new THREE.Mesh(new THREE.BoxGeometry(1.35, 0.38, 1.8), redPaint);
    sportsCabin.position.set(0, 0.62, -0.1);
    sportsCabin.castShadow = true;
    sportsGroup.add(sportsCabin);

    const sportsGlass = new THREE.Mesh(new THREE.BoxGeometry(1.36, 0.34, 1.72), glassMat);
    sportsGlass.position.set(0, 0.62, -0.1);
    sportsGroup.add(sportsGlass);

    // Rear Spoiler
    const spoiler = new THREE.Mesh(
      new THREE.BoxGeometry(1.7, 0.04, 0.3),
      new THREE.MeshStandardMaterial({ color: 0x111318 })
    );
    spoiler.position.set(0, 0.62, -2.0);
    sportsGroup.add(spoiler);

    // Headlights & Tail
    const spHl1 = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.05, 0.05), headlightMat);
    spHl1.position.set(-0.65, 0.34, 2.15);
    const spHl2 = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.05, 0.05), headlightMat);
    spHl2.position.set(0.65, 0.34, 2.15);
    const spTail = new THREE.Mesh(new THREE.BoxGeometry(1.6, 0.06, 0.05), tailMat);
    spTail.position.set(0, 0.38, -2.15);
    sportsGroup.add(spHl1, spHl2, spTail);

    addWheels(sportsGroup, 0.91, 1.35, -1.35, 0.27);
    worldGroup.add(sportsGroup);

    // =========================================================================
    // 7. BRIGHT STUDIO LIGHTING (CLEAN & IDENTIFIABLE)
    // =========================================================================
    const ambientLight = new THREE.AmbientLight(0xffffff, 1.9);
    scene.add(ambientLight);

    const mainSun = new THREE.DirectionalLight(0xffffff, 2.8);
    mainSun.position.set(5, 12, 8);
    mainSun.castShadow = true;
    mainSun.shadow.mapSize.width = 2048;
    mainSun.shadow.mapSize.height = 2048;
    mainSun.shadow.camera.near = 0.5;
    mainSun.shadow.camera.far = 30;
    scene.add(mainSun);

    const fillLight = new THREE.DirectionalLight(0xa5c4ff, 1.4);
    fillLight.position.set(-6, 8, -6);
    scene.add(fillLight);

    const violetGlow = new THREE.DirectionalLight(0xA020F0, 1.2);
    violetGlow.position.set(0, 4, 6);
    scene.add(violetGlow);

    // =========================================================================
    // 8. ANIMATION LOOP & RESIZE
    // =========================================================================
    let animId: number;
    const clock = new THREE.Clock();

    const animate = () => {
      animId = requestAnimationFrame(animate);
      const elapsed = clock.getElapsedTime();
      controls.update();

      // Pulsing green outline on open parking bay A4
      a4LineMat.opacity = 0.55 + Math.sin(elapsed * 3.2) * 0.4;

      renderer.render(scene, camera);
    };

    animate();

    const handleResize = () => {
      if (!container) return;
      const w = container.clientWidth;
      const h = container.clientHeight;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
      cancelAnimationFrame(animId);
      if (container && renderer.domElement) {
        container.removeChild(renderer.domElement);
      }
      renderer.dispose();
    };
  }, [webGLSupported]);

  return (
    <div className={`relative w-full flex items-center justify-center select-none ${className}`}>
      {/* Landscape 3D Parking Garage Canvas */}
      <div
        ref={mountRef}
        className="w-full h-[340px] sm:h-[400px] lg:h-[450px] cursor-grab active:cursor-grabbing relative rounded-2xl overflow-hidden"
        aria-label="Bright 3D Parking Lot with parked cars and an available slot. Click and drag to orbit 360 degrees."
      />
    </div>
  );
};

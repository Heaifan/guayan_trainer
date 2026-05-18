/// 水克火：水幕压火 HTML 动画
const String waterFireControlHtml = r'''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body { margin:0; padding:0; width:100%; height:100%; background-color:transparent; overflow:hidden; display:flex; justify-content:center; align-items:center; }
  svg { width:100%; height:100%; max-width:300px; max-height:300px; display:block; }
  @keyframes globalFade { 0%,5%{opacity:0.92} 10%,92%{opacity:1} 98%,100%{opacity:0.92} }
  @keyframes waterCurtainDrop { 0%,15%{transform:translateY(-80px) scaleY(1);opacity:0;animation-timing-function:ease-in} 25%{transform:translateY(68px) scaleY(1.1);opacity:1;animation-timing-function:ease-out} 28%{transform:translateY(68px) scaleY(0.95);opacity:1} 32%,85%{transform:translateY(68px) scaleY(1);opacity:0.95} 95%,100%{transform:translateY(68px) scaleY(1);opacity:0} }
  @keyframes waveFlowFront { 0%{transform:translateX(0)} 100%{transform:translateX(-40px)} }
  @keyframes waveFlowBack { 0%{transform:translateX(0)} 100%{transform:translateX(40px)} }
  @keyframes cascadeFlow { 0%{stroke-dashoffset:0} 100%{stroke-dashoffset:-30} }
  @keyframes poolSpread { 0%,24%{transform:scaleX(0) scaleY(0.5);opacity:0} 27%{transform:scaleX(0.8) scaleY(1);opacity:1} 45%{transform:scaleX(1.1) scaleY(1);opacity:0.9} 85%,100%{transform:scaleX(1.2) scaleY(0.8);opacity:0.7} }
  @keyframes foamBoil { 0%,24%{transform:scale(0.5);opacity:0} 26%{transform:scale(1.1);opacity:0.9} 35%{transform:scale(1);opacity:0.7} 50%{transform:scale(1.2);opacity:0.5} 75%,100%{transform:scale(1.3);opacity:0} }
  @keyframes fireInnerDie { 0%,22%{transform:scale(1);opacity:1} 24%,100%{transform:scale(0);opacity:0} }
  @keyframes fireMiddleShrink { 0%,22%{transform:scale(1);opacity:1} 25%{transform:scaleY(0.4) scaleX(0.8) translateY(10px);opacity:0.8} 35%,100%{transform:scaleY(0) scaleX(0) translateY(20px);opacity:0} }
  @keyframes fireOuterFlatten { 0%,23%{transform:scaleY(1) scaleX(1);opacity:1} 25%{transform:scaleY(0.4) scaleX(1.4) translateY(18px);opacity:0.9} 35%{transform:scaleY(0.15) scaleX(1.8) translateY(26px);opacity:0.6} 85%,100%{transform:scaleY(0.05) scaleX(1.9) translateY(28px);opacity:0.3} }
  @keyframes fireFlicker { 0%,100%{transform:skewX(0)} 33%{transform:skewX(-2deg)} 66%{transform:skewX(2deg)} }
  @keyframes steamContact { 0%,23%{opacity:0;transform:translateY(15px) scale(0.5)} 26%{opacity:1;transform:translateY(5px) scale(1.8)} 45%{opacity:0.8;transform:translateY(-10px) scale(2)} 75%,100%{opacity:0;transform:translateY(-30px) scale(2.8)} }
  @keyframes splashGround { 0%,24%{opacity:0;transform:translate(0,0) scale(0.5)} 26%{opacity:1;transform:translate(0,0) scale(1.2)} 40%{opacity:0;transform:translate(var(--dx),var(--dy)) scale(0.8)} 100%{opacity:0} }
  .fade-group { animation:globalFade 5s linear infinite; }
  .fire-layer { transform-origin:50px 85px; }
  .fire-flicker { animation:fireFlicker 1.2s ease-in-out infinite; }
  .fire-ember { fill:#8A3A2A; opacity:0.8; }
  .fire-outer { fill:#D9381E; animation:fireOuterFlatten 5s ease-in-out infinite; }
  .fire-middle { fill:#F27D0C; animation:fireMiddleShrink 5s ease-in-out infinite; }
  .fire-inner { fill:#FAD201; animation:fireInnerDie 5s ease-in-out infinite; }
  .water-curtain-group { animation:waterCurtainDrop 5s linear infinite; }
  .wave-back { fill:#1F5F8B; opacity:0.85; animation:waveFlowBack 1.8s linear infinite; }
  .wave-front { fill:url(#waterGrad); opacity:0.95; animation:waveFlowFront 1.2s linear infinite; }
  .cascade-line { stroke:rgba(255,255,255,0.4); stroke-width:1.5; stroke-linecap:round; stroke-dasharray:12 12; fill:none; }
  .cascade-1 { animation:cascadeFlow 0.5s linear infinite; }
  .cascade-2 { animation:cascadeFlow 0.35s linear infinite; }
  .cascade-3 { animation:cascadeFlow 0.45s linear infinite; }
  .water-pool { fill:#3E7DBF; transform-origin:50px 85px; animation:poolSpread 5s ease-out infinite; }
  .water-foam { fill:#DDECF5; transform-origin:50px 85px; animation:foamBoil 5s ease-out infinite; }
  .steam { fill:#F4F8FA; transform-origin:50px 50px; animation:steamContact 5s ease-out infinite; }
  .splash { fill:#B8D7EA; opacity:0; animation:splashGround 5s ease-out infinite; }
</style>
</head>
<body>
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="blurSteam"><feGaussianBlur stdDeviation="2.5"/></filter>
    <filter id="blurFoam"><feGaussianBlur stdDeviation="1"/></filter>
    <linearGradient id="waterGrad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#3E7DBF" stop-opacity="0.2"/>
      <stop offset="40%" stop-color="#3E7DBF" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="#1F5F8B" stop-opacity="1"/>
    </linearGradient>
  </defs>
  <g class="fade-group">
    <ellipse class="water-pool" cx="50" cy="86" rx="25" ry="6"/>
    <ellipse class="fire-ember" cx="50" cy="85" rx="16" ry="3"/>
    <g class="fire-flicker">
      <path class="fire-layer fire-outer" d="M 50 25 Q 36 45 32 65 C 30 80 40 85 50 85 C 60 85 70 80 68 65 Q 64 45 50 25 Z"/>
      <path class="fire-layer fire-middle" d="M 50 40 Q 40 55 38 68 C 37 78 43 82 50 82 C 57 82 63 78 62 68 Q 60 55 50 40 Z"/>
      <path class="fire-layer fire-inner" d="M 50 55 Q 44 65 44 73 C 43 78 47 80 50 80 C 53 80 57 78 56 73 Q 56 65 50 55 Z"/>
    </g>
    <g filter="url(#blurFoam)">
      <ellipse class="water-foam" cx="50" cy="84" rx="18" ry="4"/>
      <path class="water-foam" d="M 35 84 Q 50 78 65 84 Q 50 90 35 84 Z" style="animation-delay:0.1s"/>
    </g>
    <g filter="url(#blurSteam)">
      <ellipse class="steam" cx="50" cy="45" rx="16" ry="6"/>
      <ellipse class="steam" cx="35" cy="48" rx="12" ry="5" style="animation-delay:0.04s"/>
      <ellipse class="steam" cx="65" cy="47" rx="12" ry="5" style="animation-delay:0.06s"/>
    </g>
    <g class="water-curtain-group">
      <g class="wave-back"><path d="M -100 -50 L 200 -50 L 200 20 q -10 6 -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 Z"/></g>
      <g class="wave-front" transform="translate(15,0) scale(0.7,1)"><path d="M -100 -50 L 200 -50 L 200 20 q -10 -6 -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 t -20 0 Z"/></g>
      <path class="cascade-line cascade-1" d="M 38 -40 L 38 15"/>
      <path class="cascade-line cascade-2" d="M 50 -30 L 50 18"/>
      <path class="cascade-line cascade-3" d="M 62 -35 L 62 16"/>
    </g>
    <g>
      <circle class="splash" cx="35" cy="80" r="1.5" style="--dx:-15px;--dy:-10px"/>
      <circle class="splash" cx="65" cy="82" r="1.2" style="--dx:15px;--dy:-12px;animation-delay:0.03s"/>
      <circle class="splash" cx="42" cy="78" r="1.5" style="--dx:-10px;--dy:-18px;animation-delay:0.05s"/>
      <circle class="splash" cx="58" cy="79" r="1.8" style="--dx:12px;--dy:-15px;animation-delay:0.04s"/>
    </g>
  </g>
</svg>
</body>
</html>
''';

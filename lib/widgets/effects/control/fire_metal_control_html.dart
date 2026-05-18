/// 火克金：烈火熔金 HTML 动画
const String fireMetalControlHtml = r'''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body { margin:0; padding:0; width:100%; height:100%; background-color:transparent; overflow:hidden; display:flex; justify-content:center; align-items:center; }
  svg { width:100%; height:100%; max-width:300px; max-height:300px; display:block; }
  @keyframes globalFade { 0%,5%{opacity:0.92} 10%,92%{opacity:1} 98%,100%{opacity:0.92} }
  @keyframes fireSurge { 0%,15%{transform:scaleY(0.7)scaleX(0.9);opacity:0.8} 25%{transform:scaleY(1.35)scaleX(1.1);opacity:1} 85%{transform:scaleY(1.25)scaleX(1.05);opacity:1} 95%,100%{transform:scaleY(0.7)scaleX(0.9);opacity:0.8} }
  @keyframes fireFlicker { 0%,100%{transform:skewX(0)} 33%{transform:skewX(-3deg)} 66%{transform:skewX(3deg)} }
  @keyframes metalHeatOverlay { 0%,20%{opacity:0} 35%{opacity:0.85} 85%{opacity:0.85} 95%,100%{opacity:0} }
  @keyframes metalSquish { 0%,30%{transform:scaleY(1)} 45%,85%{transform:scaleY(0.96)} 95%,100%{transform:scaleY(1)} }
  @keyframes metalDroop { 0%,35%{transform:scaleY(1);opacity:0} 40%{transform:scaleY(1.5);opacity:1} 55%{transform:scaleY(2.6);opacity:1} 85%{transform:scaleY(2.8);opacity:1} 95%,100%{transform:scaleY(1);opacity:0} }
  @keyframes drip1 { 0%,45%{transform:translateY(0)scale(0);opacity:0} 50%{transform:translateY(2px)scale(1.2);opacity:1} 65%{transform:translateY(18px)scale(0.8);opacity:1} 70%,100%{transform:translateY(22px)scale(0);opacity:0} }
  @keyframes drip2 { 0%,52%{transform:translateY(0)scale(0);opacity:0} 57%{transform:translateY(2px)scale(1.2);opacity:1} 72%{transform:translateY(18px)scale(0.8);opacity:1} 77%,100%{transform:translateY(22px)scale(0);opacity:0} }
  @keyframes drip3 { 0%,60%{transform:translateY(0)scale(0);opacity:0} 65%{transform:translateY(2px)scale(1.2);opacity:1} 80%{transform:translateY(18px)scale(0.8);opacity:1} 85%,100%{transform:translateY(22px)scale(0);opacity:0} }
  @keyframes heatRise { 0%,25%{transform:translateY(0)scale(0.8);opacity:0} 40%{opacity:0.6} 70%{transform:translateY(-20px)scale(1.1);opacity:0} 100%{opacity:0} }
  .fade-group { animation:globalFade 5s linear infinite; }
  .fire-surge { transform-origin:50px 90px; animation:fireSurge 5s ease-in-out infinite; }
  .fire-flicker { transform-origin:50px 90px; animation:fireFlicker 1s ease-in-out infinite; }
  .fire-outer { fill:#D9381E; } .fire-middle { fill:#F27D0C; } .fire-inner { fill:#FAD201; }
  .metal-group { transform-origin:50px 15px; animation:metalSquish 5s ease-in-out infinite; }
  .metal-base { fill:url(#coldMetalGrad); }
  .metal-hot { fill:url(#hotMetalGrad); animation:metalHeatOverlay 5s ease-in-out infinite; }
  .metal-line { stroke:#FFFFFF; stroke-width:0.8; fill:none; opacity:0.5; stroke-linecap:round; }
  .metal-droop { fill:#FAD201; transform-origin:50px 47px; animation:metalDroop 5s ease-in-out infinite; }
  .drip-1 { fill:#FAD201; animation:drip1 5s ease-in infinite; }
  .drip-2 { fill:#F27D0C; animation:drip2 5s ease-in infinite; }
  .drip-3 { fill:#FAD201; animation:drip3 5s ease-in infinite; }
  .heat-wave { stroke:#F7E7A0; stroke-width:1.2; fill:none; opacity:0; stroke-linecap:round; animation:heatRise 5s ease-in-out infinite; }
  .hw-1 { animation-delay:0.1s; } .hw-2 { animation-delay:0.4s; }
</style>
</head>
<body>
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="coldMetalGrad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#F4F1E8"/><stop offset="35%" stop-color="#E2E2E2"/>
      <stop offset="70%" stop-color="#B8A98A"/><stop offset="100%" stop-color="#666666"/>
    </linearGradient>
    <radialGradient id="hotMetalGrad" cx="50%" cy="100%" r="100%">
      <stop offset="0%" stop-color="#FAD201"/><stop offset="25%" stop-color="#F27D0C"/>
      <stop offset="50%" stop-color="#D9381E"/><stop offset="75%" stop-color="#8A3A2A" stop-opacity="0.7"/>
      <stop offset="100%" stop-color="#8A3A2A" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <g class="fade-group">
    <g class="metal-group">
      <path class="metal-base" d="M 35 15 L 65 15 L 80 30 L 65 48 L 35 48 L 20 30 Z"/>
      <path class="metal-line" d="M 35 15 L 50 28 L 65 15"/>
      <path class="metal-line" d="M 20 30 L 50 28 L 80 30"/>
      <path class="metal-line" d="M 50 28 L 50 48"/>
      <path class="metal-hot" d="M 35 15 L 65 15 L 80 30 L 65 48 L 35 48 L 20 30 Z"/>
      <path class="metal-droop" d="M 38 47 Q 50 51 62 47 Q 50 45 38 47 Z"/>
    </g>
    <g transform="translate(50,52)"><path class="drip-1" d="M 0 0 Q 2 4 2 6 A 2 2 0 0 1 -2 6 Q -2 4 0 0 Z"/></g>
    <g transform="translate(43,50)"><path class="drip-2" d="M 0 0 Q 1.5 3 1.5 4.5 A 1.5 1.5 0 0 1 -1.5 4.5 Q -1.5 3 0 0 Z"/></g>
    <g transform="translate(57,51)"><path class="drip-3" d="M 0 0 Q 1.8 3.5 1.8 5 A 1.8 1.8 0 0 1 -1.8 5 Q -1.8 3.5 0 0 Z"/></g>
    <g>
      <path class="heat-wave hw-1" d="M 25 55 Q 20 45 25 35 T 25 20"/>
      <path class="heat-wave hw-2" d="M 75 50 Q 80 40 75 30 T 75 15"/>
    </g>
    <g class="fire-surge">
      <g class="fire-flicker">
        <path class="fire-outer" d="M 50 52 Q 36 67 34 80 C 34 88 42 90 50 90 C 58 90 66 88 66 80 Q 64 67 50 52 Z"/>
        <path class="fire-middle" d="M 50 61 Q 40 72 40 82 C 40 88 45 90 50 90 C 55 90 60 88 60 82 Q 60 72 50 61 Z"/>
        <path class="fire-inner" d="M 50 70 Q 45 79 45 84 C 45 88 48 90 50 90 C 52 90 55 88 55 84 Q 55 79 50 70 Z"/>
      </g>
    </g>
  </g>
</svg>
</body>
</html>
''';

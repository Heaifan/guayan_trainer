/// 金克木：金刃断木 HTML 动画
const String metalWoodControlHtml = r'''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body { margin:0; padding:0; width:100%; height:100%; background-color:transparent; overflow:hidden; display:flex; justify-content:center; align-items:center; }
  svg { width:100%; height:100%; max-width:300px; max-height:300px; display:block; }
  @keyframes globalFade { 0%,5%{opacity:0.92} 10%,92%{opacity:1} 98%,100%{opacity:0.92} }
  @keyframes bladeStrike { 0%,20%{transform:translate(60px,-60px) rotate(0);opacity:0} 25%{transform:translate(40px,-40px) rotate(-5deg);opacity:1} 40%{transform:translate(2px,-2px) rotate(-8deg);opacity:1} 44%{transform:translate(-1px,1px) rotate(-7deg);opacity:1} 84%{transform:translate(-1px,1px) rotate(-7deg);opacity:1} 94%,100%{transform:translate(-10px,10px) rotate(-5deg);opacity:0} }
  @keyframes flashGlow { 0%,38%{opacity:0} 40%{opacity:1} 45%{opacity:0.5} 55%{opacity:0} 100%{opacity:0} }
  @keyframes woodLeftSplit { 0%,39%{transform:translate(0,0) rotate(0)} 40%{transform:translate(-1.5px,0.5px) rotate(-1deg)} 55%,84%{transform:translate(-3px,1px) rotate(-2.5deg)} 94%,100%{transform:translate(0,0) rotate(0)} }
  @keyframes woodRightSplit { 0%,39%{transform:translate(0,0) rotate(0)} 40%{transform:translate(1.5px,1px) rotate(1deg)} 55%,84%{transform:translate(4px,2px) rotate(3deg)} 94%,100%{transform:translate(0,0) rotate(0)} }
  @keyframes crackOpen { 0%,39%{opacity:0;scale:0.5} 40%,84%{opacity:1;scale:1} 94%,100%{opacity:0} }
  @keyframes lineCrack { 0%,39%{stroke-dashoffset:20;opacity:0} 43%,84%{stroke-dashoffset:0;opacity:0.85} 94%,100%{opacity:0} }
  @keyframes chipFly1 { 0%,39%{transform:translate(0,0)scale(1);opacity:0} 40%{opacity:1} 52%{transform:translate(-18px,-15px)rotate(45deg);opacity:1} 65%,100%{transform:translate(-24px,-2px)rotate(90deg)scale(0.6);opacity:0} }
  @keyframes chipFly2 { 0%,39%{transform:translate(0,0)scale(1);opacity:0} 40%{opacity:1} 50%{transform:translate(15px,-18px)rotate(-30deg);opacity:1} 63%,100%{transform:translate(22px,-6px)rotate(-60deg)scale(0.5);opacity:0} }
  @keyframes chipFly3 { 0%,41%{transform:translate(0,0)scale(1);opacity:0} 42%{opacity:1} 54%{transform:translate(-5px,-22px)rotate(20deg);opacity:1} 68%,100%{transform:translate(-8px,-10px)rotate(40deg)scale(0.4);opacity:0} }
  .fade-group { animation:globalFade 5s linear infinite; }
  .wood-part { transform-origin:50px 50px; }
  .wood-left { animation:woodLeftSplit 5s cubic-bezier(0.1,0.8,0.2,1) infinite; }
  .wood-right { animation:woodRightSplit 5s cubic-bezier(0.1,0.8,0.2,1) infinite; }
  .bark { fill:#2F8F5B; } .core { fill:#B8862F; }
  .grain-line { stroke:#4A2C16; stroke-width:1; stroke-linecap:round; fill:none; opacity:0.4; }
  .wedge-cut { fill:#2C1709; transform-origin:50px 50px; animation:crackOpen 5s ease-out infinite; }
  .wood-crack { stroke:#3D2210; stroke-width:1.2; stroke-linecap:round; fill:none; stroke-dasharray:20; stroke-dashoffset:20; animation:lineCrack 5s ease-out infinite; }
  .blade-motion { transform-origin:50px 50px; animation:bladeStrike 5s cubic-bezier(0.15,0.85,0.3,1) infinite; }
  .blade-body { fill:url(#metalGrad); filter:drop-shadow(-1px 1px 2px rgba(0,0,0,0.2)); }
  .blade-edge { stroke:#FFFFFF; stroke-width:1.2; fill:none; opacity:0.8; stroke-linecap:round; }
  .blade-flash { fill:#FFFFFF; opacity:0; animation:flashGlow 5s ease-out infinite; }
  .chip { fill:#8A6A32; opacity:0; }
  .chip-1 { transform-origin:48px 48px; animation:chipFly1 5s cubic-bezier(0.25,0.46,0.45,0.94) infinite; }
  .chip-2 { transform-origin:52px 48px; animation:chipFly2 5s cubic-bezier(0.25,0.46,0.45,0.94) infinite; }
  .chip-3 { transform-origin:49px 52px; animation:chipFly3 5s cubic-bezier(0.25,0.46,0.45,0.94) infinite; }
</style>
</head>
<body>
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="metalGrad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#666666"/><stop offset="30%" stop-color="#B8A98A"/>
      <stop offset="65%" stop-color="#E2E2E2"/><stop offset="100%" stop-color="#F4F1E8"/>
    </linearGradient>
  </defs>
  <g class="fade-group">
    <g class="wood-part wood-left">
      <path class="bark" d="M 12 44 L 49 44 L 49 56 L 12 56 Q 8 50 12 44 Z"/>
      <path class="core" d="M 45 44 L 49 44 L 49 56 L 45 56 Z"/>
      <path class="grain-line" d="M 16 48 L 38 48"/><path class="grain-line" d="M 22 52 L 44 52"/>
      <path class="wood-crack" d="M 45 46 Q 32 45 20 48"/>
      <path class="wood-crack" d="M 46 53 Q 35 54 25 51" style="animation-delay:0.05s"/>
    </g>
    <g class="wood-part wood-right">
      <path class="bark" d="M 51 44 L 88 44 Q 92 50 88 56 L 51 56 Z"/>
      <path class="core" d="M 51 44 L 55 44 L 55 56 L 51 56 Z"/>
      <path class="grain-line" d="M 62 48 L 84 48"/><path class="grain-line" d="M 56 52 L 78 52"/>
      <path class="wood-crack" d="M 54 47 Q 66 46 78 49" style="animation-delay:0.08s"/>
    </g>
    <g><path class="wedge-cut" d="M 46 44 L 54 44 L 52 50 L 53 56 L 45 56 L 47 49 Z"/></g>
    <g class="blade-motion">
      <polygon class="blade-body" points="82 8, 48 42, 45 45, 49 49, 89 21"/>
      <line class="blade-edge" x1="48" y1="42" x2="45" y2="45"/>
      <line class="blade-edge" x1="45" y1="45" x2="49" y2="49"/>
      <polygon class="blade-flash" points="82 8, 48 42, 45 45, 49 49, 89 21"/>
    </g>
    <g>
      <polygon class="chip chip-1" points="47 45, 44 42, 48 41"/>
      <polygon class="chip chip-2" points="53 44, 56 41, 52 40"/>
      <path class="chip chip-3" d="M 49 53 Q 47 55 49 57 Q 51 55 49 53 Z"/>
    </g>
  </g>
</svg>
</body>
</html>
''';

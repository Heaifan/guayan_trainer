/// 火生土：灰烬堆积成土 HTML 动画
///
/// Flame burns → gradually declines → ash falls → earth mound accumulates.
/// Pure CSS, 5 s loop.
const String fireEarthHtml = r'''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
  html, body {
    width: 100%; height: 100%;
    margin: 0; padding: 0;
    background: transparent;
    overflow: hidden;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  svg {
    width: 100%; height: 100%;
    max-width: 100%; max-height: 100%;
    overflow: visible;
  }

  @keyframes flameFlicker {
    0%, 100% { transform: rotate(0deg) skewX(1deg); }
    25% { transform: rotate(-1deg) skewX(-1deg); }
    50% { transform: rotate(1.5deg) skewX(2deg); }
    75% { transform: rotate(-0.5deg) skewX(-1.5deg); }
  }
  @keyframes flameDecline {
    0%, 24% { transform: scale(1); opacity: 1; }
    56% { transform: scale(0.55) translateY(15px); opacity: 0.8; }
    84% { transform: scale(0.18) translateY(45px); opacity: 0.4; }
    92% { transform: scale(0.15) translateY(50px); opacity: 0.3; }
    100% { transform: scale(0.15) translateY(50px); opacity: 0; }
  }
  @keyframes ashFallDown {
    0%, 24% { opacity: 0; transform: translate(0, 0) scale(0); }
    35% { opacity: 0.7; }
    75%, 84% { transform: translate(var(--ax), var(--ay)); opacity: 0; }
    100% { opacity: 0; }
  }
  @keyframes moundAccumulate {
    0%, 24% { transform: scaleY(0) scaleX(0.6); opacity: 0; }
    56% { transform: scaleY(0.4) scaleX(0.8); opacity: 0.7; }
    84%, 92% { transform: scaleY(1) scaleX(1); opacity: 1; }
    100% { transform: scaleY(1) scaleX(1); opacity: 0; }
  }

  .flame-shake { transform-origin: 100px 160px; animation: flameFlicker 1s infinite ease-in-out; }
  .flame-main-group { transform-origin: 100px 160px; animation: flameDecline 5s infinite cubic-bezier(0.36, 0.07, 0.19, 0.97); }
  .ash-particle { transform-origin: center; animation: ashFallDown 5s infinite cubic-bezier(0.25, 0.46, 0.45, 0.94); }
  .earth-mound { transform-origin: 100px 165px; animation: moundAccumulate 5s infinite cubic-bezier(0.22, 0.61, 0.36, 1); }
</style>
</head>
<body>
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="earthGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#D8A600" />
      <stop offset="50%" stop-color="#B8862F" />
      <stop offset="100%" stop-color="#8A6A32" />
    </linearGradient>
    <filter id="flameGlow"><feGaussianBlur stdDeviation="1.5" /></filter>
  </defs>

  <g opacity="0.4">
    <ellipse cx="100" cy="162" rx="30" ry="5" fill="#6E675F" />
    <ellipse cx="100" cy="162" rx="15" ry="2.5" fill="#8C847A" />
  </g>

  <g class="flame-main-group" filter="url(#flameGlow)">
    <g class="flame-shake">
      <path d="M 100,55 C 55,105 45,160 100,160 C 155,160 145,105 100,55 Z" fill="#D9381E" />
      <path d="M 100,80 C 68,115 60,160 100,160 C 140,160 132,115 100,80 Z" fill="#F27D0C" />
      <path d="M 100,105 C 80,125 78,160 100,160 C 122,160 120,125 100,105 Z" fill="#FAD201" />
      <path d="M 100,55 C 55,105 45,160 100,160 C 155,160 145,105 100,55" fill="none" stroke="#F4F1E8" stroke-width="0.5" opacity="0.2" />
      <line x1="100" y1="55" x2="100" y2="160" stroke="#FAD201" stroke-width="0.5" opacity="0.3" />
    </g>
  </g>

  <g id="falling-ashes">
    <circle class="ash-particle" cx="90" cy="90" r="1.5" fill="#B8B1A6" style="--ax: -20px; --ay: 65px; animation-delay: 1.2s;" />
    <circle class="ash-particle" cx="115" cy="85" r="1.8" fill="#8C847A" style="--ax: 15px; --ay: 70px; animation-delay: 1.5s;" />
    <circle class="ash-particle" cx="100" cy="75" r="1.2" fill="#6E675F" style="--ax: -2px; --ay: 80px; animation-delay: 1.3s;" />
    <circle class="ash-particle" cx="105" cy="100" r="1.6" fill="#B8B1A6" style="--ax: 25px; --ay: 55px; animation-delay: 1.7s;" />
    <circle class="ash-particle" cx="80" cy="110" r="1.3" fill="#8C847A" style="--ax: -12px; --ay: 45px; animation-delay: 1.4s;" />
  </g>

  <g class="earth-mound">
    <path d="M 45,162 Q 100,132 155,162 Q 140,174 100,174 Q 60,174 45,162 Z" fill="url(#earthGrad)" />
    <path d="M 45,162 Q 100,132 155,162" stroke="#D8A600" stroke-width="1" fill="none" stroke-linecap="round" opacity="0.7" />
  </g>
</svg>
</body>
</html>
''';

/// 木生火：钻木取火 HTML 动画
///
/// Drill rod spins → friction heats contact point → smoke rises →
/// sparks float up → small flame grows softly.
const String woodFireHtml = r'''
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

  /* 1. Drill rod high-speed spin */
  @keyframes fastDrillSpin {
    0%, 100% { transform: scaleX(1); }
    50% { transform: scaleX(-1); }
  }

  /* 2. Slow smoke rise */
  @keyframes slowSmokeRise {
    0%, 20% { opacity: 0; transform: translateY(0) scale(0.5); }
    30% { opacity: 0.6; transform: translateY(-5px) scale(1); }
    80% { opacity: 0.3; transform: translateY(-25px) scale(1.5); }
    95%, 100% { opacity: 0; transform: translateY(-30px) scale(1.8); }
  }

  /* 3. Slow spark drift */
  @keyframes slowSparkDrift {
    0%, 44% { opacity: 0; transform: translate(0, 0) scale(0); }
    48% { opacity: 1; transform: translate(var(--start-x), var(--start-y)) scale(1); }
    85% { opacity: 0.8; transform: translate(var(--end-x), var(--end-y)) scale(0.8); }
    95%, 100% { opacity: 0; transform: translate(var(--end-x), calc(var(--end-y) - 5px)) scale(0); }
  }

  /* 4. Soft flame grow */
  @keyframes softFlameGrow {
    0%, 64% { opacity: 0; transform: scale(0); }
    70% { opacity: 0.8; transform: scale(0.4); }
    84% { opacity: 1; transform: scale(1); }
    95% { opacity: 1; transform: scale(1); }
    100% { opacity: 0; transform: scale(0); }
  }

  /* 5. Gentle flame flicker */
  @keyframes gentleFlameFlicker {
    0%, 100% { transform: skewX(0deg) scale(1, 1); }
    33% { transform: skewX(1.5deg) scale(0.96, 1.04); }
    66% { transform: skewX(-1.5deg) scale(1.04, 0.96); }
  }

  /* 6. Friction heat glow */
  @keyframes frictionHeat {
    0%, 20% { fill: #3D2210; }
    40% { fill: #8A3E10; }
    64% { fill: #D9381E; }
    84%, 95% { fill: #F27D0C; }
    100% { fill: #3D2210; }
  }

  .drill-rod {
    transform-origin: 100px 160px;
    animation: fastDrillSpin 0.125s infinite linear;
  }
  .smoke {
    transform-origin: 100px 160px;
    animation: slowSmokeRise 5s infinite ease-out;
  }
  .smoke-1 { animation-delay: 0s; }
  .smoke-2 { animation-delay: 0.3s; }
  .spark {
    opacity: 0;
    transform-origin: 100px 160px;
    animation: slowSparkDrift 5s infinite ease-out;
  }
  .flame-wrapper {
    transform-origin: 100px 160px;
    animation: softFlameGrow 5s infinite ease-in-out;
  }
  .flame-flicker {
    transform-origin: 100px 160px;
    animation: gentleFlameFlicker 1.5s infinite ease-in-out;
  }
  .heat-spot {
    animation: frictionHeat 5s infinite ease-in-out;
  }
</style>
</head>
<body>
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="softBlur">
      <feGaussianBlur stdDeviation="2" />
    </filter>
  </defs>

  <g id="base-wood">
    <rect x="30" y="160" width="140" height="20" rx="3" fill="#4A2C16" />
    <path d="M 40,166 L 160,166 M 50,174 L 150,174" stroke="#3D2210" stroke-width="1.5" stroke-linecap="round" opacity="0.6" />
    <ellipse cx="100" cy="160" rx="12" ry="4" fill="#3D2210" />
    <ellipse class="heat-spot" cx="100" cy="160" rx="6" ry="2" fill="#3D2210" />
  </g>

  <g filter="url(#softBlur)" opacity="0.8">
    <ellipse class="smoke smoke-1" cx="95" cy="155" rx="10" ry="6" fill="#C8C2B8" />
    <ellipse class="smoke smoke-2" cx="105" cy="158" rx="8" ry="5" fill="#B5AEA5" />
  </g>

  <g class="drill-rod">
    <rect x="96" y="30" width="8" height="115" fill="#5C3A21" />
    <polygon points="96,145 104,145 100,160" fill="#3D2210" />
    <line x1="98" y1="30" x2="98" y2="145" stroke="#3D2210" stroke-width="1" opacity="0.8" />
    <line x1="102" y1="30" x2="102" y2="145" stroke="#4A2C16" stroke-width="1" opacity="0.5" />
  </g>

  <g id="sparks">
    <circle class="spark" cx="100" cy="160" r="1.5" fill="#FAD201" style="--start-x: -8px; --start-y: -5px; --end-x: -12px; --end-y: -25px; animation-delay: 0s;" />
    <circle class="spark" cx="100" cy="160" r="2" fill="#F7A600" style="--start-x: 6px; --start-y: -8px; --end-x: 10px; --end-y: -30px; animation-delay: 0.1s;" />
    <circle class="spark" cx="100" cy="160" r="1.2" fill="#FAD201" style="--start-x: -2px; --start-y: -12px; --end-x: 2px; --end-y: -40px; animation-delay: 0.2s;" />
  </g>

  <g class="flame-wrapper">
    <g class="flame-flicker">
      <path d="M 100,125 C 88,145 92,160 100,160 C 108,160 112,145 100,125 Z" fill="#D9381E" />
      <path d="M 100,135 C 93,150 95,160 100,160 C 105,160 107,150 100,135 Z" fill="#F27D0C" />
      <path d="M 100,145 C 97,154 97,160 100,160 C 103,160 103,154 100,145 Z" fill="#FAD201" />
    </g>
  </g>
</svg>
</body>
</html>
''';

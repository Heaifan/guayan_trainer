/// 水生木：春雨润木 → 发芽抽条 → 树冠繁茂 HTML 动画
///
/// Rain falls → wood log moistens → sprout grows → trunk extends → canopy bursts.
const String waterWoodHtml = r'''
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

  @keyframes rainGroupFade {
    0%, 45% { opacity: 1; }
    55%, 100% { opacity: 0; }
  }
  @keyframes rainFall {
    0% { transform: translate(15px, -30px); opacity: 0; }
    20% { opacity: 0.8; }
    80% { transform: translate(-20px, 120px); opacity: 0.8; }
    100% { transform: translate(-25px, 140px); opacity: 0; }
  }
  @keyframes woodRipple {
    0% { transform: scale(0.2) scaleY(0.4); opacity: 0; }
    20% { transform: scale(0.6) scaleY(0.4); opacity: 0.8; stroke-width: 2px; }
    100% { transform: scale(2.5) scaleY(0.4); opacity: 0; stroke-width: 0.5px; }
  }
  @keyframes moistGrow {
    0%, 10% { opacity: 0; transform: scale(0.8); }
    30%, 60% { opacity: 0.8; transform: scale(1.2); }
    80%, 100% { opacity: 0; transform: scale(1); }
  }
  @keyframes trunkGrow {
    0%, 15% { transform: scaleY(0); opacity: 0; }
    16% { opacity: 1; }
    30%, 45% { transform: scaleY(0.4); opacity: 1; stroke-width: 3px; }
    60%, 90% { transform: scaleY(1); opacity: 1; stroke-width: 4.5px; }
    100% { transform: scaleY(1); opacity: 0; }
  }
  @keyframes leafPopL {
    0%, 28% { transform: scale(0) rotate(20deg); opacity: 0; }
    38%, 90% { transform: scale(1) rotate(0deg); opacity: 1; }
    100% { transform: scale(1); opacity: 0; }
  }
  @keyframes leafPopR {
    0%, 28% { transform: scale(0) rotate(-20deg); opacity: 0; }
    38%, 90% { transform: scale(1) rotate(0deg); opacity: 1; }
    100% { transform: scale(1); opacity: 0; }
  }
  @keyframes canopyPop {
    0%, 56% { transform: scale(0); opacity: 0; }
    62% { transform: scale(1.15); opacity: 1; }
    68%, 90% { transform: scale(1); opacity: 1; }
    100% { transform: scale(1); opacity: 0; }
  }
  @keyframes treeSway {
    0%, 100% { transform: rotate(0deg); }
    40% { transform: rotate(1.5deg); }
    80% { transform: rotate(-1deg); }
  }
  @keyframes vitalityFlash {
    0%, 60% { opacity: 0; transform: scale(0.8); }
    70% { opacity: 0.6; transform: scale(1.1); }
    85%, 100% { opacity: 0; transform: scale(1); }
  }

  .rain-group { animation: rainGroupFade 5s infinite; }
  .rain-line { stroke: #B8D7EA; stroke-width: 1.5; stroke-linecap: round; animation: rainFall 1.2s infinite linear; }
  .r1 { animation-delay: 0.1s; } .r2 { animation-delay: 0.4s; } .r3 { animation-delay: 0.7s; }
  .r4 { animation-delay: 0.3s; } .r5 { animation-delay: 0.8s; }
  .ripple-group { animation: rainGroupFade 5s infinite; }
  .wood-ripple { transform-origin: 100px 150px; fill: none; stroke: #B8D7EA; animation: woodRipple 1.5s infinite ease-out; }
  .wr1 { animation-delay: 0.2s; } .wr2 { animation-delay: 0.8s; }
  .moist-spot { transform-origin: 100px 150px; animation: moistGrow 5s infinite ease-in-out; }
  .tree-group { transform-origin: 100px 150px; animation: treeSway 3s infinite ease-in-out; }
  .tree-trunk { transform-origin: 100px 150px; animation: trunkGrow 5s infinite ease-in-out; }
  .sprout-leaf-l { transform-origin: 100px 124px; animation: leafPopL 5s infinite cubic-bezier(0.34, 1.56, 0.64, 1); }
  .sprout-leaf-r { transform-origin: 100px 124px; animation: leafPopR 5s infinite cubic-bezier(0.34, 1.56, 0.64, 1); }
  .tree-canopy { transform-origin: 100px 85px; animation: canopyPop 5s infinite cubic-bezier(0.34, 1.56, 0.64, 1); }
  .vitality-glow { transform-origin: 100px 80px; animation: vitalityFlash 5s infinite ease-in-out; }
</style>
</head>
<body>
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="softBlur"><feGaussianBlur stdDeviation="1.5" /></filter>
    <radialGradient id="vitalityGrad" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#DDF3D2" stop-opacity="0.8" />
      <stop offset="50%" stop-color="#A8D5A2" stop-opacity="0.3" />
      <stop offset="100%" stop-color="#A8D5A2" stop-opacity="0" />
    </radialGradient>
  </defs>

  <g id="wood-log">
    <rect x="30" y="142" width="140" height="22" rx="6" fill="#4A2C16" />
    <ellipse cx="38" cy="153" rx="8" ry="11" fill="#3D2210" opacity="0.9" />
    <path d="M 45,147 L 160,147 M 50,153 L 150,153 M 40,159 L 165,159" stroke="#3D2210" stroke-width="1.5" stroke-linecap="round" opacity="0.5"/>
    <path d="M 95,142 L 102,146 L 105,142" fill="none" stroke="#2c1709" stroke-width="2" stroke-linecap="round"/>
  </g>

  <ellipse class="moist-spot" cx="100" cy="148" rx="18" ry="5" fill="#B8D7EA" filter="url(#softBlur)" opacity="0" />
  <g class="ripple-group">
    <ellipse class="wood-ripple wr1" cx="100" cy="148" rx="15" ry="15" />
    <ellipse class="wood-ripple wr2" cx="100" cy="148" rx="15" ry="15" />
  </g>

  <g class="tree-group">
    <circle class="vitality-glow" cx="100" cy="80" r="35" fill="url(#vitalityGrad)" filter="url(#softBlur)" />
    <path class="tree-trunk" d="M 100,146 Q 97,110 100,85" stroke="#528747" stroke-linecap="round" fill="none" />
    <g class="sprout-leaf-l">
      <path d="M 100,124 Q 85,115 80,124 Q 90,130 100,124 Z" fill="#A8D5A2" />
    </g>
    <g class="sprout-leaf-r">
      <path d="M 100,124 Q 115,115 120,124 Q 110,130 100,124 Z" fill="#A8D5A2" />
    </g>
    <g class="tree-canopy">
      <circle cx="100" cy="72" r="24" fill="#2F8F5B" />
      <circle cx="82" cy="88" r="18" fill="#528747" />
      <circle cx="118" cy="88" r="18" fill="#528747" />
      <circle cx="100" cy="88" r="16" fill="#2F8F5B" />
      <circle cx="92" cy="65" r="8" fill="#A8D5A2" opacity="0.4" />
      <circle cx="110" cy="80" r="5" fill="#A8D5A2" opacity="0.3" />
    </g>
  </g>

  <g class="rain-group">
    <line class="rain-line r1" x1="65" y1="20" x2="60" y2="35" />
    <line class="rain-line r2" x1="105" y1="0" x2="100" y2="15" />
    <line class="rain-line r3" x1="145" y1="30" x2="140" y2="45" />
    <line class="rain-line r4" x1="85" y1="40" x2="80" y2="55" />
    <line class="rain-line r5" x1="125" y1="15" x2="120" y2="30" />
  </g>
</svg>
</body>
</html>
''';

/// 金生水：寒风拂金 → 水珠凝结 → 滴落成水 HTML 动画
///
/// Cold wind blows from right → metal crystal gleams → water beads merge →
/// drop falls → ripples spread.
const String metalWaterHtml = r'''
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

  @keyframes metalGleam {
    0%, 100% { opacity: 0.6; filter: drop-shadow(0 0 2px #F4F1E8); }
    50% { opacity: 1; filter: drop-shadow(0 0 8px #FFF2B8); }
  }
  @keyframes rightToLeftWind {
    0% { opacity: 0; stroke-dashoffset: 180; transform: translate(15px, -5px); }
    25% { opacity: 0.8; }
    55% { opacity: 0.5; stroke-dashoffset: 0; transform: translate(-5px, 2px); }
    85%, 100% { opacity: 0; stroke-dashoffset: -150; transform: translate(-20px, 8px); }
  }
  @keyframes beadMerge {
    0%, 40% { opacity: 0; transform: translate(0, 0) scale(0); }
    58% { opacity: 1; transform: translate(0, 0) scale(1); }
    74% { opacity: 0; transform: translate(var(--merge-dx), var(--merge-dy)) scale(0.5); }
    100% { opacity: 0; transform: translate(var(--merge-dx), var(--merge-dy)) scale(0); }
  }
  @keyframes dropSwellAndFall {
    0%, 73% { opacity: 0; transform: translateY(0) scale(0); }
    74% { opacity: 1; transform: translateY(0) scale(1); }
    76% { transform: translateY(0) scaleY(1.2) scaleX(0.8); }
    80% { transform: translateY(65px) scaleY(1.4) scaleX(0.7); opacity: 1; }
    82%, 100% { transform: translateY(70px) scale(0); opacity: 0; }
  }
  @keyframes rippleExpand {
    0%, 79% { transform: scale(0); opacity: 0; }
    80% { transform: scale(0.1); opacity: 0.8; stroke-width: 2px; }
    95% { transform: scale(1); opacity: 0; stroke-width: 0.5px; }
    100% { transform: scale(1); opacity: 0; }
  }

  .metal-crystal { animation: metalGleam 4s infinite ease-in-out; }
  .wind-stream {
    fill: none; stroke: #B8D7EA; stroke-linecap: round;
    stroke-dasharray: 180;
    animation: rightToLeftWind 5s infinite cubic-bezier(0.4, 0, 0.2, 1);
  }
  .bead-slide { animation: beadMerge 5s infinite cubic-bezier(0.4, 0, 0.6, 1); }
  .falling-drop { transform-origin: 100px 125px; animation: dropSwellAndFall 5s infinite cubic-bezier(0.2, 0.8, 0.4, 1); }
  .water-ripple { transform-origin: 100px 185px; animation: rippleExpand 5s infinite ease-out; }
</style>
</head>
<body>
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="metalGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#F4F1E8" />
      <stop offset="50%" stop-color="#E2E2E2" />
      <stop offset="100%" stop-color="#B8A98A" />
    </linearGradient>
    <filter id="airBlur"><feGaussianBlur stdDeviation="1.2" /></filter>
  </defs>

  <g filter="url(#airBlur)">
    <path class="wind-stream" d="M 170,30 Q 120,40 50,70" stroke-width="1.5" style="animation-delay: 0s;" />
    <path class="wind-stream" d="M 190,65 Q 130,80 40,105" stroke="#DDECF5" stroke-width="2.5" style="animation-delay: 0.15s;" />
    <path class="wind-stream" d="M 160,95 Q 110,105 30,125" stroke-width="1.2" style="animation-delay: 0.3s;" />
  </g>

  <g class="metal-crystal" id="gold-crystal">
    <polygon points="100,50 140,85 100,125 60,85" fill="url(#metalGrad)" stroke="#B8A98A" stroke-width="0.5"/>
    <line x1="100" y1="50" x2="100" y2="125" stroke="#F4F1E8" stroke-width="0.5" opacity="0.6" />
    <line x1="60" y1="85" x2="140" y2="85" stroke="#F4F1E8" stroke-width="0.5" opacity="0.4" />
  </g>

  <g id="merging-beads">
    <circle class="bead-slide" cx="80" cy="85" r="2.5" fill="#3E7DBF" style="transform-origin: 80px 85px; --merge-dx: 20px; --merge-dy: 40px;" />
    <circle class="bead-slide" cx="120" cy="85" r="3" fill="#1F5F8B" style="transform-origin: 120px 85px; --merge-dx: -20px; --merge-dy: 40px; animation-delay: 0.1s;" />
    <circle class="bead-slide" cx="100" cy="105" r="2" fill="#3E7DBF" style="transform-origin: 100px 105px; --merge-dx: 0px; --merge-dy: 20px; animation-delay: 0.15s;" />
  </g>

  <path class="falling-drop" d="M 100,125 C 96,131 96,137 100,137 C 104,137 104,131 100,125 Z" fill="#3E7DBF" />

  <g id="ripples">
    <ellipse class="water-ripple" cx="100" cy="185" rx="30" ry="8" fill="none" stroke="#3E7DBF" stroke-linecap="round" />
    <ellipse class="water-ripple" cx="100" cy="185" rx="45" ry="12" fill="none" stroke="#1F5F8B" stroke-linecap="round" style="animation-delay: 0.1s;" />
  </g>
</svg>
</body>
</html>
''';

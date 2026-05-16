/// 土生金：金石破土而出 HTML 动画
///
/// Earth arches → gold stone emerges → halo glows → dust falls away.
const String earthMetalHtml = r'''
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

  @keyframes earthArch {
    0% { transform: scaleY(1) translateY(0); }
    24% { transform: scaleY(1.06) translateY(-2px); }
    52% { transform: scaleY(1.02) translateY(-0.5px); }
    92% { transform: scaleY(1.02) translateY(-0.5px); opacity: 1; }
    100% { transform: scaleY(1) translateY(0); opacity: 0; }
  }
  @keyframes stoneEmerge {
    0%, 24% { transform: translateY(45px) scale(0.6); opacity: 0; }
    52% { transform: translateY(0px) scale(1); opacity: 1; }
    92% { transform: translateY(0px) scale(1); opacity: 1; }
    100% { transform: translateY(0px) scale(1); opacity: 0; }
  }
  @keyframes softGlow {
    0%, 52% { opacity: 0; transform: scale(0.8); }
    64% { opacity: 0.8; transform: scale(1.05); }
    72% { opacity: 0.4; transform: scale(0.98); }
    80% { opacity: 1; transform: scale(1); }
    92% { opacity: 0; transform: scale(0.9); }
    100% { opacity: 0; }
  }
  @keyframes dustFall {
    0% { transform: translate(0, 0); opacity: 0; }
    10% { opacity: 0.6; }
    24% { transform: translate(var(--dx), var(--dy)); opacity: 0; }
    100% { opacity: 0; }
  }

  .earth-group { transform-origin: 100px 175px; animation: earthArch 5s infinite cubic-bezier(0.25, 1, 0.5, 1); }
  .gold-stone { transform-origin: 100px 140px; animation: stoneEmerge 5s infinite cubic-bezier(0.34, 1.56, 0.64, 1); }
  .halo-glow { transform-origin: 100px 115px; animation: softGlow 5s infinite ease-in-out; }
  .dust-particle { animation: dustFall 5s infinite linear; }
</style>
</head>
<body>
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="earthGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#D8A600" />
      <stop offset="40%" stop-color="#B8862F" />
      <stop offset="100%" stop-color="#8A6A32" />
    </linearGradient>
    <linearGradient id="stoneLight" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#F4F1E8" />
      <stop offset="100%" stop-color="#E2E2E2" />
    </linearGradient>
    <linearGradient id="stoneShadow" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#E2E2E2" />
      <stop offset="100%" stop-color="#B8A98A" />
    </linearGradient>
    <radialGradient id="glowGradiant" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#FFF2B8" stop-opacity="1" />
      <stop offset="50%" stop-color="#F7E7A0" stop-opacity="0.5" />
      <stop offset="100%" stop-color="#F7E7A0" stop-opacity="0" />
    </radialGradient>
  </defs>

  <g class="earth-group" opacity="0.6">
    <ellipse cx="100" cy="170" rx="55" ry="12" fill="#8A6A32" />
  </g>

  <circle class="halo-glow" cx="100" cy="115" r="35" fill="url(#glowGradiant)" />

  <g class="gold-stone">
    <polygon points="100,75 72,115 100,135" fill="url(#stoneLight)" />
    <polygon points="100,75 128,115 100,135" fill="#E2E2E2" />
    <polygon points="72,115 100,155 100,135" fill="url(#stoneShadow)" />
    <polygon points="128,115 100,155 100,135" fill="#B8A98A" />
    <polyline points="100,75 100,155" stroke="#F4F1E8" stroke-width="0.5" stroke-linecap="round" opacity="0.6"/>
    <polygon points="100,75 128,115 100,155 72,115" fill="none" stroke="#B8A98A" stroke-width="0.5" opacity="0.4" />
  </g>

  <g class="earth-group">
    <path d="M 35,175 Q 100,145 165,175 Q 150,192 100,192 Q 50,192 35,175 Z" fill="url(#earthGrad)" />
    <path d="M 35,175 Q 100,145 165,175" stroke="#D8A600" stroke-width="1.5" fill="none" stroke-linecap="round" opacity="0.8" />
    <circle class="dust-particle" cx="85" cy="160" r="1.5" fill="#B8862F" style="--dx: -15px; --dy: 20px; animation-delay: 0.1s;" />
    <circle class="dust-particle" cx="115" cy="162" r="1.2" fill="#D8A600" style="--dx: 18px; --dy: 18px; animation-delay: 0.2s;" />
    <circle class="dust-particle" cx="100" cy="158" r="1.6" fill="#8A6A32" style="--dx: -5px; --dy: 25px; animation-delay: 0s;" />
    <circle class="dust-particle" cx="75" cy="168" r="1" fill="#D8A600" style="--dx: -12px; --dy: 12px; animation-delay: 0.3s;" />
    <circle class="dust-particle" cx="125" cy="166" r="1.4" fill="#B8862F" style="--dx: 14px; --dy: 15px; animation-delay: 0.15s;" />
  </g>
</svg>
</body>
</html>
''';

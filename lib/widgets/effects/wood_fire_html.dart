/// Embedded HTML/SVG for the "木生火" flame animation.
const String woodFireHtml = r'''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body {
    width: 100%; height: 100%;
    margin: 0; padding: 0;
    background: transparent;
    overflow: hidden;
  }
  body {
    display: flex;
    justify-content: center;
    align-items: center;
  }
  svg {
    width: 100%; height: 100%;
    display: block;
  }
  .flame {
    transform-box: fill-box;
    transform-origin: bottom center;
    animation: flicker 1.5s infinite alternate ease-in-out;
  }
  .flame-yellow { animation-duration: 1.2s; animation-delay: 0.1s; }
  .flame-orange { animation-duration: 1.5s; animation-delay: 0.3s; }
  .flame-red { animation-duration: 1.8s; animation-delay: 0s; }
  @keyframes flicker {
    0%   { transform: scale(1,1) rotate(0deg); opacity: 0.95; }
    25%  { transform: scale(0.98,1.04) rotate(-1deg); }
    50%  { transform: scale(1.02,0.98) rotate(1deg); opacity: 1; }
    75%  { transform: scale(0.99,1.02) rotate(-0.5deg); }
    100% { transform: scale(1.01,0.99) rotate(0.5deg); opacity: 0.9; }
  }
  .spark {
    transform-origin: center;
    animation: floatUp 2.5s infinite cubic-bezier(0.25,0.46,0.45,0.94);
    opacity: 0;
  }
  .spark:nth-child(1) { animation-duration: 2.5s; animation-delay: 0s; }
  .spark:nth-child(2) { animation-duration: 3.0s; animation-delay: 0.8s; }
  .spark:nth-child(3) { animation-duration: 2.2s; animation-delay: 1.4s; }
  .spark:nth-child(4) { animation-duration: 2.8s; animation-delay: 0.5s; }
  .spark:nth-child(5) { animation-duration: 3.2s; animation-delay: 1.8s; }
  @keyframes floatUp {
    0%   { transform: translateY(0) translateX(0) scale(1); opacity: 1; }
    50%  { opacity: 0.8; }
    100% { transform: translateY(-80px) translateX(12px) scale(0); opacity: 0; }
  }
</style>
</head>
<body>
<svg viewBox="0 0 200 300">
  <g id="wood">
    <rect x="50" y="240" width="100" height="20" rx="8" fill="#5c3a21" transform="rotate(25 100 250)"/>
    <rect x="50" y="240" width="100" height="20" rx="8" fill="#4a2c16" transform="rotate(-25 100 250)"/>
    <path d="M60 245 L140 245" stroke="#3d2210" stroke-width="2" stroke-linecap="round" transform="rotate(25 100 250)"/>
    <path d="M60 245 L140 245" stroke="#2c1709" stroke-width="2" stroke-linecap="round" transform="rotate(-25 100 250)"/>
  </g>
  <g id="fire" transform="translate(100, 240)">
    <path class="flame flame-red" d="M0,0 C-45,-20 -55,-90 0,-140 C55,-90 45,-20 0,0 Z" fill="#d9381e"/>
    <path class="flame flame-orange" d="M0,0 C-30,-15 -35,-70 0,-100 C35,-70 30,-15 0,0 Z" fill="#f27d0c"/>
    <path class="flame flame-yellow" d="M0,0 C-15,-10 -20,-45 0,-65 C20,-45 15,-10 0,0 Z" fill="#fad201"/>
  </g>
  <g id="sparks" transform="translate(100, 160)" fill="#fad201">
    <circle class="spark" cx="-15" cy="0" r="2.5"/>
    <circle class="spark" cx="20" cy="15" r="3"/>
    <circle class="spark" cx="5" cy="30" r="2"/>
    <circle class="spark" cx="-25" cy="10" r="3.5"/>
    <circle class="spark" cx="30" cy="5" r="2"/>
  </g>
</svg>
</body>
</html>
''';

/// Embedded HTML/SVG for the "火生土" animation.
///
/// Flame burns → ash falls → ash pile grows → fire smothered → ash remains.
/// Loop: 5 s.
const String fireEarthHtml = r'''
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
    overflow: visible;
  }
  @keyframes flicker1 {
    0%, 100% { transform: scale(1) skewX(2deg); }
    50% { transform: scale(1.05) skewX(-2deg); }
  }
  @keyframes flicker2 {
    0%, 100% { transform: scale(1) skewX(-3deg); }
    50% { transform: scale(0.95) skewX(3deg); }
  }
  .flame-outer { animation: flicker1 0.4s infinite alternate; transform-origin: 125px 280px; }
  .flame-mid { animation: flicker2 0.3s infinite alternate; transform-origin: 125px 280px; }
  .flame-inner { animation: flicker1 0.5s infinite alternate; transform-origin: 125px 280px; }
  #flames { transform-origin: 125px 280px; }
  #ash-cone { transform-origin: 125px 280px; transform: scaleY(0); }
</style>
</head>
<body>
<svg id="scene" viewBox="20 110 210 220" preserveAspectRatio="xMidYMid meet">
  <ellipse cx="125" cy="280" rx="55" ry="8" fill="#2a2a2a" />
  <g id="flames">
    <path class="flame-outer" d="M125,180 Q160,250 125,280 Q90,250 125,180 Z" fill="#e65100"/>
    <path class="flame-mid" d="M125,200 Q145,255 125,280 Q105,255 125,200 Z" fill="#ff9800"/>
    <path class="flame-inner" d="M125,225 Q135,260 125,280 Q115,260 125,225 Z" fill="#ffeb3b"/>
  </g>
  <path id="ash-cone" d="M 75 280 Q 125 200 175 280 Z" fill="#6a6a6a" opacity="0.95" />
  <g id="particles"></g>
</svg>
<script>
  const flames = document.getElementById('flames');
  const ashCone = document.getElementById('ash-cone');
  const particlesGroup = document.getElementById('particles');
  let ashInterval;

  function spawnAsh() {
    const p = document.createElementNS("http://www.w3.org/2000/svg", "circle");
    const r = Math.random() * 2 + 0.8;
    p.setAttribute("r", r);
    p.setAttribute("fill", Math.random() > 0.4 ? "#888888" : "#555555");
    const startX = 125 + (Math.random() - 0.5) * 70;
    const startY = 250 - Math.random() * 90;
    p.setAttribute("cx", startX);
    p.setAttribute("cy", startY);
    particlesGroup.appendChild(p);
    const fallX = startX + (Math.random() - 0.5) * 30;
    const fallY = 275 + Math.random() * 10;
    const duration = Math.random() * 800 + 500;
    p.animate([
      { transform: 'translate(0, 0)', opacity: 0.9 },
      { transform: 'translate(' + (fallX - startX) + 'px, ' + (fallY - startY) + 'px)', opacity: 0 }
    ], { duration: duration, easing: 'ease-in' });
    setTimeout(() => {
      if (particlesGroup.contains(p)) p.remove();
    }, duration);
  }

  function runSequence() {
    flames.style.transition = 'none';
    ashCone.style.transition = 'none';
    flames.style.transform = 'scale(1) translateY(0)';
    flames.style.opacity = '1';
    ashCone.style.transform = 'scaleY(0)';
    particlesGroup.innerHTML = '';
    void flames.offsetWidth;
    clearInterval(ashInterval);
    ashInterval = setInterval(spawnAsh, 55);
    setTimeout(() => {
      flames.style.transition = 'transform 2s ease-in, opacity 1.8s ease-in';
      ashCone.style.transition = 'transform 2s ease-out';
      ashCone.style.transform = 'scaleY(1)';
      flames.style.transform = 'scale(0.2) translateY(30px)';
      flames.style.opacity = '0';
    }, 1500);
    setTimeout(() => {
      clearInterval(ashInterval);
    }, 3500);
  }

  runSequence();
  setInterval(runSequence, 5000);
</script>
</body>
</html>
''';

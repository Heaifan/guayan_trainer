/// 土克水：土堤束水 HTML 动画
const String earthWaterControlHtml = r'''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body { margin:0; padding:0; width:100%; height:100%; background-color:transparent; overflow:hidden; display:flex; justify-content:center; align-items:center; }
  svg { width:100%; height:100%; max-width:300px; max-height:300px; display:block; }
  @keyframes globalFade { 0%,2%{opacity:0} 5%,95%{opacity:1} 98%,100%{opacity:0} }
  @keyframes waterRushIn { 0%{transform:translateX(-40px)} 15%{transform:translateX(-20px)} 42%{transform:translateX(0)} 100%{transform:translateX(0)} }
  @keyframes waterSurgeAndCalm { 0%,35%{transform:translateY(0) scaleY(1)} 42%{transform:translateY(-2px) scaleY(1.15)} 60%{transform:translateY(0.5px) scaleY(0.9)} 88%,100%{transform:translateY(1.5px) scaleY(0.72)} }
  @keyframes infiniteFlow { 0%{transform:translateX(0)} 100%{transform:translateX(60px)} }
  @keyframes earthRise { 0%,15%{transform:translateY(20px);opacity:0.8} 42%{transform:translateY(0);opacity:1} 100%{transform:translateY(0);opacity:1} }
  @keyframes waveRollback { 0%,38%{opacity:0;transform:scale(0.3) rotate(15deg)} 42%{opacity:0.9;transform:scale(0.9) rotate(0)} 52%{opacity:1;transform:scale(1.1) rotate(-20deg) translateX(-5px)} 65%{opacity:0;transform:scale(1.2) rotate(-30deg) translateX(-10px)} 100%{opacity:0} }
  @keyframes splashAnim { 0%,40%{opacity:0;transform:translate(0,0) scale(0.5)} 42%{opacity:1;transform:translate(0,0) scale(1)} 55%{opacity:1;transform:translate(var(--dx),var(--dy)) scale(1)} 65%,100%{opacity:0;transform:translate(calc(var(--dx)-3px),calc(var(--dy)+4px)) scale(0.5)} }
  .fade-group { animation:globalFade 5s linear infinite; }
  .water-rush { animation:waterRushIn 5s ease-out infinite; }
  .water-calm { transform-origin:0 65px; animation:waterSurgeAndCalm 5s ease-in-out infinite; }
  .water-deep { fill:#1F5F8B; animation:infiniteFlow 2.8s linear infinite; }
  .water-surface { fill:#3E7DBF; opacity:0.85; animation:infiniteFlow 2.2s linear infinite; }
  .earth-group { animation:earthRise 5s cubic-bezier(0.25,0.8,0.3,1) infinite; }
  .earth-base { fill:#B8862F; } .earth-highlight { fill:#D8A600; } .earth-shadow { fill:#8A6A32; }
  .rollback-wave { fill:#B8D7EA; transform-origin:45px 60px; animation:waveRollback 5s ease-out infinite; }
  .splash { fill:#DDECF5; opacity:0; animation:splashAnim 5s ease-out infinite; }
</style>
</head>
<body>
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <g class="fade-group">
    <g class="water-rush">
      <g class="water-calm">
        <path class="water-deep" d="M -120 65 Q -105 62 -90 65 T -60 65 T -30 65 T 0 65 T 30 65 T 60 65 T 90 65 T 120 65 T 150 65 L 150 100 L -120 100 Z" />
        <path class="water-surface" d="M -120 62 Q -105 65 -90 62 T -60 62 T -30 62 T 0 62 T 30 62 T 60 62 T 90 62 T 120 62 T 150 62 L 150 100 L -120 100 Z" />
      </g>
    </g>
    <g class="earth-group">
      <path class="earth-base" d="M 46 100 Q 54 58 76 54 Q 90 53 105 55 L 105 100 Z" />
      <path class="earth-highlight" d="M 46 100 Q 54 58 76 54 L 81 54 Q 63 64 53 100 Z" />
      <path class="earth-shadow" d="M 76 54 Q 90 53 105 55 L 105 100 L 88 100 Q 82 70 76 54 Z" />
      <path class="earth-base" d="M -10 100 L -10 90 Q 40 85 105 90 L 105 100 Z" />
      <path class="earth-highlight" d="M -10 90 Q 40 85 105 90 L 105 93 Q 40 88 -10 93 Z" />
      <path d="M 54 62 L 56 72" stroke="#5A3A1C" stroke-width="1.5" fill="none" opacity="0.7" stroke-linecap="round"/>
      <path d="M 66 58 L 69 67" stroke="#5A3A1C" stroke-width="1.5" fill="none" opacity="0.7" stroke-linecap="round"/>
      <path d="M 20 92 L 28 95" stroke="#5A3A1C" stroke-width="1.5" fill="none" opacity="0.7" stroke-linecap="round"/>
    </g>
    <path class="rollback-wave" d="M 47 62 C 47 52, 33 52, 35 59 C 37 61, 42 62, 47 63 Z" />
    <g>
      <circle class="splash" cx="44" cy="57" r="1.5" style="--dx:-8px;--dy:-6px;" />
      <circle class="splash" cx="46" cy="59" r="1.0" style="--dx:-4px;--dy:-10px;animation-delay:0.05s;" />
      <circle class="splash" cx="42" cy="60" r="1.2" style="--dx:-10px;--dy:-3px;animation-delay:0.1s;" />
    </g>
  </g>
</svg>
</body>
</html>
''';

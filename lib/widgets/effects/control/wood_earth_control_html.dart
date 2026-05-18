/// 木克土：木根破土 HTML 动画
const String woodEarthControlHtml = r'''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body { margin:0; padding:0; width:100%; height:100%; background-color:transparent; overflow:hidden; display:flex; justify-content:center; align-items:center; }
  svg { width:100%; height:100%; max-width:300px; max-height:300px; display:block; }
  @keyframes globalFade { 0%,90%{opacity:1} 95%,100%{opacity:0} }
  @keyframes mainRootGrow { 0%,20%{stroke-dashoffset:60;opacity:0} 21%{stroke-dashoffset:60;opacity:1} 68%,90%{stroke-dashoffset:0;opacity:1} 95%,100%{stroke-dashoffset:0;opacity:0} }
  @keyframes mainCrackSpread { 0%,48%{stroke-dashoffset:50;opacity:0} 49%{stroke-dashoffset:50;opacity:1} 68%,90%{stroke-dashoffset:0;opacity:1} 95%,100%{stroke-dashoffset:0;opacity:0} }
  @keyframes sideCrackSpread { 0%,52%{stroke-dashoffset:30;opacity:0} 53%{stroke-dashoffset:30;opacity:1} 68%,90%{stroke-dashoffset:0;opacity:1} 95%,100%{stroke-dashoffset:0;opacity:0} }
  @keyframes sideRootGrow { 0%,68%{stroke-dashoffset:30;opacity:0} 69%{stroke-dashoffset:30;opacity:1} 88%,90%{stroke-dashoffset:0;opacity:1} 95%,100%{stroke-dashoffset:0;opacity:0} }
  @keyframes particleShift { 0%,68%{opacity:0;transform:translate(0,0)} 69%{opacity:1} 88%,90%{opacity:1;transform:translate(var(--dx),var(--dy))} 95%,100%{opacity:0} }
  .fade-group { animation:globalFade 5s linear infinite; }
  .soil-body { fill:#B8862F; } .soil-surface { fill:#D8A600; }
  .crack-main { stroke:#3D2815; stroke-width:1.5; fill:none; stroke-linecap:round; stroke-dasharray:50; stroke-dashoffset:50; opacity:0; animation:mainCrackSpread 5s ease-in-out infinite; }
  .crack-side { stroke:#5A3A1C; stroke-width:0.8; fill:none; stroke-linecap:round; stroke-dasharray:30; stroke-dashoffset:30; opacity:0; animation:sideCrackSpread 5s ease-in-out infinite; }
  .main-root { stroke:#2F8F5B; stroke-width:3; fill:none; stroke-linecap:round; stroke-dasharray:60; stroke-dashoffset:60; opacity:0; animation:mainRootGrow 5s linear infinite; }
  .side-root { stroke:#528747; stroke-width:1.8; fill:none; stroke-linecap:round; stroke-dasharray:30; stroke-dashoffset:30; opacity:0; animation:sideRootGrow 5s ease-out infinite; }
  .particle { fill:#8A6A32; opacity:0; animation:particleShift 5s ease-out infinite; }
</style>
</head>
<body>
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <g class="fade-group">
    <g class="soil-group">
      <path class="soil-body" d="M 5 45 Q 50 43 95 45 L 95 95 Q 50 98 5 95 Z" />
      <path class="soil-surface" d="M 5 45 Q 50 43 95 45 L 90 50 Q 50 48 10 50 Z" />
    </g>
    <g class="cracks-group">
      <path class="crack-main" d="M 50 45 L 48 53 L 53 61 L 47 70 L 51 80" />
      <path class="crack-side" d="M 48 53 L 40 57 L 35 63" />
      <path class="crack-side" d="M 53 61 L 61 64 L 66 71" />
    </g>
    <g class="roots-group">
      <path class="side-root" d="M 49 61 Q 42 66 38 74" />
      <path class="side-root" d="M 50 71 Q 57 74 61 82" />
      <path class="main-root" d="M 50 44 C 44 54, 56 64, 49 74 C 46 79, 52 83, 50 85" />
    </g>
    <g class="particles-group">
      <circle class="particle" cx="47" cy="46" r="1.2" style="--dx:-3px;--dy:-1px;" />
      <circle class="particle" cx="53" cy="47" r="1.0" style="--dx:3px;--dy:0px;" />
      <circle class="particle" cx="50" cy="48" r="0.8" style="--dx:-1px;--dy:2px;" />
    </g>
  </g>
</svg>
</body>
</html>
''';

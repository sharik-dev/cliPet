var SPRITES = {"idle":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"walk1":["..........................XX.....",".........................XXXX....","........................XXXXX....",".....XXX...............XXXXXXX...","....XgggXXXXXg.....XXXXXXXXXXX...","....XgggXXXXXXXXXXXXXXXXXXXXXX...","...XgXggXXXXXXXXXgXXXXgXXXXXXX...","...XggXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwwwX..wgX..ggwwwwg..XwwgwX.....","..XXX...XX...gXgwwwwX.XggwwX.....","........XX....gXwggwX..XXXX......","..............gXggwXX............","...............gXXX..............","................................."],"walk2":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"walk3":["..........................XX.....",".........................XXXX....","........................XXXXX....","...XXX.................XXXXXXX...","..XgggXX.XXXXg.....XXXXXXXXXXX...","..XgggXX.XXXXXXXXXXXXXXXXXXXXX...",".XgXggXX.XXXXXXXXgXXXXgXXXXXXX...",".XggXXXX.XXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXw..XwwgwX.....",".XXXXXggwwwgggggXXXwX.XggwwX.....",".XgXggggwwwwggggggXXX..XXXX......",".XwggggwwgX..ggwwwwgX............",".XwwwwgXXX...gXgwwww.............",".XwwwwXXXX....gXwggw.............",".XwwwX........gXggwX.............","..XXX..........gXXX..............","................................."],"walk4":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"sit":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"sleep":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"play":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"yarn1":[".....XXXXXXX","...XXppXXXXX","..XppXpppXXX",".XprppppppXX",".XppppXpppXX","XppppppppppX","XpXpXpXpXpXX","XXppppppppXX","XXppppXpppXX","XXXppppppXXX","XXXXXpXXXXXX","XXXXXXXXXXXX"],"yarn2":[".....XXXXXXX","...XXppXXXXX","..XppppXpXXX",".XprpppXppXX",".XXXppXpppXX","XpppXXXppppX","XppppXXXpppX","XXpppXppXXXX","XXppXpppppXX","XXXpXppppXXX","XXXXXppXXXXX","XXXXXXXXXXXX"],"yarn3":[".....XXXXXXX","...XXppXXXXX","..XppppppXXX",".XprppppXpXX",".XppXppXppXX","XppppXXppppX","XppppXXppppX","XXppXppXppXX","XXpXppppXpXX","XXXppppppXXX","XXXXXppXXXXX","XXXXXXXXXXXX"],"yarn4":[".....XXXXXXX","...XXppXXXXX","..XpXppppXXX",".XprXpppppXX",".XpppXppXXXX","XppppXXXpppX","XpppXXXppppX","XXXXppXpppXX","XXpppppXppXX","XXXppppXpXXX","XXXXXppXXXXX","XXXXXXXXXXXX"]};

/* cliPet — moteur pixel (canvas) : chat qui suit le curseur, icônes, FAQ */
(function () {
  "use strict";

  // Palette officielle du pet « Cœur gris » (identité de marque — miroir de l'app).
  var CAT = { ".": null, "X": "#17191C", "g": "#969BA1", "w": "#F5F5F5", "p": "#CE2828", "r": "#F2A24C" };

  // ---- rendu générique d'une grille ASCII sur un canvas ----
  function drawGrid(ctx, rows, palette, scale, ox, oy, flip, w) {
    ox = ox || 0; oy = oy || 0;
    var H = rows.length, W = rows[0].length;
    for (var y = 0; y < H; y++) {
      for (var x = 0; x < W; x++) {
        var c = palette[rows[y][x]];
        if (!c) continue;
        var px = flip ? (W - 1 - x) : x;
        ctx.fillStyle = c;
        ctx.fillRect(ox + px * scale, oy + y * scale, scale, scale);
      }
    }
  }

  // ============ Logo + icône statique (sprites) ============
  document.querySelectorAll("canvas[data-sprite]").forEach(function (cv) {
    var rows = SPRITES[cv.dataset.sprite];
    if (!rows) return;
    var s = Math.floor(cv.width / rows[0].length) || 1;
    drawGrid(cv.getContext("2d"), rows, CAT, s);
  });

  // ============ Icônes pixel des features ============
  var ICONS = {
    menubar: [".........","#########","#.#####.#","#.......#","#########",".........","..#####..",".#.....#.",".#######."],
    paw:     [".#.....#.","###...###","###...###",".........","..##.##..",".#######.","#########","#########",".#######."],
    cursor:  ["#........","##.......","###......","####.....","#####....","######...","###.##...","#...##...","....##..."],
    clipboard:["..###....",".#####...","#.....#..","#.###.#..","#.....#..","#.###.#..","#.....#..","#######..","........."],
    palette: [".#####...","#######..","#.#.#.##.","#.....###","#.#.#..##","#######..",".#####...",".........","........."],
    pencil:  ["......##.",".....##..","....##.#.","...##.##.","..##.##..",".##.##...","###.#....","##.#.....","#........"],
    stack:   ["..#####..","..#...#..","#########","#.#.#.#.#","#.......#","#########","#.#.#.#.#","#########","........."],
    chip:    [".#.#.#.#.","#########","#.......#","#.#####.#","#.#...#.#","#.#####.#","#.......#","#########",".#.#.#.#."],
    lock:    ["..#####..",".#....#..",".#....#..","#######..","#######..","#..#..#..","#..#..#..","#######..","........."]
  };
  var ICO_PAL = { ".": null, "#": "#d8cfc2" };
  document.querySelectorAll("canvas[data-icon]").forEach(function (cv) {
    var rows = ICONS[cv.dataset.icon];
    if (!rows) return;
    var s = 4;
    cv.width = rows[0].length * s; cv.height = rows.length * s;
    drawGrid(cv.getContext("2d"), rows, ICO_PAL, s);
  });

  // ============ Playground : le chat suit la souris ============
  var pg = document.getElementById("playground");
  if (pg) runPlayground(pg);

  // ============ Panneau presse-papier (ouvert au clic sur le pet) ============
  var clipPanel = document.getElementById("clipPanel");
  var clipOpen = false;               // le pet reste immobile tant que c'est vrai
  function openClip(petCx, petTop) {
    if (!clipPanel) return;
    clipOpen = true;
    var ms = document.getElementById("macScreen");
    if (ms && petCx != null) {
      var msw = ms.clientWidth;
      var pw = Math.min(300, msw * 0.86);
      clipPanel.style.width = pw + "px";
      // centré horizontalement sur le pet, borné dans l'écran
      clipPanel.style.left = Math.round(Math.max(8, Math.min(petCx - pw / 2, msw - pw - 8))) + "px";
      // juste au-dessus du pet (mesure la hauteur réelle du panneau)
      var ph = clipPanel.offsetHeight;
      clipPanel.style.top = Math.round(Math.max(8, petTop - ph - 6)) + "px";
    }
    clipPanel.classList.add("show");
    clipPanel.setAttribute("aria-hidden", "false");
  }
  function closeClip() {
    if (!clipPanel) return;
    clipOpen = false;
    clipPanel.classList.remove("show");
    clipPanel.setAttribute("aria-hidden", "true");
  }
  (function () {
    if (!clipPanel) return;
    var x = document.getElementById("clipClose");
    if (x) x.addEventListener("click", function (e) { e.stopPropagation(); closeClip(); });
    // Empêche un clic dans le panneau de le refermer (le fond le ferme via le canvas)
    clipPanel.addEventListener("click", function (e) { e.stopPropagation(); });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeClip(); });

    // « Screenshot.png » du presse-papier : un vrai rendu du pet sur le bureau
    var shot = document.getElementById("clipShot");
    if (shot) {
      var sx = shot.getContext("2d");
      var g = sx.createLinearGradient(0, 0, 0, shot.height);
      g.addColorStop(0, "#2f2b4d"); g.addColorStop(0.55, "#8a5d6a"); g.addColorStop(1, "#e8a866");
      sx.fillStyle = g; sx.fillRect(0, 0, shot.width, shot.height);
      var rows = SPRITES.sit, s = 3, w = rows[0].length * s, h = rows.length * s;
      drawGrid(sx, rows, CAT, s, Math.round((shot.width - w) / 2), shot.height - h + 2);
    }
  })();

  function runPlayground(cv) {
    var ctx = cv.getContext("2d");
    var SC = 6;                              // taille d'un pixel (petit pet discret)
    var catW = SPRITES.idle[0].length * SC;  // 33*9
    var catH = SPRITES.idle.length * SC;
    var walkFrames = [SPRITES.walk1, SPRITES.walk2, SPRITES.walk3, SPRITES.walk4];
    var floorY = cv.height - catH + 4;       // pattes au ras du bas de l'écran

    var cat = { x: cv.width * 0.28, face: 1 }; // déjà là, puis se balade
    var target = cv.width * 0.5;
    var targetY = floorY;
    var pointerActive = false;
    var lastMove = 0;
    var idleSince = 0;
    var t0 = performance.now();
    var wanderNext = 1500;

    function toInternal(e) {
      var r = cv.getBoundingClientRect();
      return {
        x: (e.clientX - r.left) * (cv.width / r.width),
        y: (e.clientY - r.top) * (cv.height / r.height)
      };
    }
    cv.addEventListener("pointermove", function (e) {
      var p = toInternal(e);
      target = Math.max(20, Math.min(cv.width - 20, p.x));
      targetY = p.y;
      pointerActive = true;
      lastMove = performance.now();
    });
    cv.addEventListener("pointerleave", function () { pointerActive = false; });

    // — clic sur le pet « Cœur gris » → ouvre son presse-papier au-dessus de lui —
    cv.addEventListener("click", function (e) {
      var p = toInternal(e);
      var onCat = p.x > cat.x - 30 && p.x < cat.x + catW + 30 && p.y > floorY - 30;
      if (onCat) {
        e.stopPropagation();
        var r = cv.getBoundingClientRect();
        var ms = cv.parentElement.getBoundingClientRect();
        var sx = r.width / cv.width, sy = r.height / cv.height;
        var petCx = (r.left - ms.left) + (cat.x + catW / 2) * sx;  // centre du pet (px écran)
        var petTop = (r.top - ms.top) + floorY * sy;               // haut du pet
        openClip(petCx, petTop);
      } else closeClip();
    });

    function frame(now) {
      var t = now - t0;

      // Presse-papier ouvert → le pet reste immobile (assis) à sa position.
      if (clipOpen) {
        ctx.clearRect(0, 0, cv.width, cv.height);
        var sCx = cat.x + catW / 2, sCy = floorY + catH - 6;
        var sg = ctx.createRadialGradient(sCx, sCy, 4, sCx, sCy, catW * 0.42);
        sg.addColorStop(0, "rgba(0,0,0,0.32)"); sg.addColorStop(1, "rgba(0,0,0,0)");
        ctx.fillStyle = sg;
        ctx.beginPath(); ctx.ellipse(sCx, sCy, catW * 0.42, 14, 0, 0, Math.PI * 2); ctx.fill();
        drawGrid(ctx, SPRITES.sit, CAT, SC, Math.round(cat.x), floorY, cat.face < 0);
        requestAnimationFrame(frame);
        return;
      }

      // auto-balade : le chat marche le long du bas de l'écran
      if (!pointerActive && t > wanderNext) {
        target = 80 + Math.random() * (cv.width - 160);
        wanderNext = t + 700 + Math.random() * 1400;
      }

      // déplacement du chat vers la cible
      var reach = pointerActive ? 70 : 24;
      var dx = target - (cat.x + catW / 2);
      var moving = Math.abs(dx) > reach;
      if (moving) {
        cat.face = dx > 0 ? 1 : -1;
        cat.x += Math.max(-7, Math.min(7, dx * 0.12));
        idleSince = 0;
      } else {
        if (!idleSince) idleSince = t;
      }

      // choix du sprite
      var sprite, flip = cat.face < 0;
      if (moving) {
        sprite = walkFrames[Math.floor(t / 110) % 4];
      } else {
        var idleFor = t - idleSince;
        if (pointerActive && Math.abs(target - (cat.x + catW / 2)) < 90) {
          sprite = SPRITES.play;            // joue avec la pelote
        } else if (idleFor > 4500) {
          sprite = SPRITES.sleep;           // s'endort
        } else {
          sprite = SPRITES.idle;
        }
      }

      // --- dessin ---
      ctx.clearRect(0, 0, cv.width, cv.height);

      // ombre douce sous le chat
      var shCx = cat.x + catW / 2, shCy = floorY + catH - 6;
      var g = ctx.createRadialGradient(shCx, shCy, 4, shCx, shCy, catW * 0.42);
      g.addColorStop(0, "rgba(0,0,0,0.32)"); g.addColorStop(1, "rgba(0,0,0,0)");
      ctx.fillStyle = g;
      ctx.beginPath();
      ctx.ellipse(shCx, shCy, catW * 0.42, 14, 0, 0, Math.PI * 2);
      ctx.fill();

      drawGrid(ctx, sprite, CAT, SC, Math.round(cat.x), floorY, flip);
      // Pas de pelote : le vrai curseur souris reste affiché ; le pet le suit.

      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  }

  // ============ i18n — EN par défaut, FR auto-détecté ============
  // (EN est dans le HTML ; on ne stocke ici que les traductions.)
  var I18N = {
    fr: {
      "doc.title": "cliPet — un chat pixel qui vit sur ton Mac",
      "doc.desc": "cliPet : un compagnon pixel-art natif macOS qui se balade en bas de ton écran, chasse ton curseur et garde ton presse-papier. Léger, local, adorable.",
      "nav.features": "Fonctionnalités", "nav.pricing": "Tarif", "nav.faq": "FAQ", "nav.download": "Télécharger",
      "hero.h1": "Un chat pixel qui<br><span class=\"dyn\" id=\"dynWord\">vit sur ton Mac</span>",
      "hero.lead": "Il se balade en bas de ton écran, dort, et <strong>chasse ton curseur</strong>. Natif, ultra-léger, 100&nbsp;% local.",
      "hero.cta1": "Obtenir cliPet", "hero.cta2": "Voir ce qu'il sait faire",
      "stage.title": "cliPet — en direct sur ton bureau",
      "menu.file": "Fichier", "menu.edit": "Édition", "menu.window": "Fenêtre", "menu.help": "Aide",
      "notch.status": "ronronne · humeur au top", "notch.online": "en ligne",
      "notch.clipboard": "Presse-papier", "notch.copied": "copié · 2m",
      "notch.skin": "Skin actif", "notch.skins": "3 dispo",
      "notch.sounds": "Sons rétro", "notch.onstate": "on",
      "stage.hint": "↑ <span class=\"accent\">bouge ta souris</span> — il te suit. <span class=\"accent\">Clique dessus</span> pour ouvrir son presse-papier.",
      "clip.title": "PRESSE-PAPIER", "clip.history": "Historique", "clip.search": "Rechercher…", "clip.shot": "Capture.png",
      "features.eyebrow": "Fonctionnalités", "features.h2": "Petit, mais bien vivant",
      "features.sub": "Tout ce qu'un compagnon de bureau doit savoir faire — et rien qui te ralentisse.",
      "f1.t": "Dans la barre de menus", "f1.d": "Zéro fenêtre, toujours là, jamais dans le chemin. Un clic pour tout régler.",
      "f2.t": "Animations pixel", "f2.d": "Il marche, court, s'assoit, dort, bondit et cligne des yeux. Fait main, image par image.",
      "f3.t": "Chasse le curseur", "f3.d": "Lâche la pelote : il la poursuit à travers l'écran et lui saute dessus.",
      "f4.t": "Presse-papier", "f4.d": "Un presse-papier intelligent qui détecte les codes couleur, affiche les miniatures d'images, trace les chemins de fichiers et sauvegarde tes photos sur le disque. Rien ne passe au travers.",
      "f5.t": "Skins personnalisables", "f5.d": "Change la robe et le style du chat. Plusieurs skins inclus, d'autres à venir.",
      "f6.t": "Éditeur de sprites", "f6.d": "Dessine tes propres animations pixel directement dans l'app. Ton chat, tes règles.",
      "f7.t": "Tout est capturé", "f7.d": "Texte, images, photos, PDFs, fichiers, codes hex — chaque copie est sauvegardée avec un aperçu riche. Tout ton historique, consultable en un clic.",
      "f8.t": "100&nbsp;% natif", "f8.d": "Swift &amp; AppKit. Pas d'Electron, moins de 50&nbsp;Mo de RAM. Rapide et discret.",
      "f9.t": "Priorité vie privée", "f9.d": "Aucun cloud, aucun compte, aucune donnée perso. Ton presse-papier ne quitte jamais ton Mac — seulement des stats d'usage anonymes.",
      "pricing.eyebrow": "Tarif", "pricing.h2": "Adopte-le aujourd'hui",
      "pricing.sub": "Un seul achat, à toi pour toujours. Mises à jour comprises.",
      "price.value": "4,99 €", "price.sub": "Achat unique · mises à jour à vie",
      "check1": "Le compagnon pixel complet (marche, sommeil, chasse)",
      "check2": "Gestionnaire de presse-papier intégré",
      "check3": "Skins &amp; éditeur de sprites",
      "check4": "Historique riche — textes, images, fichiers &amp; couleurs",
      "check5": "Natif Swift — moins de 50&nbsp;Mo de RAM",
      "price.btn1": "Acheter sur Gumroad", "price.btn2": "Acheter sur Lemon Squeezy", "price.note": "Un souci ? <a href=\"mailto:sharikmohamed9@gmail.com?subject=cliPet%20Support\">Écris-nous</a>",
      "faq.eyebrow": "FAQ", "faq.h2": "Questions fréquentes",
      "q1": "cliPet ralentit-il mon Mac ?", "a1": "Non. C'est une app native Swift qui consomme moins de 50&nbsp;Mo de RAM et un CPU négligeable. Pas d'Electron, pas de navigateur caché.",
      "q2": "Mes données partent-elles quelque part ?", "a2": "Ton contenu reste sur ton Mac : aucun cloud, aucun compte, et l'historique du presse-papier ne quitte jamais ta machine. La seule chose que cliPet envoie, ce sont des stats d'usage anonymes et non personnelles (par ex. quels écrans tu ouvres) pour nous aider à l'améliorer.",
      "q3": "Compatible avec les Mac Intel ?", "a3": "Oui. cliPet tourne sur Apple Silicon (M1 et +) comme sur les Mac Intel, à partir de macOS&nbsp;13.",
      "q4": "Le chat gêne-t-il quand je travaille ?", "a4": "Il vit en bas de l'écran et ne capte pas tes clics. Tu peux le mettre en pause ou le cacher d'un clic depuis la barre de menus.",
      "q5": "Comment le désinstaller ?", "a5": "Glisse simplement l'app dans la corbeille. Aucun fichier système, aucun résidu.",
      "final.h2": "Prêt à adopter ton chat ?", "final.p": "Il t'attend déjà en bas de l'écran.",
      "footer.tagline": "Un chat pixel qui vit sur ton Mac.",
      "footer.product": "PRODUIT", "footer.legal": "LÉGAL",
      "footer.privacy": "Confidentialité", "footer.terms": "Mentions légales",
      "footer.copyright": "© 2026 cliPet · fait avec ❤ et beaucoup de pixels"
    },
    es: {
      "doc.title": "cliPet — un gato pixel que vive en tu Mac",
      "doc.desc": "cliPet: un compañero pixel-art nativo de macOS que pasea por la parte baja de tu pantalla, persigue tu cursor y guarda tu portapapeles. Ligero, local, adorable.",
      "nav.features": "Funciones", "nav.pricing": "Precio", "nav.faq": "FAQ", "nav.download": "Descargar",
      "hero.h1": "Un gato pixel que<br><span class=\"dyn\" id=\"dynWord\">vive en tu Mac</span>",
      "hero.lead": "Pasea por la parte baja de tu pantalla, duerme y <strong>persigue tu cursor</strong>. Nativo, ligerísimo, 100&nbsp;% local.",
      "hero.cta1": "Obtener cliPet", "hero.cta2": "Mira lo que sabe hacer",
      "stage.title": "cliPet — en directo en tu escritorio",
      "menu.file": "Archivo", "menu.edit": "Edición", "menu.window": "Ventana", "menu.help": "Ayuda",
      "notch.status": "ronronea · de buen humor", "notch.online": "en línea",
      "notch.clipboard": "Portapapeles", "notch.copied": "copiado · 2m",
      "notch.skin": "Skin activo", "notch.skins": "3 disponibles",
      "notch.sounds": "Sonidos retro", "notch.onstate": "on",
      "stage.hint": "↑ <span class=\"accent\">mueve el ratón</span> — te sigue. <span class=\"accent\">Haz clic</span> para abrir su portapapeles.",
      "clip.title": "PORTAPAPELES", "clip.history": "Historial", "clip.search": "Buscar…", "clip.shot": "Captura.png",
      "features.eyebrow": "Funciones", "features.h2": "Pequeño, pero muy vivo",
      "features.sub": "Todo lo que un compañero de escritorio debe hacer — y nada que te frene.",
      "f1.t": "En la barra de menús", "f1.d": "Sin ventanas, siempre ahí, nunca en medio. Un clic para ajustarlo todo.",
      "f2.t": "Animaciones pixel", "f2.d": "Camina, corre, se sienta, duerme, salta y parpadea. Hecho a mano, fotograma a fotograma.",
      "f3.t": "Persigue tu cursor", "f3.d": "Suelta el ovillo: lo persigue por la pantalla y se abalanza sobre él.",
      "f4.t": "Gestor de portapapeles", "f4.d": "Un portapapeles inteligente que detecta colores hex, muestra miniaturas de imágenes, rastrea rutas de archivos y guarda tus fotos en disco. Nada se pierde.",
      "f5.t": "Skins personalizables", "f5.d": "Cambia el pelaje y el estilo del gato. Varios skins incluidos, y más en camino.",
      "f6.t": "Editor de sprites", "f6.d": "Dibuja tus propias animaciones pixel dentro de la app. Tu gato, tus reglas.",
      "f7.t": "Captura todo", "f7.d": "Texto, imágenes, fotos, PDFs, archivos, colores hex — cada copia se guarda con una vista previa rica. Todo tu historial, buscable en un panel.",
      "f8.t": "100&nbsp;% nativo", "f8.d": "Swift y AppKit. Sin Electron, menos de 50&nbsp;MB de RAM. Rápido y discreto.",
      "f9.t": "Privacidad primero", "f9.d": "Sin nube, sin cuenta, sin datos personales. Tu portapapeles nunca sale de tu Mac — solo estadísticas de uso anónimas.",
      "pricing.eyebrow": "Precio", "pricing.h2": "Adóptalo hoy",
      "pricing.sub": "Una sola compra, tuyo para siempre. Actualizaciones incluidas.",
      "price.value": "4,99 €", "price.sub": "Pago único · actualizaciones de por vida",
      "check1": "El compañero pixel completo (pasear, dormir, perseguir)",
      "check2": "Gestor de portapapeles integrado",
      "check3": "Skins y editor de sprites",
      "check4": "Historial rico — textos, imágenes, archivos &amp; colores",
      "check5": "Swift nativo — menos de 50&nbsp;MB de RAM",
      "price.btn1": "Comprar en Gumroad", "price.btn2": "Comprar en Lemon Squeezy", "price.note": "¿Algún problema? <a href=\"mailto:sharikmohamed9@gmail.com?subject=cliPet%20Support\">Escríbenos</a>",
      "faq.eyebrow": "FAQ", "faq.h2": "Preguntas frecuentes",
      "q1": "¿cliPet ralentiza mi Mac?", "a1": "No. Es una app nativa en Swift que usa menos de 50&nbsp;MB de RAM y una CPU insignificante. Sin Electron, sin navegador oculto.",
      "q2": "¿Mis datos van a algún sitio?", "a2": "Tu contenido se queda en tu Mac: sin nube, sin cuenta, y el historial del portapapeles nunca sale de tu equipo. Lo único que cliPet envía son estadísticas de uso anónimas y no personales (como qué pantallas abres) para poder mejorarlo.",
      "q3": "¿Funciona en Macs Intel?", "a3": "Sí. cliPet funciona tanto en Apple Silicon (M1 y posteriores) como en Macs Intel, desde macOS&nbsp;13.",
      "q4": "¿El gato molesta mientras trabajo?", "a4": "Vive en la parte baja de la pantalla y no intercepta tus clics. Puedes pausarlo u ocultarlo con un clic desde la barra de menús.",
      "q5": "¿Cómo lo desinstalo?", "a5": "Solo arrastra la app a la papelera. Sin archivos de sistema, sin restos.",
      "final.h2": "¿Listo para adoptar tu gato?", "final.p": "Ya te espera en la parte baja de tu pantalla.",
      "footer.tagline": "Un gato pixel que vive en tu Mac.",
      "footer.product": "PRODUCTO", "footer.legal": "LEGAL",
      "footer.privacy": "Privacidad", "footer.terms": "Aviso legal",
      "footer.copyright": "© 2026 cliPet · hecho con ❤ y muchos píxeles"
    },
    de: {
      "doc.title": "cliPet — eine Pixel-Katze, die auf deinem Mac lebt",
      "doc.desc": "cliPet: ein nativer macOS-Pixel-Begleiter, der am unteren Bildschirmrand spaziert, deinem Cursor nachjagt und deine Zwischenablage verwaltet. Leicht, lokal, niedlich.",
      "nav.features": "Funktionen", "nav.pricing": "Preis", "nav.faq": "FAQ", "nav.download": "Laden",
      "hero.h1": "Deine Pixel-Katze<br><span class=\"dyn\" id=\"dynWord\">lebt auf deinem Mac</span>",
      "hero.lead": "Sie spaziert am unteren Bildschirmrand, schläft und <strong>jagt deinem Cursor nach</strong>. Nativ, federleicht, 100&nbsp;% lokal.",
      "hero.cta1": "cliPet holen", "hero.cta2": "Sieh, was sie kann",
      "stage.title": "cliPet — live auf deinem Schreibtisch",
      "menu.file": "Ablage", "menu.edit": "Bearbeiten", "menu.window": "Fenster", "menu.help": "Hilfe",
      "notch.status": "schnurrt · beste Laune", "notch.online": "online",
      "notch.clipboard": "Zwischenablage", "notch.copied": "kopiert · 2m",
      "notch.skin": "Aktiver Skin", "notch.skins": "3 verfügbar",
      "notch.sounds": "Retro-Sounds", "notch.onstate": "an",
      "stage.hint": "↑ <span class=\"accent\">beweg deine Maus</span> — sie folgt dir. <span class=\"accent\">Klick sie an</span>, um ihre Zwischenablage zu öffnen.",
      "clip.title": "ZWISCHENABLAGE", "clip.history": "Verlauf", "clip.search": "Suchen…", "clip.shot": "Bildschirmfoto.png",
      "features.eyebrow": "Funktionen", "features.h2": "Klein, aber quicklebendig",
      "features.sub": "Alles, was ein Schreibtisch-Begleiter können sollte — und nichts, was dich bremst.",
      "f1.t": "In der Menüleiste", "f1.d": "Kein Fenster, immer da, nie im Weg. Ein Klick für alle Einstellungen.",
      "f2.t": "Pixel-Animationen", "f2.d": "Sie läuft, rennt, sitzt, schläft, springt und blinzelt. Handgemacht, Bild für Bild.",
      "f3.t": "Jagt deinem Cursor nach", "f3.d": "Lass das Wollknäuel los: sie jagt es über den Bildschirm und springt darauf.",
      "f4.t": "Zwischenablage-Verlauf", "f4.d": "Eine smarte Zwischenablage, die Hex-Farben erkennt, Bildvorschauen anzeigt, Dateipfade verfolgt und Fotos auf die Festplatte speichert. Nichts geht verloren.",
      "f5.t": "Anpassbare Skins", "f5.d": "Ändere Fell und Stil der Katze. Mehrere Skins inklusive, weitere folgen.",
      "f6.t": "Sprite-Editor", "f6.d": "Zeichne deine eigenen Pixel-Animationen direkt in der App. Deine Katze, deine Regeln.",
      "f7.t": "Erfasst alles", "f7.d": "Text, Bilder, Fotos, PDFs, Dateien, Hex-Farben — jede Kopie wird mit einer detaillierten Vorschau gespeichert. Dein gesamter Verlauf, in einem Panel durchsuchbar.",
      "f8.t": "100&nbsp;% nativ", "f8.d": "Swift &amp; AppKit. Kein Electron, unter 50&nbsp;MB RAM. Schnell und unauffällig.",
      "f9.t": "Datenschutz zuerst", "f9.d": "Keine Cloud, kein Konto, keine personenbezogenen Daten. Deine Zwischenablage verlässt nie deinen Mac — nur anonyme Nutzungsstatistiken.",
      "pricing.eyebrow": "Preis", "pricing.h2": "Adoptiere sie heute",
      "pricing.sub": "Einmal kaufen, für immer deins. Updates inklusive.",
      "price.value": "4,99 €", "price.sub": "Einmalkauf · lebenslange Updates",
      "check1": "Der komplette Pixel-Begleiter (laufen, schlafen, jagen)",
      "check2": "Integrierter Zwischenablage-Verlauf",
      "check3": "Skins &amp; Sprite-Editor",
      "check4": "Reichhaltiger Verlauf — Texte, Bilder, Dateien &amp; Farben",
      "check5": "Nativ in Swift — unter 50&nbsp;MB RAM",
      "price.btn1": "Bei Gumroad kaufen", "price.btn2": "Bei Lemon Squeezy kaufen", "price.note": "Ein Problem? <a href=\"mailto:sharikmohamed9@gmail.com?subject=cliPet%20Support\">Schreib uns</a>",
      "faq.eyebrow": "FAQ", "faq.h2": "Häufige Fragen",
      "q1": "Verlangsamt cliPet meinen Mac?", "a1": "Nein. Eine native Swift-App mit unter 50&nbsp;MB RAM und vernachlässigbarer CPU-Last. Kein Electron, kein verstecktes Browserfenster.",
      "q2": "Gehen meine Daten irgendwohin?", "a2": "Deine Inhalte bleiben auf deinem Mac: keine Cloud, kein Konto, und der Verlauf der Zwischenablage verlässt nie dein Gerät. Das Einzige, was cliPet sendet, sind anonyme, nicht personenbezogene Nutzungsstatistiken (z. B. welche Bildschirme du öffnest), um es zu verbessern.",
      "q3": "Läuft es auf Intel-Macs?", "a3": "Ja. cliPet läuft auf Apple Silicon (M1 und neuer) ebenso wie auf Intel-Macs, ab macOS&nbsp;13.",
      "q4": "Stört die Katze beim Arbeiten?", "a4": "Sie lebt am unteren Bildschirmrand und fängt deine Klicks nicht ab. Du kannst sie mit einem Klick aus der Menüleiste pausieren oder ausblenden.",
      "q5": "Wie deinstalliere ich sie?", "a5": "Zieh die App einfach in den Papierkorb. Keine Systemdateien, keine Reste.",
      "final.h2": "Bereit, deine Katze zu adoptieren?", "final.p": "Sie wartet schon am unteren Rand deines Bildschirms.",
      "footer.tagline": "Eine Pixel-Katze, die auf deinem Mac lebt.",
      "footer.product": "PRODUKT", "footer.legal": "RECHTLICHES",
      "footer.privacy": "Datenschutz", "footer.terms": "Impressum",
      "footer.copyright": "© 2026 cliPet · mit ❤ und vielen Pixeln gemacht"
    },
    it: {
      "doc.title": "cliPet — un gatto pixel che vive sul tuo Mac",
      "doc.desc": "cliPet: un compagno pixel-art nativo per macOS che passeggia in fondo allo schermo, insegue il cursore e conserva i tuoi appunti. Leggero, locale, adorabile.",
      "nav.features": "Funzioni", "nav.pricing": "Prezzo", "nav.faq": "FAQ", "nav.download": "Scarica",
      "hero.h1": "Un gatto pixel che<br><span class=\"dyn\" id=\"dynWord\">vive sul tuo Mac</span>",
      "hero.lead": "Passeggia in fondo allo schermo, dorme e <strong>insegue il cursore</strong>. Nativo, leggerissimo, 100&nbsp;% locale.",
      "hero.cta1": "Ottieni cliPet", "hero.cta2": "Guarda cosa sa fare",
      "stage.title": "cliPet — dal vivo sulla tua scrivania",
      "menu.file": "File", "menu.edit": "Modifica", "menu.window": "Finestra", "menu.help": "Aiuto",
      "notch.status": "fa le fusa · umore al top", "notch.online": "online",
      "notch.clipboard": "Appunti", "notch.copied": "copiato · 2m",
      "notch.skin": "Skin attivo", "notch.skins": "3 disponibili",
      "notch.sounds": "Suoni retro", "notch.onstate": "on",
      "stage.hint": "↑ <span class=\"accent\">muovi il mouse</span> — ti segue. <span class=\"accent\">Cliccalo</span> per aprire i suoi appunti.",
      "clip.title": "APPUNTI", "clip.history": "Cronologia", "clip.search": "Cerca…", "clip.shot": "Schermata.png",
      "features.eyebrow": "Funzioni", "features.h2": "Piccolo, ma vivissimo",
      "features.sub": "Tutto ciò che un compagno da scrivania dovrebbe fare — e niente che ti rallenti.",
      "f1.t": "Nella barra dei menu", "f1.d": "Nessuna finestra, sempre lì, mai d'intralcio. Un clic per regolare tutto.",
      "f2.t": "Animazioni pixel", "f2.d": "Cammina, corre, si siede, dorme, balza e sbatte le palpebre. Fatto a mano, fotogramma per fotogramma.",
      "f3.t": "Insegue il cursore", "f3.d": "Lascia il gomitolo: lo insegue per lo schermo e ci si avventa sopra.",
      "f4.t": "Gestore appunti", "f4.d": "Una clipboard intelligente che rileva colori hex, mostra miniature di immagini, traccia percorsi file e salva le foto su disco. Niente sfugge.",
      "f5.t": "Skin personalizzabili", "f5.d": "Cambia il manto e lo stile del gatto. Diversi skin inclusi, altri in arrivo.",
      "f6.t": "Editor di sprite", "f6.d": "Disegna le tue animazioni pixel direttamente nell'app. Il tuo gatto, le tue regole.",
      "f7.t": "Cattura tutto", "f7.d": "Testo, immagini, foto, PDF, file, colori hex — ogni copia viene salvata con un'anteprima ricca. Tutta la tua cronologia, ricercabile in un pannello.",
      "f8.t": "100&nbsp;% nativo", "f8.d": "Swift &amp; AppKit. Niente Electron, meno di 50&nbsp;MB di RAM. Veloce e discreto.",
      "f9.t": "Privacy al primo posto", "f9.d": "Niente cloud, niente account, nessun dato personale. I tuoi appunti non lasciano mai il Mac — solo statistiche d'uso anonime.",
      "pricing.eyebrow": "Prezzo", "pricing.h2": "Adottalo oggi",
      "pricing.sub": "Un solo acquisto, tuo per sempre. Aggiornamenti inclusi.",
      "price.value": "4,99 €", "price.sub": "Acquisto unico · aggiornamenti a vita",
      "check1": "Il compagno pixel completo (cammina, dorme, insegue)",
      "check2": "Gestore appunti integrato",
      "check3": "Skin ed editor di sprite",
      "check4": "Cronologia ricca — testi, immagini, file &amp; colori",
      "check5": "Swift nativo — meno di 50&nbsp;MB di RAM",
      "price.btn1": "Acquista su Gumroad", "price.btn2": "Acquista su Lemon Squeezy", "price.note": "Un problema? <a href=\"mailto:sharikmohamed9@gmail.com?subject=cliPet%20Support\">Scrivici</a>",
      "faq.eyebrow": "FAQ", "faq.h2": "Domande frequenti",
      "q1": "cliPet rallenta il mio Mac?", "a1": "No. È un'app nativa in Swift che usa meno di 50&nbsp;MB di RAM e una CPU trascurabile. Niente Electron, nessun browser nascosto.",
      "q2": "I miei dati vanno da qualche parte?", "a2": "I tuoi contenuti restano sul Mac: niente cloud, niente account, e la cronologia degli appunti non lascia mai il tuo dispositivo. L'unica cosa che cliPet invia sono statistiche d'uso anonime e non personali (ad es. quali schermate apri) per poterlo migliorare.",
      "q3": "Funziona sui Mac Intel?", "a3": "Sì. cliPet gira su Apple Silicon (M1 e successivi) come sui Mac Intel, da macOS&nbsp;13 in poi.",
      "q4": "Il gatto dà fastidio mentre lavoro?", "a4": "Vive in fondo allo schermo e non intercetta i tuoi clic. Puoi metterlo in pausa o nasconderlo con un clic dalla barra dei menu.",
      "q5": "Come lo disinstallo?", "a5": "Trascina semplicemente l'app nel cestino. Nessun file di sistema, nessun residuo.",
      "final.h2": "Pronto ad adottare il tuo gatto?", "final.p": "Ti aspetta già in fondo allo schermo.",
      "footer.tagline": "Un gatto pixel che vive sul tuo Mac.",
      "footer.product": "PRODOTTO", "footer.legal": "LEGALE",
      "footer.privacy": "Privacy", "footer.terms": "Note legali",
      "footer.copyright": "© 2026 cliPet · fatto con ❤ e tanti pixel"
    },
    pt: {
      "doc.title": "cliPet — um gato pixel que vive no seu Mac",
      "doc.desc": "cliPet: um companheiro pixel-art nativo do macOS que passeia na base da sua tela, persegue o cursor e guarda a sua área de transferência. Leve, local, adorável.",
      "nav.features": "Funções", "nav.pricing": "Preço", "nav.faq": "FAQ", "nav.download": "Baixar",
      "hero.h1": "Um gato pixel que<br><span class=\"dyn\" id=\"dynWord\">vive no seu Mac</span>",
      "hero.lead": "Ele passeia na base da sua tela, dorme e <strong>persegue seu cursor</strong>. Nativo, leve como pluma, 100&nbsp;% local.",
      "hero.cta1": "Obter o cliPet", "hero.cta2": "Veja o que ele faz",
      "stage.title": "cliPet — ao vivo na sua área de trabalho",
      "menu.file": "Arquivo", "menu.edit": "Editar", "menu.window": "Janela", "menu.help": "Ajuda",
      "notch.status": "ronronando · de bom humor", "notch.online": "online",
      "notch.clipboard": "Transferência", "notch.copied": "copiado · 2m",
      "notch.skin": "Skin ativo", "notch.skins": "3 disponíveis",
      "notch.sounds": "Sons retrô", "notch.onstate": "on",
      "stage.hint": "↑ <span class=\"accent\">mexa o mouse</span> — ele segue você. <span class=\"accent\">Clique nele</span> para abrir sua área de transferência.",
      "clip.title": "TRANSFERÊNCIA", "clip.history": "Histórico", "clip.search": "Buscar…", "clip.shot": "Captura.png",
      "features.eyebrow": "Funções", "features.h2": "Pequeno, mas bem vivo",
      "features.sub": "Tudo o que um companheiro de mesa deve fazer — e nada que te atrase.",
      "f1.t": "Na barra de menus", "f1.d": "Sem janelas, sempre ali, nunca no caminho. Um clique para ajustar tudo.",
      "f2.t": "Animações pixel", "f2.d": "Ele anda, corre, senta, dorme, salta e pisca. Feito à mão, quadro a quadro.",
      "f3.t": "Persegue seu cursor", "f3.d": "Solte o novelo: ele persegue pela tela e dá o bote.",
      "f4.t": "Gerenciador de transferência", "f4.d": "Uma área de transferência inteligente que detecta cores hex, exibe miniaturas de imagens, rastreia caminhos de arquivo e salva fotos no disco. Nada passa despercebido.",
      "f5.t": "Skins personalizáveis", "f5.d": "Mude a pelagem e o estilo do gato. Vários skins inclusos, e mais a caminho.",
      "f6.t": "Editor de sprites", "f6.d": "Desenhe suas próprias animações pixel dentro do app. Seu gato, suas regras.",
      "f7.t": "Captura tudo", "f7.d": "Texto, imagens, fotos, PDFs, arquivos, cores hex — cada cópia é salva com uma prévia rica. Todo o seu histórico, pesquisável em um painel.",
      "f8.t": "100&nbsp;% nativo", "f8.d": "Swift &amp; AppKit. Sem Electron, menos de 50&nbsp;MB de RAM. Rápido e discreto.",
      "f9.t": "Privacidade primeiro", "f9.d": "Sem nuvem, sem conta, sem dados pessoais. A sua área de transferência nunca sai do Mac — apenas estatísticas de uso anônimas.",
      "pricing.eyebrow": "Preço", "pricing.h2": "Adote hoje",
      "pricing.sub": "Uma compra só, seu para sempre. Atualizações incluídas.",
      "price.value": "4,99 €", "price.sub": "Compra única · atualizações vitalícias",
      "check1": "O companheiro pixel completo (andar, dormir, perseguir)",
      "check2": "Gerenciador de área de transferência integrado",
      "check3": "Skins e editor de sprites",
      "check4": "Histórico rico — textos, imagens, arquivos &amp; cores",
      "check5": "Swift nativo — menos de 50&nbsp;MB de RAM",
      "price.btn1": "Comprar na Gumroad", "price.btn2": "Comprar na Lemon Squeezy", "price.note": "Algum problema? <a href=\"mailto:sharikmohamed9@gmail.com?subject=cliPet%20Support\">Fale conosco</a>",
      "faq.eyebrow": "FAQ", "faq.h2": "Perguntas frequentes",
      "q1": "O cliPet deixa meu Mac lento?", "a1": "Não. É um app nativo em Swift que usa menos de 50&nbsp;MB de RAM e CPU insignificante. Sem Electron, sem navegador escondido.",
      "q2": "Meus dados vão para algum lugar?", "a2": "O seu conteúdo fica no seu Mac: sem nuvem, sem conta, e o histórico da área de transferência nunca sai da sua máquina. A única coisa que o cliPet envia são estatísticas de uso anônimas e não pessoais (como quais telas você abre) para podermos melhorá-lo.",
      "q3": "Funciona em Macs Intel?", "a3": "Sim. O cliPet roda em Apple Silicon (M1 e superiores) e em Macs Intel, a partir do macOS&nbsp;13.",
      "q4": "O gato atrapalha enquanto eu trabalho?", "a4": "Ele vive na base da tela e não intercepta seus cliques. Você pode pausar ou ocultar com um clique pela barra de menus.",
      "q5": "Como desinstalo?", "a5": "Basta arrastar o app para a lixeira. Sem arquivos de sistema, sem sobras.",
      "final.h2": "Pronto para adotar seu gato?", "final.p": "Ele já espera na base da sua tela.",
      "footer.tagline": "Um gato pixel que vive no seu Mac.",
      "footer.product": "PRODUTO", "footer.legal": "LEGAL",
      "footer.privacy": "Privacidade", "footer.terms": "Aviso legal",
      "footer.copyright": "© 2026 cliPet · feito com ❤ e muitos pixels"
    }
  };

  // Langues disponibles (pour le menu déroulant)
  var LANGS = [
    { code: "en", label: "English" },
    { code: "fr", label: "Français" },
    { code: "es", label: "Español" },
    { code: "de", label: "Deutsch" },
    { code: "it", label: "Italiano" },
    { code: "pt", label: "Português" }
  ];

  // Verbes du titre dynamique (façon Vibe Island, par langue)
  // Phrases dynamiques (verbe) mettant en avant les capacités : pet + presse-papier
  var DYN = {
    en: ["lives on your Mac", "chases your cursor", "previews hex colors", "previews images", "keeps your images", "saves what you copy"],
    fr: ["vit sur ton Mac", "chasse ton curseur", "affiche les codes hex", "affiche tes images", "garde tes images", "retient tes copies"],
    es: ["vive en tu Mac", "persigue tu cursor", "muestra colores hex", "muestra tus imágenes", "guarda tus imágenes", "recuerda lo copiado"],
    de: ["lebt auf deinem Mac", "jagt deinem Cursor", "zeigt Hex-Farben", "zeigt deine Bilder", "behält deine Bilder", "merkt sich Kopiertes"],
    it: ["vive sul tuo Mac", "insegue il cursore", "mostra i colori hex", "mostra le immagini", "conserva le immagini", "ricorda ciò che copi"],
    pt: ["vive no seu Mac", "persegue seu cursor", "mostra cores hex", "mostra suas imagens", "guarda suas imagens", "lembra o que copia"]
  };
  var dynTimer = null;
  function startDynamic(lang) {
    var el = document.getElementById("dynWord");
    if (!el) return;
    if (dynTimer) clearInterval(dynTimer);
    var words = DYN[lang] || DYN.en;
    var i = 0;
    el.textContent = words[0];
    dynTimer = setInterval(function () {
      el.classList.add("swap");
      setTimeout(function () {
        i = (i + 1) % words.length;
        el.textContent = words[i];
        el.classList.remove("swap");
      }, 420);
    }, 4200);
  }

  (function () {
    // Snapshot EN depuis le HTML (langue principale) -> sert de base + fallback
    var EN = {};
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      EN[el.getAttribute("data-i18n")] = el.innerHTML;
    });
    EN["doc.title"] = document.title;
    var meta = document.querySelector('meta[name="description"]');
    EN["doc.desc"] = meta ? meta.content : "";
    I18N.en = EN;

    // ============ Prix localisé — base 4,99 €, converti selon la device ============
    // Prix arrondis « façon store » (pas de conversion FX brute), calés sur ~4,99 €.
    var PRICES = {
      USD: "$4.99", EUR: "4,99 €", GBP: "£4.49", CHF: "CHF 4.90",
      CAD: "CA$6.99", AUD: "A$7.99", JPY: "¥700", CNY: "¥35",
      INR: "₹399", BRL: "R$24,90", MXN: "$99", RUB: "499 ₽",
      KRW: "₩6,500", SAR: "ر.س 18.99", AED: "د.إ 18.99"
    };
    // Région (depuis la locale) → devise.
    var REGION_CCY = {
      US: "USD", GB: "GBP", CH: "CHF", CA: "CAD", AU: "AUD", NZ: "AUD",
      JP: "JPY", CN: "CNY", TW: "CNY", HK: "CNY", IN: "INR", BR: "BRL",
      MX: "MXN", RU: "RUB", KR: "KRW", SA: "SAR", AE: "AED"
    };
    var EUROZONE = "FR DE ES IT PT NL BE AT IE FI GR LU SK SI LT LV EE CY MT";
    function userPrice() {
      var loc = (navigator.language || navigator.userLanguage || "en-US");
      var region = (loc.split("-")[1] || "").toUpperCase();
      var ccy = REGION_CCY[region];
      if (!ccy) {
        if (EUROZONE.indexOf(region) >= 0) ccy = "EUR";
        else ccy = (loc.slice(0, 2).toLowerCase() === "en") ? "USD" : "EUR";
      }
      return PRICES[ccy] || PRICES.USD;
    }
    function applyPrice() {
      var p = userPrice();
      document.querySelectorAll("[data-price]").forEach(function (el) { el.textContent = p; });
    }

    function setLang(lang) {
      if (!I18N[lang]) lang = "en";
      var dict = I18N[lang];
      document.documentElement.lang = lang;
      document.querySelectorAll("[data-i18n]").forEach(function (el) {
        var k = el.getAttribute("data-i18n");
        if (dict[k] != null) el.innerHTML = dict[k];
      });
      applyPrice();   // garde le prix localisé (jamais « gratuit »)
      if (dict["doc.title"]) document.title = dict["doc.title"];
      if (meta && dict["doc.desc"]) meta.content = dict["doc.desc"];
      try { localStorage.setItem("clipet-lang", lang); } catch (e) {}
      // met à jour le déclencheur + l'état actif du menu
      var cur = document.getElementById("langCur");
      if (cur) cur.textContent = lang.toUpperCase();
      var menu = document.getElementById("langMenu");
      if (menu) menu.querySelectorAll("li").forEach(function (li) {
        li.setAttribute("aria-selected", li.dataset.code === lang ? "true" : "false");
      });
      startDynamic(lang);              // relance le mot dynamique du titre
    }

    // — construit le menu déroulant de langues —
    var menu = document.getElementById("langMenu");
    if (menu) {
      LANGS.forEach(function (l) {
        var li = document.createElement("li");
        li.textContent = l.label;
        li.dataset.code = l.code;
        li.setAttribute("role", "option");
        li.addEventListener("click", function () {
          setLang(l.code);
          closeMenu();
        });
        menu.appendChild(li);
      });
    }
    var langWrap = document.getElementById("lang");
    var langBtn = document.getElementById("langBtn");
    function openMenu() { if (langWrap) { langWrap.classList.add("open"); langBtn.setAttribute("aria-expanded", "true"); } }
    function closeMenu() { if (langWrap) { langWrap.classList.remove("open"); langBtn.setAttribute("aria-expanded", "false"); } }
    if (langBtn) langBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      langWrap.classList.contains("open") ? closeMenu() : openMenu();
    });
    document.addEventListener("click", function (e) {
      if (langWrap && !langWrap.contains(e.target)) closeMenu();
    });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeMenu(); });

    // — détection : choix sauvegardé > langue du navigateur > anglais —
    var saved = null;
    try { saved = localStorage.getItem("clipet-lang"); } catch (e) {}
    var navLang = (navigator.language || navigator.userLanguage || "en").slice(0, 2).toLowerCase();
    var available = LANGS.map(function (l) { return l.code; });
    var lang = (saved && available.indexOf(saved) >= 0) ? saved
      : (available.indexOf(navLang) >= 0 ? navLang : "en");
    setLang(lang);
  })();

  // ============ Navbar intégrée : fond/flou seulement au scroll ============
  (function () {
    var nav = document.querySelector(".nav");
    if (!nav) return;
    function onScroll() {
      if (window.scrollY > 24) nav.classList.add("scrolled");
      else nav.classList.remove("scrolled");
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
  })();

  // ============ Fond interactif : suit le curseur ============
  (function () {
    var root = document.documentElement;
    var raf = null, mx = -500, my = -500;
    function apply() {
      root.style.setProperty("--mx", mx + "px");
      root.style.setProperty("--my", my + "px");
      raf = null;
    }
    window.addEventListener("pointermove", function (e) {
      mx = e.clientX; my = e.clientY;
      if (!raf) raf = requestAnimationFrame(apply);
    }, { passive: true });
  })();

  // ============ FAQ accordéon (un seul ouvert à la fois) ============
  var qas = document.querySelectorAll(".qa");
  qas.forEach(function (d) {
    var btn = d.querySelector("button");
    if (!btn) return;
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      var willOpen = !d.open;
      qas.forEach(function (o) { o.open = false; });
      d.open = willOpen;
    });
  });

  // ============ Scroll reveal ============
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add("in"); io.unobserve(en.target); }
      });
    }, { threshold: 0.12 });
    document.querySelectorAll(".reveal").forEach(function (el) { io.observe(el); });
  } else {
    document.querySelectorAll(".reveal").forEach(function (el) { el.classList.add("in"); });
  }
})();

var SPRITES = {"idle":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"walk1":["..........................XX.....",".........................XXXX....","........................XXXXX....",".....XXX...............XXXXXXX...","....XgggXXXXXg.....XXXXXXXXXXX...","....XgggXXXXXXXXXXXXXXXXXXXXXX...","...XgXggXXXXXXXXXgXXXXgXXXXXXX...","...XggXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwwwX..wgX..ggwwwwg..XwwgwX.....","..XXX...XX...gXgwwwwX.XggwwX.....","........XX....gXwggwX..XXXX......","..............gXggwXX............","...............gXXX..............","................................."],"walk2":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"walk3":["..........................XX.....",".........................XXXX....","........................XXXXX....","...XXX.................XXXXXXX...","..XgggXX.XXXXg.....XXXXXXXXXXX...","..XgggXX.XXXXXXXXXXXXXXXXXXXXX...",".XgXggXX.XXXXXXXXgXXXXgXXXXXXX...",".XggXXXX.XXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXw..XwwgwX.....",".XXXXXggwwwgggggXXXwX.XggwwX.....",".XgXggggwwwwggggggXXX..XXXX......",".XwggggwwgX..ggwwwwgX............",".XwwwwgXXX...gXgwwww.............",".XwwwwXXXX....gXwggw.............",".XwwwX........gXggwX.............","..XXX..........gXXX..............","................................."],"walk4":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"sit":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"sleep":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"play":["..........................XX.....",".........................XXXX....","........................XXXXX....","....XXX................XXXXXXX...","...XgggXXXXXXg.....XXXXXXXXXXX...","...XgggXXXXXXXXXXXXXXXXXXXXXXX...","..XgXggXXXXXXXXXXgXXXXgXXXXXXX...","..XggXXXXXXXXXXXXXgXXgggXgXXXX...",".XXgggXXXXppXXXXXXggXXggXggXXX...",".XgXXXXXXXprpXXXXXgggXggggggXX...",".XXggXXXXXprrppXXggggggggggXXX...",".XgXXXXXXXXprppXXgggggggggXXXX...",".XXggXXXXXXXpXXXXgggggggggXXgX...",".XXXXXXXXXXXXXXgggXXXgggggwXwX...",".XXgggXXXXXXXXgggXXXXXgwwgXXwXXX.",".XggXXXXXXXXXggggXgXXXgwwwXXwwX..","..XXXXXXgXXgggggwgwwXXgwwwwwXXXX.","..XXXXXXXgXXXXXgwwwXXXwwggwwwX...","...XXXXXggXXgggXXgwXXwwwXXwwgX...","...XgXXggXgggggwwwwwwwwwwwwgX....","..XXgXggXXgggggXXXXwwwwwwwgX.....","..XXggggXXggggggXXwwwwwwXXX......","..XXggggXgggXggggggggggXX........","..XXXgggXgggXggXXgggwgXXgX.......",".XXXXgggXggggggXXXXwwXgggXX......",".XXXXXggwwwgggggXXXwgXwwwwXX.....",".XgXggggwwwwggggggXXXXwwwwwX.....",".XwggggwwgXXXgggwgwX..XwwgwX.....",".XwwwwgXXX...ggwwwwgX.XggwwX.....",".XwwwwXXXX...gXgwwwwX..XXXX......",".XwwwX........gXwggwX............","..XXX.........gXggwX.............","...............gXXX.............."],"yarn1":[".....XXXXXXX","...XXppXXXXX","..XppXpppXXX",".XprppppppXX",".XppppXpppXX","XppppppppppX","XpXpXpXpXpXX","XXppppppppXX","XXppppXpppXX","XXXppppppXXX","XXXXXpXXXXXX","XXXXXXXXXXXX"],"yarn2":[".....XXXXXXX","...XXppXXXXX","..XppppXpXXX",".XprpppXppXX",".XXXppXpppXX","XpppXXXppppX","XppppXXXpppX","XXpppXppXXXX","XXppXpppppXX","XXXpXppppXXX","XXXXXppXXXXX","XXXXXXXXXXXX"],"yarn3":[".....XXXXXXX","...XXppXXXXX","..XppppppXXX",".XprppppXpXX",".XppXppXppXX","XppppXXppppX","XppppXXppppX","XXppXppXppXX","XXpXppppXpXX","XXXppppppXXX","XXXXXppXXXXX","XXXXXXXXXXXX"],"yarn4":[".....XXXXXXX","...XXppXXXXX","..XpXppppXXX",".XprXpppppXX",".XpppXppXXXX","XppppXXXpppX","XpppXXXppppX","XXXXppXpppXX","XXpppppXppXX","XXXppppXpXXX","XXXXXppXXXXX","XXXXXXXXXXXX"]};

/* cliPet — moteur pixel (canvas) : chat qui suit le curseur, icônes, FAQ */
(function () {
  "use strict";

  // Palette des sprites du chat (depuis gen_sprites.py)
  var CAT = { ".": null, "X": "#2b2622", "g": "#a2a3a6", "w": "#f3f1ea", "p": "#d94f4f", "r": "#e0833f" };

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
    speaker: ["....##...","...###.#.","..####..#","####.#.#.","####.#.#.","..####..#","...###.#.","....##...","........."],
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

  function runPlayground(cv) {
    var ctx = cv.getContext("2d");
    var SC = 9;                              // taille d'un pixel
    var catW = SPRITES.idle[0].length * SC;  // 33*9
    var catH = SPRITES.idle.length * SC;
    var yarnFrames = [SPRITES.yarn1, SPRITES.yarn2, SPRITES.yarn3, SPRITES.yarn4];
    var walkFrames = [SPRITES.walk1, SPRITES.walk2, SPRITES.walk3, SPRITES.walk4];
    var floorY = cv.height - catH - 14;

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

    function frame(now) {
      var t = now - t0;

      // auto-balade quand pas de souris
      if (!pointerActive && t > wanderNext) {
        target = 60 + Math.random() * (cv.width - 120);
        wanderNext = t + 2200 + Math.random() * 2600;
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

      // pelote (= curseur) quand la souris est dans le cadre
      if (pointerActive) {
        var yf = yarnFrames[Math.floor(t / 90) % 4];
        var yS = 6, yW = yf[0].length * yS;
        drawGrid(ctx, yf, CAT, yS,
          Math.round(target - yW / 2),
          Math.round(Math.min(floorY + catH - yW, targetY - yW / 2)));
      }

      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  }

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

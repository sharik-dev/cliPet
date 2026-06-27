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

  // ============ i18n — EN par défaut, FR auto-détecté ============
  // (EN est dans le HTML ; on ne stocke ici que les traductions.)
  var I18N = {
    fr: {
      "doc.title": "cliPet — un chat pixel qui vit sur ton Mac",
      "doc.desc": "cliPet : un compagnon pixel-art natif macOS qui se balade en bas de ton écran, chasse ton curseur et garde ton presse-papier. Léger, local, adorable.",
      "nav.features": "Fonctionnalités", "nav.pricing": "Tarif", "nav.faq": "FAQ", "nav.download": "Télécharger",
      "hero.h1": "Un chat pixel<br>qui vit sur ton Mac",
      "hero.lead": "Il se balade en bas de ton écran, dort, et <strong>chasse ton curseur</strong>. Natif, ultra-léger, 100&nbsp;% local.",
      "hero.cta1": "Télécharger gratuitement", "hero.cta2": "Voir ce qu'il sait faire",
      "stage.title": "cliPet — en direct sur ton bureau",
      "menu.file": "Fichier", "menu.edit": "Édition", "menu.window": "Fenêtre", "menu.help": "Aide",
      "notch.status": "ronronne · humeur au top", "notch.online": "en ligne",
      "notch.clipboard": "Presse-papier", "notch.copied": "copié · 2m",
      "notch.skin": "Skin actif", "notch.skins": "3 dispo",
      "notch.sounds": "Sons rétro", "notch.onstate": "on",
      "stage.hint": "↑ <span class=\"accent\">bouge ta souris</span> dans le cadre — il te suit pour de vrai",
      "features.eyebrow": "Fonctionnalités", "features.h2": "Petit, mais bien vivant",
      "features.sub": "Tout ce qu'un compagnon de bureau doit savoir faire — et rien qui te ralentisse.",
      "f1.t": "Dans la barre de menus", "f1.d": "Zéro fenêtre, toujours là, jamais dans le chemin. Un clic pour tout régler.",
      "f2.t": "Animations pixel", "f2.d": "Il marche, court, s'assoit, dort, bondit et cligne des yeux. Fait main, image par image.",
      "f3.t": "Chasse le curseur", "f3.d": "Lâche la pelote : il la poursuit à travers l'écran et lui saute dessus.",
      "f4.t": "Presse-papier", "f4.d": "Historique de ton clipboard intégré, accessible d'un seul clic. Pratique au quotidien.",
      "f5.t": "Skins personnalisables", "f5.d": "Change la robe et le style du chat. Plusieurs skins inclus, d'autres à venir.",
      "f6.t": "Éditeur de sprites", "f6.d": "Dessine tes propres animations pixel directement dans l'app. Ton chat, tes règles.",
      "f7.t": "Sons rétro", "f7.d": "De petits bruitages 8-bit pour chaque action. Désactivables quand tu veux le calme.",
      "f8.t": "100&nbsp;% natif", "f8.d": "Swift &amp; AppKit. Pas d'Electron, moins de 50&nbsp;Mo de RAM. Rapide et discret.",
      "f9.t": "Tout reste local", "f9.d": "Aucun cloud, aucun compte, aucune télémétrie. Ce qui se passe sur ton Mac y reste.",
      "pricing.eyebrow": "Tarif", "pricing.h2": "Adopte-le aujourd'hui",
      "pricing.sub": "Un seul achat, à toi pour toujours. Mises à jour comprises.",
      "price.value": "Gratuit", "price.sub": "pendant le lancement — bientôt payant",
      "check1": "Le compagnon pixel complet (marche, sommeil, chasse)",
      "check2": "Gestionnaire de presse-papier intégré",
      "check3": "Skins &amp; éditeur de sprites",
      "check4": "Sons rétro 8-bit",
      "check5": "Natif Swift — moins de 50&nbsp;Mo de RAM",
      "price.btn": "Télécharger pour macOS", "price.note": "Un souci ? <a href=\"#\">Écris-nous</a>",
      "faq.eyebrow": "FAQ", "faq.h2": "Questions fréquentes",
      "q1": "cliPet ralentit-il mon Mac ?", "a1": "Non. C'est une app native Swift qui consomme moins de 50&nbsp;Mo de RAM et un CPU négligeable. Pas d'Electron, pas de navigateur caché.",
      "q2": "Mes données partent-elles quelque part ?", "a2": "Jamais. Tout reste sur ta machine : aucun cloud, aucun compte, aucune télémétrie. L'historique du presse-papier ne quitte pas ton Mac.",
      "q3": "Compatible avec les Mac Intel ?", "a3": "Oui. cliPet tourne sur Apple Silicon (M1 et +) comme sur les Mac Intel, à partir de macOS&nbsp;13.",
      "q4": "Le chat gêne-t-il quand je travaille ?", "a4": "Il vit en bas de l'écran et ne capte pas tes clics. Tu peux le mettre en pause ou le cacher d'un clic depuis la barre de menus.",
      "q5": "Comment le désinstaller ?", "a5": "Glisse simplement l'app dans la corbeille. Aucun fichier système, aucun résidu.",
      "final.h2": "Prêt à adopter ton chat ?", "final.p": "Il t'attend déjà en bas de l'écran.",
      "footer.tagline": "Un chat pixel qui vit sur ton Mac.",
      "footer.product": "PRODUIT", "footer.legal": "LÉGAL",
      "footer.privacy": "Confidentialité", "footer.terms": "Mentions légales",
      "footer.copyright": "© 2026 cliPet · fait avec ❤ et beaucoup de pixels"
    }
  };

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

    function setLang(lang) {
      if (!I18N[lang]) lang = "en";
      var dict = I18N[lang];
      document.documentElement.lang = lang;
      document.querySelectorAll("[data-i18n]").forEach(function (el) {
        var k = el.getAttribute("data-i18n");
        if (dict[k] != null) el.innerHTML = dict[k];
      });
      if (dict["doc.title"]) document.title = dict["doc.title"];
      if (meta && dict["doc.desc"]) meta.content = dict["doc.desc"];
      try { localStorage.setItem("clipet-lang", lang); } catch (e) {}
      var t = document.getElementById("langToggle");
      if (t) t.textContent = lang === "fr" ? "EN" : "FR";
    }

    var saved = null;
    try { saved = localStorage.getItem("clipet-lang"); } catch (e) {}
    var nav = (navigator.language || navigator.userLanguage || "en").toLowerCase();
    var lang = saved || (nav.indexOf("fr") === 0 ? "fr" : "en");
    setLang(lang);

    var toggle = document.getElementById("langToggle");
    if (toggle) toggle.addEventListener("click", function () {
      setLang(document.documentElement.lang === "fr" ? "en" : "fr");
    });
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

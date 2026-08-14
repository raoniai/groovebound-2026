(() => {
  "use strict";

  const body = document.body;
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const loader = document.querySelector("[data-loader]");
  const header = document.querySelector("[data-header]");
  const allVideos = () => [...document.querySelectorAll("video")];
  const fileSlug = (value) => String(value).toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
  const titleFromFile = (value) => String(value).replace(/-/g, " ").replace(/\b\w/g, (letter) => letter.toUpperCase());

  if (body.dataset.page === "home") {
    const main = document.querySelector("main");
    const moduleOrder = [
      ".hero",
      ".game-trailer",
      "#resonants",
      "#story",
      "#world-tour",
      ".current-build",
      ".fusion-lab",
      "#arsenal",
      ".remix",
      ".signal-strip",
      ".download-stage"
    ];
    if (main) moduleOrder.forEach((selector) => {
      const module = main.querySelector(selector);
      if (module) main.append(module);
    });
    if (window.location.hash) {
      const restoreHashPosition = () => {
        const target = document.querySelector(window.location.hash);
        if (!target) return;
        const headerOffset = header?.getBoundingClientRect().height || 0;
        window.scrollTo({ top: target.getBoundingClientRect().top + window.scrollY - headerOffset, behavior: "instant" });
      };
      window.requestAnimationFrame(restoreHashPosition);
      window.addEventListener("load", () => {
        [180, 650, 1300].forEach((delay) => window.setTimeout(restoreHashPosition, delay));
        document.fonts?.ready.then(restoreHashPosition);
      }, { once: true });
    }
  }
  document.querySelectorAll("[data-frame-sequence]").forEach((element) => {
    const count = Math.max(1, Number(element.dataset.frameCount || 1));
    for (let index = 1; index <= count; index += 1) {
      const image = document.createElement("img");
      image.src = `${element.dataset.frameSequence}-${String(index).padStart(2, "0")}.png`;
      image.alt = "";
      image.decoding = "async";
      image.style.setProperty("--frame-index", String(index - 1));
      element.append(image);
    }
  });
  const numberedFiles = (prefix, count) => Array.from({ length: count }, (_, index) => `${prefix}-${String(index + 1).padStart(2, "0")}`);
  const collection = (root, files) => ({ root: `assets/world-tour/sprites/${root}`, files });
  const spriteCollections = {
    "backbeat-environments": collection("environments/backbeat/base", numberedFiles("base", 8)),
    "backbeat-expansions": collection("environments/backbeat/expansion", numberedFiles("expansion", 8)),
    "orbit-environments": collection("environments/orbit/base", numberedFiles("base", 8)),
    "orbit-expansions": collection("environments/orbit/expansion", numberedFiles("expansion", 8)),
    "funk-environments": collection("environments/funk", ["boombox-barricade", "record-kiosk", "amp-wall", "turntable-console", "disco-palm", "talkbox-streetlight", "vinyl-stack", "hologram-dancer"]),
    "soul-environments": collection("environments/soul", numberedFiles("prop", 8)),
    "disco-environments": collection("environments/disco", numberedFiles("prop", 8)),
    "jazz-environments": collection("environments/jazz", numberedFiles("prop", 8)),
    "backbeat-floors": collection("floors/backbeat", numberedFiles("surface", 4)),
    "orbit-floors": collection("floors/orbit", numberedFiles("surface", 4)),
    "funk-enemies": collection("enemies/funk", ["pocket-gremlin", "slapback-hound", "groove-guard", "talkbox-oracle", "boogie-tank", "funkadelic-wasp", "mothership-of-funk", "pocket-phantom"]),
    "soul-enemies": collection("enemies/soul", ["choir-automaton", "string-sentinel", "organ-walker", "harmony-linker", "gospel-moth", "velvet-knight", "organ-colossus", "velvet-titan"]),
    "disco-enemies": collection("enemies/disco", ["prism-roller", "mirror-drone", "laser-fan", "reflection-twin", "platform-pouncer", "glitter-guard", "laser-conductor", "prism-monarch"]),
    "jazz-enemies": collection("enemies/jazz", ["syncopated-imp", "blue-note-bat", "walking-bass-bot", "scat-cannon", "bebop-behemoth", "brushfire-skitter", "brass-regent", "midnight-maestro"]),
    "funk-floors": collection("floors/funk", numberedFiles("surface", 4)),
    "soul-floors": collection("floors/soul", numberedFiles("surface", 4)),
    "disco-floors": collection("floors/disco", numberedFiles("surface", 4)),
    "jazz-floors": collection("floors/jazz", numberedFiles("surface", 4)),
    "world-mechanics": collection("mechanics", ["funk-pocket-05", "disco-spotlight-05"]),
    "world-tour-ui": collection("ui/world-tour", ["campaign", "funk", "soul", "locked-world", "portal", "grade-d", "grade-c", "grade-b", "grade-a", "grade-s"]),
    "world-interface": collection("ui/interface", ["global-tour", "funk", "soul", "disco", "perk-database", "remix", "encore-gate", "world-route", "encore-coin", "mastery"]),
    "menu-icons": collection("ui/menu", ["continue", "new-game", "world-tour", "settings", "quit", "equalizer-divider", "reset-campaign", "reset-warning", "reset-confirm", "reserved"]),
    evolutions: collection("evolutions", ["prismatic-triangle", "velvet-impaler", "carnival-superorbit", "resonance-rupture", "stadium-keytar", "cathedral-overdrive", "infinite-mixtape", "aurora-harp"]),
    perks: collection("perks", ["open-ears", "pocket-drive", "breakstep", "warm-current", "velvet-guard", "mirrorball-tips", "spotlight-spin", "four-count", "floor-control", "live-wire", "signal-boost", "precision-loop", "hard-reset", "orbital-balance", "encore-spark", "deep-reserve", "afterglow", "neon-dividend", "first-drop"]),
    "musical-chest": collection("chests/musical", ["frame-08"]),
    "chest-luck": collection("chests/luck", [...numberedFiles("luck", 5), ...numberedFiles("reward-backplate", 5)]),
    completion: collection("chests/completion", ["backbeat-complete", "orbit-complete", "campaign-victory", "funk-mastery", "encore-chest", "resonance", "enemy", "boss"]),
    "funk-pocket": collection("mechanics/funk-pocket", numberedFiles("pad", 5))
  };
  document.querySelectorAll("[data-sprite-collection]").forEach((element) => {
    const set = spriteCollections[element.dataset.spriteCollection];
    if (!set) return;
    set.files.forEach((file) => {
      const image = document.createElement("img");
      image.src = `${set.root}/${file}.png`;
      image.alt = file.replace(/-/g, " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
      image.loading = "lazy";
      image.decoding = "async";
      element.append(image);
    });
  });

  body.classList.add("is-loading");
  const finishLoading = () => {
    body.classList.remove("is-loading");
    loader?.classList.add("is-hidden");
  };
  window.addEventListener("load", () => window.setTimeout(finishLoading, 180), { once: true });
  window.setTimeout(finishLoading, 900);

  const menuToggle = document.querySelector(".menu-toggle");
  menuToggle?.addEventListener("click", () => {
    const open = header?.classList.toggle("menu-open");
    menuToggle.setAttribute("aria-expanded", String(Boolean(open)));
    menuToggle.textContent = open ? "Close" : "Menu";
  });
  document.querySelectorAll(".site-nav a").forEach((link) => link.addEventListener("click", () => {
    header?.classList.remove("menu-open");
    menuToggle?.setAttribute("aria-expanded", "false");
    if (menuToggle) menuToggle.textContent = "Menu";
  }));

  const firstSection = document.querySelector("main > section");
  if (firstSection && header) {
    const headerObserver = new IntersectionObserver(([entry]) => header.classList.toggle("is-scrolled", !entry.isIntersecting), { rootMargin: "-68px 0px 0px", threshold: 0.04 });
    headerObserver.observe(firstSection);
  }

  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.classList.add("is-visible");
      revealObserver.unobserve(entry.target);
    });
  }, { threshold: 0.12, rootMargin: "0px 0px -5%" });
  const observeReveal = (element) => {
    if (element.matches(".reveal:not(.is-visible)")) revealObserver.observe(element);
  };
  document.querySelectorAll(".reveal:not(.is-visible)").forEach(observeReveal);

  const worldShowcase = document.querySelector("[data-world-showcase]");
  if (worldShowcase) {
    const tabs = [...worldShowcase.querySelectorAll("[data-world-tab]")];
    const panels = [...worldShowcase.querySelectorAll("[data-world-panel]")];
    const selectWorld = (world, focus = false) => {
      tabs.forEach((tab) => {
        const active = tab.dataset.worldTab === world;
        tab.classList.toggle("is-active", active);
        tab.setAttribute("aria-selected", String(active));
        tab.tabIndex = active ? 0 : -1;
        if (active && focus) tab.focus();
      });
      panels.forEach((panel) => {
        const active = panel.dataset.worldPanel === world;
        panel.hidden = !active;
        panel.classList.toggle("is-active", active);
      });
    };
    tabs.forEach((tab, index) => {
      tab.addEventListener("click", () => selectWorld(tab.dataset.worldTab));
      tab.addEventListener("keydown", (event) => {
        if (event.key !== "ArrowLeft" && event.key !== "ArrowRight" && event.key !== "Home" && event.key !== "End") return;
        event.preventDefault();
        const nextIndex = event.key === "Home" ? 0 : event.key === "End" ? tabs.length - 1 :
          (index + (event.key === "ArrowRight" ? 1 : -1) + tabs.length) % tabs.length;
        selectWorld(tabs[nextIndex].dataset.worldTab, true);
      });
    });
    selectWorld(tabs.find((tab) => tab.classList.contains("is-active"))?.dataset.worldTab || "funk");
  }

  const prologueShowcase = document.querySelector("[data-prologue-showcase]");
  if (prologueShowcase) {
    const tabs = [...document.querySelectorAll("[data-prologue-tab]")];
    const panels = [...prologueShowcase.querySelectorAll("[data-prologue-panel]")];
    const selectPrologueStage = (stage, focus = false) => {
      tabs.forEach((tab) => {
        const active = tab.dataset.prologueTab === stage;
        tab.classList.toggle("is-active", active);
        tab.setAttribute("aria-selected", String(active));
        tab.tabIndex = active ? 0 : -1;
        if (active && focus) tab.focus();
      });
      panels.forEach((panel) => {
        const active = panel.dataset.prologuePanel === stage;
        panel.hidden = !active;
        panel.classList.toggle("is-active", active);
        if (!active) panel.querySelectorAll("video").forEach((video) => video.pause());
      });
    };
    tabs.forEach((tab, index) => {
      tab.addEventListener("click", () => selectPrologueStage(tab.dataset.prologueTab));
      tab.addEventListener("keydown", (event) => {
        if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return;
        event.preventDefault();
        const nextIndex = event.key === "Home" ? 0 : event.key === "End" ? tabs.length - 1 :
          (index + (event.key === "ArrowRight" ? 1 : -1) + tabs.length) % tabs.length;
        selectPrologueStage(tabs[nextIndex].dataset.prologueTab, true);
      });
    });
    selectPrologueStage(tabs.find((tab) => tab.classList.contains("is-active"))?.dataset.prologueTab || "backbeat");
  }

  const setMediaLabel = (video, playingSound) => {
    document.querySelectorAll(`[data-video-sound="#${video.id}"]`).forEach((control) => {
      control.setAttribute("aria-pressed", String(playingSound));
      const label = playingSound ? "Mute scene" : "Unmute scene";
      control.setAttribute("aria-label", label);
      control.setAttribute("title", label);
      const icon = control.querySelector("[data-sound-icon]");
      if (icon) {
        icon.classList.toggle("is-playing", playingSound);
        icon.classList.toggle("is-muted", !playingSound);
        const glyph = icon.querySelector("[data-sound-glyph]");
        if (glyph) glyph.src = playingSound ? "assets/icons/sound-on.png" : "assets/icons/sound-off.png";
      }
    });
  };

  const muteOtherMedia = (activeVideo) => {
    allVideos().forEach((video) => {
      if (video === activeVideo) return;
      video.muted = true;
      setMediaLabel(video, false);
    });
    const audio = document.querySelector("[data-audio]");
    if (audio && !audio.paused) audio.pause();
  };

  document.querySelectorAll("[data-video-sound]").forEach((control) => {
    control.addEventListener("click", async () => {
      const video = document.querySelector(control.dataset.videoSound);
      if (!(video instanceof HTMLVideoElement)) return;
      const willUnmute = video.muted;
      if (willUnmute) muteOtherMedia(video);
      video.muted = !willUnmute;
      try {
        await video.play();
        setMediaLabel(video, willUnmute);
      } catch {
        setMediaLabel(video, false);
      }
    });
  });

  const videoObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      const video = entry.target;
      if (!(video instanceof HTMLVideoElement)) return;
      if (entry.isIntersecting && entry.intersectionRatio > 0.18 && !reducedMotion.matches) {
        video.play().catch(() => {});
      } else if (!entry.isIntersecting) {
        video.pause();
      }
    });
  }, { threshold: [0, 0.18, 0.5] });
  allVideos().forEach((video) => {
    if (!video.matches("[data-manual-video]")) videoObserver.observe(video);
  });

  document.querySelectorAll("[data-parallax-zone]").forEach((zone) => {
    if (reducedMotion.matches) return;
    let frame = 0;
    zone.addEventListener("pointermove", (event) => {
      if (frame) return;
      frame = requestAnimationFrame(() => {
        const rect = zone.getBoundingClientRect();
        const nx = (event.clientX - rect.left) / rect.width - 0.5;
        const ny = (event.clientY - rect.top) / rect.height - 0.5;
        zone.querySelectorAll("[data-depth]").forEach((element) => {
          const depth = Number(element.dataset.depth || 1);
          element.style.setProperty("--parallax-x", `${(nx * depth * 26).toFixed(2)}px`);
          element.style.setProperty("--parallax-y", `${(ny * depth * 18).toFixed(2)}px`);
        });
        frame = 0;
      });
    });
    zone.addEventListener("pointerleave", () => zone.querySelectorAll("[data-depth]").forEach((element) => {
      element.style.setProperty("--parallax-x", "0px");
      element.style.setProperty("--parallax-y", "0px");
    }));
  });

  document.querySelectorAll(".button").forEach((button) => button.addEventListener("click", () => {
    if (reducedMotion.matches) return;
    button.animate([
      { filter: "brightness(1)", offset: 0 },
      { filter: "brightness(1.45)", offset: 0.35 },
      { filter: "brightness(1)", offset: 1 }
    ], { duration: 380, easing: "cubic-bezier(.16,1,.3,1)" });
  }));

  const stat = (icon, label, value, level) => ({ icon, label, value, level: Math.max(0, Math.min(100, level)) });
  const weaponStats = (damage, cooldown, count, speed, pierce = 0) => [
    stat("DMG", "Rank 10 damage", String(damage), damage / 110 * 100),
    stat("BPM", "Activations", `${(1 / cooldown).toFixed(2)}/s`, (1 / cooldown) / 4 * 100),
    stat("AMT", "Projectiles", String(count), count / 16 * 100),
    stat("VEL", "Projectile speed", String(speed), speed / 800 * 100),
    stat("PXR", "Pierce", String(pierce), pierce / 7 * 100)
  ];
  const weapons = [
    { name: "Kazoo Pistol", role: "Balanced starter", rarity: "Common", pattern: "Aimed", description: "Joe's trusty starter fires focused buzzing notes.", strength: "Reliable damage, fast scaling, and flexible targeting.", weakness: "Less crowd coverage than radial or wall patterns.", stats: weaponStats(28,.43,3,500,0) },
    { name: "Bass Drop", role: "Heavy piercer", rarity: "Uncommon", pattern: "Aimed", description: "A slow, heavy note with high damage and natural pierce.", strength: "Deletes dense enemy lines and rewards deliberate aiming.", weakness: "Longer cooldown and slower projectile travel.", stats: weaponStats(72,.65,3,410,4) },
    { name: "Cymbal Slicer", role: "Wide spread", rarity: "Common", pattern: "Aimed fan", description: "Fast cutting notes fan across nearby targets.", strength: "High activation speed and broad close-range coverage.", weakness: "Each individual note deals lighter damage.", stats: weaponStats(23,.25,5,620,1) },
    { name: "Feedback Loop", role: "Rapid focus", rarity: "Uncommon", pattern: "Aimed", description: "A sustained tone accelerates as it ranks up.", strength: "Excellent tempo with growing projectile volume.", weakness: "Needs ranks before its pierce and count become dominant.", stats: weaponStats(30,.26,4,570,2) },
    { name: "Drum Circle", role: "Radial control", rarity: "Rare", pattern: "Radial", description: "Throws a complete ring of percussion around the Resonant.", strength: "Controls encirclement with fourteen notes at rank 10.", weakness: "Slower activation rhythm than focused weapons.", stats: weaponStats(24,.72,14,420,2) },
    { name: "Trumpet Burst", role: "Close burst", rarity: "Common", pattern: "Aimed cone", description: "A tight cone of brass notes lands with strong knockback.", strength: "Excellent close pressure and space-making force.", weakness: "Short lifetime asks the player to stay near danger.", stats: weaponStats(38,.42,8,570,0) },
    { name: "Vinyl Scratch", role: "Lane cutter", rarity: "Uncommon", pattern: "Cross", description: "Alternating cuts rake through packed enemy lanes.", strength: "High pierce and dependable crowd-line coverage.", weakness: "Cross lanes demand good positioning.", stats: weaponStats(45,.37,6,600,4) },
    { name: "Synth Wave", role: "Area wall", rarity: "Rare", pattern: "Wall", description: "Projects a slow wall of oversized neon notes.", strength: "Large projectiles sweep broad formations.", weakness: "Slow travel and a deliberate cooldown.", stats: weaponStats(56,.60,8,340,4) },
    { name: "Triangle Tracer", role: "Rapid piercer", rarity: "Common", pattern: "Aimed", description: "Rapid silver pings drill through one precise target line.", strength: "Fastest projectile travel in the base roster.", weakness: "Small projectiles provide limited lateral coverage.", stats: weaponStats(17,.258,3,758,4) },
    { name: "Cello Lance", role: "Precision sniper", rarity: "Rare", pattern: "Aimed", description: "A deliberate string thrust carries extreme damage and pierce.", strength: "Highest rank-10 base damage and deep penetration.", weakness: "The slowest activation rhythm rewards patience.", stats: weaponStats(106,1.02,2,832,7) },
    { name: "Maraca Orbit", role: "Spiral defense", rarity: "Uncommon", pattern: "Spiral", description: "Rotating percussion spirals continuously sweep nearby space.", strength: "Persistent defensive coverage with seven projectiles.", weakness: "Lower single-hit damage than heavy weapons.", stats: weaponStats(17,.545,7,402,2) },
    { name: "Tuning Fork", role: "Front-back lane", rarity: "Common", pattern: "Front and back", description: "Matched notes fire through both sides of an encirclement.", strength: "Protects two opposing lanes at the same time.", weakness: "Side pressure can slip between its paired lines.", stats: weaponStats(32,.532,5,600,3) },
    { name: "Keytar Chord", role: "Broad formation", rarity: "Uncommon", pattern: "Wall", description: "Lyra's broad harmonic wall advances through whole crowds.", strength: "Large formation coverage and strong late-rank pierce.", weakness: "Slow projectile travel needs proactive movement.", stats: weaponStats(28,.72,7,348,4) },
    { name: "Bell Tower", role: "Heavy nova", rarity: "Rare", pattern: "Radial", description: "Slow bronze tolls erupt outward with crushing knockback.", strength: "Heavy radial damage and the strongest base knockback.", weakness: "Long activation interval leaves openings.", stats: weaponStats(59,1.175,8,332,4) },
    { name: "Tape Repeater", role: "Side-lane repeat", rarity: "Uncommon", pattern: "Sideways", description: "Recorded attacks echo from alternating side lanes.", strength: "Fast repeating coverage with useful pierce.", weakness: "Its direction changes with the lane pattern.", stats: weaponStats(24,.415,5,551,4) },
    { name: "Laser Harp", role: "Rapid cone", rarity: "Rare", pattern: "Aimed fan", description: "A brilliant fan of fast strings rewards close positioning.", strength: "Eight fast projectiles create intense close pressure.", weakness: "Lower damage per string and a short lifetime.", stats: weaponStats(20,.318,8,719,2) }
  ].map((weapon, index) => ({ ...weapon, key: `weapon-${index + 1}`, type: "Base weapon", image: `assets/sprites/weapons/weapon-${index + 1}.png`, facts: [`Rank 10 shown`, weapon.pattern, weapon.role] }));

  const supports = [
    { name: "Quickstep", description: "Move faster.", strength: "Creates escape lanes and supports aggressive repositioning.", weakness: "Adds no direct damage or defense.", bonus: "+10% speed per level", max: 5, fusion: "Orbital Ovation / Carnival Superorbit" },
    { name: "Encore", description: "Increase maximum health.", strength: "Raises survival margin during long boss patterns.", weakness: "Does not reduce incoming damage.", bonus: "+15% max HP per level", max: 5, fusion: "Thunderhead Ensemble / Stadium Keytar" },
    { name: "Breath Control", description: "Shorten cooldowns and tighten projectile spread.", strength: "Improves activation stability and focused accuracy.", weakness: "Offers no immediate health or pickup utility.", bonus: "+8% stability per level", max: 5, fusion: "Brass Barrage / Prismatic Triangle" },
    { name: "Power Amplifier", description: "Increase all weapon damage.", strength: "Scales every active damage source at once.", weakness: "Does not add coverage or attack count.", bonus: "+12% damage per level", max: 5, fusion: "Subwoofer Supernova / Velvet Impaler" },
    { name: "Pickup Magnet", description: "Increase gem attraction range.", strength: "Collects progression safely while the arena is crowded.", weakness: "Offers no direct combat power.", bonus: "+20% attraction per level", max: 5, fusion: "Gravity Groove / Infinite Mixtape" },
    { name: "Overdrive Pedal", description: "Increase weapon activation speed.", strength: "Raises total output across the whole active rack.", weakness: "More projectiles can make positioning harder to read.", bonus: "+9% fire rate per level", max: 5, fusion: "Improvised Solo / Resonance Rupture" },
    { name: "Echo Chamber", description: "Add another projectile to every activation.", strength: "Directly expands coverage for every weapon pattern.", weakness: "Only three ranks and no defensive value.", bonus: "+1 projectile per level", max: 3, fusion: "Neon Crescendo / Aurora Harp" },
    { name: "Safety Vest", description: "Gain a reserve of temporary Guard.", strength: "Absorbs mistakes before vitality is lost.", weakness: "Guard is finite and must be managed.", bonus: "+12 Guard per level", max: 5, fusion: "Golden Fortissimo / Cathedral Overdrive" }
  ].map((support, index) => ({
    ...support,
    key: `support-${index + 1}`,
    type: "Support",
    rarity: "Build support",
    role: support.bonus,
    image: `assets/sprites/supports/support-${index + 1}.png`,
    facts: [`Maximum rank ${support.max}`, support.bonus, `Fuses into ${support.fusion}`],
    stats: [stat("LVL", "Maximum rank", String(support.max), support.max / 5 * 100), stat("BON", "Per-rank effect", support.bonus, 78), stat("FUS", "Fusion readiness", "Rank 1+", 20)]
  }));

  const expansionEvolutionFiles = ["prismatic-triangle", "velvet-impaler", "carnival-superorbit", "resonance-rupture", "stadium-keytar", "cathedral-overdrive", "infinite-mixtape", "aurora-harp"];
  const evolvedImage = (number) => number <= 8
    ? `assets/sprites/evolved/evolved-${number}.png`
    : `assets/world-tour/sprites/evolutions/${expansionEvolutionFiles[number - 9]}.png`;
  const evolved = [
    { name: "Brass Barrage", description: "Kazoo Pistol and Breath Control fuse into a piercing three-note burst.", strength: "Fast, focused, and naturally piercing.", weakness: "Still aims in one primary direction.", recipe: "Kazoo Pistol R10 + Breath Control", role: "Kazoo fusion", pattern: "Aimed", stats: weaponStats(42,.36,3,560,3) },
    { name: "Subwoofer Supernova", description: "Bass Drop and Power Amplifier collapse into a piercing radial shockwave.", strength: "Huge radial coverage, damage, and knockback.", weakness: "A deliberate cooldown separates each nova.", recipe: "Bass Drop R10 + Power Amplifier", role: "Bass fusion", pattern: "Radial", stats: weaponStats(76,.58,12,410,5) },
    { name: "Orbital Ovation", description: "Cymbal Slicer and Quickstep become a relentless golden orbit.", strength: "The fastest evolved activation rhythm.", weakness: "Lower single-hit damage than heavy evolutions.", recipe: "Cymbal Slicer R10 + Quickstep", role: "Cymbal fusion", pattern: "Spiral", stats: weaponStats(31,.18,8,610,4) },
    { name: "Improvised Solo", description: "Feedback Loop and Overdrive Pedal fuse into an accelerating electric phrase.", strength: "Rapid front-back pressure with focused speed.", weakness: "Narrower coverage than radial evolved forms.", recipe: "Feedback Loop R10 + Overdrive Pedal", role: "Feedback fusion", pattern: "Front and back", stats: weaponStats(34,.28,2,620,2) },
    { name: "Thunderhead Ensemble", description: "Drum Circle and Encore merge into a restorative thunder nova.", strength: "Sixteen-projectile radial control with powerful knockback.", weakness: "Lower pierce than the most focused evolutions.", recipe: "Drum Circle R10 + Encore", role: "Drum fusion", pattern: "Radial", stats: weaponStats(48,.48,16,450,3) },
    { name: "Golden Fortissimo", description: "Trumpet Burst and Safety Vest form an armored brass barrage.", strength: "Ten fast notes with the strongest evolved knockback.", weakness: "Shorter projectile lifetime favors close combat.", recipe: "Trumpet Burst R10 + Safety Vest", role: "Trumpet fusion", pattern: "Aimed cone", stats: weaponStats(58,.30,10,650,3) },
    { name: "Gravity Groove", description: "Vinyl Scratch and Pickup Magnet cut four gravitational lanes.", strength: "Deepest evolved pierce and excellent lane control.", weakness: "Cross geometry still rewards deliberate positioning.", recipe: "Vinyl Scratch R10 + Pickup Magnet", role: "Vinyl fusion", pattern: "Cross", stats: weaponStats(62,.34,8,590,6) },
    { name: "Neon Crescendo", description: "Synth Wave and Echo Chamber become a repeating iridescent wall.", strength: "Largest evolved projectiles and dominant crowd coverage.", weakness: "The slowest evolved projectile travel.", recipe: "Synth Wave R10 + Echo Chamber", role: "Synth fusion", pattern: "Wall", stats: weaponStats(68,.52,12,390,5) },
    { name: "Prismatic Triangle", description: "Triangle Tracer and Breath Control refract into three piercing spectral lanes.", strength: "Nine fast projectiles carry deep pierce through crossing lanes.", weakness: "Cross geometry still rewards deliberate alignment.", recipe: "Triangle Tracer R10 + Breath Control", role: "Triangle fusion", pattern: "Cross", stats: weaponStats(64,.34,9,690,6) },
    { name: "Velvet Impaler", description: "Cello Lance and Power Amplifier become a sustained armored spear line.", strength: "Extreme damage, travel speed, and the deepest fusion pierce.", weakness: "Three focused projectiles leave less lateral coverage.", recipe: "Cello Lance R10 + Power Amplifier", role: "Cello fusion", pattern: "Aimed", stats: weaponStats(92,.42,3,760,9) },
    { name: "Carnival Superorbit", description: "Maraca Orbit and Quickstep expand into a relentless carnival halo.", strength: "Twelve projectiles cycle at an exceptionally fast rhythm.", weakness: "Its spiral pattern concentrates on nearby space.", recipe: "Maraca Orbit R10 + Quickstep", role: "Maraca fusion", pattern: "Spiral", stats: weaponStats(42,.19,12,600,5) },
    { name: "Resonance Rupture", description: "Tuning Fork and Overdrive Pedal tear synchronized lanes through the arena.", strength: "Eight high-damage notes combine speed, pierce, and knockback.", weakness: "Front-back lanes demand directional positioning.", recipe: "Tuning Fork R10 + Overdrive Pedal", role: "Tuning fork fusion", pattern: "Front and back", stats: weaponStats(78,.30,8,720,8) },
    { name: "Stadium Keytar", description: "Keytar Chord and Encore fill the stage with a championship wall of sound.", strength: "Fourteen large projectiles dominate wide formations.", weakness: "Its wall travels more deliberately than focused fusion shots.", recipe: "Keytar Chord R10 + Encore", role: "Keytar fusion", pattern: "Wall", stats: weaponStats(72,.50,14,430,6) },
    { name: "Cathedral Overdrive", description: "Bell Tower and Safety Vest toll an arena-clearing overdrive nova.", strength: "The heaviest fusion damage and knockback across eighteen radial notes.", weakness: "A deliberate cooldown separates each nova.", recipe: "Bell Tower R10 + Safety Vest", role: "Bell fusion", pattern: "Radial", stats: weaponStats(105,.70,18,470,7) },
    { name: "Infinite Mixtape", description: "Tape Repeater and Pickup Magnet loop luminous side lanes without an ending.", strength: "Ten fast, piercing notes maintain constant side-lane pressure.", weakness: "Sideways coverage depends on controlling the lane angle.", recipe: "Tape Repeater R10 + Pickup Magnet", role: "Tape fusion", pattern: "Sideways", stats: weaponStats(54,.20,10,680,6) },
    { name: "Aurora Harp", description: "Laser Harp and Echo Chamber fan celestial strings across the whole front line.", strength: "The fastest activation and projectile travel in the fusion roster.", weakness: "Lower damage and pierce than the heaviest evolved forms.", recipe: "Laser Harp R10 + Echo Chamber", role: "Laser harp fusion", pattern: "Aimed fan", stats: weaponStats(48,.16,12,820,4) }
  ].map((item, index) => ({ ...item, key: `evolved-${index + 1}`, type: "Evolved weapon", rarity: "Legendary fusion", image: evolvedImage(index + 1), facts: [item.recipe, item.pattern, "Consumes both ingredients"] }));

  const gems = [
    { name: "Pulse Shard", role: "Tier 1 Resonance gem", description: "A standard enemy condenses its exact XP reward into one collectible shard.", strength: "Simple, immediate progression from common threats.", weakness: "The lowest XP concentration in the current roster.", experience: "10-24 XP", source: "Standard enemies", radius: 8, dropCount: "1", dropRate: "100%" },
    { name: "Charged Shard", role: "Tier 2 Resonance gem", description: "Enemies worth at least 30 XP split their reward across two charged gems.", strength: "A denser pickup shower from tougher regular enemies.", weakness: "The total reward is divided between both drops.", experience: "15-24 XP each", source: "30+ XP enemies", radius: 9, dropCount: "2", dropRate: "100%" },
    { name: "Elite Crystal", role: "Tier 3 Resonance gem", description: "Elites drop three crystals and minibosses drop five. Their split always preserves the exact XP total.", strength: "High progression density after major threats.", weakness: "Requires defeating an elite or miniboss.", experience: "22-72 XP each", source: "Elites and minibosses", radius: 10, dropCount: "3 / 5", dropRate: "100%" },
    { name: "Boss Resonance", role: "Tier 4 Resonance gem", description: "A final boss releases eight large crystals carrying its complete Resonance reward.", strength: "The highest individual and total XP yield.", weakness: "Only appears after a final boss falls.", experience: "62-125 XP each", source: "Final bosses", radius: 11, dropCount: "8", dropRate: "100%" }
  ].map((gem, index) => ({
    ...gem,
    key: `gem-${index + 1}`,
    type: "Resonance gem",
    rarity: `Tier ${index + 1}`,
    image: `assets/sprites/gems/gem-${index + 1}.png?v=site005`,
    facts: [gem.experience, gem.source, `${gem.radius}px collision radius`],
    stats: [stat("XP", "Experience value", gem.experience, [18,32,64,100][index]), stat("TIR", "Drop tier", `${index + 1} of 4`, (index + 1) * 25), stat("PCK", "Pickup radius", `${gem.radius}px`, gem.radius / 11 * 100), stat("MAG", "Attraction speed", "360 px/s", 60)]
  }));

  const characters = [
    { key: "character-joe", name: "Joe", logo: "assets/character-logos/joe-logo.png", type: "Playable Resonant", rarity: "The Backbeat", role: "Durable control", image: "assets/sprites/talking/joe-1.png", description: "A steady street fighter who turns pressure into power.", strength: "Starts with 18 Guard and delivers 20% heavier knockback.", weakness: "His activation tempo is 6% below baseline.", facts: ["Kazoo Pistol", "Hold the Line", "18 starting Guard"], stats: [stat("VIT","Vitality","1.15x",96),stat("PWR","Power","1.12x",93),stat("SPD","Speed","1.00x",83),stat("DEF","Defense","1.12x",93),stat("BPM","Tempo","0.94x",78),stat("RES","Resonance XP","1.00x",83)] },
    { key: "character-lyra", name: "Lyra Vex", logo: "assets/character-logos/lyra-vex-logo.png", type: "Playable Resonant", rarity: "The Live Wire", role: "Speed and tempo", image: "assets/sprites/talking/lyra-1.png", description: "A cosmic rock explorer built for fast, risky movement.", strength: "Moves 16% faster, fires 12% faster, and earns 8% more Resonance XP.", weakness: "Lower vitality, defense, and knockback than Joe.", facts: ["Keytar Chord", "Stage Dive", "+8% Resonance XP"], stats: [stat("VIT","Vitality","0.94x",78),stat("PWR","Power","0.96x",80),stat("SPD","Speed","1.16x",97),stat("DEF","Defense","0.92x",77),stat("BPM","Tempo","1.12x",93),stat("RES","Resonance XP","1.08x",90)] }
  ];

  const inspectionCatalog = new Map();
  [...weapons, ...supports, ...evolved, ...gems, ...characters].forEach((item) => inspectionCatalog.set(item.key, item));
  const weaponGrid = document.querySelector("[data-weapon-grid]");
  if (weaponGrid) {
    const fragment = document.createDocumentFragment();
    weapons.forEach((weapon, index) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "weapon-card";
      button.dataset.name = `${weapon.name}: ${weapon.role}`;
      button.dataset.inspectKey = weapon.key;
      button.style.setProperty("--float-delay", `${-index * 0.19}s`);
      button.setAttribute("aria-label", `Inspect ${weapon.name}, ${weapon.role}`);
      const image = document.createElement("img");
      image.src = weapon.image;
      image.alt = weapon.name;
      image.width = 256;
      image.height = 256;
      image.loading = "lazy";
      image.decoding = "async";
      const preview = document.createElement("span");
      preview.className = "weapon-card__preview";
      preview.innerHTML = `<b>${weapon.name}</b><small>${weapon.rarity} / ${weapon.role}</small><em>Open full stats</em>`;
      button.append(image, preview);
      fragment.append(button);
    });
    weaponGrid.replaceChildren(fragment);
  }

  const enemyStats = (hp, damage, speed, xp) => [
    stat("HP", "Vitality", String(hp), Math.log10(hp + 1) / Math.log10(14501) * 100),
    stat("DMG", "Contact damage", String(damage), damage / 40 * 100),
    stat("SPD", "Movement speed", `${speed} px/s`, speed / 140 * 100),
    stat("XP", "Resonance reward", String(xp), Math.log10(xp + 1) / Math.log10(1001) * 100)
  ];
  const enemies = [
    { name: "Monotone", behavior: "Chases the nearest Resonant", file: "backbeat-1", hp:20, speed:60, damage:10, xp:10, coins:1, rank:"Standard" },
    { name: "Tempo Leech", behavior: "Zigzags through the beat", file: "backbeat-2", hp:45, speed:95, damage:15, xp:20, coins:2, rank:"Standard" },
    { name: "Metronome Guardian", behavior: "Charges as the Stage 1 miniboss", file: "backbeat-3", hp:900, speed:72, damage:22, xp:140, coins:75, rank:"Miniboss" },
    { name: "Static Baron", behavior: "Anchors in place and attacks at range", file: "backbeat-4", hp:3200, speed:0, damage:18, xp:500, coins:250, rank:"Final boss" },
    { name: "Syncopation Skitter", behavior: "Fast zigzag pressure unit", file: "backbeat-5", hp:34, speed:138, damage:12, xp:15, coins:2, rank:"Standard" },
    { name: "Feedback Phantom", behavior: "Spectral chaser with heavier pressure", file: "backbeat-6", hp:80, speed:76, damage:18, xp:30, coins:4, rank:"Standard" },
    { name: "Bass Brute", behavior: "Heavy charger at close range", file: "backbeat-7", hp:180, speed:52, damage:28, xp:48, coins:7, rank:"Heavy" },
    { name: "Noise Turret", behavior: "Static ranged note attacker", file: "backbeat-8", hp:115, speed:0, damage:11, xp:38, coins:5, rank:"Ranged" },
    { name: "Vinyl Drone", behavior: "Chases through the Orbit Line", file: "orbit-1", hp:95, speed:92, damage:15, xp:24, coins:3, rank:"Standard" },
    { name: "Trumpet Ray", behavior: "Maintains range and fires hostile notes", file: "orbit-2", hp:130, speed:76, damage:16, xp:34, coins:4, rank:"Ranged" },
    { name: "Drum Wheel", behavior: "Charges through open arena lanes", file: "orbit-3", hp:220, speed:88, damage:24, xp:44, coins:6, rank:"Heavy" },
    { name: "Theremin Jelly", behavior: "Pulses a close Resonance field", file: "orbit-4", hp:175, speed:58, damage:19, xp:42, coins:6, rank:"Pulse" },
    { name: "Amp Hound", behavior: "Fast elite orbiting predator", file: "orbit-5", hp:420, speed:132, damage:27, xp:68, coins:10, rank:"Elite" },
    { name: "Keyboard Centipede", behavior: "Elite zigzag and ranged lane pressure", file: "orbit-6", hp:560, speed:82, damage:31, xp:82, coins:12, rank:"Elite" },
    { name: "Turntable Sentinel", behavior: "Ranged Orbit Line miniboss", file: "orbit-7", hp:5200, speed:44, damage:30, xp:360, coins:150, rank:"Miniboss" },
    { name: "Grand Orchestrator", behavior: "Final boss with Resonance pulses", file: "orbit-8", hp:14500, speed:34, damage:36, xp:1000, coins:500, rank:"Final boss" }
  ].map((enemy, index) => ({
    ...enemy,
    key: `enemy-${index + 1}`,
    type: "Enemy",
    rarity: enemy.rank,
    role: enemy.behavior,
    image: `assets/sprites/enemies/${enemy.file}.png?v=site005`,
    description: `${enemy.name} is part of the hostile instrument-machine orchestra. ${enemy.behavior}.`,
    strength: enemy.speed >= 120 ? "Exceptional mobility creates immediate pressure." : enemy.hp >= 900 ? "Large health pool and boss-scale arena control." : enemy.damage >= 24 ? "High contact damage punishes positioning mistakes." : "Simple behavior becomes dangerous inside a mixed wave.",
    weakness: enemy.speed === 0 ? "Cannot reposition once deployed." : enemy.speed < 60 ? "Slow movement gives the player room to reset." : enemy.hp < 100 ? "Low vitality makes focused fire effective." : "Pattern recognition creates safe counterplay windows.",
    facts: [`${enemy.xp} XP total`, `${enemy.coins} coin reward`, enemy.rank],
    stats: enemyStats(enemy.hp, enemy.damage, enemy.speed, enemy.xp)
  }));
  enemies.forEach((enemy) => inspectionCatalog.set(enemy.key, enemy));
  const worldEnemyRows = {
    funk: [
      ["Pocket Gremlin", "Zigzags through close lanes", 52,104,14,18,2,"Standard"],
      ["Slapback Hound", "Fast enemy that circles the player", 110,142,19,29,4,"Standard"],
      ["Groove Guard", "Heavy charger", 260,66,28,52,7,"Heavy"],
      ["Talkbox Oracle", "Keeps its distance and fires note bolts", 190,62,20,46,6,"Ranged"],
      ["Boogie Tank", "Stage boss with a close Resonance pulse", 7200,46,32,780,390,"Final boss"],
      ["Funkadelic Wasp", "Very fast zigzag attacker", 76,166,17,24,3,"Standard"],
      ["Mothership of Funk", "World boss with a large ranged attack", 16800,28,40,1400,700,"Final boss"],
      ["Pocket Phantom", "Circles the player and releases a Resonance pulse", 225,112,24,49,7,"Pulse"]
    ],
    soul: [
      ["Choir Automaton", "Chases the player", 92,82,17,22,5,"Standard"],
      ["String Sentinel", "Keeps its distance and fires note bolts", 145,70,19,34,5,"Ranged"],
      ["Organ Walker", "Heavy charger", 290,55,27,69,5,"Heavy"],
      ["Harmony Linker", "Circles the player and releases a Resonance pulse", 210,76,22,50,5,"Pulse"],
      ["Gospel Moth", "Fast zigzag attacker", 78,156,16,18,5,"Standard"],
      ["Velvet Knight", "Armoured charger", 430,64,31,103,5,"Heavy"],
      ["Organ Colossus", "Stage boss with a close Resonance pulse", 8200,38,34,850,420,"Final boss"],
      ["Velvet Titan", "World boss with a large ranged attack", 17800,32,42,1500,760,"Final boss"]
    ],
    disco: [
      ["Prism Roller", "Fast enemy that circles the player", 108,132,18,25,5,"Standard"],
      ["Mirror Drone", "Very fast zigzag attacker", 92,168,17,22,5,"Standard"],
      ["Laser Fan", "Keeps its distance and fires note bolts", 175,62,21,42,5,"Ranged"],
      ["Reflection Twin", "Chases the player", 275,96,25,66,5,"Standard"],
      ["Platform Pouncer", "Fast charger", 135,150,20,32,5,"Heavy"],
      ["Glitter Guard", "Armoured charger", 480,72,33,115,5,"Heavy"],
      ["Laser Conductor", "Stage boss with a large ranged attack", 9000,42,36,920,460,"Final boss"],
      ["Prism Monarch", "World boss with a large static wave", 19400,36,44,1650,820,"Final boss"]
    ],
    jazz: [
      ["Syncopated Imp", "Zigzags through syncopated lanes", 122,118,19,29,5,"Standard"],
      ["Blue Note Bat", "Fast enemy that circles the player", 104,174,18,24,5,"Standard"],
      ["Walking Bass Bot", "Heavy charger", 320,58,29,76,5,"Heavy"],
      ["Scat Cannon", "Keeps its distance and fires note bolts", 205,48,23,49,5,"Ranged"],
      ["Bebop Behemoth", "Heavy enemy with a close Resonance pulse", 540,68,35,129,5,"Pulse"],
      ["Brushfire Skitter", "Very fast zigzag attacker", 158,162,21,37,5,"Standard"],
      ["Brass Regent", "Stage boss with a large static wave", 9800,45,38,1000,500,"Final boss"],
      ["Midnight Maestro", "World boss with a large static wave", 20800,38,46,1780,880,"Final boss"]
    ]
  };
  const worldEnemies = Object.entries(worldEnemyRows).flatMap(([world, rows]) => rows.map((row, index) => {
    const [name, behavior, hp, speed, damage, xp, coins, rank] = row;
    return {
      key: `world-enemy-${world}-${index + 1}`,
      world, name, behavior, hp, speed, damage, xp, coins, rank,
      type: "Enemy",
      rarity: rank,
      role: `${world[0].toUpperCase() + world.slice(1)} World / ${behavior}`,
      image: `assets/world-tour/sprites/enemies/${world}/${fileSlug(name)}.png`,
      description: `${name} appears in the ${world[0].toUpperCase() + world.slice(1)} World.`,
      strength: behavior,
      weakness: speed < 60 ? "Slow movement leaves time to reposition." : hp < 100 ? "Low health makes focused attacks effective." : "Learn the attack pattern and keep a clear escape lane.",
      facts: [`${xp} XP total`, `${coins} coin reward`, rank],
      stats: enemyStats(hp, damage, speed, xp)
    };
  }));
  worldEnemies.forEach((enemy) => inspectionCatalog.set(enemy.key, enemy));

  const worlds = [
    ["funk","Funk","The Pocket District","Mothership of Funk","Playable","Stand on the active downbeat pad to build a Pocket chain and gain a damage boost.","assets/world-tour/sprites/ui/interface/funk.png","Core world"],
    ["soul","Soul","Velvet Chapel","Velvet Titan","Playable","Charge a shared reserve in combat, then spend it to recover health.","assets/world-tour/sprites/ui/interface/soul.png","Core world"],
    ["disco","Disco","Mirrorball Metro","Prism Monarch","Playable","Follow the moving spotlight to gain a speed boost.","assets/world-tour/sprites/ui/interface/disco.png","Core world"],
    ["jazz","Jazz","Blue Note Borough","Midnight Maestro","Playable","Catch each blue-note improvisation window to gain a temporary speed boost.","assets/world-tour/emblems/jazz.png","Core world"],
    ["house","House","Beyond the tour map","Signal locked","Coming soon","A relentless pulse waits behind the next gate.","assets/world-tour/sprites/ui/world-tour/locked-world.png","Core world"],
    ["techno","Techno","Beyond the tour map","Signal locked","Coming soon","A machine rhythm waits behind the next gate.","assets/world-tour/sprites/ui/world-tour/locked-world.png","Core world"],
    ["cosmic-boogie","Cosmic Boogie","Orbital Dance Deck","Celestial Selector","Secret route","Find the hidden connection between Funk and Disco.","assets/world-tour/sprites/ui/world-tour/locked-world.png","Secret world"],
    ["soulful-garage","Soulful Garage","Midnight Garage","Night Shift Conductor","Secret route","Find the hidden connection between Soul and House.","assets/world-tour/sprites/ui/world-tour/locked-world.png","Secret world"],
    ["future-funk","Future Funk","Tomorrow Mall","The Recompiler","Secret route","Find the hidden connection between Jazz and Techno.","assets/world-tour/sprites/ui/world-tour/locked-world.png","Secret world"]
  ].map(([id,name,location,boss,status,mechanic,image,kind]) => ({
    key: `world-${id}`, name, type: "World", rarity: kind, role: location, image,
    description: status === "Playable" ? `${name} opens into two connected stages with its own route, enemies, bosses, and musical identity.` : `${name} waits beyond the tour map, its signal already pulsing behind the gate.`,
    strength: mechanic,
    weakness: status === "Playable" ? "Choose this route from the World Tour map." : "The route remains locked for now.",
    facts: [status, location, boss]
  }));
  worlds.forEach((world) => inspectionCatalog.set(world.key, world));

  const numberedLabels = (prefix, count) => Array.from({ length: count }, (_, index) => `${prefix} ${String(index + 1).padStart(2, "0")}`);
  const funkFiles = ["boombox-barricade", "record-kiosk", "amp-wall", "turntable-console", "disco-palm", "talkbox-streetlight", "vinyl-stack", "hologram-dancer"];
  const jazzEnvironmentNames = ["Blue Note Club Entrance", "Midnight Note Lamp", "Walking Bass Stack", "Improvisation Kiosk", "Saxophone Moon Fountain", "Blue Palm Planter", "Equalizer Bench", "Blue Note Spotlight"];
  const jazzFloorNames = ["Midnight Inlay", "Blue Note Grid", "Brass Solo Mosaic", "Cosmic Club Diamond"];
  const scenarioEnvironmentSets = [
    { id: "backbeat-base", world: "Backbeat Streets", location: "The Prologue", root: "backbeat/base", files: numberedFiles("base", 8), names: numberedLabels("Backbeat Streets Prop", 8) },
    { id: "backbeat-expansion", world: "Backbeat Streets", location: "The Prologue", root: "backbeat/expansion", files: numberedFiles("expansion", 8), names: numberedLabels("Backbeat Streets Expansion", 8) },
    { id: "orbit-base", world: "The Orbit Line", location: "The Prologue", root: "orbit/base", files: numberedFiles("base", 8), names: numberedLabels("Orbit Line Prop", 8) },
    { id: "orbit-expansion", world: "The Orbit Line", location: "The Prologue", root: "orbit/expansion", files: numberedFiles("expansion", 8), names: numberedLabels("Orbit Line Expansion", 8) },
    { id: "funk", world: "Funk World", location: "The Pocket District", root: "funk", files: funkFiles, names: funkFiles.map(titleFromFile), worldKey: "world-funk" },
    { id: "soul", world: "Soul World", location: "Velvet Chapel", root: "soul", files: numberedFiles("prop", 8), names: numberedLabels("Velvet Chapel Prop", 8), worldKey: "world-soul" },
    { id: "disco", world: "Disco World", location: "Mirrorball Metro", root: "disco", files: numberedFiles("prop", 8), names: numberedLabels("Mirrorball Metro Prop", 8), worldKey: "world-disco" },
    { id: "jazz", world: "Jazz World", location: "Blue Note Borough", root: "jazz", files: numberedFiles("prop", 8), names: jazzEnvironmentNames, worldKey: "world-jazz" }
  ];
  const scenarioFloorSets = [
    { id: "backbeat", world: "Backbeat Streets", location: "The Prologue", names: numberedLabels("Backbeat Surface", 4) },
    { id: "orbit", world: "The Orbit Line", location: "The Prologue", names: numberedLabels("Orbit Surface", 4) },
    { id: "funk", world: "Funk World", location: "The Pocket District", names: numberedLabels("Funk Surface", 4), worldKey: "world-funk" },
    { id: "soul", world: "Soul World", location: "Velvet Chapel", names: numberedLabels("Soul Surface", 4), worldKey: "world-soul" },
    { id: "disco", world: "Disco World", location: "Mirrorball Metro", names: numberedLabels("Disco Surface", 4), worldKey: "world-disco" },
    { id: "jazz", world: "Jazz World", location: "Blue Note Borough and Midnight Changes", names: jazzFloorNames, worldKey: "world-jazz" }
  ];
  const scenarioRecords = [
    ...scenarioEnvironmentSets.flatMap((set) => set.files.map((file, index) => ({
      key: `scenario-${set.id}-${file}`,
      name: set.names[index],
      type: "Scenario asset",
      rarity: set.world,
      role: "Environment prop",
      image: `assets/world-tour/sprites/environments/${set.root}/${file}.png`,
      description: `${set.names[index]} is an authentic environment sprite used in ${set.location}.`,
      strength: `Builds ${set.world}'s readable scenario vocabulary.`,
      weakness: "Visual scenario asset; it has no direct gameplay effect.",
      facts: [set.world, "Environment prop", set.location],
      worldKey: set.worldKey
    }))),
    ...scenarioFloorSets.flatMap((set) => numberedFiles("surface", 4).map((file, index) => ({
      key: `scenario-${set.id}-${file}`,
      name: set.names[index],
      type: "Scenario asset",
      rarity: set.world,
      role: "Scenario background",
      image: `assets/world-tour/sprites/floors/${set.id}/${file}.png`,
      description: `${set.names[index]} is an authored floor and background surface used across ${set.location}.`,
      strength: "Defines the playable route's floor language without obscuring combat silhouettes.",
      weakness: "Visual scenario asset; it has no direct gameplay effect.",
      facts: [set.world, "Scenario background", set.location],
      worldKey: set.worldKey
    })))
  ];
  scenarioRecords.forEach((item) => inspectionCatalog.set(item.key, item));

  const perkRows = [
    ["open-ears","Open Ears",5,"Clear the Prologue","Increase pickup radius."],
    ["pocket-drive","Pocket Drive",5,"Funk grade C","Increase base damage."],
    ["breakstep","Breakstep",3,"Funk grade A","Increase movement speed."],
    ["warm-current","Warm Current",5,"Soul grade C","Increase maximum health."],
    ["velvet-guard","Velvet Guard",3,"Soul grade A","Reduce incoming damage."],
    ["mirrorball-tips","Mirrorball Tips",5,"Disco grade C","Increase eligible in-run coin value."],
    ["spotlight-spin","Spotlight Spin",1,"Disco grade A","Add one level-up reroll per run."],
    ["four-count","Four Count",5,"House grade C","Extend the positive Groove timing window."],
    ["floor-control","Floor Control",3,"House grade A","Reduce arena-hazard damage."],
    ["live-wire","Live Wire",5,"Jazz grade C","Reduce attack cooldowns."],
    ["signal-boost","Signal Boost",3,"Jazz grade A","Increase XP gain."],
    ["precision-loop","Precision Loop",5,"Techno grade C","Extend combo grace time."],
    ["hard-reset","Hard Reset",1,"Techno grade A","Reduce the first damaging hit of each run."],
    ["orbital-balance","Orbital Balance",3,"Cosmic Boogie grade C","Improve knockback resistance and recovery."],
    ["encore-spark","Encore Spark",1,"Cosmic Boogie grade A","Add one reward choice after the first boss."],
    ["deep-reserve","Deep Reserve",5,"Soulful Garage grade C","Increase healing effectiveness."],
    ["afterglow","Afterglow",3,"Soulful Garage grade A","Extend protection after taking damage."],
    ["neon-dividend","Neon Dividend",5,"Future Funk grade C","Increase the capped Encore payout."],
    ["first-drop","First Drop",1,"Future Funk grade A","Start each run with eight XP."]
  ];
  const perks = perkRows.map(([id,name,max,source,description], index) => ({
    key: `perk-${id}`, name, type: "Permanent perk", rarity: max === 1 ? "Rare" : max === 3 ? "Uncommon" : "Common",
    role: source, image: `assets/world-tour/sprites/perks/${id}.png`,
    description, strength: "The bonus applies to future runs in the same save slot.",
    weakness: `Maximum rank: ${max}.`, max, source,
    facts: [source, `Maximum rank ${max}`, "Permanent progression"]
  }));
  perks.forEach((perk) => inspectionCatalog.set(perk.key, perk));

  const chests = [
    { key: "chest-musical", name: "Musical Chest", image: "assets/world-tour/sprites/chests/musical/frame-01.png", role: "Random run rewards", description: "Rolls five hidden reels and gives one, three, or five rewards.", strength: "Can add weapons, supports, upgrades, or eligible fusions during a run.", weakness: "The final reward count depends on the luck roll.", facts: ["Eight-frame animation", "Five hidden reels", "1 / 3 / 5 rewards"] },
    { key: "chest-encore-gate", name: "Encore Gate", image: "assets/world-tour/sprites/chests/encore-gate.png", role: "World stage completion", description: "Drops after a World boss and completes the stage when collected.", strength: "Closes the stage and carries your loadout into the next step.", weakness: "Appears only after the stage boss is defeated.", facts: ["Mandatory collection", "Boss reward", "Stage transition"] }
  ].map((chest) => ({ ...chest, type: "Chest", rarity: "World Tour" }));
  chests.forEach((chest) => inspectionCatalog.set(chest.key, chest));

  const categoryMeta = {
    weapon: { label: "Weapon", icon: "assets/sprites/weapons/weapon-1.png" },
    support: { label: "Passive", icon: "assets/sprites/supports/support-3.png" },
    evolution: { label: "Evolution", icon: "assets/sprites/evolved/evolved-1.png" },
    character: { label: "Character", icon: "assets/sprites/talking/joe-1.png" },
    enemy: { label: "Enemy", icon: "assets/sprites/enemies/orbit-3.png?v=site005" },
    gem: { label: "Gem", icon: "assets/sprites/gems/gem-2.png?v=site005" },
    world: { label: "World", icon: "assets/world-tour/sprites/ui/interface/global-tour.png" },
    scenario: { label: "Scenario asset", icon: "assets/world-tour/sprites/environments/backbeat/base/base-01.png" },
    perk: { label: "Permanent perk", icon: "assets/world-tour/sprites/ui/interface/perk-database.png" },
    chest: { label: "Chest", icon: "assets/world-tour/sprites/chests/encore-gate.png" }
  };
  const categoryFor = (item) => {
    if (item.type === "Base weapon") return "weapon";
    if (item.type === "Support") return "support";
    if (item.type === "Evolved weapon") return "evolution";
    if (item.type === "Playable Resonant") return "character";
    if (item.type === "Enemy") return "enemy";
    if (item.type === "World") return "world";
    if (item.type === "Scenario asset") return "scenario";
    if (item.type === "Permanent perk") return "perk";
    if (item.type === "Chest") return "chest";
    return "gem";
  };
  inspectionCatalog.forEach((item) => { item.category = categoryFor(item); });

  const evolutionRecipes = [
    { evolution: "evolved-1", weapon: "weapon-1", support: "support-3" },
    { evolution: "evolved-2", weapon: "weapon-2", support: "support-4" },
    { evolution: "evolved-3", weapon: "weapon-3", support: "support-1" },
    { evolution: "evolved-4", weapon: "weapon-4", support: "support-6" },
    { evolution: "evolved-5", weapon: "weapon-5", support: "support-2" },
    { evolution: "evolved-6", weapon: "weapon-6", support: "support-8" },
    { evolution: "evolved-7", weapon: "weapon-7", support: "support-5" },
    { evolution: "evolved-8", weapon: "weapon-8", support: "support-7" },
    { evolution: "evolved-9", weapon: "weapon-9", support: "support-3" },
    { evolution: "evolved-10", weapon: "weapon-10", support: "support-4" },
    { evolution: "evolved-11", weapon: "weapon-11", support: "support-1" },
    { evolution: "evolved-12", weapon: "weapon-12", support: "support-6" },
    { evolution: "evolved-13", weapon: "weapon-13", support: "support-2" },
    { evolution: "evolved-14", weapon: "weapon-14", support: "support-8" },
    { evolution: "evolved-15", weapon: "weapon-15", support: "support-5" },
    { evolution: "evolved-16", weapon: "weapon-16", support: "support-7" }
  ];
  const connectRecord = (sourceKey, targetKey, label) => {
    const source = inspectionCatalog.get(sourceKey);
    if (!source || !inspectionCatalog.has(targetKey)) return;
    source.relations = [...(source.relations || []), { key: targetKey, label }];
  };
  evolutionRecipes.forEach(({ evolution, weapon, support }) => {
    connectRecord(evolution, weapon, "Base weapon");
    connectRecord(evolution, support, "Required passive");
    connectRecord(weapon, support, "Required passive");
    connectRecord(weapon, evolution, "Evolution");
    connectRecord(support, weapon, "Paired weapon");
    connectRecord(support, evolution, "Evolution");
  });
  connectRecord("character-joe", "weapon-1", "Starting weapon");
  connectRecord("character-lyra", "weapon-13", "Starting weapon");
  enemies.forEach((enemy) => {
    const gemKey = enemy.rank === "Final boss" ? "gem-4" : enemy.rank === "Miniboss" || enemy.rank === "Elite" ? "gem-3" : enemy.xp >= 30 ? "gem-2" : "gem-1";
    connectRecord(enemy.key, gemKey, "Resonance drop");
  });
  worldEnemies.forEach((enemy) => {
    const gemKey = enemy.rank === "Final boss" ? "gem-4" : enemy.rank === "Miniboss" || enemy.rank === "Elite" ? "gem-3" : enemy.xp >= 30 ? "gem-2" : "gem-1";
    connectRecord(enemy.key, `world-${enemy.world}`, "World");
    connectRecord(enemy.key, gemKey, "Resonance drop");
  });
  scenarioRecords.forEach((scenario) => {
    if (scenario.worldKey) connectRecord(scenario.key, scenario.worldKey, "World");
  });

  const catalogGroups = document.querySelector("[data-catalog-groups]");
  const catalogFilters = document.querySelector("[data-catalog-filters]");
  const catalogSearch = document.querySelector("[data-catalog-search]");
  const catalogCount = document.querySelector("[data-catalog-count]");
  const catalogEmpty = document.querySelector("[data-catalog-empty]");
  if (catalogGroups && catalogFilters) {
    const catalogOrder = ["character", "weapon", "support", "evolution", "gem", "enemy", "world", "scenario", "perk", "chest"];
    const pluralLabels = { character: "Characters", weapon: "Weapons", support: "Supports", evolution: "Fusions", gem: "Resonance gems", enemy: "Enemies", world: "World Tour worlds", scenario: "Scenario backgrounds", perk: "Permanent perks", chest: "Chests" };
    let activeCategory = "all";
    const allItems = Array.from(inspectionCatalog.values());
    const makeFilter = (category, label, icon, count) => {
      const button = document.createElement("button");
      button.type = "button";
      button.dataset.catalogFilter = category;
      button.setAttribute("aria-pressed", String(category === "all"));
      if (icon) {
        const image = document.createElement("img");
        image.src = icon;
        image.alt = "";
        button.append(image);
      }
      const name = document.createElement("span");
      name.textContent = label;
      const amount = document.createElement("strong");
      amount.textContent = String(count);
      button.append(name, amount);
      return button;
    };
    catalogFilters.append(makeFilter("all", "All records", "assets/gb-icon.png?v=20260813-02", allItems.length));
    catalogOrder.forEach((category) => {
      const items = allItems.filter((item) => item.category === category);
      catalogFilters.append(makeFilter(category, pluralLabels[category], categoryMeta[category].icon, items.length));
    });
    catalogOrder.forEach((category) => {
      const items = allItems.filter((item) => item.category === category);
      const section = document.createElement("section");
      section.className = "catalog-group";
      section.dataset.catalogGroup = category;
      const header = document.createElement("div");
      header.className = "catalog-group__header";
      const icon = document.createElement("img");
      icon.src = categoryMeta[category].icon;
      icon.alt = "";
      const title = document.createElement("h2");
      title.textContent = pluralLabels[category];
      const total = document.createElement("span");
      total.textContent = `${items.length} records`;
      header.append(icon, title, total);
      const grid = document.createElement("div");
      grid.className = "catalog-grid";
      items.forEach((item) => {
        const card = document.createElement("button");
        card.type = "button";
        card.className = "catalog-card";
        card.dataset.inspectKey = item.key;
        card.dataset.catalogCard = "";
        card.dataset.search = [item.name, item.role, item.type, item.rarity, item.description, item.strength, ...(item.facts || [])].join(" ").toLowerCase();
        card.setAttribute("aria-label", `Inspect ${item.name}`);
        const image = document.createElement("img");
        image.src = item.image;
        image.alt = item.name;
        image.loading = "lazy";
        image.decoding = "async";
        const copy = document.createElement("span");
        copy.className = "catalog-card__copy";
        const name = document.createElement("strong");
        name.textContent = item.name;
        const plus = document.createElement("span");
        plus.className = "catalog-card__plus";
        plus.textContent = "+";
        plus.setAttribute("aria-hidden", "true");
        copy.append(name);
        card.append(image, copy, plus);
        if (item.category === "enemy" && (item.rank === "Miniboss" || item.rank === "Final boss")) {
          const bossTag = document.createElement("span");
          bossTag.className = `catalog-boss-tag${item.rank === "Final boss" ? " catalog-boss-tag--final" : ""}`;
          bossTag.textContent = item.rank === "Final boss" ? "Boss" : "Miniboss";
          card.append(bossTag);
        }
        grid.append(card);
      });
      section.append(header, grid);
      catalogGroups.append(section);
    });
    const applyCatalogFilter = () => {
      const query = catalogSearch?.value.trim().toLowerCase() || "";
      let visibleCount = 0;
      catalogGroups.querySelectorAll("[data-catalog-group]").forEach((group) => {
        let groupCount = 0;
        group.querySelectorAll("[data-catalog-card]").forEach((card) => {
          const matchesCategory = activeCategory === "all" || group.dataset.catalogGroup === activeCategory;
          const matchesQuery = !query || card.dataset.search.includes(query);
          card.hidden = !(matchesCategory && matchesQuery);
          if (!card.hidden) { visibleCount += 1; groupCount += 1; }
        });
        group.hidden = groupCount === 0;
      });
      catalogFilters.querySelectorAll("[data-catalog-filter]").forEach((button) => button.setAttribute("aria-pressed", String(button.dataset.catalogFilter === activeCategory)));
      if (catalogCount) catalogCount.textContent = String(visibleCount);
      if (catalogEmpty) catalogEmpty.hidden = visibleCount !== 0;
    };
    catalogFilters.addEventListener("click", (event) => {
      const button = event.target.closest("[data-catalog-filter]");
      if (!button) return;
      activeCategory = button.dataset.catalogFilter;
      applyCatalogFilter();
    });
    catalogSearch?.addEventListener("input", applyCatalogFilter);
    applyCatalogFilter();
    const requestedRecord = new URLSearchParams(window.location.search).get("record");
    const requestedCard = requestedRecord ? catalogGroups.querySelector(`[data-inspect-key="${CSS.escape(requestedRecord)}"]`) : null;
    if (requestedCard) requestAnimationFrame(() => {
      requestedCard.classList.add("is-catalog-target");
      requestedCard.scrollIntoView({ behavior: reducedMotion.matches ? "auto" : "smooth", block: "center" });
      requestedCard.focus({ preventScroll: true });
    });
  }

  const remixStage = document.querySelector("[data-remix-stage]");
  if (remixStage) {
    const positions = [[7,16,9],[21,10,11],[36,20,13],[52,12,16],[67,23,10],[81,12,11],[93,28,12],[13,51,10],[28,65,11],[43,49,11],[58,65,12],[72,47,12],[87,66,13],[94,49,13],[39,86,17],[70,86,20]];
    const fragment = document.createDocumentFragment();
    enemies.forEach((enemy, index) => {
      const [x, y, size] = positions[index];
      const button = document.createElement("button");
      button.type = "button";
      button.className = "remix-token draggable";
      button.dataset.drag = "";
      button.dataset.name = `${enemy.name}: ${enemy.behavior}. Drag or inspect.`;
      button.dataset.inspectKey = enemy.key;
      button.setAttribute("aria-label", `Drag or inspect ${enemy.name}, ${enemy.behavior}`);
      button.style.setProperty("--x", `${x}%`);
      button.style.setProperty("--y", `${y}%`);
      button.style.setProperty("--size", `${size}%`);
      button.style.setProperty("--speed", `${18 + (index % 5) * 2.25}s`);
      button.style.setProperty("--delay", `${-index * 0.23}s`);
      const image = document.createElement("img");
      image.src = enemy.image;
      image.alt = enemy.name;
      image.loading = "lazy";
      image.decoding = "async";
      button.append(image);
      fragment.append(button);
    });
    [[17,34,"assets/sprites/gems/gem-2.png?v=site005","Charged Resonance gem","gem-2"],[89,36,"assets/sprites/gems/gem-4.png?v=site005","Boss Resonance crystal","gem-4"],[52,38,"assets/sprites/weapons/weapon-13.png","Keytar Chord","weapon-13"],[5,78,"assets/sprites/weapons/weapon-1.png","Kazoo Pistol","weapon-1"]].forEach(([x,y,src,name,key], index) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "remix-token draggable";
      button.dataset.drag = "";
      button.dataset.name = `${name}. Drag or inspect.`;
      button.dataset.inspectKey = key;
      button.setAttribute("aria-label", `Drag or inspect ${name}`);
      button.style.setProperty("--x", `${x}%`);
      button.style.setProperty("--y", `${y}%`);
      button.style.setProperty("--size", index < 2 ? "8%" : "10%");
      button.style.setProperty("--speed", `${20 + index * 2.5}s`);
      button.style.setProperty("--delay", `${-index * 0.4}s`);
      const image = document.createElement("img");
      image.src = String(src);
      image.alt = String(name);
      image.loading = "lazy";
      button.append(image);
      fragment.append(button);
    });
    remixStage.replaceChildren(fragment);
  }

  const characterData = {
    joe: {
      portrait: "assets/sprites/talking/joe-1.png", logo: "assets/character-logos/joe-logo.png", inspect: "character-joe", video: "assets/video/joe-intro.mp4",
      alt: "Joe, The Backbeat", copy: "Joe starts with Guard, stronger knockback, and the Kazoo Pistol. He moves at the standard speed but attacks slightly slower.",
      stats: [["Style", "Durable control", "assets/sprites/characters/joe-4.png"], ["Starting weapon", "Kazoo Pistol", "assets/sprites/weapons/weapon-1.png"], ["Trait", "Hold the Line", "assets/sprites/supports/support-8.png"]]
    },
    lyra: {
      portrait: "assets/sprites/talking/lyra-1.png", logo: "assets/character-logos/lyra-vex-logo.png", inspect: "character-lyra", video: "assets/video/lyra-intro.mp4",
      alt: "Lyra Vex, The Live Wire", copy: "Lyra starts with the Keytar Chord. She moves and attacks faster, earns more Resonance XP, and has lower defence than Joe.",
      stats: [["Style", "Fast movement", "assets/sprites/characters/lyra-4.png"], ["Starting weapon", "Keytar Chord", "assets/sprites/weapons/weapon-13.png"], ["Trait", "Stage Dive", "assets/sprites/supports/support-1.png"]]
    }
  };
  const selectCharacter = (key, tab) => {
    const data = characterData[key];
    const portrait = document.querySelector("[data-character-portrait]");
    const logo = document.querySelector("[data-character-logo]");
    const video = document.querySelector("[data-character-video]");
    const copy = document.querySelector("[data-character-copy]");
    const inspectButton = document.querySelector("[data-character-profile-inspect]");
    if (!data || !portrait || !logo || !video || !copy || !inspectButton) return;
    document.querySelectorAll("[data-character]").forEach((button) => {
      const active = button === tab;
      button.classList.toggle("is-active", active);
      button.setAttribute("aria-selected", String(active));
    });
    const swap = () => {
      portrait.src = data.portrait;
      portrait.alt = "";
      logo.src = data.logo;
      logo.alt = data.alt.replace(/,.*/, "");
      inspectButton.dataset.inspectKey = data.inspect;
      inspectButton.setAttribute("aria-label", `View full details for ${data.alt}`);
      video.src = data.video;
      video.poster = data.portrait;
      video.muted = true;
      video.load();
      video.play().catch(() => {});
      copy.innerHTML = `<p>${data.copy}</p><dl class="stat-lines">${data.stats.map(([term, value, icon]) => `<div><dt><img src="${icon}" alt="" width="627" height="627">${term}</dt><dd>${value}</dd></div>`).join("")}</dl>`;
    };
    if (document.startViewTransition && !reducedMotion.matches) document.startViewTransition(swap); else swap();
  };
  document.querySelectorAll("[data-character]").forEach((tab) => tab.addEventListener("click", () => selectCharacter(tab.dataset.character, tab)));

  const fusionData = [
    ["Kazoo Pistol R10",1,"Breath Control",3,"Brass Barrage",1,"weapon-1","support-3","evolved-1"], ["Bass Drop R10",2,"Power Amplifier",4,"Subwoofer Supernova",2,"weapon-2","support-4","evolved-2"],
    ["Cymbal Slicer R10",3,"Quickstep",1,"Orbital Ovation",3,"weapon-3","support-1","evolved-3"], ["Feedback Loop R10",4,"Overdrive Pedal",6,"Improvised Solo",4,"weapon-4","support-6","evolved-4"],
    ["Drum Circle R10",5,"Encore",2,"Thunderhead Ensemble",5,"weapon-5","support-2","evolved-5"], ["Trumpet Burst R10",6,"Safety Vest",8,"Golden Fortissimo",6,"weapon-6","support-8","evolved-6"],
    ["Vinyl Scratch R10",7,"Pickup Magnet",5,"Gravity Groove",7,"weapon-7","support-5","evolved-7"], ["Synth Wave R10",8,"Echo Chamber",7,"Neon Crescendo",8,"weapon-8","support-7","evolved-8"],
    ["Triangle Tracer R10",9,"Breath Control",3,"Prismatic Triangle",9,"weapon-9","support-3","evolved-9"], ["Cello Lance R10",10,"Power Amplifier",4,"Velvet Impaler",10,"weapon-10","support-4","evolved-10"],
    ["Maraca Orbit R10",11,"Quickstep",1,"Carnival Superorbit",11,"weapon-11","support-1","evolved-11"], ["Tuning Fork R10",12,"Overdrive Pedal",6,"Resonance Rupture",12,"weapon-12","support-6","evolved-12"],
    ["Keytar Chord R10",13,"Encore",2,"Stadium Keytar",13,"weapon-13","support-2","evolved-13"], ["Bell Tower R10",14,"Safety Vest",8,"Cathedral Overdrive",14,"weapon-14","support-8","evolved-14"],
    ["Tape Repeater R10",15,"Pickup Magnet",5,"Infinite Mixtape",15,"weapon-15","support-5","evolved-15"], ["Laser Harp R10",16,"Echo Chamber",7,"Aurora Harp",16,"weapon-16","support-7","evolved-16"]
  ];
  const fusionPicker = document.querySelector("[data-fusion-picker]");
  const fusionStage = document.querySelector("[data-fusion-stage]");
  const selectFusion = (index) => {
    const data = fusionData[index];
    if (!data || !fusionStage) return;
    const [weaponName, weaponImage, supportName, supportImage, resultName, resultImage, weaponKey, supportKey, resultKey] = data;
    const weapon = document.querySelector("[data-fusion-weapon]");
    const support = document.querySelector("[data-fusion-support]");
    const result = document.querySelector("[data-fusion-result]");
    if (weapon) { weapon.src = `assets/sprites/weapons/weapon-${weaponImage}.png`; weapon.alt = weaponName.replace(" R10", ""); }
    if (support) { support.src = `assets/sprites/supports/support-${supportImage}.png`; support.alt = supportName; }
    if (result) { result.src = evolvedImage(resultImage); result.alt = resultName; }
    const inspectKeys = { weapon: weaponKey, support: supportKey, result: resultKey };
    fusionStage.querySelectorAll("[data-fusion-inspect]").forEach((element) => {
      element.dataset.inspectKey = inspectKeys[element.dataset.fusionInspect];
      element.setAttribute("aria-label", `Inspect ${inspectionCatalog.get(element.dataset.inspectKey)?.name || "fusion item"}`);
    });
    document.querySelector("[data-fusion-weapon-name]").textContent = weaponName;
    document.querySelector("[data-fusion-support-name]").textContent = supportName;
    document.querySelector("[data-fusion-result-name]").textContent = resultName;
    fusionStage.setAttribute("aria-label", `${weaponName} plus ${supportName} becomes ${resultName}`);
    fusionPicker?.querySelectorAll("button").forEach((button, buttonIndex) => {
      button.classList.toggle("is-active", buttonIndex === index);
      button.setAttribute("aria-pressed", String(buttonIndex === index));
    });
    if (!reducedMotion.matches) {
      fusionStage.classList.add("is-restarting");
      requestAnimationFrame(() => requestAnimationFrame(() => fusionStage.classList.remove("is-restarting")));
    }
  };
  if (fusionPicker) {
    fusionData.forEach((data, index) => {
      const button = document.createElement("button");
      button.type = "button";
      const image = document.createElement("img");
      image.src = evolvedImage(data[5]);
      image.alt = "";
      image.width = 48;
      image.height = 48;
      button.append(image);
      button.setAttribute("aria-label", `${data[0]} plus ${data[2]}`);
      button.setAttribute("aria-pressed", "false");
      button.addEventListener("click", () => selectFusion(index));
      fusionPicker.append(button);
    });
    selectFusion(0);
  }

  const escapeHTML = (value) => String(value).replace(/[&<>'"]/g, (character) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "'": "&#39;", "\"": "&quot;" })[character]);
  const inspector = document.createElement("dialog");
  inspector.className = "inspect-dialog";
  inspector.setAttribute("aria-labelledby", "inspect-title");
  inspector.innerHTML = `
    <button class="inspect-dialog__close" type="button" data-inspect-close aria-label="Close details" title="Close details">×</button>
    <article class="inspect-card">
      <div class="inspect-card__visual"><div class="inspect-card__rings" aria-hidden="true"><i></i><i></i><i></i></div><img data-inspect-image src="assets/sprites/gems/gem-1.png?v=site005" alt=""></div>
      <div class="inspect-card__body" aria-live="polite">
        <div class="inspect-card__category" data-inspect-category></div>
        <div class="inspect-card__meta" data-inspect-meta></div>
        <img class="inspect-card__title-logo" data-inspect-title-logo src="assets/character-logos/joe-logo.png" alt="" hidden>
        <h2 id="inspect-title" data-inspect-title tabindex="-1"></h2>
        <p class="inspect-card__role" data-inspect-role></p>
        <p class="inspect-card__description" data-inspect-description></p>
        <div class="inspect-card__category-content" data-inspect-content></div>
        <section class="inspect-relations" data-inspect-relations hidden><div class="inspect-relations__head"><h3>Connected records</h3><p>Open any linked ingredient or result.</p></div><div class="inspect-relations__grid" data-inspect-relations-grid></div></section>
        <div class="inspect-card__actions"><a class="button button--gold" data-inspect-catalog href="catalog.html#archive"><span>View in full catalog</span><span aria-hidden="true">→</span></a></div>
      </div>
    </article>`;
  document.body.append(inspector);
  let inspectReturnTarget = null;
  const statGlyphs = { DMG: "✦", BPM: "◷", AMT: "×", VEL: "»", PXR: "⇥", LVL: "↑", BON: "+", FUS: "⇄", VIT: "♡", PWR: "✦", SPD: "»", DEF: "◇", RES: "◆", HP: "♡", XP: "◆", COIN: "◎" };
  const renderMetricGrid = (entries, modifier = "") => `<div class="inspect-metrics ${modifier}">${entries.map((entry) => `<div class="inspect-metric"><span class="inspect-metric__icon" aria-hidden="true">${escapeHTML(statGlyphs[entry.icon] || entry.icon)}</span><strong>${escapeHTML(entry.value)}</strong><span>${escapeHTML(entry.label)}</span></div>`).join("")}</div>`;
  const renderAnalysis = (item, labels) => `<div class="inspect-analysis"><section><span class="inspect-analysis__icon" aria-hidden="true">+</span><div><b>${escapeHTML(labels[0])}</b><p>${escapeHTML(item.strength)}</p></div></section><section><span class="inspect-analysis__icon" aria-hidden="true">!</span><div><b>${escapeHTML(labels[1])}</b><p>${escapeHTML(item.weakness)}</p></div></section></div>`;
  const renderCategoryContent = (item) => {
    if (item.category === "gem") {
      const xpValue = item.experience.replace(/ XP(?: each)?$/i, "");
      const xpLabel = /each/i.test(item.experience) ? "XP each" : "XP value";
      return `<div class="inspect-gem-summary"><div class="inspect-gem-metrics"><div><strong>${escapeHTML(xpValue)}</strong><span>${xpLabel}</span></div><div><strong>${escapeHTML(item.dropRate)}</strong><span>Drop rate</span></div><div><strong>${escapeHTML(item.dropCount)}</strong><span>Gems per kill</span></div><div><strong>${escapeHTML(`${item.radius}px`)}</strong><span>Pickup body</span></div></div><p><b>Drops from</b> ${escapeHTML(item.source)}. The full enemy XP reward is always preserved.</p></div>`;
    }
    if (item.category === "support") {
      return `<div class="inspect-support-core"><div><strong>${escapeHTML(item.bonus)}</strong><span>Per rank</span></div><div><strong>${escapeHTML(String(item.max))}</strong><span>Maximum rank</span></div></div>${renderAnalysis(item, ["Build advantage", "Opportunity cost"])}`;
    }
    if (item.category === "character") {
      const characterFacts = (item.facts || []).slice(1).map((fact, index) => `<div><span aria-hidden="true">${index === 0 ? "◆" : "+"}</span><strong>${escapeHTML(fact)}</strong></div>`).join("");
      return `<div class="inspect-character-signals">${characterFacts}</div>${renderAnalysis(item, ["Signature edge", "Character risk"])}${renderMetricGrid(item.stats || [], "inspect-metrics--character")}`;
    }
    if (item.category === "enemy") {
      const enemyMetrics = [stat("HP", "Vitality", String(item.hp), 0), stat("DMG", "Contact damage", String(item.damage), 0), stat("SPD", "Movement speed", `${item.speed} px/s`, 0), stat("XP", "Resonance reward", String(item.xp), 0), stat("COIN", "Coin reward", String(item.coins), 0)];
      return `${renderAnalysis(item, ["Threat profile", "Counterplay"])}${renderMetricGrid(enemyMetrics, "inspect-metrics--enemy")}`;
    }
    if (item.category === "world") {
      return `${renderAnalysis(item, ["World mechanic", "Availability"])}<div class="inspect-character-signals">${(item.facts || []).map((fact) => `<div><span aria-hidden="true">◆</span><strong>${escapeHTML(fact)}</strong></div>`).join("")}</div>`;
    }
    if (item.category === "scenario") {
      return `${renderAnalysis(item, ["Scenario role", "Gameplay scope"])}<div class="inspect-character-signals">${(item.facts || []).map((fact) => `<div><span aria-hidden="true">◆</span><strong>${escapeHTML(fact)}</strong></div>`).join("")}</div>`;
    }
    if (item.category === "perk") {
      return `<div class="inspect-support-core"><div><strong>${escapeHTML(String(item.max))}</strong><span>Maximum rank</span></div><div><strong>${escapeHTML(item.source)}</strong><span>Unlock source</span></div></div>${renderAnalysis(item, ["Permanent effect", "Limit"])}`;
    }
    if (item.category === "chest") {
      return `${renderAnalysis(item, ["Reward", "Condition"])}<div class="inspect-character-signals">${(item.facts || []).map((fact) => `<div><span aria-hidden="true">+</span><strong>${escapeHTML(fact)}</strong></div>`).join("")}</div>`;
    }
    const labels = item.category === "evolution" ? ["Legendary strength", "Pattern limit"] : ["Combat strength", "Tradeoff"];
    return `${renderAnalysis(item, labels)}${renderMetricGrid(item.stats || [], item.category === "evolution" ? "inspect-metrics--evolution" : "inspect-metrics--weapon")}`;
  };
  const openInspector = (key, opener, linked = false) => {
    const item = inspectionCatalog.get(key);
    if (!item) return;
    if (!linked) {
      document.querySelectorAll(".is-inspect-active").forEach((element) => element.classList.remove("is-inspect-active"));
      inspectReturnTarget = opener instanceof HTMLElement ? opener : null;
      inspectReturnTarget?.classList.add("is-inspect-active");
    }
    const image = inspector.querySelector("[data-inspect-image]");
    image.src = item.image;
    image.alt = item.name;
    const category = categoryMeta[item.category] || categoryMeta.gem;
    inspector.querySelector("[data-inspect-category]").textContent = category.label;
    const metaByCategory = {
      weapon: [item.rarity, item.pattern],
      support: [],
      evolution: [item.rarity, item.pattern],
      character: [item.rarity],
      enemy: [item.rank],
      gem: [item.rarity],
      world: [item.rarity, item.facts?.[0]],
      scenario: [item.rarity, item.role],
      perk: [item.rarity],
      chest: [item.rarity]
    };
    inspector.querySelector("[data-inspect-meta]").innerHTML = (metaByCategory[item.category] || []).filter(Boolean).map((value) => `<span>${escapeHTML(value)}</span>`).join("");
    const title = inspector.querySelector("[data-inspect-title]");
    const titleLogo = inspector.querySelector("[data-inspect-title-logo]");
    title.textContent = item.name;
    title.hidden = Boolean(item.logo);
    titleLogo.hidden = !item.logo;
    if (item.logo) {
      titleLogo.src = item.logo;
      titleLogo.alt = item.name;
    }
    const role = inspector.querySelector("[data-inspect-role]");
    const roleCopy = item.category === "support" || item.category === "gem" ? "" : item.role;
    role.textContent = roleCopy;
    role.hidden = !roleCopy;
    inspector.querySelector("[data-inspect-description]").textContent = item.description;
    inspector.querySelector("[data-inspect-content]").innerHTML = renderCategoryContent(item);
    const relations = inspector.querySelector("[data-inspect-relations]");
    const relationGrid = inspector.querySelector("[data-inspect-relations-grid]");
    relationGrid.innerHTML = (item.relations || []).map((relation) => {
      const related = inspectionCatalog.get(relation.key);
      if (!related) return "";
      return `<button type="button" class="inspect-relation" data-related-record="${escapeHTML(related.key)}"><img src="${escapeHTML(related.image)}" alt=""><span><small>${escapeHTML(relation.label)}</small><strong>${escapeHTML(related.name)}</strong><em>Open details</em></span></button>`;
    }).join("");
    relations.hidden = relationGrid.childElementCount === 0;
    inspector.querySelector("[data-inspect-catalog]").href = `catalog.html?record=${encodeURIComponent(item.key)}#archive`;
    inspector.dataset.kind = item.type.toLowerCase().replace(/\s+/g, "-");
    inspector.dataset.category = item.category;
    inspector.dataset.record = item.key;
    if (!inspector.open) {
      if (document.startViewTransition && !reducedMotion.matches) document.startViewTransition(() => inspector.showModal()); else inspector.showModal();
    } else if (!reducedMotion.matches) {
      inspector.querySelector(".inspect-card__body").animate([{ opacity: .42, transform: "translateY(8px)" }, { opacity: 1, transform: "translateY(0)" }], { duration: 280, easing: "cubic-bezier(.16,1,.3,1)" });
      title.focus({ preventScroll: true });
    }
  };
  inspector.addEventListener("click", (event) => {
    const relation = event.target.closest("[data-related-record]");
    if (!relation) return;
    openInspector(relation.dataset.relatedRecord, relation, true);
  });
  inspector.querySelector("[data-inspect-close]").addEventListener("click", () => inspector.close());
  inspector.addEventListener("click", (event) => { if (event.target === inspector) inspector.close(); });
  inspector.addEventListener("close", () => {
    inspectReturnTarget?.classList.remove("is-inspect-active");
    inspectReturnTarget?.focus();
  });
  const prepareInspectables = () => document.querySelectorAll("[data-inspect-key]").forEach((element) => {
    const item = inspectionCatalog.get(element.dataset.inspectKey);
    const category = categoryMeta[item?.category] || categoryMeta.gem;
    element.classList.add("is-inspectable");
    element.dataset.category = item?.category || "gem";
    element.dataset.categoryLabel = category.label;
    const hasVisual = Boolean(element.querySelector(":scope > img")) || element.matches(".fusion-piece, .fusion-result, .character-profile__visual");
    if (hasVisual && !element.querySelector(":scope > .inspect-cue")) {
      const cue = document.createElement("span");
      cue.className = "inspect-cue";
      cue.textContent = "Inspect";
      element.append(cue);
      let pointerFrame = 0;
      element.addEventListener("pointermove", (event) => {
        if (event.pointerType && event.pointerType !== "mouse") return;
        if (pointerFrame) cancelAnimationFrame(pointerFrame);
        pointerFrame = requestAnimationFrame(() => {
          const rect = element.getBoundingClientRect();
          const cueRect = cue.getBoundingClientRect();
          const x = Math.max(8, Math.min(rect.width - cueRect.width - 8, event.clientX - rect.left + 18));
          const y = Math.max(cueRect.height / 2 + 8, Math.min(rect.height - cueRect.height / 2 - 8, event.clientY - rect.top));
          element.style.setProperty("--inspect-x", `${x}px`);
          element.style.setProperty("--inspect-y", `${y}px`);
          pointerFrame = 0;
        });
      });
      element.addEventListener("pointerleave", () => {
        if (pointerFrame) cancelAnimationFrame(pointerFrame);
        pointerFrame = 0;
      });
    }
    if (!element.matches("button, a")) {
      element.tabIndex = 0;
      element.setAttribute("role", "button");
      element.setAttribute("aria-label", `Inspect ${item?.name || "element"}`);
      element.title = `View ${category.label.toLowerCase()} details`;
    }
  });
  prepareInspectables();

  const signalStrip = document.querySelector("[data-signal-strip]");
  const signalTrack = document.querySelector("[data-signal-track]");
  if (signalStrip && signalTrack) {
    let drag = null;
    let signalOffset = 0;
    const moveTrack = (offset) => {
      const setWidth = signalTrack.scrollWidth / 3;
      if (!setWidth) return;
      signalOffset = ((offset % setWidth) + setWidth) % setWidth - setWidth;
      signalTrack.style.setProperty("--signal-offset", `${signalOffset}px`);
    };
    signalStrip.addEventListener("pointerdown", (event) => {
      if (event.button !== 0) return;
      if (reducedMotion.matches) {
        drag = { pointerId: event.pointerId, startX: event.clientX, scrollLeft: signalStrip.scrollLeft, reduced: true };
      } else {
        drag = { pointerId: event.pointerId, startX: event.clientX, offset: signalOffset, reduced: false };
      }
      signalStrip.setPointerCapture(event.pointerId);
      signalStrip.classList.add("is-dragging");
    });
    signalStrip.addEventListener("pointermove", (event) => {
      if (!drag || event.pointerId !== drag.pointerId) return;
      const delta = event.clientX - drag.startX;
      if (drag.reduced) signalStrip.scrollLeft = drag.scrollLeft - delta;
      else moveTrack(drag.offset + delta);
    });
    const finishSignalDrag = (event) => {
      if (!drag || event.pointerId !== drag.pointerId) return;
      signalStrip.releasePointerCapture(event.pointerId);
      signalStrip.classList.remove("is-dragging");
      drag = null;
    };
    signalStrip.addEventListener("pointerup", finishSignalDrag);
    signalStrip.addEventListener("pointercancel", finishSignalDrag);
    signalStrip.addEventListener("keydown", (event) => {
      if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
      event.preventDefault();
      if (reducedMotion.matches) signalStrip.scrollBy({ left: event.key === "ArrowRight" ? 180 : -180, behavior: "smooth" });
      else moveTrack(signalOffset + (event.key === "ArrowRight" ? -180 : 180));
    });
  }
  document.addEventListener("click", (event) => {
    const target = event.target.closest("[data-inspect-key]");
    if (!target || target.dataset.dragMoved === "true") return;
    event.preventDefault();
    openInspector(target.dataset.inspectKey, target);
  });
  document.addEventListener("keydown", (event) => {
    if (!event.target.matches("[data-inspect-key]:not(button):not(a)")) return;
    if (event.key !== "Enter" && event.key !== " ") return;
    event.preventDefault();
    openInspector(event.target.dataset.inspectKey, event.target);
  });

  const loreScenes = {
    world: { label: "Backbeat", title: "A city wired for music.", copy: "Train timing, street lights, rooftop venues, and Pulse Tower share a living network called the Resonance.", video: "assets/video/main-menu.mp4", portrait: "assets/sprites/talking/joe-1.png", alt: "Joe in Backbeat" },
    break: { label: "The Break", title: "A cosmic chord plays backwards.", copy: "Instrument-machine invaders descend, sampling the city and turning familiar sounds into hostile attack patterns.", video: "assets/video/prologue.mp4", portrait: "assets/sprites/enemies/backbeat-4.png?v=site005", alt: "The Static Baron invasion" },
    heroes: { label: "The Resonants", title: "Two answers to the same pressure.", copy: "Joe holds the line. Lyra turns risk into speed. Their strengths are complementary, not direct upgrades.", video: "assets/video/joe-intro.mp4", portrait: "assets/sprites/talking/joe-2.png", alt: "Joe, The Backbeat" },
    orbit: { label: "Orbit Line", title: "The dead line is still broadcasting.", copy: "The First Press points beneath the city toward alien platforms, cosmic speakers, and the Grand Orchestrator.", video: "assets/video/lyra-intro.mp4", portrait: "assets/sprites/enemies/orbit-8.png?v=site005", alt: "The Grand Orchestrator" }
  };
  document.querySelectorAll("[data-lore-scene]").forEach((button) => button.addEventListener("click", () => {
    const scene = loreScenes[button.dataset.loreScene];
    const video = document.querySelector("[data-lore-video]");
    const portrait = document.querySelector("[data-lore-portrait]");
    const copy = document.querySelector("[data-lore-copy]");
    if (!scene || !video || !portrait || !copy) return;
    document.querySelectorAll("[data-lore-scene]").forEach((other) => {
      const active = other === button;
      other.classList.toggle("is-active", active);
      other.setAttribute("aria-selected", String(active));
    });
    portrait.classList.add("is-changing");
    const swap = () => {
      video.src = scene.video;
      video.muted = true;
      video.load();
      video.play().catch(() => {});
      portrait.src = scene.portrait;
      portrait.alt = scene.alt;
      copy.innerHTML = `<p class="pixel-label">${scene.label}</p><h3>${scene.title}</h3><p>${scene.copy}</p>`;
      window.setTimeout(() => portrait.classList.remove("is-changing"), 40);
    };
    window.setTimeout(swap, reducedMotion.matches ? 0 : 190);
  }));

  const methodData = {
    direction: { label: "Creative direction", title: "Make every layer speak the same language.", copy: "Pixel art, cinematic cutscenes, music-powered fiction, UI, enemies, and weapon silhouettes reinforce one supernatural funk identity.", image: "assets/campaign-banner.png", alt: "Groove Bound creative direction overview" },
    systems: { label: "Game systems", title: "Turn a build choice into a story beat.", copy: "Sixteen weapons, eight supports, rank-10 fusions, chests, enemy patterns, and persistent two-stage progression create expressive runs.", image: "assets/screens/level-up-cards.jpg", alt: "Groove Bound level-up system" },
    world: { label: "World building", title: "Make the mechanics belong to the city.", copy: "The Resonance explains XP, power, transit, Pulse Tower, the Break, the First Press, and the enemy orchestra within the same fiction.", image: "assets/first-press-orbit.png", alt: "The First Press route to the Orbit Line" },
    verification: { label: "Play experience", title: "Make every choice feel alive.", copy: "Readable combat, expressive upgrades, musical feedback, and clear world transitions keep each run moving with purpose.", image: "assets/screens/gameplay-combat.png", alt: "Groove Bound combat in Backbeat Streets" }
  };
  document.querySelectorAll("[data-method]").forEach((button) => button.addEventListener("click", () => {
    const data = methodData[button.dataset.method];
    const display = document.querySelector("[data-method-display]");
    if (!data || !display) return;
    document.querySelectorAll("[data-method]").forEach((other) => {
      const active = other === button;
      other.classList.toggle("is-active", active);
      other.setAttribute("aria-selected", String(active));
    });
    display.classList.add("is-changing");
    window.setTimeout(() => {
      const image = display.querySelector("[data-method-image]");
      image.src = data.image;
      image.alt = data.alt;
      display.querySelector("[data-method-label]").textContent = data.label;
      display.querySelector("[data-method-title]").textContent = data.title;
      display.querySelector("[data-method-copy]").textContent = data.copy;
      display.classList.remove("is-changing");
    }, reducedMotion.matches ? 0 : 210);
  }));

  const initDraggables = () => {
    document.querySelectorAll("[data-drag]").forEach((element) => {
      let dragState = null;
      element.dataset.tx = element.dataset.tx || "0";
      element.dataset.ty = element.dataset.ty || "0";
      const moveTo = (x, y) => {
        element.dataset.tx = String(x);
        element.dataset.ty = String(y);
        element.style.setProperty("--dx", `${x}px`);
        element.style.setProperty("--dy", `${y}px`);
      };
      element.addEventListener("pointerdown", (event) => {
        if (event.button !== 0) return;
        const zone = element.closest("[data-drag-zone]") || element.parentElement;
        if (!zone) return;
        element.dataset.dragMoved = "false";
        dragState = { pointerId: event.pointerId, startX: event.clientX, startY: event.clientY, baseX: Number(element.dataset.tx), baseY: Number(element.dataset.ty), zone };
        element.setPointerCapture(event.pointerId);
        element.classList.add("is-dragging");
        event.preventDefault();
      });
      element.addEventListener("pointermove", (event) => {
        if (!dragState || event.pointerId !== dragState.pointerId) return;
        const deltaX = event.clientX - dragState.startX;
        const deltaY = event.clientY - dragState.startY;
        if (Math.hypot(deltaX, deltaY) > 6) element.dataset.dragMoved = "true";
        const elementRect = element.getBoundingClientRect();
        const zoneRect = dragState.zone.getBoundingClientRect();
        let nextX = dragState.baseX + deltaX;
        let nextY = dragState.baseY + deltaY;
        const shiftX = nextX - Number(element.dataset.tx);
        const shiftY = nextY - Number(element.dataset.ty);
        if (elementRect.left + shiftX < zoneRect.left) nextX += zoneRect.left - (elementRect.left + shiftX);
        if (elementRect.right + shiftX > zoneRect.right) nextX -= (elementRect.right + shiftX) - zoneRect.right;
        if (elementRect.top + shiftY < zoneRect.top) nextY += zoneRect.top - (elementRect.top + shiftY);
        if (elementRect.bottom + shiftY > zoneRect.bottom) nextY -= (elementRect.bottom + shiftY) - zoneRect.bottom;
        moveTo(nextX, nextY);
      });
      const finishDrag = (event) => {
        if (!dragState || event.pointerId !== dragState.pointerId) return;
        element.classList.remove("is-dragging");
        element.style.setProperty("--drop-rotate", "0deg");
        element.releasePointerCapture(event.pointerId);
        if (element.hasAttribute("data-route-marker")) {
          const map = element.closest("[data-route-map]");
          const status = document.querySelector("[data-route-status]");
          if (map) {
            const mapRect = map.getBoundingClientRect();
            const elementRect = element.getBoundingClientRect();
            const complete = elementRect.left + elementRect.width / 2 > mapRect.left + mapRect.width * 0.66;
            map.classList.toggle("is-complete", complete);
            if (status) status.textContent = complete ? "Route found: Orbit Line" : "Starting point: Pulse Tower";
          }
        }
        dragState = null;
        window.setTimeout(() => { element.dataset.dragMoved = "false"; }, 0);
      };
      element.addEventListener("pointerup", finishDrag);
      element.addEventListener("pointercancel", finishDrag);
      element.addEventListener("keydown", (event) => {
        const amount = event.shiftKey ? 24 : 10;
        const directions = { ArrowLeft: [-amount,0], ArrowRight: [amount,0], ArrowUp: [0,-amount], ArrowDown: [0,amount] };
        const delta = directions[event.key];
        if (!delta) return;
        event.preventDefault();
        moveTo(Number(element.dataset.tx) + delta[0], Number(element.dataset.ty) + delta[1]);
      });
    });
  };
  initDraggables();

  document.querySelectorAll("[data-reset-drag]").forEach((button) => button.addEventListener("click", () => {
    const section = button.closest("section") || document;
    section.querySelectorAll("[data-drag]").forEach((element) => {
      element.dataset.tx = "0";
      element.dataset.ty = "0";
      element.style.setProperty("--dx", "0px");
      element.style.setProperty("--dy", "0px");
      element.style.setProperty("--drop-rotate", "0deg");
    });
    section.querySelector("[data-route-map]")?.classList.remove("is-complete");
  }));

  document.querySelectorAll(".weapon-card, .draggable").forEach((element) => element.addEventListener("click", (event) => {
    if (element.dataset.inspectKey) return;
    if (element.classList.contains("is-dragging")) return;
    if (event.pointerType === "mouse") return;
    element.classList.toggle("is-tipped");
  }));

  const shotDialog = document.querySelector("[data-shot-dialog]");
  const dialogImage = document.querySelector("[data-dialog-image]");
  document.querySelectorAll("[data-shot]").forEach((shot) => shot.addEventListener("click", () => {
    if (!shotDialog || !dialogImage) return;
    const open = () => {
      dialogImage.src = shot.dataset.shot;
      dialogImage.alt = shot.dataset.shotAlt || "Groove Bound screenshot";
      shotDialog.showModal();
    };
    if (document.startViewTransition && !reducedMotion.matches) document.startViewTransition(open); else open();
  }));
  document.querySelector("[data-dialog-close]")?.addEventListener("click", () => shotDialog?.close());
  shotDialog?.addEventListener("click", (event) => { if (event.target === shotDialog) shotDialog.close(); });

  document.addEventListener("error", (event) => {
    const target = event.target;
    if (target instanceof HTMLImageElement) {
      target.hidden = true;
      const parent = target.parentElement;
      if (!parent || parent.querySelector(".asset-fallback")) return;
      parent.classList.add("asset-failed");
      const fallback = document.createElement("span");
      fallback.className = "asset-fallback";
      fallback.textContent = target.alt || "Image unavailable";
      parent.append(fallback);
    }
    if (target instanceof HTMLVideoElement) {
      target.hidden = true;
      const parent = target.parentElement;
      if (parent && target.poster) parent.style.background = `center / cover no-repeat url("${target.poster}")`;
    }
  }, true);
})();

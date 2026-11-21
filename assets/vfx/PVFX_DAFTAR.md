# Daftar efek PVFX (alat bantu mencari angka)

Dibuat dari `pack.json` paket PVFX Foundry 1.2 (253 efek). Pakai Ctrl+F untuk mencari kata (misal `heal`, `fire`, `shield`).

* **Ukuran** = ukuran satu frame (lebar x tinggi) = nilai *Size* untuk SpriteFrames; sheet punya 8 kolom.
* **FPS** = 1000 / ms per frame. **Pivot** = titik efek yang menempel pada targetnya (dipakai untuk Offset).
* **Impact** = ms sejak awal efek sampai momen kena (kalau ada). **Varian** = warna lain: folder `variants/<nama>/`.
* Path sheet: `effects/<id>/lit/grid/sprite-sheet.png` (atau `strict`); varian: `effects/<id>/variants/<nama>/lit/grid/sprite-sheet.png`.

| id | ukuran | frame | ms | fps | putar | pivot | impact | varian | deskripsi |
|---|---|---|---|---|---|---|---|---|---|
| `ambient/broken-wire-sparks` | 40x56 | 20 | 70 | 14.3 | loop | 20,4 |  |  | Seamless ambient loop of a severed cable hanging from a conduit: it sways and sparks in i… |
| `ambient/candle-flame` | 12x20 | 16 | 75 | 13.3 | loop | 6,18 |  |  | Seamless candle-flame loop: a small teardrop flame on a dark wick with a cream heart and … |
| `ambient/cloud-drift` | 128x128 | 96 | 80 | 12.5 | loop | 64,64 |  |  | Seamless tileable cloud loop: a few big flat-toned cloud masses drift right at two depths… |
| `ambient/crystal-glow` | 32x40 | 24 | 80 | 12.5 | loop | 16,36 |  | ember,venom,void,solar | Seamless ambient loop of a faceted crystal cluster on a rubble mound: light cores rise an… |
| `ambient/dust-motes` | 96x96 | 32 | 80 | 12.5 | loop | 48,48 |  |  | Seamless ambient loop of dust in a slanted shaft of light: motes drift lazily on small lo… |
| `ambient/falling-leaves` | 128x128 | 96 | 70 | 14.3 | loop | 64,64 |  |  | Seamless tileable autumn loop: crimson, orange, amber and gold leaves in three depths tum… |
| `ambient/fireflies` | 96x64 | 40 | 80 | 12.5 | loop | 48,32 |  |  | Seamless fireflies loop: nine fireflies wander on smooth looping paths and blink on their… |
| `ambient/fog-bank` | 160x56 | 120 | 100 | 10.0 | loop | 80,28 |  |  | Seamless tileable low fog loop (tiles on x at 160 px): a translucent, streaky fog volume … |
| `ambient/lantern-glow` | 48x60 | 24 | 80 | 12.5 | loop | 24,30 |  |  | Seamless ambient loop of a hanging iron lantern: a small flame flickers behind glass pane… |
| `ambient/lava-bubbles` | 64x32 | 20 | 80 | 12.5 | loop | 32,20 |  |  | Seamless ambient loop of a lava pool: hot veins wander through the orange surface between… |
| `ambient/magic-motes` | 64x64 | 24 | 80 | 12.5 | loop | 32,32 |  | ember,frost,venom,solar,spirit | Seamless ambient loop of drifting arcane motes over a 64 px area: specks, beads and diamo… |
| `ambient/portal-idle` | 64x80 | 24 | 80 | 12.5 | loop | 32,76 |  | ember,venom,void,spirit | Seamless ambient loop of a standing portal in the portal-summon palette: three spiral arm… |
| `ambient/rain` | 128x128 | 24 | 60 | 16.7 | loop | 64,64 |  |  | Seamless tileable rain loop: slanted streaks in far, mid and near depth layers (far short… |
| `ambient/rising-embers` | 64x96 | 30 | 80 | 12.5 | loop | 32,96 |  |  | Seamless rising-embers loop for over lava or a campfire: a sparse column of streaks, spar… |
| `ambient/sandstorm` | 160x120 | 24 | 60 | 16.7 | loop | 80,60 |  |  | Seamless tileable sandstorm loop: wind-blown sand streaks in far, mid and near layers (st… |
| `ambient/snowfall` | 128x128 | 96 | 70 | 14.3 | loop | 64,64 |  |  | Seamless tileable snowfall loop: flakes in far, mid and near depth layers drift down with… |
| `ambient/wall-torch` | 24x40 | 12 | 75 | 13.3 | loop | 12,32 |  |  | Seamless wall-torch loop: a single tall flame in an iron cup that sways and licks with tw… |
| `ambient/water-sparkle` | 96x48 | 24 | 80 | 12.5 | loop | 48,24 |  |  | Seamless ambient loop of sunlight glinting on water: clusters of glints wake along faint … |
| `ambient/waterfall` | 48x96 | 16 | 75 | 13.3 | loop | 24,88 |  |  | Seamless waterfall segment: a rippling curtain of falling water with dark and pale flow s… |
| `arcane/arcane-beam` | 168x64 | 8 | 75 | 13.3 | loop | 18,32 |  |  | Spiked source orb, a banded beam whose width churns locally with spiral strands, one brig… |
| `arcane/arcane-cast` | 64x64 | 13 | 70 | 14.3 | 1x | 32,34 | 420 |  | Rune glyph motes orbit the hand on a tilted ellipse and contract into a swelling magenta … |
| `arcane/arcane-orb-projectile` | 128x52 | 27 | 60 | 16.7 | 1x | 104,26 | 540 |  | A small bright magenta orb charges from spiralling rune motes, flies trailing satellite m… |
| `arcane/arcane-rain` | 128x118 | 24 | 60 | 16.7 | 1x | 64,94 | 480 |  | Violet lances of light rain down on a marked ground area in staggered strikes; each lands… |
| `arcane/blink-dash` | 128x48 | 22 | 60 | 16.7 | 1x | 64,24 |  | ember,venom,void,solar | A slit swallows the figure, one designed smear frame crosses with stepped afterimages, a … |
| `arcane/blink-out` | 64x80 | 19 | 60 | 16.7 | 1x | 32,72 |  |  | The figure's space folds into vertical streaks that pinch to a bright line, flash white o… |
| `arcane/dispel` | 88x100 | 17 | 60 | 16.7 | 1x | 44,44 | 120 |  | A white-blue ring snaps out from a star burst and sweeps through a violet rune circle, br… |
| `arcane/gravity-well` | 112x100 | 24 | 70 | 14.3 | loop | 56,50 |  |  | Seamless loop of a void core inside a flickering photon ring, lensed light rings that ben… |
| `arcane/magic-circle` | 96x64 | 20 | 80 | 12.5 | 1x | 48,47 |  | ember,frost,venom,solar,spirit | An inner ring draws on, the outer ring and runes counter-rotate in holds, a pillar of lig… |
| `arcane/mana-shield` | 80x76 | 20 | 70 | 14.3 | loop | 40,66 |  |  | Seamless loop of a hexagon-cell mana dome over a ground ring: a slowly turning lattice li… |
| `arcane/polymorph-poof` | 64x64 | 16 | 60 | 16.7 | 1x | 32,34 | 60 |  | A comic poof: a pink-violet smoke puff blooms with a white pop, twists round a spiral cur… |
| `arcane/portal-summon` | 108x128 | 22 | 80 | 12.5 | 1x | 54,108 |  | ember,venom,void,spirit | A rune band draws itself around a floor ellipse, the floor tears open on one white frame,… |
| `arcane/rune-trap` | 64x48 | 19 | 65 | 15.4 | 1x | 32,39 | 325 |  | A dormant teal floor seal lights its runes one by one, fires a jagged spike of light (one… |
| `arcane/shield-shatter` | 64x64 | 17 | 60 | 16.7 | 1x | 0,0 |  |  | A hex-faceted violet dome is hit from the left, cracks, flashes white along its cracks fo… |
| `arcane/teleport-in` | 40x64 | 19 | 60 | 16.7 | 1x | 20,57 |  | frost,venom,solar,spirit | Motes and streaks converge onto the spot as a floor glyph tightens, a slit of light opens… |
| `arcane/time-stop` | 144x144 | 28 | 60 | 16.7 | 1x | 72,68 | 660 |  | A clockwork dial snaps open with ticking hands, greys the world inside into frozen ripple… |
| `explosions/arcane-burst` | 72x72 | 20 | 65 | 15.4 | 1x | 36,38 | 195 |  | A violet charge curls five streaks inward, bursts on one white frame into a leaning magen… |
| `explosions/barrel-explosion` | 128x128 | 23 | 70 | 14.3 | 1x | 64,116 |  |  | Powder keg blast: one white peak, a squat orange fireball hugging the ground, wooden stav… |
| `explosions/big-explosion` | 128x128 | 18 | 70 | 14.3 | 1x | 64,113 |  | frost,venom,void | One white peak, a lobed fireball that cools white to red, smoke that rises and hollows, d… |
| `explosions/cluster-bomb` | 176x136 | 31 | 70 | 14.3 | 1x | 88,108 |  |  | One white flash, then a ring of smaller staggered blasts popping around it on the ground,… |
| `explosions/fire-nova` | 96x64 | 19 | 60 | 16.7 | 1x | 48,44 | 120 |  | One-shot radial fire nova around a caster: embers sucked into a hot ground core, one whit… |
| `explosions/firework-burst` | 64x80 | 23 | 65 | 15.4 | 1x | 32,30 | 325 |  | A rocket spark climbs, hangs, and bursts on one white frame into uneven magenta-gold come… |
| `explosions/frost-explosion` | 136x104 | 25 | 70 | 14.3 | 1x | 68,80 |  |  | A cold ground detonation: one white crystalline star, a crown of ice spikes that holds an… |
| `explosions/implosion` | 96x96 | 28 | 70 | 14.3 | 1x | 48,48 | 980 |  | A black void with a hot lobed rim opens and drags dust and sparks inward, crushes to a he… |
| `explosions/small-explosion` | 64x64 | 14 | 60 | 16.7 | 1x | 32,57 |  | frost,venom,void | One white flash, four lobes that roll out and cool to smoke, flung debris, puffs that hol… |
| `explosions/toxic-explosion` | 128x96 | 27 | 70 | 14.3 | 1x | 64,82 |  |  | A chemical blast: one white splash-crown frame, a green-yellow bloom that keeps bubbling … |
| `fire/campfire` | 40x56 | 12 | 75 | 13.3 | loop | 20,50 |  |  | Seamless campfire loop: crossed logs lit on their fire side, a coal bed, leaning flame to… |
| `fire/fire-breath` | 160x96 | 24 | 60 | 16.7 | 1x | 8,50 | 180 |  | A dragon's breath to the right: a continuous jet of flame from a white-hot mouth that wid… |
| `fire/fire-cast` | 64x64 | 15 | 60 | 16.7 | 1x | 32,38 | 480 |  | Four lobed flame tongues and a swarm of embers spiral into the palm around a swelling whi… |
| `fire/fire-dash` | 128x56 | 18 | 70 | 14.3 | 1x | 64,46 |  |  | A burning dash trail: a mover streaks forward leaving a line of fire whose tongues lick u… |
| `fire/fire-pillar` | 64x112 | 24 | 70 | 14.3 | 1x | 32,102 | 210 |  | A ground crack heats up, a column of fire erupts with one white-yellow peak, fat tongues … |
| `fire/fire-tornado` | 48x80 | 16 | 70 | 14.3 | loop | 24,74 |  |  | Seamless fire-tornado loop: a leaning open funnel of two torn flame ribbons climbing a sp… |
| `fire/fire-wall` | 128x76 | 16 | 75 | 13.3 | loop | 64,68 |  |  | Seamless, tileable fire barrier loop: a ground line of tall shaded flame tongues before a… |
| `fire/fireball-impact` | 96x64 | 15 | 70 | 14.3 | 1x | 72,38 | 350 |  | Fireball travel loop with lobed trailing tongues, a squash on contact, one white impact f… |
| `fire/flame-ring` | 112x80 | 17 | 70 | 14.3 | 1x | 56,60 |  |  | Fire erupts in a ring on the ground around the caster and runs outward, the near side tal… |
| `fire/flamethrower` | 128x48 | 16 | 60 | 16.7 | loop | 6,32 |  |  | Seamless flamethrower jet blowing right: cream core at the nozzle, an orange body of roll… |
| `fire/ground-flames` | 64x40 | 16 | 75 | 13.3 | loop | 32,33 |  |  | Seamless burning-ground hazard loop: four lobed flame clumps along a scorched perspective… |
| `fire/incinerate` | 64x64 | 19 | 70 | 14.3 | 1x | 22,60 |  |  | A target catches fire from the feet up, flares white, and the fire collapses into tumblin… |
| `fire/lava-burst` | 64x72 | 23 | 70 | 14.3 | 1x | 32,62 | 210 |  | The ground bulges and its cracks glow, one white peak bursts it open, a heavy lava founta… |
| `fire/meteor-strike` | 96x96 | 26 | 60 | 16.7 | 1x | 47,82 | 360 |  | A rock falls diagonally with a lit leading rim and a tongued flame trail, one white impac… |
| `fire/phoenix-burst` | 128x112 | 22 | 70 | 14.3 | 1x | 64,84 |  |  | A bird of flame spreads its wings upward with one white flare, beats once, then scatters … |
| `holy/angel-feathers` | 56x72 | 21 | 70 | 14.3 | 1x | 28,17 | 210 |  | A chunky tilted golden halo torus flares over the head, flashes white once and bursts qui… |
| `holy/barrier-block` | 40x56 | 16 | 55 | 18.2 | 1x | 0,0 | 110 |  | A hexagonal light pane snaps in, takes a hit from the right in one white frame, ripples a… |
| `holy/divine-beam` | 48x96 | 19 | 70 | 14.3 | 1x | 24,88 | 280 |  | A faint sliver and a broken floor halo build, then a heavy notched column of light slams … |
| `holy/halo-crown` | 44x50 | 24 | 80 | 12.5 | loop | 22,16 |  |  | Seamless floating halo loop: a golden ring crowned with six small tines slowly tilts open… |
| `holy/holy-cast` | 64x64 | 16 | 60 | 16.7 | 1x | 32,28 | 480 |  | A small halo ring draws itself around the palm and tightens while light motes rise and cu… |
| `holy/holy-heal` | 64x96 | 21 | 80 | 12.5 | 1x | 32,86 | 720 |  | Ground glint, floor ring, rising rods pulled into a star, one white pillar frame that bre… |
| `holy/holy-nova` | 128x108 | 25 | 70 | 14.3 | 1x | 64,48 | 140 |  | A radiant holy burst: one white eight-point star flare, a wide halo ring that widens, coo… |
| `holy/holy-smite` | 80x120 | 14 | 80 | 12.5 | 1x | 40,108 |  |  | A golden-white pillar slams down in two frames, one white peak with a domed splash, a thi… |
| `holy/holy-sword-fall` | 104x112 | 14 | 60 | 16.7 | 1x | 52,100 | 180 |  | A great sword of light falls point first into the ground with one white cross-shaped flas… |
| `holy/purify` | 60x88 | 16 | 70 | 14.3 | 1x | 30,76 | 140 |  | A cleansing burst: a gold ring opens at the feet, one white star flashes at the chest, an… |
| `holy/regen-aura` | 48x64 | 16 | 80 | 12.5 | loop | 24,57 |  |  | Seamless health-regeneration status loop: a low broken ellipse of green light at the feet… |
| `holy/resurrect` | 48x80 | 21 | 70 | 14.3 | 1x | 24,72 | 560 |  | A golden floor sigil draws itself, a beam with a ray-broken top descends onto it, one whi… |
| `holy/sanctuary` | 132x114 | 40 | 60 | 16.7 | loop | 66,80 |  |  | A golden ground circle with turning glyph marks, a light wave running round it and soft c… |
| `holy/shield-bubble` | 72x88 | 16 | 75 | 13.3 | loop | 36,84 |  |  | Seamless holy shield loop: a sphere shell with a bright gold rim on the lit upper left an… |
| `ice/blizzard` | 80x56 | 16 | 70 | 14.3 | loop | 40,50 |  |  | Seamless localized snowstorm: wind-driven snow slanting down-right in far, mid and near d… |
| `ice/freeze-encase` | 56x64 | 20 | 70 | 14.3 | 1x | 28,57 |  |  | Ice teeth grow up around a character footprint into a faceted block that glints white onc… |
| `ice/frost-armor` | 60x64 | 16 | 75 | 13.3 | loop | 30,60 |  |  | Seamless status loop: a faceted crystal shell around a figure whose facets glint one afte… |
| `ice/frost-breath` | 96x40 | 14 | 65 | 15.4 | loop | 4,21 |  |  | Seamless cone of cold blowing right: a dense pale root, rolling vapour lobes with lit top… |
| `ice/frost-nova` | 120x76 | 18 | 80 | 12.5 | 1x | 60,50 |  |  | Converging motes, an empty beat, a white eruption of faceted ice crystals on a floor ring… |
| `ice/frozen-ground` | 128x64 | 24 | 75 | 13.3 | loop | 64,32 |  |  | Seamless loop of a single patch of ice on the floor (it does not tile): a frost-rimmed, c… |
| `ice/ice-cast` | 64x64 | 16 | 60 | 16.7 | 1x | 32,28 | 480 |  | Bold frost streaks and tumbling hex shards shoot into the palm inside a contracting broke… |
| `ice/ice-shatter` | 100x64 | 23 | 70 | 14.3 | 1x | 50,54 |  |  | A frozen block cracks with white lines, then bursts into real faceted fragments that tumb… |
| `ice/ice-spike` | 96x80 | 26 | 70 | 14.3 | 1x | 46,68 |  |  | Frost spreads under the target, a big faceted ice crystal with three side shards shoots u… |
| `ice/ice-wall` | 80x56 | 21 | 70 | 14.3 | 1x | 40,48 |  |  | Frost creeps along the ground, a staggered row of jagged faceted ice slabs erupts into a … |
| `ice/icicle-rain` | 160x104 | 25 | 70 | 14.3 | 1x | 80,92 |  |  | Icicles drop in staggered columns and shatter on the floor in small crystal bursts of tum… |
| `ice/snowball-impact` | 80x48 | 20 | 65 | 15.4 | 1x | 62,26 | 325 |  | A lumpy shaded snowball arcs in shedding powder puffs, squashes on the target, flashes wh… |
| `impacts/block-guard` | 48x60 | 10 | 60 | 16.7 | 1x | 22,26 |  |  | A blocked hit: a guard plane bows back into one white lens under the blow, sparks shear o… |
| `impacts/blood-splat` | 128x120 | 16 | 70 | 14.3 | 1x | 28,62 |  |  | A crimson pop, then seven jets of blood tear out of the wound as lit ligaments over a thi… |
| `impacts/crater-impact` | 96x64 | 17 | 70 | 14.3 | 1x | 48,40 | 70 |  | A heavy landing: a flat white ground flash, a crater rim of rock teeth heaved up in an el… |
| `impacts/crit-hit` | 96x80 | 11 | 70 | 14.3 | 1x | 48,40 |  | frost,venom,void,spirit | Inward pinch, one white jagged starburst cut by a diagonal slash, chunky shards and a bro… |
| `impacts/death-poof` | 48x48 | 13 | 70 | 14.3 | 1x | 24,28 |  |  | An enemy despawn: a pale pop, one white star flash, then a cluster of distinct lavender s… |
| `impacts/ground-slam` | 128x64 | 19 | 70 | 14.3 | 1x | 64,44 |  |  | One white crack-flash on the floor, a flattened shockwave ring that breaks into arcs, thr… |
| `impacts/hit-spark` | 64x64 | 8 | 80 | 12.5 | 1x | 32,32 |  | frost,venom,void,spirit | Needle, one white peak frame, a long X and broken ring that cool down the ramp, embers th… |
| `impacts/magic-hit` | 48x48 | 14 | 60 | 16.7 | 1x | 24,24 |  |  | A small spell hit: a violet star pop, a broken ring that thins as it spreads, and runic m… |
| `impacts/metal-clang` | 58x44 | 13 | 60 | 16.7 | 1x | 24,26 |  |  | Blade on armour: one hard white tick, a fan of orange sparks that hang, fall and skid alo… |
| `impacts/parry` | 96x80 | 13 | 60 | 16.7 | 1x | 48,38 |  |  | Contact needle, one white cross-glint peak, a steel ring that breaks into arcs, sparks th… |
| `impacts/punch-hit` | 48x40 | 11 | 60 | 16.7 | 1x | 17,21 |  |  | Squashed pinch, one white uneven comic-burst star, a hollow jagged ring of the same spike… |
| `impacts/rock-shatter` | 64x56 | 18 | 60 | 16.7 | 1x | 30,44 |  |  | A faceted boulder struck from above-left cracks, flares pale cream along its cracks for o… |
| `impacts/shockwave-ring` | 120x52 | 16 | 70 | 14.3 | 1x | 60,30 |  | ember,venom,void,solar | A clean perspective shockwave ring for landings and heavy blows: white contact flash, a t… |
| `impacts/slime-splat` | 64x44 | 16 | 70 | 14.3 | 1x | 32,36 | 70 |  | A goo hit: a green glob squashes into a crowned splat, ropes stretch and snap into flung … |
| `impacts/wood-splinter` | 50x40 | 14 | 60 | 16.7 | 1x | 22,26 |  |  | A blunt hit on wood: a pale splintered flash, tan splinters and chips that spin out, fall… |
| `lightning/arc-discharge` | 100x66 | 14 | 60 | 16.7 | 1x | 50,36 | 120 |  | A heavy, jagged white-cored arc jumps between two points with forked branches, re-paths a… |
| `lightning/ball-lightning` | 96x48 | 20 | 60 | 16.7 | 1x | 0,24 | 540 |  | A crackling plasma orb with flickering jagged tendrils flies left to right, trailing a br… |
| `lightning/chain-lightning` | 180x72 | 14 | 70 | 14.3 | 1x | 10,40 | 70 |  | A bolt hops left to right across three targets in quick succession; each hop strikes as a… |
| `lightning/lightning-cast` | 64x64 | 15 | 60 | 16.7 | 1x | 32,32 | 480 |  | Five charge nodes close in on the palm while angular arcs crackle between them and into a… |
| `lightning/lightning-dash` | 126x60 | 11 | 60 | 16.7 | 1x | 12,32 | 120 |  | A zigzag teleport streak: one white flash from the departure to a tall slit flash at the … |
| `lightning/lightning-strike` | 96x128 | 18 | 80 | 12.5 | 1x | 38,118 |  |  | Leader, one white peak strike with a spike crown, re-strikes every 3 frames on fresh path… |
| `lightning/lightning-whip` | 138x88 | 14 | 60 | 16.7 | 1x | 14,44 | 240 |  | An electric whip lashes out in an S-curve, its tip cracks in a white spiky burst, then th… |
| `lightning/static-burst` | 112x112 | 13 | 60 | 16.7 | 1x | 56,58 |  |  | Angular bolts stab inward to a pale knot, then one white frame of a large clean nine-poin… |
| `lightning/storm-field` | 124x129 | 24 | 60 | 16.7 | loop | 62,95 |  |  | A crackling ground circle of static where small bolts strike at random points around the … |
| `lightning/thunder-cloud` | 56x72 | 24 | 70 | 14.3 | loop | 28,69 |  |  | Seamless storm-cloud hazard loop: dark slate lobes churn over slanted two-depth rain that… |
| `lightning/thunderclap` | 128x112 | 11 | 60 | 16.7 | 1x | 64,72 | 60 |  | A thunder blast on the ground: one jagged white flash, then a crackling electric ring rac… |
| `melee/axe-smear` | 128x104 | 9 | 80 | 12.5 | 1x | 66,50 |  |  | A heavy overhead axe chop: a thick steel crescent smear arcs down over three frames with … |
| `melee/dagger-slash` | 48x40 | 7 | 60 | 16.7 | 1x | 22,20 |  |  | A quick double stab-slash: two thin, short steel crescents hook forward to the same point… |
| `melee/greatsword-sweep` | 104x64 | 15 | 70 | 14.3 | 1x | 52,34 | 280 |  | A heavy two-handed horizontal sweep: a slow wind-up glint, one thick steel crescent with … |
| `melee/hammer-smash` | 84x56 | 15 | 60 | 16.7 | 1x | 44,44 |  |  | A heavy overhead hammer blow: a thick earth-toned crescent smear lands on the ground, one… |
| `melee/quickdraw-slash` | 104x64 | 11 | 70 | 14.3 | 1x | 52,32 | 210 |  | An iaido draw: one white hairline cut across the frame, a held beat of stillness, then th… |
| `melee/rapier-flurry` | 64x48 | 16 | 60 | 16.7 | 1x | 6,24 |  |  | A flurry of fast rapier thrusts: thin steel needles stabbing out at slightly different an… |
| `melee/scythe-reap` | 96x92 | 16 | 70 | 14.3 | 1x | 44,58 |  |  | A wide reaping stroke swept low to high: a hooked violet crescent with one white edge, gh… |
| `melee/shadow-claw` | 56x56 | 12 | 50 | 20.0 | 1x | 28,28 |  |  | A three-claw shadow rake swiped down-right: three tapered violet crescents land a frame a… |
| `melee/shield-bash` | 72x52 | 16 | 60 | 16.7 | 1x | 14,28 |  |  | A forward shield shove: a curved shield-shaped shock front with one white frame, a jolt o… |
| `melee/spear-thrust` | 72x32 | 10 | 60 | 16.7 | 1x | 12,16 |  |  | A straight spear lunge: a tapered steel wedge smear with a warm-white head and parallel s… |
| `melee/spin-slash` | 120x72 | 14 | 60 | 16.7 | 1x | 60,34 |  |  | A full spinning slash around the actor: a flattened ring smear, thick and bright on the n… |
| `melee/sword-combo` | 104x64 | 14 | 70 | 14.3 | 1x | 52,30 |  |  | Three crescent slashes in quick succession: down, rising reverse, and a heavy horizontal … |
| `melee/uppercut` | 48x76 | 10 | 60 | 16.7 | 1x | 24,62 | 120 |  | A rising fist: a tall teardrop smear that shoots up, a white pop of sparks at the top, an… |
| `melee/whip-crack` | 96x40 | 8 | 60 | 16.7 | 1x | 5,22 |  |  | A whip lashes out to the right: a hooked wind-up, an S-wave rolling out along the lash wi… |
| `nature/acid-spit` | 80x40 | 20 | 60 | 16.7 | 1x | 74,26 | 300 |  | A lumpy, glowing gob of acid is spat along a shallow arc, dripping droplets and shedding … |
| `nature/acid-splash` | 96x72 | 27 | 70 | 14.3 | 1x | 48,64 | 140 |  | A glob lands and bursts into a crown of acid droplets that arc and splat; the puddle bubb… |
| `nature/bloom-heal` | 56x64 | 22 | 70 | 14.3 | 1x | 28,55 |  |  | A sprout pushes out of a soil crack, unfurls two leaves and a bud that blooms into a six-… |
| `nature/boulder-toss` | 80x56 | 22 | 65 | 15.4 | 1x | 50,46 | 390 |  | A faceted, mossy boulder tumbles along a shallow arc trailing dust, lands in one white du… |
| `nature/earth-spike` | 128x64 | 22 | 70 | 14.3 | 1x | 62,54 |  |  | A fissure splits the floor, six faceted rock spikes punch up in a quick staggered row, ho… |
| `nature/fissure` | 112x40 | 21 | 60 | 16.7 | 1x | 8,27 | 360 |  | A jagged, branching crack races along the ground, opening into a glowing gap as slabs til… |
| `nature/leaf-storm` | 80x56 | 18 | 65 | 15.4 | 1x | 0,0 | 390 |  | Leaves spiral in from the edges into a spinning knot that bursts in one pale flash as a f… |
| `nature/mud-splash` | 80x64 | 26 | 70 | 14.3 | 1x | 40,50 |  |  | A heavy glob of mud slaps the floor and throws up a thick crown with blunt fingers that p… |
| `nature/nature-cast` | 64x64 | 13 | 70 | 14.3 | 1x | 32,36 | 420 |  | Leaves tumble in on a tightening swirl with green spores while a bud of light swells in t… |
| `nature/poison-cloud` | 64x48 | 24 | 80 | 12.5 | loop | 32,45 |  |  | Seamless lingering poison gas loop: a ground-hugging cumulus of shaded green-and-purple l… |
| `nature/pollen-drift` | 64x96 | 32 | 75 | 13.3 | loop | 32,92 |  |  | Seamless ambient loop: golden pollen motes swirl around a lazily swaying column and drift… |
| `nature/quicksand` | 112x60 | 24 | 80 | 12.5 | loop | 56,28 |  |  | Seamless sinking-sand loop: an elliptical pit with a lit far slope and shadowed near slop… |
| `nature/rockfall` | 128x134 | 31 | 70 | 14.3 | 1x | 64,122 |  |  | Faceted boulders and pebbles tumble down in turn, the biggest landing with one white flas… |
| `nature/spore-burst` | 64x56 | 20 | 70 | 14.3 | 1x | 32,52 | 140 |  | A fungal puffball squashes and bursts: a dense ochre-and-olive spore cloud billows up in … |
| `nature/sprout-burst` | 64x56 | 30 | 70 | 14.3 | 1x | 32,48 |  |  | Seeds pop out of the soil and drop back in, a tuft of grass whips up around a climbing st… |
| `nature/thorn-wall` | 128x70 | 27 | 70 | 14.3 | 1x | 64,60 |  |  | A row of woody bramble briars, thick bark canes hooked over with big curved thorns, whips… |
| `nature/vine-snare` | 56x56 | 19 | 70 | 14.3 | 1x | 28,46 |  |  | The ground cracks, four thick vines whip up and coil around the target, lock in one green… |
| `projectiles/acid-glob-flight` | 52x38 | 8 | 70 | 14.3 | loop | 38,16 |  |  | Seamless acid glob flight loop pointing right: a wobbling green glob with a lime lit side… |
| `projectiles/acid-glob-impact` | 80x60 | 21 | 70 | 14.3 | 1x | 38,48 | 70 |  | The acid glob lands: it squashes and throws up a tall, hollow splash crown of bulb-tipped… |
| `projectiles/arrow-flight` | 51x15 | 8 | 60 | 16.7 | loop | 45,7 |  |  | Seamless arrow flight loop pointing right: a wooden arrow with a steel broadhead, fletchi… |
| `projectiles/arrow-impact` | 64x32 | 17 | 60 | 16.7 | 1x | 50,17 | 180 |  | A wooden arrow flies in on a short pale wind streak, thunks into a surface with one white… |
| `projectiles/fireball-flight` | 72x32 | 6 | 70 | 14.3 | loop | 58,16 |  |  | Seamless fireball flight loop pointing right: a round head with a white-yellow leading po… |
| `projectiles/fireball-impact` | 64x56 | 13 | 70 | 14.3 | 1x | 42,32 | 0 |  | Starts at contact: the fireball squashes on the target, one white lobed splat frame with … |
| `projectiles/holy-lance-flight` | 72x28 | 8 | 70 | 14.3 | loop | 64,14 |  |  | Seamless holy-lance flight loop pointing right: a bold faceted golden lance head with a w… |
| `projectiles/holy-lance-impact` | 72x72 | 17 | 70 | 14.3 | 1x | 46,34 | 0 |  | Starts at contact: the holy lance pins into the target, one white cross-flare frame that … |
| `projectiles/ice-shard` | 112x48 | 19 | 70 | 14.3 | 1x | 92,24 | 350 |  | A faceted ice crystal launched from a frost puff flies right on a thin cold streak sheddi… |
| `projectiles/lightning-bolt-flight` | 72x32 | 10 | 60 | 16.7 | loop | 58,16 |  |  | Seamless lightning-bolt flight loop pointing right: a crackling spearpoint head with a wh… |
| `projectiles/lightning-bolt-impact` | 64x64 | 12 | 60 | 16.7 | 1x | 42,32 | 0 |  | Starts at contact: the lightning spear rams the target, one white jagged starburst frame,… |
| `projectiles/magic-missile` | 156x60 | 28 | 70 | 14.3 | 1x | 128,30 | 700 | ember,frost,venom,solar,spirit | Arcane orb: gather, flight on an S path dragging a long twisting ribbon that ends in a do… |
| `projectiles/poison-dart` | 96x40 | 18 | 60 | 16.7 | 1x | 80,18 | 240 |  | A small barbed dart streaks in trailing toxic droplets and a curling vapour wisp, bursts … |
| `projectiles/shuriken-flight` | 36x24 | 8 | 60 | 16.7 | loop | 22,12 |  |  | Seamless shuriken flight loop travelling right: a four-point steel star with hooked, beve… |
| `projectiles/shuriken-impact` | 46x48 | 12 | 60 | 16.7 | 1x | 34,18 | 60 |  | A spinning steel shuriken bites into a wall on the right: one white tick along the wall f… |
| `projectiles/thorn-shot-flight` | 64x28 | 8 | 70 | 14.3 | loop | 46,14 |  |  | Seamless thorn-shot flight loop pointing right: a bold hooked thorn with a pale lit rim s… |
| `projectiles/thorn-shot-impact` | 64x40 | 17 | 70 | 14.3 | 1x | 46,16 | 70 |  | A spinning thorn punches into a target on one white crack-flash, its shaft splinters into… |
| `projectiles/water-bolt-flight` | 56x28 | 6 | 70 | 14.3 | loop | 40,14 |  |  | Seamless water-bolt flight loop pointing right: a wobbling teardrop of water with a foam … |
| `projectiles/water-bolt-impact` | 72x52 | 18 | 70 | 14.3 | 1x | 50,26 | 70 |  | A water bolt slaps into a target on one white frame, blooms back into a tall crescent cup… |
| `scifi/bullet-impact` | 56x48 | 13 | 60 | 16.7 | 1x | 42,26 |  |  | A bullet from the left strikes a hard surface: a contact bead and crack of light, one whi… |
| `scifi/bullet-tracer` | 56x16 | 8 | 60 | 16.7 | loop | 46,8 |  |  | Seamless tracer round in flight pointing right: a cel-shaded slug with a cream core insid… |
| `scifi/cloak-shimmer` | 48x72 | 24 | 70 | 14.3 | loop | 22,69 |  |  | Seamless sci-fi cloak loop: an invisible figure shown only by a broken refractive outline… |
| `scifi/drone-thruster` | 24x40 | 12 | 60 | 16.7 | loop | 12,9 |  |  | Seamless sci-fi drone thruster loop: a small steel nozzle firing a downward jet with a pa… |
| `scifi/emp-pulse` | 120x120 | 14 | 60 | 16.7 | 1x | 60,60 |  |  | An electromagnetic pulse face-on: a primed device core, one white square-cornered flash, … |
| `scifi/energy-shield` | 88x64 | 16 | 75 | 13.3 | loop | 44,57 |  | ember,venom,void,solar | Seamless sci-fi shield loop: a tall hard-surface dome with a crisp cyan rim, a faint hex … |
| `scifi/hologram-glitch` | 48x64 | 16 | 75 | 13.3 | loop | 24,60 |  |  | Seamless sci-fi hologram loop: a projector puck with chasing status lights throws a dashe… |
| `scifi/laser-beam` | 128x24 | 8 | 60 | 16.7 | loop | 12,12 |  |  | A ruler-straight cyan laser held from a pulsing emitter flare off the right edge: a crisp… |
| `scifi/laser-impact` | 80x56 | 18 | 60 | 16.7 | 1x | 64,30 | 60 |  | A cyan laser burns into a surface, starting on contact: a hot dot, one white frame flatte… |
| `scifi/laser-sword-slash` | 96x80 | 10 | 60 | 16.7 | 1x | 48,37 | 120 |  | A neon blade swings a wide diagonal arc: one white-cored peak crescent inside pink and vi… |
| `scifi/mech-explosion` | 120x128 | 19 | 70 | 14.3 | 1x | 60,119 |  |  | A machine blowing apart on the ground: cracks of light, one white frame of an angular sta… |
| `scifi/muzzle-flash` | 40x28 | 10 | 60 | 16.7 | 1x | 3,15 |  |  | A gun's muzzle flash firing right: one white star frame with a long forward spike and dia… |
| `scifi/plasma-bolt-flight` | 72x28 | 8 | 60 | 16.7 | loop | 65,14 |  | ember,venom,void,solar | A cyan plasma slug in flight, pointing +x: a round white-hot heart banded through pale cy… |
| `scifi/plasma-impact` | 88x64 | 18 | 60 | 16.7 | 1x | 54,32 | 60 | ember,venom,void,solar | The cyan plasma bolt splashes on a target, starting on contact: its nose squashes, one wh… |
| `scifi/railgun-shot` | 160x32 | 15 | 60 | 16.7 | 1x | 9,16 | 60 |  | A railgun fires right: a pale charge, one white frame of a dead-straight hair-thin beam w… |
| `scifi/rocket-exhaust` | 96x40 | 8 | 60 | 16.7 | loop | 90,20 |  |  | Seamless rocket thruster plume streaming left from a nozzle on the right: a pale blue-whi… |
| `scifi/scanner-sweep` | 104x64 | 24 | 70 | 14.3 | loop | 52,30 |  |  | Seamless sci-fi scanner loop: a pale cyan scan line sweeps across a floor area in perspec… |
| `scifi/shield-hit` | 88x64 | 12 | 60 | 16.7 | 1x | 44,57 | 60 | ember,venom,void,solar | The energy shield takes a shot from the left: a plasma bolt strikes the dome, the hex cel… |
| `scifi/shotgun-blast` | 72x44 | 15 | 60 | 16.7 | 1x | 3,25 |  |  | A shotgun firing right: one white frame of a wide ragged flash cone with pellet streaks l… |
| `scifi/teleport-beam` | 48x72 | 13 | 60 | 16.7 | 1x | 24,66 |  |  | Sci-fi teleport arrival: an emitter ring opens overhead and drops a scanline column onto … |
| `scifi/warp-jump` | 64x96 | 13 | 60 | 16.7 | 1x | 32,88 | 420 |  | A figure warps out: it stretches into a tall line of light that lifts off the floor, coll… |
| `shadow/curse` | 96x112 | 28 | 80 | 12.5 | 1x | 48,66 |  |  | A dark curse pool opens at the target's feet, a scowling skull-wraith tears up out of it … |
| `shadow/dark-mist` | 128x52 | 36 | 80 | 12.5 | loop | 0,50 |  |  | Seamless low creeping mist of violet-black that tiles on x: a flat, wispy layer darkest a… |
| `shadow/doom-mark` | 44x67 | 20 | 80 | 12.5 | loop | 22,24 |  |  | Seamless doom debuff loop: a violet skull mark bobbing over the target, its eyes glaring … |
| `shadow/hex-sigil` | 64x66 | 22 | 70 | 14.3 | 1x | 32,36 | 560 |  | A curse sigil draws itself over a target in thin violet strokes (ring, inverted triangle,… |
| `shadow/shadow-bolt` | 112x56 | 19 | 70 | 14.3 | 1x | 86,30 | 560 |  | A writhing violet-black smoke bolt with a magenta-white core flies right trailing curling… |
| `shadow/shadow-burst` | 112x108 | 14 | 70 | 14.3 | 1x | 56,54 | 70 |  | A dark explosion: an inverted flash of a jagged black star with a violet rim, then black … |
| `shadow/shadow-cast` | 64x64 | 13 | 70 | 14.3 | 1x | 32,36 | 420 |  | Violet-black smoke tendrils curl inward, lit magenta by a dark orb gathering at the hand,… |
| `shadow/shadow-spikes` | 136x64 | 22 | 70 | 14.3 | 1x | 68,56 | 140 |  | A dark pool runs along the ground and black spikes burst up from it in a staggered line, … |
| `shadow/shadow-step` | 96x60 | 22 | 70 | 14.3 | 1x | 48,50 | 630 |  | A shadow teleport: a hooded shadow figure melts into a puddle, a smear of dark wisps race… |
| `shadow/shadow-tendrils` | 64x56 | 21 | 70 | 14.3 | 1x | 32,46 | 350 |  | A shadow pool spreads and five glossy liquid-shadow tentacles erupt, curl in and clench o… |
| `shadow/soul-drain` | 96x48 | 23 | 65 | 15.4 | 1x | 0,0 |  |  | Pale teardrop souls are torn out of a target and stream left on wavy staggered paths into… |
| `shadow/void-implosion` | 96x96 | 21 | 70 | 14.3 | 1x | 48,48 |  |  | Violet arms and debris spiral into a black core with a sickly rim, it holds, pops on one … |
| `shadow/void-rift` | 64x94 | 24 | 80 | 12.5 | loop | 32,47 |  |  | Seamless loop of a vertical tear in space: a black slit with a deep violet lip and ragged… |
| `smoke/chimney-smoke` | 61x64 | 24 | 80 | 12.5 | loop | 12,61 |  |  | A seamless chimney smoke loop: a thin plume rises from a point, swells and drifts sideway… |
| `smoke/dash-dust` | 68x32 | 13 | 60 | 16.7 | 1x | 24,28 |  |  | A dash/skid dust: billows kick back and up from the start foot, a low dust streak and spe… |
| `smoke/dust-puff` | 72x40 | 14 | 70 | 14.3 | 1x | 36,33 |  |  | A landing dust puff: soft scalloped billows roll out along the ground and rise, thin into… |
| `smoke/landing-dust` | 88x46 | 12 | 70 | 14.3 | 1x | 44,40 |  |  | Dust shoots out sideways from under a landing figure in two low, unequal plumes whose hea… |
| `smoke/smoke-bomb` | 64x56 | 21 | 70 | 14.3 | 1x | 32,50 | 140 |  | A ninja smoke bomb: a pellet lands and pops white, a low wide cloud of six shaded grey-vi… |
| `smoke/smoke-screen` | 168x84 | 22 | 80 | 12.5 | 1x | 84,80 |  |  | A smoke grenade pops and fills a wide area: big grey lobes roll out along the ground into… |
| `smoke/soot-burst` | 74x62 | 13 | 70 | 14.3 | 1x | 19,33 | 70 |  | A cartoon backfire: a jagged white-hot bang throws a fat black cauliflower puff of soot t… |
| `smoke/steam-vent` | 48x72 | 30 | 80 | 12.5 | loop | 14,68 |  |  | A hissing steam vent loop: soft shaded puffs rise from a small glowing floor crack, lean,… |
| `status/berserk` | 56x64 | 16 | 70 | 14.3 | loop | 28,61 |  |  | A seamless berserk status loop: a jagged blood-red vein outline round the figure throbs w… |
| `status/bleeding` | 40x56 | 20 | 80 | 12.5 | loop | 20,49 |  |  | Seamless bleeding status loop on an implied body: three wounds bead and swell drops that … |
| `status/blessed` | 48x64 | 16 | 80 | 12.5 | loop | 24,58 |  |  | Seamless blessed/holy-buff status loop: a soft golden halo bobs above an empty character … |
| `status/burning-aura` | 48x64 | 12 | 75 | 13.3 | loop | 24,54 |  |  | Seamless burning status loop: shaded flame tongues around an empty character footprint th… |
| `status/charm-hearts` | 40x40 | 20 | 80 | 12.5 | loop | 20,23 |  |  | Seamless charmed status loop: four chunky shaded hearts bob and rock round a tilted orbit… |
| `status/confused` | 50x52 | 16 | 75 | 13.3 | loop | 25,48 |  |  | A seamless confused-status loop: a wobbling dizzy spiral spins over the head while gold q… |
| `status/electrified` | 48x56 | 14 | 65 | 15.4 | loop | 24,47 |  |  | Seamless shocked status loop: jagged 2 px-cored arcs crawl and flicker over a character's… |
| `status/frozen-chill` | 40x48 | 14 | 70 | 14.3 | loop | 20,42 |  |  | Seamless chilled/slowed status loop: faceted ice crystals crusting the feet that glint in… |
| `status/haste` | 72x52 | 16 | 60 | 16.7 | loop | 48,47 |  |  | A seamless haste status loop around a character facing right: a cyan wind shell hugs its … |
| `status/petrified` | 72x54 | 17 | 70 | 14.3 | 1x | 36,48 | 420 |  | A petrify overlay for any character: stone collars close round it from the feet up in sea… |
| `status/poisoned` | 64x80 | 18 | 80 | 12.5 | loop | 32,72 |  |  | Seamless poison status loop wrapping an empty character footprint: two tall toxic vapour … |
| `status/power-up-aura` | 56x56 | 14 | 70 | 14.3 | loop | 28,50 |  | frost,venom,void,spirit | Seamless powered-up status loop: golden energy flames licking up from a ground ellipse an… |
| `status/silenced` | 52x46 | 16 | 75 | 13.3 | loop | 26,22 |  |  | Seamless loop: a speech bubble struck through by a red bar floats over the target with a … |
| `status/sleep` | 40x48 | 30 | 80 | 12.5 | loop | 12,46 |  |  | Seamless asleep status loop: chunky shaded Z glyphs drift up and right on uneven sways, g… |
| `status/slowed` | 48x56 | 16 | 80 | 12.5 | loop | 24,50 |  |  | Seamless slowed status loop on an empty character footprint: heavy grey-teal swirl bands … |
| `status/soaked` | 48x56 | 16 | 75 | 13.3 | loop | 24,50 |  |  | Seamless soaked/wet status loop on an empty character footprint: beads swell at the hair,… |
| `status/stun-stars` | 48x32 | 16 | 75 | 13.3 | loop | 24,16 |  |  | Seamless dazed status loop: four bevelled five-point stars tumble round a tight tilted or… |
| `status/target-mark` | 68x68 | 16 | 60 | 16.7 | loop | 34,34 |  |  | Seamless target reticle loop: a red ring of arcs and inward chevrons that turn against ea… |
| `ui/buff-arrow` | 40x48 | 13 | 60 | 16.7 | 1x | 20,42 | 360 |  | Gold upward chevrons snap up one after another and stack, a pale shine climbs through the… |
| `ui/chest-open` | 72x80 | 18 | 70 | 14.3 | 1x | 36,58 | 140 |  | An overlay for a chest sprite: a slit of light cracks along the lid seam, bursts into a w… |
| `ui/click-ripple` | 37x37 | 8 | 60 | 16.7 | 1x | 18,18 |  |  | A crisp UI click: a pale press, one white frame of a ringed cross, then the ring runs out… |
| `ui/coin-pickup` | 32x32 | 10 | 60 | 16.7 | 1x | 16,16 |  |  | A gold glint winks, one white four-point star peak over a gold X, a held pale star inside… |
| `ui/debuff-arrow` | 44x60 | 13 | 80 | 12.5 | 1x | 22,47 | 240 |  | Wide purple downward chevrons fade in high, drop and land heavily into a stack, sag with … |
| `ui/gem-pickup` | 40x48 | 15 | 60 | 16.7 | 1x | 20,32 |  |  | A faceted green gem pops and hops, a shine sweeps its facets, it flashes white once with … |
| `ui/heal-plus` | 46x48 | 13 | 70 | 14.3 | 1x | 23,38 |  |  | Green plus signs leave a point on staggered beats, float up swaying and grow in steps, th… |
| `ui/heart-pickup` | 32x40 | 10 | 70 | 14.3 | 1x | 16,27 |  |  | A chunky heart squashes, pops up and bursts in one white frame; a pink ring breaks into d… |
| `ui/level-up` | 64x96 | 20 | 70 | 14.3 | 1x | 32,88 | 420 | frost,venom,void,spirit | Floor glint, a gold ring sweeping feet to crown with rising light streaks, one white crow… |
| `ui/mana-pickup` | 44x44 | 13 | 60 | 16.7 | 1x | 22,22 | 480 |  | A shaded blue orb swells and bursts into motes that swing out, spiral back inward faster … |
| `ui/star-burst-pickup` | 40x40 | 13 | 60 | 16.7 | 1x | 20,26 |  | frost,venom,void,spirit | A gold five-point star squashes, stretches and spins edge-on, flashes one white four-poin… |
| `ui/treasure-glint` | 48x48 | 16 | 75 | 13.3 | loop | 24,24 |  |  | Looping pickup glint: a crisp leaning four-point hero star grows to one white beat that f… |
| `water/bubble-burst` | 48x48 | 12 | 60 | 16.7 | 1x | 24,24 |  |  | Four wobbling water bubbles swell; the largest pops on one white frame into droplet wedge… |
| `water/bubble-shield` | 70x76 | 16 | 75 | 13.3 | loop | 35,70 |  |  | Seamless bubble shield status loop: a wobbling water bubble standing around the figure, a… |
| `water/drip-splash` | 54x48 | 20 | 60 | 16.7 | 1x | 27,40 | 180 |  | A single drop falls and lands: a white splat frame, a tiny five-tined crown whose outer t… |
| `water/ripple` | 96x52 | 24 | 75 | 13.3 | loop | 48,30 |  |  | Seamless water ripple loop: a drop falls into still water, splashes a tiny crown and jet … |
| `water/tidal-wave` | 96x56 | 20 | 70 | 14.3 | 1x | 48,47 | 350 |  | A swell rises, curls a foam-lipped wave that rolls right and crashes on one white foam fr… |
| `water/water-cast` | 64x64 | 13 | 70 | 14.3 | 1x | 32,28 | 420 |  | Droplets and a ribbon of water spiral into a wobbling orb at the hand, it swells and comp… |
| `water/water-geyser` | 48x88 | 21 | 65 | 15.4 | 1x | 24,80 | 130 |  | A wet patch bubbles, then a wavering water column blasts up under a churning foam crown t… |
| `water/water-jet` | 136x62 | 20 | 60 | 16.7 | 1x | 8,20 | 240 |  | A pressurised water stream blasts forward behind a bulbous foam-fronted head that bursts … |
| `water/water-splash` | 112x80 | 22 | 70 | 14.3 | 1x | 56,66 | 70 |  | A drop hits the water: a ragged crown cup flares on one white frame, tears open around a … |
| `water/water-whip` | 148x100 | 18 | 70 | 14.3 | 1x | 18,67 | 350 |  | A tendril of water climbs from the hand, curls overhead and lashes forward in a whip wave… |
| `water/whirlpool` | 72x48 | 20 | 70 | 14.3 | loop | 36,25 |  |  | Seamless ground whirlpool loop: ragged spiral arms with lit foam crests and deep shadow s… |
| `wind/air-burst` | 112x74 | 17 | 60 | 16.7 | 1x | 8,44 | 60 |  | A forward blast of compressed air: a soft white pop at the muzzle, a cone of crescent pre… |
| `wind/sonic-boom` | 128x96 | 16 | 60 | 16.7 | 1x | 44,48 | 180 |  | A sonic boom tearing past left to right: a pale bead of compressed air snaps open into a … |
| `wind/tornado` | 84x112 | 16 | 70 | 14.3 | loop | 42,102 |  |  | Seamless tornado loop: a tall solid grey-white funnel lit on one side, twisting diagonal … |
| `wind/updraft` | 56x80 | 16 | 75 | 13.3 | loop | 28,74 |  |  | Seamless updraft loop: air lines rise out of a floor vent as swaying, fanning streamlines… |
| `wind/vacuum-pull` | 112x90 | 17 | 60 | 16.7 | 1x | 56,49 | 600 |  | A vacuum draws everything in: thick spiral arms and air lines rush inward from the first … |
| `wind/whirlwind` | 48x72 | 14 | 65 | 15.4 | loop | 24,68 |  |  | Seamless whirlwind loop: a swaying funnel of pale grey-green crescent bands sliding aroun… |
| `wind/wind-blade` | 96x44 | 16 | 60 | 16.7 | 1x | 0,22 | 480 |  | A thrown crescent of compressed air: a thick pale-green blade with two fading echo cresce… |
| `wind/wind-gust` | 96x48 | 13 | 70 | 14.3 | 1x | 48,24 |  |  | A one-shot horizontal gust: a broad white-teal ribbon unrolls into a C-curl in a soft blo… |

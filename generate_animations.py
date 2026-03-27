import json, math, os

OUT = r"c:\fitness\fitapp\assets\animations"
os.makedirs(OUT, exist_ok=True)

# ── helpers ──────────────────────────────────────────────────────────────────

def rect(cx, cy, w, h, r=8):
    return {"ty":"rc","d":1,"s":{"a":0,"k":[w,h]},"p":{"a":0,"k":[cx,cy]},"r":{"a":0,"k":r}}

def ellipse(cx, cy, w, h):
    return {"ty":"el","d":1,"s":{"a":0,"k":[w,h]},"p":{"a":0,"k":[cx,cy]}}

def fill(r,g,b, op=100):
    return {"ty":"fl","c":{"a":0,"k":[r,g,b,1]},"o":{"a":0,"k":op},"r":1}

def stroke(r,g,b, width=3, op=100):
    return {"ty":"st","c":{"a":0,"k":[r,g,b,1]},"o":{"a":0,"k":op},"w":{"a":0,"k":width},"lc":2,"lj":2}

def tr(px=0,py=0,ax=0,ay=0,sx=100,sy=100,rot=0,op=100):
    return {"ty":"tr","p":{"a":0,"k":[px,py]},"a":{"a":0,"k":[ax,ay]},
            "s":{"a":0,"k":[sx,sy]},"r":{"a":0,"k":rot},"o":{"a":0,"k":op},
            "sk":{"a":0,"k":0},"sa":{"a":0,"k":0}}

def tr_anim_rot(frames, px=0, py=0, ax=0, ay=0):
    """Animated rotation transform"""
    kfs = []
    for i,(t,v) in enumerate(frames):
        kf = {"t":t,"s":[v]}
        if i < len(frames)-1:
            kf["i"] = {"x":[0.42],"y":[1]}
            kf["o"] = {"x":[0.58],"y":[0]}
        kfs.append(kf)
    return {"ty":"tr","p":{"a":0,"k":[px,py]},"a":{"a":0,"k":[ax,ay]},
            "s":{"a":0,"k":[100,100]},"r":{"a":1,"k":kfs},"o":{"a":0,"k":100},
            "sk":{"a":0,"k":0},"sa":{"a":0,"k":0}}

def tr_anim_pos(frames, ax=0, ay=0, rot=0):
    """Animated position transform"""
    kfs = []
    for i,(t,x,y) in enumerate(frames):
        kf = {"t":t,"s":[x,y,0]}
        if i < len(frames)-1:
            kf["i"] = {"x":0.42,"y":1}
            kf["o"] = {"x":0.58,"y":0}
            kf["to"] = [0,0,0]; kf["ti"] = [0,0,0]
        kfs.append(kf)
    return {"ty":"tr","p":{"a":1,"k":kfs},"a":{"a":0,"k":[ax,ay,0]},
            "s":{"a":0,"k":[100,100,100]},"r":{"a":0,"k":rot},"o":{"a":0,"k":100},
            "sk":{"a":0,"k":0},"sa":{"a":0,"k":0}}

def group(name, shapes, transform):
    return {"ty":"gr","nm":name,"it":shapes+[transform]}

def layer(ind, name, shapes, ip=0, op=60):
    return {"ddd":0,"ind":ind,"ty":4,"nm":name,"sr":1,
            "ks":{"o":{"a":0,"k":100},"r":{"a":0,"k":0},
                  "p":{"a":0,"k":[0,0,0]},"a":{"a":0,"k":[0,0,0]},
                  "s":{"a":0,"k":[100,100,100]}},
            "ao":0,"shapes":shapes,"ip":ip,"op":op,"st":0}

def base_template(name, layers, fr=30, op=60):
    return {"v":"5.7.4","fr":fr,"ip":0,"op":op,"w":400,"h":500,
            "nm":name,"ddd":0,"assets":[],"layers":layers}

# Colour palette
SKIN  = [0.96, 0.78, 0.64]
HAIR  = [0.18, 0.12, 0.08]
SHIRT = [0.38, 0.52, 0.96]
PANTS = [0.15, 0.20, 0.55]
SHOE  = [0.12, 0.12, 0.14]
ACC   = [0.56, 0.32, 0.98]   # accent purple

# ── 1. PUSH-UP (chest.json) ───────────────────────────────────────────────────
# Body tilts down/up, arms extend/flex
def make_chest():
    OP=90
    # Head bobbing down/up with push-up
    # Body tilted horizontal (like doing pushup from side view)
    head = layer(1,"Head",[
        group("head",[ellipse(0,0,54,58), fill(*SKIN)], tr(200,160))
    ], op=OP)
    hair = layer(2,"Hair",[
        group("hair",[rect(0,-12,52,30,14), fill(*HAIR)], tr(200,148))
    ], op=OP)
    torso_anim = tr_anim_pos([(0,200,240),(22,200,255),(45,200,240),(67,200,255),(89,200,240)], rot=-10)
    torso = layer(3,"Torso",[
        group("torso",[rect(0,0,70,110,10), fill(*SHIRT)], torso_anim)
    ], op=OP)
    # Left arm – upper arm fixed, forearm rotates (elbow bends)
    larm_up = layer(4,"LArm-Upper",[
        group("lau",[rect(0,0,22,70,8), fill(*SHIRT)],
              tr_anim_pos([(0,165,210),(22,165,220),(45,165,210),(67,165,220),(89,165,210)], rot=-30))
    ], op=OP)
    larm_fore = layer(5,"LArm-Fore",[
        group("laf",[rect(0,0,20,65,8), fill(*SKIN)],
              tr_anim_rot([(0,-50),(22,10),(45,-50),(67,10),(89,-50)], px=165, py=260, ax=0, ay=-30))
    ], op=OP)
    rarm_up = layer(6,"RArm-Upper",[
        group("rau",[rect(0,0,22,70,8), fill(*SHIRT)],
              tr_anim_pos([(0,235,210),(22,235,220),(45,235,210),(67,235,220),(89,235,210)], rot=30))
    ], op=OP)
    rarm_fore = layer(7,"RArm-Fore",[
        group("raf",[rect(0,0,20,65,8), fill(*SKIN)],
              tr_anim_rot([(0,50),(22,-10),(45,50),(67,-10),(89,50)], px=235, py=260, ax=0, ay=-30))
    ], op=OP)
    legs = layer(8,"Legs",[
        group("legs",[rect(-18,0,22,120,8), fill(*PANTS),
                      rect(18,0,22,120,8), fill(*PANTS)], tr(200,360))
    ], op=OP)
    lfeet = layer(9,"Feet",[
        group("feet",[rect(-18,0,40,18,5), fill(*SHOE),
                      rect(18,0,40,18,5), fill(*SHOE)], tr(200,425))
    ], op=OP)
    return base_template("Push-Up",[lfeet,legs,larm_fore,rarm_fore,larm_up,rarm_up,torso,hair,head], fr=30, op=OP)

# ── 2. RUNNING (cardio.json) ─────────────────────────────────────────────────
def make_cardio():
    OP=80
    # Body bobs, arms and legs swing alternately
    head = layer(1,"Head",[
        group("h",[ellipse(0,0,52,56), fill(*SKIN)],
              tr_anim_pos([(0,200,90),(10,200,85),(20,200,90),(30,200,85),(40,200,90),(50,200,85),(60,200,90),(70,200,85),(79,200,90)]))
    ], op=OP)
    torso = layer(2,"Torso",[
        group("t",[rect(0,0,68,100,10), fill(*SHIRT)],
              tr_anim_pos([(0,200,195),(10,200,190),(20,200,195),(30,200,190),(40,200,195),(50,200,190),(60,200,195),(70,200,190),(79,200,195)]))
    ], op=OP)
    # Arms swing opposite to legs
    larm = layer(3,"LArm",[
        group("la",[rect(0,-30,20,70,8), fill(*SHIRT)],
              tr_anim_rot([(0,-45),(20,30),(40,-45),(60,30),(79,-45)], px=168,py=215, ax=0,ay=-5))
    ], op=OP)
    rarm = layer(4,"RArm",[
        group("ra",[rect(0,-30,20,70,8), fill(*ACC)],
              tr_anim_rot([(0,45),(20,-30),(40,45),(60,-30),(79,45)], px=232,py=215, ax=0,ay=-5))
    ], op=OP)
    lthigh = layer(5,"LThigh",[
        group("lt",[rect(0,-40,24,90,8), fill(*PANTS)],
              tr_anim_rot([(0,-50),(20,30),(40,-50),(60,30),(79,-50)], px=185,py=310, ax=0,ay=-30))
    ], op=OP)
    rthigh = layer(6,"RThigh",[
        group("rt",[rect(0,-40,24,90,8), fill(*PANTS)],
              tr_anim_rot([(0,50),(20,-30),(40,50),(60,-30),(79,50)], px=215,py=310, ax=0,ay=-30))
    ], op=OP)
    lshin = layer(7,"LShin",[
        group("ls",[rect(0,-30,20,75,8), fill(*SKIN)],
              tr_anim_rot([(0,30),(20,-50),(40,30),(60,-50),(79,30)], px=185,py=385, ax=0,ay=-25))
    ], op=OP)
    rshin = layer(8,"RShin",[
        group("rs",[rect(0,-30,20,75,8), fill(*SKIN)],
              tr_anim_rot([(0,-30),(20,50),(40,-30),(60,50),(79,-30)], px=215,py=385, ax=0,ay=-25))
    ], op=OP)
    shoes = layer(9,"Shoes",[
        group("sh",[rect(-15,0,40,16,5), fill(*SHOE), rect(15,0,40,16,5), fill(*SHOE)], tr(200,455))
    ], op=OP)
    hair = layer(10,"Hair",[
        group("hr",[rect(0,-10,50,28,12), fill(*HAIR)],
              tr_anim_pos([(0,200,77),(10,200,72),(20,200,77),(30,200,72),(40,200,77),(50,200,72),(60,200,77),(70,200,72),(79,200,77)]))
    ], op=OP)
    return base_template("Running Cardio",[shoes,rshin,lshin,rthigh,lthigh,rarm,larm,torso,hair,head], fr=30, op=OP)

# ── 3. BICEP CURL (arms.json) ────────────────────────────────────────────────
def make_arms():
    OP=90
    head = layer(1,"Head",[group("h",[ellipse(0,0,54,58), fill(*SKIN)], tr(200,100))], op=OP)
    hair = layer(2,"Hair",[group("hr",[rect(0,-12,52,30,14), fill(*HAIR)], tr(200,88))], op=OP)
    torso= layer(3,"Torso",[group("t",[rect(0,0,80,120,10), fill(*SHIRT)], tr(200,225))], op=OP)
    # Left arm – bicep curl upward
    lup  = layer(4,"LUpper",[group("lu",[rect(0,-35,24,80,8), fill(*SHIRT)], tr(155,225))], op=OP)
    lfore= layer(5,"LFore",[group("lf",[rect(0,-30,22,70,8), fill(*SKIN)],
                 tr_anim_rot([(0,0),(22,-110),(45,0),(67,-110),(89,0)], px=155,py=295, ax=0,ay=-25))], op=OP)
    # Right arm – opposite phase
    rup  = layer(6,"RUpper",[group("ru",[rect(0,-35,24,80,8), fill(*ACC)], tr(245,225))], op=OP)
    rfore= layer(7,"RFore",[group("rf",[rect(0,-30,22,70,8), fill(*SKIN)],
                 tr_anim_rot([(0,-110),(22,0),(45,-110),(67,0),(89,-110)], px=245,py=295, ax=0,ay=-25))], op=OP)
    # Dumbbells
    ldb  = layer(8,"LDumbbell",[
        group("ld",[rect(0,0,60,14,5), fill(*SHOE), rect(-24,0,14,24,4), fill(*SHOE), rect(24,0,14,24,4), fill(*SHOE)],
              tr_anim_rot([(0,0),(22,-110),(45,0),(67,-110),(89,0)], px=155,py=360, ax=0,ay=-30))
    ], op=OP)
    legs = layer(9,"Legs",[group("lg",[rect(-20,0,28,130,8), fill(*PANTS), rect(20,0,28,130,8), fill(*PANTS)], tr(200,375))], op=OP)
    feet = layer(10,"Feet",[group("ft",[rect(-20,0,44,18,5), fill(*SHOE), rect(20,0,44,18,5), fill(*SHOE)], tr(200,445))], op=OP)
    return base_template("Bicep Curl",[feet,legs,ldb,rfore,lfore,rup,lup,torso,hair,head], fr=30, op=OP)

# ── 4. SQUAT (legs.json) ─────────────────────────────────────────────────────
def make_legs():
    OP=90
    head = layer(1,"Head",[group("h",[ellipse(0,0,54,58), fill(*SKIN)],
                  tr_anim_pos([(0,200,95),(22,200,165),(45,200,95),(67,200,165),(89,200,95)]))], op=OP)
    hair = layer(2,"Hair",[group("hr",[rect(0,-12,52,30,14), fill(*HAIR)],
                  tr_anim_pos([(0,200,82),(22,200,152),(45,200,82),(67,200,152),(89,200,82)]))], op=OP)
    torso= layer(3,"Torso",[group("t",[rect(0,0,80,110,10), fill(*SHIRT)],
                  tr_anim_pos([(0,200,210),(22,200,280),(45,200,210),(67,200,280),(89,200,210)]))], op=OP)
    # Arms go out during squat
    larm = layer(4,"LArm",[group("la",[rect(0,-30,22,80,8), fill(*SHIRT)],
                  tr_anim_rot([(0,-10),(22,-70),(45,-10),(67,-70),(89,-10)], px=155,py=230))], op=OP)
    rarm = layer(5,"RArm",[group("ra",[rect(0,-30,22,80,8), fill(*SHIRT)],
                  tr_anim_rot([(0,10),(22,70),(45,10),(67,70),(89,10)], px=245,py=230))], op=OP)
    # Thighs rotate outward during squat
    lthigh=layer(6,"LThigh",[group("lt",[rect(0,-40,28,90,8), fill(*PANTS)],
                  tr_anim_rot([(0,-5),(22,-60),(45,-5),(67,-60),(89,-5)], px=182,py=325, ax=0,ay=-40))], op=OP)
    rthigh=layer(7,"RThigh",[group("rt",[rect(0,-40,28,90,8), fill(*PANTS)],
                  tr_anim_rot([(0,5),(22,60),(45,5),(67,60),(89,5)], px=218,py=325, ax=0,ay=-40))], op=OP)
    lshin = layer(8,"LShin",[group("ls",[rect(0,-30,24,80,8), fill(*SKIN)],
                  tr_anim_rot([(0,0),(22,55),(45,0),(67,55),(89,0)], px=175,py=405, ax=0,ay=-25))], op=OP)
    rshin = layer(9,"RShin",[group("rs",[rect(0,-30,24,80,8), fill(*SKIN)],
                  tr_anim_rot([(0,0),(22,-55),(45,0),(67,-55),(89,0)], px=225,py=405, ax=0,ay=-25))], op=OP)
    feet  = layer(10,"Feet",[group("ft",[rect(-22,0,46,18,5), fill(*SHOE), rect(22,0,46,18,5), fill(*SHOE)], tr(200,458))], op=OP)
    return base_template("Squat",[feet,rshin,lshin,rthigh,lthigh,rarm,larm,torso,hair,head], fr=30, op=OP)

# ── 5. DEADLIFT (back.json) ──────────────────────────────────────────────────
def make_back():
    OP=90
    # Torso hinges forward/back
    head = layer(1,"Head",[group("h",[ellipse(0,0,54,58), fill(*SKIN)],
                  tr_anim_pos([(0,200,100),(22,200,195),(45,200,100),(67,200,195),(89,200,100)]))], op=OP)
    hair = layer(2,"Hair",[group("hr",[rect(0,-12,52,30,14), fill(*HAIR)],
                  tr_anim_pos([(0,200,87),(22,200,182),(45,200,87),(67,200,182),(89,200,87)]))], op=OP)
    torso= layer(3,"Torso",[group("t",[rect(0,0,75,120,10), fill(*SHIRT)],
                  tr_anim_rot([(0,-5),(22,60),(45,-5),(67,60),(89,-5)], px=200,py=215, ax=0,ay=-55))], op=OP)
    larm = layer(4,"LArm",[group("la",[rect(0,-30,22,100,8), fill(*SHIRT)],
                  tr_anim_rot([(0,0),(22,55),(45,0),(67,55),(89,0)], px=162,py=220))], op=OP)
    rarm = layer(5,"RArm",[group("ra",[rect(0,-30,22,100,8), fill(*SHIRT)],
                  tr_anim_rot([(0,0),(22,55),(45,0),(67,55),(89,0)], px=238,py=220))], op=OP)
    # Barbell
    bar  = layer(6,"Bar",[
        group("b",[rect(0,0,220,14,4), fill(*SHOE),
                   rect(-95,0,28,38,5), fill(*ACC), rect(95,0,28,38,5), fill(*ACC)],
              tr_anim_pos([(0,200,365),(22,200,280),(45,200,365),(67,200,280),(89,200,365)]))
    ], op=OP)
    legs = layer(7,"Legs",[group("lg",[rect(-20,0,28,130,8), fill(*PANTS), rect(20,0,28,130,8), fill(*PANTS)], tr(200,385))], op=OP)
    feet = layer(8,"Feet",[group("ft",[rect(-20,0,44,18,5), fill(*SHOE), rect(20,0,44,18,5), fill(*SHOE)], tr(200,455))], op=OP)
    return base_template("Deadlift",[feet,legs,bar,rarm,larm,torso,hair,head], fr=30, op=OP)

# ── 6. SHOULDER PRESS (shoulders.json) ───────────────────────────────────────
def make_shoulders():
    OP=90
    head = layer(1,"Head",[group("h",[ellipse(0,0,54,58), fill(*SKIN)], tr(200,100))], op=OP)
    hair = layer(2,"Hair",[group("hr",[rect(0,-12,52,30,14), fill(*HAIR)], tr(200,88))], op=OP)
    torso= layer(3,"Torso",[group("t",[rect(0,0,80,120,10), fill(*SHIRT)], tr(200,225))], op=OP)
    # Arms go from bent at sides to fully extended overhead
    lup  = layer(4,"LUpper",[group("lu",[rect(0,-35,24,80,8), fill(*SHIRT)],
                  tr_anim_rot([(0,-15),(22,-120),(45,-15),(67,-120),(89,-15)], px=155,py=215, ax=0,ay=-30))], op=OP)
    lfore= layer(5,"LFore",[group("lf",[rect(0,-30,22,70,8), fill(*SKIN)],
                  tr_anim_rot([(0,-80),(22,0),(45,-80),(67,0),(89,-80)], px=148,py=285, ax=0,ay=-25))], op=OP)
    rup  = layer(6,"RUpper",[group("ru",[rect(0,-35,24,80,8), fill(*ACC)],
                  tr_anim_rot([(0,15),(22,120),(45,15),(67,120),(89,15)], px=245,py=215, ax=0,ay=-30))], op=OP)
    rfore= layer(7,"RFore",[group("rf",[rect(0,-30,22,70,8), fill(*SKIN)],
                  tr_anim_rot([(0,80),(22,0),(45,80),(67,0),(89,80)], px=252,py=285, ax=0,ay=-25))], op=OP)
    # Dumbbells at hands
    ldb  = layer(8,"LDumbbell",[
        group("ld",[rect(0,0,52,12,4), fill(*SHOE), rect(-20,0,12,22,3), fill(*SHOE), rect(20,0,12,22,3), fill(*SHOE)],
              tr_anim_rot([(0,-80),(22,0),(45,-80),(67,0),(89,-80)], px=145,py=350, ax=0,ay=-30))
    ], op=OP)
    rdb  = layer(9,"RDumbbell",[
        group("rd",[rect(0,0,52,12,4), fill(*SHOE), rect(-20,0,12,22,3), fill(*SHOE), rect(20,0,12,22,3), fill(*SHOE)],
              tr_anim_rot([(0,80),(22,0),(45,80),(67,0),(89,80)], px=255,py=350, ax=0,ay=-30))
    ], op=OP)
    legs = layer(10,"Legs",[group("lg",[rect(-20,0,28,130,8), fill(*PANTS), rect(20,0,28,130,8), fill(*PANTS)], tr(200,375))], op=OP)
    feet = layer(11,"Feet",[group("ft",[rect(-20,0,44,18,5), fill(*SHOE), rect(20,0,44,18,5), fill(*SHOE)], tr(200,445))], op=OP)
    return base_template("Shoulder Press",[feet,legs,rdb,ldb,rfore,lfore,rup,lup,torso,hair,head], fr=30, op=OP)

# ── 7. SIT-UP / CRUNCH (core.json) ───────────────────────────────────────────
def make_core():
    OP=90
    # Person lying, torso crunches up
    head = layer(1,"Head",[group("h",[ellipse(0,0,54,58), fill(*SKIN)],
                  tr_anim_pos([(0,200,380),(22,200,260),(45,200,380),(67,200,260),(89,200,380)]))], op=OP)
    hair = layer(2,"Hair",[group("hr",[rect(0,-12,52,30,14), fill(*HAIR)],
                  tr_anim_pos([(0,200,367),(22,200,247),(45,200,367),(67,200,247),(89,200,367)]))], op=OP)
    torso= layer(3,"Torso",[group("t",[rect(0,0,75,120,10), fill(*SHIRT)],
                  tr_anim_rot([(0,80),(22,20),(45,80),(67,20),(89,80)], px=200,py=400, ax=0,ay=-50))], op=OP)
    # Legs flat on ground
    lthigh=layer(4,"LThigh",[group("lt",[rect(0,-40,28,100,8), fill(*PANTS)],
                  tr_anim_rot([(0,95),(22,85),(45,95),(67,85),(89,95)], px=185,py=455, ax=0,ay=-40))], op=OP)
    rthigh=layer(5,"RThigh",[group("rt",[rect(0,-40,28,100,8), fill(*PANTS)],
                  tr_anim_rot([(0,85),(22,75),(45,85),(67,75),(89,85)], px=215,py=455, ax=0,ay=-40))], op=OP)
    # Arms reach toward knees
    larm = layer(6,"LArm",[group("la",[rect(0,-30,22,80,8), fill(*SHIRT)],
                  tr_anim_rot([(0,60),(22,25),(45,60),(67,25),(89,60)], px=162,py=390, ax=0,ay=-25))], op=OP)
    rarm = layer(7,"RArm",[group("ra",[rect(0,-30,22,80,8), fill(*ACC)],
                  tr_anim_rot([(0,120),(22,155),(45,120),(67,155),(89,120)], px=238,py=390, ax=0,ay=-25))], op=OP)
    # Mat / floor line
    mat  = layer(8,"Mat",[group("m",[rect(0,0,320,14,6), fill(0.2,0.2,0.4)], tr(200,475))], op=OP)
    return base_template("Sit-Up Core",[mat,rthigh,lthigh,rarm,larm,torso,hair,head], fr=30, op=OP)

# ── GENERATE ALL ─────────────────────────────────────────────────────────────
animations = {
    "chest.json":     make_chest(),
    "cardio.json":    make_cardio(),
    "arms.json":      make_arms(),
    "legs.json":      make_legs(),
    "back.json":      make_back(),
    "shoulders.json": make_shoulders(),
    "core.json":      make_core(),
}

for fname, data in animations.items():
    path = os.path.join(OUT, fname)
    with open(path, "w") as f:
        json.dump(data, f, separators=(',',':'))
    size = os.path.getsize(path)
    print(f"✓ {fname:20s}  {size:,} bytes")

print("\nAll animations generated successfully!")

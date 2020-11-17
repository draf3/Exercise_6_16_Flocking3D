import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

GUI gui;
Flock flock;
Path path;

PostFX fx;

int max_path = 100;
int flock_s = 500;
float maxDist;

boolean isPostFX = true;
boolean isSaved = false;

void setup() {
  size(1200, 800, P3D);
  colorMode(HSB, 360, 100, 100);
  gui = new GUI(this);
  init();
}

void init() {
  flock = new Flock();
  createPath();

  if (isPostFX) {
    fx = new PostFX(this); 
  }

  for (int i = 0; i < flock_s; i++) {
    flock.addBoid(new Boid(random(width), random(height), 0, i));
  }
}

void draw() {
  
  // 背景を描画する
  if (isPostFX) {
    background(0, 0, 90);
    
  } else {
    color c1 = color(0, 0, 100);
    color c2 = color(0, 0, 50);
    maxDist = dist(0, 0, width, height);
    for (float d = maxDist; d > 0; d -= 5) {
      color c = lerpColor(c1, c2, d / maxDist);
      fill(c);
      ellipse(width / 2, height / 2, d, d);
    }
  }  

  // シーン設定
  pushMatrix();
  
  directionalLight(0, 0, 100, 100, 100, -500); 
  camera(0, 0, 600, 
    0, 0, 0, 
    0, 1, 0);
    
  translate(-width/2, -height/2, 0);
  
  // パスを更新して描画する
  path.update();
  path.display();
  
  // ボイドルールの更新と描画
  float sep = gui.separate.getValue();
  float ali = gui.align.getValue();
  float coh = gui.cohesion.getValue();
  float lat = gui.laterally.getValue();
  float pa = gui.path.getValue();
  float maxspeed = gui.maxspeed.getValue();
  float maxforce = gui.maxforce.getValue();
  float neighbordist = gui.neighbordist.getValue();
  float desiredseparation = gui.desiredseparation.getValue();
  flock.update(sep, ali, coh, lat, pa, maxspeed, maxforce, neighbordist, desiredseparation);
  flock.follow(path);
  flock.run();

  popMatrix();
  
  // ポストエフェクト
  if (isPostFX) {
    fx.render()
      .bloom(0.5, 7, 7)
      .vignette(0.5, 0.05)
      .compose();
  }

  // 連番画像を保存する
  if (isSaved) {
    saveFrame("output/######.png");
  }
} 

// パスを生成する
void createPath() {
  path = new Path();
  for (int i = 0; i < max_path; i++) {
    path.addPoint(float(i)/(max_path-1)*width, height/2);
  }
}

void keyPressed() {
  // パスの初期化
  if (key == 'p' || key == 'P') {
    createPath();
  }

  // リセット
  if (key == 'r' || key == 'R') {
    init();
  }

  // 連番画像保存
  if (key == 's' || key == 'S') {
    isSaved = !isSaved;
  }
}

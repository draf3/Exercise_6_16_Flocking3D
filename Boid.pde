class Boid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;
  float maxspeed;
  float d;
  int id;
  float sep_w;
  float ali_w;
  float coh_w;
  float lat_w;
  float path_w;
  float neighbordist;
  float desiredseparation;

  Boid(float x, float y, float z, int _id) {
    acceleration = new PVector(0, 0, 0);
    position = new PVector(x, y, z);
    r = 8.0;
    maxspeed = 3;
    velocity = new PVector(random(maxspeed), random(maxspeed), random(maxspeed));
    maxforce = 0.15;
    d = 40;
    id = _id;
    sep_w = 1.0; //分離のパラメータの重み
    ali_w = 1.0; //整列のパラメータの重み
    coh_w = 1.0; //集合のパラメータの重み
    lat_w = 1.0; //視界のパラメータの重み
    path_w = 1.0; //パスのパラメータの重み
    neighbordist = 50; // 整列、結合、視界の基準となる距離
    desiredseparation = r*5; // 分離の基準となる距離
  }
  
  // 力を加速度に加える
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void run(ArrayList<Boid> boids) {
    updateAccel(boids);
    updatePosition();
    border();
    display();
  }

  // 位置を更新する
  void updatePosition() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0); // 加速度は毎回リセットする
  }

  // 加速度を更新する
  void updateAccel(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    PVector lat = laterally(boids);

    // boidアルゴリズムの重みを調整
    sep.mult(sep_w);
    ali.mult(ali_w);
    coh.mult(coh_w);
    lat.mult(lat_w);

    // 力を加速度に適応する
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(lat);
  }

  // 分離
  PVector separate(ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0, 0);
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    
    // 近いボイドの個数とベクトルを合計値を求める
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);

      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }

    // 進行方向を求める
    if (count > 0) {
      sum.div(count);   
      sum.setMag(maxspeed);  
      steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // 整列
  PVector align(ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    
    // 近いボイドの個数と速度の合計値を求める
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    
    // 進行方向を求める
    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0, 0);
    }
  }

  // 結合
  PVector cohesion (ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    
    // 近いボイドの位置の合計値を求める
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position);
        count++;
      }
    }
    
    // 進行方向を求める
    if (count > 0) {
      sum.div(count);
      return seekDir(sum);
    } else {
      return new PVector(0, 0, 0);
    }
  }

  // 視界：視界を遮るボイドを横に避ける
  PVector laterally (ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    
    // 近くかつ視界前方30度の範囲内のボイドの個数と位置を求める
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        float theta = PVector.angleBetween(velocity, PVector.sub(other.position, position));
        float angle = degrees(theta);
        if (angle < 30) {   
          sum.add(other.position);
          count++;
        }
      }
    }
    
    // 進行方向を求める
    if (count > 0) {
      sum.div(count);
      PVector steer = PVector.sub(sum, position);
      steer.normalize();
      steer.rotate(HALF_PI); // ベクトルを90度右回りに回転する
      steer.mult(maxspeed);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0, 0);
    }
  }

  // パスを追従する
  void follow(Path p) {
    PVector predict = velocity.copy();
    predict.normalize();
    predict.mult(50);
    PVector predictPos = PVector.add(position, predict);

    PVector target = new PVector(0, 0, 0);
    float worldRecord = 1000000;
    PVector a = new PVector(0, 0, 0);
    PVector b = new PVector(0, 0, 0);
    PVector normalPoint = new PVector(0, 0, 0);
    PVector dir = new PVector(0, 0, 0);

    // ビークルにもっとも近い法線の点を探索し目標にする
    for (int i = 0; i < p.points.size()-1; i++) {
      a = p.points.get(i);
      b = p.points.get(i+1);
      normalPoint = getNormalPoint(predictPos, a, b);

      if (normalPoint.x < a.x || normalPoint.x > b.x) {
        normalPoint = b.copy();
      }

      float distance = PVector.dist(predictPos, normalPoint);

      // 最も近い法線の点を目標する
      if (distance < worldRecord) {
        worldRecord = distance;
        dir = PVector.sub(b, a);
        dir.normalize();
        dir.mult(10);
        target = normalPoint.copy();
        target.add(dir);
      }
    }
    
    fill(0, 100, 100);
    strokeWeight(0.5);
    stroke(0, 100, 100);
    line(position.x, position.y, position.z, target.x, target.y, 0);// ボイドからパス上の法線の点まで線を引く
    ellipse(target.x, target.y, 5, 5); // 法線の点
    
    // 進行方向の力を求め加速度に加える
    if (worldRecord > p.radius) { 
      PVector steer = seekDir(target);
      steer.mult(path_w);
      applyForce(steer);
    }
  }

  // 進行方向を求める
  PVector seekDir(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);
    return steer;
  }

  // 法線の点を求める
  PVector getNormalPoint(PVector p, PVector a, PVector b) {
    PVector ap = PVector.sub(p, a);
    PVector ab = PVector.sub(b, a);

    ab.normalize();
    ab.mult(ap.dot(ab));
    PVector normalPoint = PVector.add(a, ab);

    return normalPoint;
  }

  void display() {
    float vel_r = velocity.mag();
    float vel_c = vel_r / maxspeed;
    float theta = velocity.heading() + PI/2;
    fill(220, 100, min(100, 100*vel_c));
    noStroke();
    pushMatrix();
    translate(position.x, position.y, position.z);
    rotate(theta);
    box(r, r*vel_r*2.0, r);
    popMatrix();
  }
  
  // ボイドの位置を制限する
  void border() {
    // 位置を表示エリアに収める
    if (position.x < 0) position.x = width;
    if (position.x > width) position.x = 0;
    if (position.y < 0) position.y = height;
    if (position.y > height) position.y = 0;

    // 奥行きを制限する
    if (position.z < -200) {
      position.z = -200;
      velocity.z *= -1;
    } else if (position.z > 200) {
      position.z = 200;
      velocity.z *= -1;
    }
  }
}

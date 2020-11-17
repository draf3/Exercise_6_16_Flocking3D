class Path {
  ArrayList<PVector> points;
  float radius;
  float offs;

  Path() {
    radius = 100;
    points = new ArrayList<PVector>();
    offs = 0;
  }

  // パスのポイントを追加する
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }

  // パスの最初の点の位置を取得する
  PVector getStart() {
    return points.get(0);
  }

  // パスの最後の点の位置を取得する
  PVector getEnd() {
    return points.get(points.size()-1);
  } 

  // パスを更新する
  void update() {
    for (PVector v : points) {
      v.y += sin(v.x * 0.005 + offs);
    }
    offs += 0.01;
  }

  void display() {
    noFill();
    strokeWeight(1);
    stroke(0, 0, 60);
    beginShape();
    for (PVector v : points) {
      vertex(v.x, v.y);
    }
    endShape();
  }
}

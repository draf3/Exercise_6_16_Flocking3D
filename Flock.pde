class Flock {
  ArrayList<Boid> boids;

  Flock() {
    boids = new ArrayList<Boid>();
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);
    }
  }

  // パスを追従する
  void follow(Path p) {
    for (Boid b : boids) {
      b.follow(p);
    }
  }

  // ボイドルールのパラメータを更新する
  void update(float sep, 
    float ali, 
    float coh, 
    float lat, 
    float path, 
    float maxspeed, 
    float maxforce, 
    float neighbordist, 
    float desiredseparation) {
    for (Boid b : boids) {
      b.sep_w = sep;
      b.ali_w = ali;
      b.coh_w = coh;
      b.lat_w = lat;
      b.path_w = path;
      b.maxspeed = maxspeed;
      b.maxforce = maxforce;
      b.neighbordist = neighbordist;
      b.desiredseparation = desiredseparation;
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
}

import controlP5.*;

class GUI {
  ControlP5 cp5;
  Slider separate, align, cohesion, laterally, maxspeed, maxforce, neighbordist, desiredseparation, path;
  ArrayList<Slider> sliders;

  GUI(PApplet a) {
    // コントローラーを作成
    cp5 = new ControlP5(a);
    sliders = new ArrayList<Slider>();
    separate = cp5.addSlider("separate");
    align = cp5.addSlider("align");
    cohesion = cp5.addSlider("cohesion");
    laterally = cp5.addSlider("laterally");
    path = cp5.addSlider("path");
    maxspeed = cp5.addSlider("maxspeed");
    maxforce = cp5.addSlider("maxforce");
    neighbordist = cp5.addSlider("neighbordist");
    desiredseparation = cp5.addSlider("desiredseparation");

    // スライダーをレイアウトするため、配列に格納する
    sliders.add(separate);
    sliders.add(align);
    sliders.add(cohesion);
    sliders.add(laterally);
    sliders.add(path);
    sliders.add(maxspeed);
    sliders.add(maxforce);
    sliders.add(neighbordist);
    sliders.add(desiredseparation);

    // スライダーを配置する
    for (int i = 0; i < sliders.size(); i++) {
      sliders.get(i).setColorCaptionLabel(color(0))
        .setPosition(10, i*20)
        .setSize(100, 15);
    }
    
    // パラメータを設定する
    separate.setRange(0.0, 4.0).setValue(2.0);
    align.setRange(0.0, 4.0).setValue(1.0);
    cohesion.setRange(0.0, 4.0).setValue(1.0);
    laterally.setRange(0.0, 4.0).setValue(0.0);
    path.setRange(0.0, 4.0).setValue(2.0);
    maxspeed.setRange(0.0, 20.0).setValue(10.0);
    maxforce.setRange(0.0, 1.0).setValue(0.15);
    neighbordist.setRange(0.0, 100.0).setValue(50);
    desiredseparation.setRange(0.0, 100.0).setValue(20);
  }
}

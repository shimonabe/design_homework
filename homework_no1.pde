PImage sprite;  

int npartTotal = 500; // 粒子数を減らしてテスト
int npartPerFrame = 10;
float speed = 1.0;
float gravity = 0.05;
float partSize = 20;

int partLifetime;
PVector positions[];
PVector velocities[];
int lifetimes[];

int fcount, lastm;
float frate;
int fint = 3;

void setup() {
  size(640, 480, P3D);
  frameRate(120);
  
  sprite = loadImage("sprite.png");
  if (sprite == null) {
    println("Sprite not found. Falling back to default particles.");
  } else {
    println("Sprite successfully loaded.");
  }

  partLifetime = npartTotal / npartPerFrame;
  println("Particle Lifetime: " + partLifetime);
  
  initPositions();
  initVelocities();
  initLifetimes();

  hint(DISABLE_DEPTH_MASK);
}

void draw() {
  // 背景を完全にリセット（黒で塗りつぶす）
  background(0);

  for (int n = 0; n < npartTotal; n++) {
    lifetimes[n]++;
    if (lifetimes[n] == partLifetime) {
      lifetimes[n] = 0;
    }

    if (0 <= lifetimes[n]) {
      float opacity = 1.0 - float(lifetimes[n]) / partLifetime;

      if (lifetimes[n] == 0) {
        // 再生成時にランダムな速度と位置
        positions[n].x = mouseX + random(-50, 50);
        positions[n].y = mouseY + random(-50, 50);

        float angle = random(0, TWO_PI);
        float s = random(0.3 * speed, 0.7 * speed);
        velocities[n].x = s * cos(angle);
        velocities[n].y = s * sin(angle);
      } else {
        positions[n].x += velocities[n].x;
        positions[n].y += velocities[n].y;

        // 重力の調整
        float dx = mouseX - positions[n].x;
        float dy = mouseY - positions[n].y;
        float dist = sqrt(dx * dx + dy * dy);
        velocities[n].y += gravity * (1.0 - constrain(dist / width, 0, 1));
      }

      drawParticle(positions[n], opacity, lifetimes[n]);
    }
  }

  // フレームレート計算
  fcount++;
  int m = millis();
  if (m - lastm > 1000 * fint) {
    frate = float(fcount) / fint;
    fcount = 0;
    lastm = m;
    println("FPS: " + frate);
  }
}

void drawParticle(PVector center, float opacity, int lifetime) {
  if (sprite != null) {
    beginShape(QUAD);
    noStroke();

    // 色の変更部分
    float r = map(lifetime, 0, partLifetime, 255, 50);
    float g = map(lifetime, 0, partLifetime, 50, 255);
    float b = map(lifetime, 0, partLifetime, 150, 255);
    tint(r, g, b, opacity * 255);

    texture(sprite);
    normal(0, 0, 1);
    vertex(center.x - partSize / 2, center.y - partSize / 2, 0, 0);
    vertex(center.x + partSize / 2, center.y - partSize / 2, sprite.width, 0);
    vertex(center.x + partSize / 2, center.y + partSize / 2, sprite.width, sprite.height);
    vertex(center.x - partSize / 2, center.y + partSize / 2, 0, sprite.height);
    endShape();
  } else {
    // スプライトがない場合はデフォルトで円を描画
    noStroke();
    fill(255, opacity * 255);
    ellipse(center.x, center.y, partSize, partSize);
  }
}


void initPositions() {
  positions = new PVector[npartTotal];
  for (int n = 0; n < positions.length; n++) {
    positions[n] = new PVector(); // 初期位置を0,0に設定
  }
}

void initVelocities() {
  velocities = new PVector[npartTotal];
  for (int n = 0; n < velocities.length; n++) {
    velocities[n] = new PVector(); // 初期速度を0,0に設定
  }
}

void initLifetimes() {
  lifetimes = new int[npartTotal];
  int t = -1;
  for (int n = 0; n < lifetimes.length; n++) {
    if (n % npartPerFrame == 0) {
      t++;
    }
    lifetimes[n] = -t;
  }
}


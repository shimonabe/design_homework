int npartTotal = 1000; // 粒子の総数
int npartPerFrame = 10; // 毎フレーム生成される粒子の数
float speed = 1.0; // 粒子の速度
float gravity = 0.05; // 粒子にかかる重力
float partSize = 20; // 粒子のサイズ

int partLifetime; // 粒子の寿命
PVector positions[]; // 粒子の位置を保持する配列
PVector velocities[]; // 粒子の速度を保持する配列
int lifetimes[]; // 粒子の寿命を保持する配列

int fcount, lastm;
float frate;
int fint = 3; // FPS計測用の時間間隔

void setup() {
  size(640, 480, P3D);
  frameRate(120);

  // 粒子の寿命を計算
  partLifetime = npartTotal / npartPerFrame;
  println("Particle Lifetime: " + partLifetime);

  // 粒子の位置、速度、寿命を初期化
  initPositions();
  initVelocities();
  initLifetimes();

  hint(DISABLE_DEPTH_MASK); // 重なりの描画順を制御
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
        // 再生成時にランダムな速度と位置を設定
        float t = random(0, TWO_PI); // ランダムな角度
        float x = 16 * pow(sin(t), 3);
        float y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);
        positions[n].x = mouseX + x * 3; // スケール調整
        positions[n].y = mouseY - y * 3; // Y軸を反転


        float angle = random(0, TWO_PI);
        float s = random(0.3 * speed, 0.7 * speed);
        velocities[n].x = s * cos(angle);
        velocities[n].y = s * sin(angle);
      } else {
        positions[n].x += velocities[n].x;
        positions[n].y += velocities[n].y;

        // 重力を適用
        float dx = mouseX - positions[n].x;
        float dy = mouseY - positions[n].y;
        float dist = sqrt(dx * dx + dy * dy);
        velocities[n].y += gravity * (1.0 - constrain(dist / width, 0, 1));
      }

      // 粒子を描画
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
  noStroke();

  // 粒子の色を寿命に応じて変化させる
  float r = map(lifetime, 0, partLifetime, 255, 50); // 赤の成分
  float g = map(lifetime, 0, partLifetime, 50, 255); // 緑の成分
  float b = map(lifetime, 0, partLifetime, 150, 255); // 青の成分
  fill(r, g, b, opacity * 255); // 色を設定

  // 粒子を円形で描画
  ellipse(center.x, center.y, partSize, partSize);
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

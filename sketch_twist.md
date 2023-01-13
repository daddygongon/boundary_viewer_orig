

# intro

粒界Energyの有限温度第一原理計算では，Einsteinモデルのバネ定数決定に大量の第一原理計算が必要となる．

100原子程度のサイズの計算では，系のエネルギー計算は10分程度である．これを100原子，４点，３方向，４体積で計算するとなると， 30日程度が必要となる．

等価なサイトを抽出することでその計算量を激減させることが可能である．その様子を以下に示した．

![img](https://nishitani.qiita.com/files/6e7fa5a9-c6ed-401b-e93a-178b849218a1.png)

これは，5x5のユニットを示している．No.0とNo.59のサイトが等価であることがすぐにわかる．その4分の一の領域にせばめて考えても，10, 2 ,34 ,44 が等価なサイトとみなせそうである．そうすると，26原子での計算が5サイトの計算ですますことが可能となる．

つまり，1/5程度に削減することができる．そのほかの層でも同じことが可能であろう．このように，等価なサイトを見つけやすくする視覚化を進めていくことが，計算量削減の重要なステップであり，本研究の目的である．そのためには，モデルの視認性の高い表示と実際のvasp計算での数値的な整合性を確かめる必要がある．


# sketch\_twist.pde

次にprocessingで書いた表示codeを示している．このパラメータ調整やリファクタリングを進めることで，視認性の高い表示を駆使できるソフトを作成する．

用意されている大域変数と関数は以下の通り．

```c++

  1
  2import processing.pdf.*;
  3
  4float[] la = new float[3];
  5float[][] pos;
  6float scale = 80.0; // whole scale
  7float theta;
  8String[] lines;
  9String[] m;
 10
 11int n_atom;
 12int sigma;
 13float x_lat; // = 168;
 14float y_lat; // = 100;
 15int rr=6; // ellipse radius
 16
 17void setup() {...}
 23void draw() {...}
 32void circle(int x, int y, int r) {...}
 35void up_tri(float x, float y, float r) {...}
 46void down_tri(float x, float y, float r) {...}
 57float[] r_matrix(float theta, float x, float y) {...}
 63void load_poscar() {...}
 81void draw_tilt_rect() {...}
 97void draw_number(int num, float[] pos, boolean print_num) {...}
104void draw_atom(boolean print_num) {...}
```

setupあるいはdraw関数のパラメータを調節することで表示をコントロールする．うまくいけば，controllerを入れてviewer自身にスイッチをつける．

```c++
void setup() {
  size(600, 480);
  load_poscar();
  noLoop();
  beginRecord(PDF, "filename.pdf");
}

void draw() {
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  background(255);

  rect(-0.5*x_lat+width/2, 0.5*y_lat+height/2, x_lat, -y_lat);
  draw_atom(false);
  draw_tilt_rect(153);
  endRecord();
}
```

```c++:sketch_twist/sketch_twist.pde
import processing.pdf.*;

float[] la = new float[3];
float[][] pos;
float scale = 80.0; // whole scale
float theta;
String[] lines;
String[] m;  

int n_atom;
int sigma;
float x_lat; // = 168;
float y_lat; // = 100;
int rr=6; // ellipse radius

void setup() {
  size(600, 480);
  load_poscar();
  noLoop();
  beginRecord(PDF, "filename.pdf");
}
void draw() {
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  background(255);

  rect(-0.5*x_lat+width/2, 0.5*y_lat+height/2, x_lat, -y_lat);
//  draw_atom(true, 0.125, 0.0, 1.0); // 0-7
//  draw_atom(true, 0.125, 0.125, 0.5-0.125); // 1-2
//  draw_atom(true, 0.125, 0.5-0.125, 0.5+0.125); // 3-4
  draw_atom(true, 0.125, 0.5+0.125, 1.0-0.125); // 5-6
  draw_tilt_rect(153);
  endRecord();
}

void circle(int x, int y, int r) {
  ellipse(x, y, r, r);
}
void up_tri(float x, float y, float r) {
  float rx = 0.866025*1.2;
  float ry = 0.5*1.2;
  float x1 = x- rx*r;
  float y1 = y+ ry*r;
  float x2 = x+ rx*r;
  float y2 = y+ ry*r;
  float x3 = x;
  float y3 = y - r;
  triangle(x1, y1, x2, y2, x3, y3);
}
void down_tri(float x, float y, float r) {
  float rx = 0.866025*1.2;
  float ry = 0.5*1.2;
  float x1 = x- rx*r;
  float y1 = y- ry*r;
  float x2 = x+ rx*r;
  float y2 = y- ry*r;
  float x3 = x;
  float y3 = y + r;
  triangle(x1, y1, x2, y2, x3, y3);
}
float[] r_matrix(float theta, float x, float y) {
  float[] vv = new float[2];
  vv[0] = cos(theta)*x-sin(theta)*y;
  vv[1] = sin(theta)*x+cos(theta)*y;
  return vv;
}
void load_poscar() {
  lines = loadStrings("POSCAR");
  println(lines[0]);
  m = match(lines[0], "n_sigma=\\s+(\\d+)");
  float sigma = float(m[1]);
  theta = atan2(1.0, sigma);
  println(theta);
  for (int i = 0; i < 3; i++) {
    m = match(lines[i+2], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(\\d+.\\d+)");
    la[i] = float(m[i+1]);
  }
  m = match(lines[5], "\\s*(\\d+)");
  n_atom = int(m[1]);
  println(n_atom);

  x_lat = la[0]*scale;
  y_lat = la[1]*scale;
}
void draw_tilt_rect(int gray) {
  stroke(gray);
  float[][] p_v = { {0.0, 0.0}, {0.0, 1.0}, {1.0, 1.0}, {1.0, 0.0}, {0.0, 0.0} }; 
  float[] v0 = new float[2];
  float[] v1 = new float[2];
  for (int i = 0; i<4; i++) {
    v0 = r_matrix(theta, p_v[i][0], p_v[i][1]);
    v1 = r_matrix(theta, p_v[i+1][0], p_v[i+1][1]);
    line((-0.5+v0[0])*x_lat+width/2, (0.5-v0[1])*y_lat+height/2, 
      (-0.5+v1[0])*x_lat+width/2, (0.5-v1[1])*y_lat+height/2);
    v0 = r_matrix(-theta, p_v[i][0], p_v[i][1]);
    v1 = r_matrix(-theta, p_v[i+1][0], p_v[i+1][1]);
    line((-0.5+v0[0])*x_lat+width/2, (0.5-v0[1])*y_lat+height/2, 
      (-0.5+v1[0])*x_lat+width/2, (0.5-v1[1])*y_lat+height/2);
  }
}
void draw_number(int num, float[] pos, boolean print_num) {
  if (print_num) {
    textSize(14);
    fill(0, 102, 153);
    text(num, pos[0]-5, pos[1]-10);
  }
}
void draw_atom(boolean print_num, float dev,
    float init,  float fin) {
  pos = new float[n_atom][3];
  for (int i = 0; i < n_atom; i++) {
    m = match(lines[i+7], "\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)");
    pos[i][0] = (float(m[1])-0.5)*x_lat+width/2;
    pos[i][1] = (-float(m[2])+0.5)*y_lat+height/2;
    pos[i][2] = float(m[3]);   
    for (int j=-1; j<2; j++) {
      for (int k=-1; k<2; k++) {
	if ( (pos[i][2] >= init) && (pos[i][2] < init+dev) ) { // 1st
	  //if ((pos[i][2] >= 0.5-0.125) && (pos[i][2] < 0.5)) { // 4th 
	  fill(0);
	  down_tri(pos[i][0]+x_lat*j, pos[i][1]+y_lat*k, rr);
	  draw_number(i, pos[i], print_num);
	} else if ((pos[i][2] >=  (fin-dev)/1.0) && (pos[i][2] < (fin-0.01)/1.0)) { //
	  //} else if ((pos[i][2] >= 0.5) && (pos[i][2] < 0.625)) { // 5th
	  fill(255);
	  up_tri(pos[i][0]+x_lat*j, pos[i][1]+y_lat*k, rr);
	  draw_number(i, pos[i], print_num);
	}
      }
    }
  }
}
```


# 全層の表示

3x3のposcarをz軸の値でソートすると次の通り．

    n_sigma=   3, theta=  0.3218, angle= 18.4349, twist boundary
    4.0414
       1.5811388301    0.0000000000    0.0000000000
       0.0000000000    1.5811388301    0.0000000000
       0.0000000000    0.0000000000    4.0000000000
    40
    Direct
       0.0000000000    0.0000000000    0.0000000000
       0.4000000000    0.8000000000    0.0000000000
       0.8000000000    0.6000000000    0.0000000000
       0.6000000000    0.2000000000    0.0000000000
       0.2000000000    0.4000000000    0.0000000000
       0.3000000000    0.1000000000    0.1250000000
       0.9000000000    0.3000000000    0.1250000000
       0.5000000000    0.5000000000    0.1250000000
       0.1000000000    0.7000000000    0.1250000000
       0.7000000000    0.9000000000    0.1250000000
       0.6000000000    0.2000000000    0.2500000000
       0.2000000000    0.4000000000    0.2500000000
       0.8000000000    0.6000000000    0.2500000000
       0.0000000000    0.0000000000    0.2500000000
       0.4000000000    0.8000000000    0.2500000000
       0.7000000000    0.9000000000    0.3750000000
       0.1000000000    0.7000000000    0.3750000000
       0.5000000000    0.5000000000    0.3750000000
       0.9000000000    0.3000000000    0.3750000000
       0.3000000000    0.1000000000    0.3750000000
       0.4000000000    0.2000000000    0.5000000000
       0.6000000000    0.8000000000    0.5000000000
       0.2000000000    0.6000000000    0.5000000000
       0.8000000000    0.4000000000    0.5000000000
       0.0000000000    0.0000000000    0.5000000000
       0.1000000000    0.3000000000    0.6250000000
       0.9000000000    0.7000000000    0.6250000000
       0.3000000000    0.9000000000    0.6250000000
       0.7000000000    0.1000000000    0.6250000000
       0.5000000000    0.5000000000    0.6250000000
       0.8000000000    0.4000000000    0.7500000000
       0.2000000000    0.6000000000    0.7500000000
       0.4000000000    0.2000000000    0.7500000000
       0.6000000000    0.8000000000    0.7500000000
       0.0000000000    0.0000000000    0.7500000000
       0.9000000000    0.7000000000    0.8750000000
       0.1000000000    0.3000000000    0.8750000000
       0.3000000000    0.9000000000    0.8750000000
       0.5000000000    0.5000000000    0.8750000000
       0.7000000000    0.1000000000    0.8750000000

pdeのdraw\_atomに描画範囲を選択する引数を入れて

```c++
//  draw_atom(true, 0.125, 0.0, 1.0); // 0-7
//  draw_atom(true, 0.125, 0.125, 0.5-0.125); // 1-2
//  draw_atom(true, 0.125, 0.5-0.125, 0.5+0.125); // 3-4
  draw_atom(true, 0.125, 0.5+0.125, 1.0-0.125); // 5-6
```

としてそれぞれの層を描画．デフォルトは0-7層．

| ![img](https://nishitani.qiita.com/files/ea74acb6-dbba-a203-0ba8-8c3d3a20f674.png)| ![img](https://nishitani.qiita.com/files/b106de6d-edc2-839e-a54b-d8b62f089ecb.png)|
|:---------------------------------------------------------------------------|:-------------------------------------------------------------------------|
| 0-7 層                                                                     | 1-2層                                                                    |
| ![img](https://nishitani.qiita.com/files/c0facd9c-930a-9810-7b66-aeda9c3dafa6.png)| ![img](https://nishitani.qiita.com/files/3d194009-d8f0-807f-750d-f56d6d13b98a.png)|
| 3-4層                                                                      | 5-6層                                                                    |

 0-7層と3-4層に粒界がある．一方，1-2層及び5-6層は完全結晶となっている．これから等価なサイトの番号は，

    4: 38, 24, 17
    3: ...

などと予想される．これを，ksで確認する．


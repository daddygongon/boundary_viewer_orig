// #+name: skecth_viewer2.pde
// #+begin_src c++
float[] la = new float[3];
float[][] pos;
float[][] pos2;
//float scale = 30.0;
float scale = 50.0;
int n_atom = 40;
float x_lat = 168;
float y_lat = 100;
int my_frame = 0;

void setup() {
  size(600, 480);
  frameRate(5);
}

void draw() {
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  println(my_frame);
  draw_atom(my_frame);
  my_frame += 1;
  if (my_frame == 100){
    my_frame = 0;
  }
}

void draw_atom(int my_frame) {
  String[] lines;

  //try {
    lines = loadStrings("POSCAR_"+my_frame);
  //} 
  //catch(IOException e) {
//    return;
  //}
  String[] m;
  println(lines[0]);
  for (int i = 0; i < 3; i++) {
    // println(lines[i+2]);
    m = match(lines[i+2], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(\\d+.\\d+)");
    la[i] = float(m[i+1]);
    //      println(la[i]);
  }
  pos = new float[n_atom][3];

  for (int i = 0; i < n_atom; i++) {
    // println(lines[i+7]);
    m = match(lines[i+7], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(.\\d+.\\d+)");
    pos[i][0] = (float(m[1])-0.5)*la[0]*scale+width/2;
    pos[i][1] = (float(m[2])-0.5)*la[1]*scale+height/2;
    pos[i][2] = (float(m[3])+0.5)*la[2]*scale;
    //      println(pos[i][0], pos[i][1], pos[i][2]);
  }
  x_lat = la[0]*scale;
  y_lat = la[1]*scale;
  //  }

  background(255);
  for (int i = 0; i < n_atom; i++) {
    if (pos[i][2] > 30) {
      fill(255);
    } else {
      fill(0);
    }
    ellipse(pos[i][0], pos[i][1], 3, 3); 
    ellipse(pos[i][0]+x_lat, pos[i][1], 3, 3); 
    ellipse(pos[i][0]-x_lat, pos[i][1], 3, 3); 
    ellipse(pos[i][0]+x_lat, pos[i][1]+y_lat, 3, 3);
    ellipse(pos[i][0]+x_lat, pos[i][1]-y_lat, 3, 3);
    ellipse(pos[i][0], pos[i][1]+y_lat, 3, 3);
    ellipse(pos[i][0], pos[i][1]-y_lat, 3, 3);
    ellipse(pos[i][0]-x_lat, pos[i][1]-y_lat, 3, 3);
    ellipse(pos[i][0]-x_lat, pos[i][1]+y_lat, 3, 3);
  }
}
// #+end_src

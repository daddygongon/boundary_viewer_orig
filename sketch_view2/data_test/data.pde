float[] la =new float[3];
float[][] pos;
float scale = 30.0;
int n_atom = 40;

void setup() {
  size(600, 480);
  //textSize(400);
  // textAlign(CENTER);
  //char keys[] = {key};
  //text(new String(keys),0,0,width,height);
  String[] lines = loadStrings("POSCAR_0");
  String[] m;
  println("lines:::::" + lines[0]);
  for (int i = 0; i < 3; i++) {
    println(lines[i+2]);
    m = match(lines[i+2], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(\\d+.\\d+)");
    la[i] = float(m[i+1]);
    println(+la[i]);
  }

  pos = new float[n_atom][3];
  for (int i = 0; i < n_atom; i++) {
    println("88888888888888"+lines[i+7]);
    m = match(lines[i+7], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(\\d+.\\d+)");
    //pos[i][0] = (float(m[1])-0.5)*la[0]*scale+width/2;
    //pos[i][1] = (float(m[2])-0.5)*la[1]*scale+height/2;
    //pos[i][2] = float(m[3]);
    //println(pos[i][0], pos[i][1], pos[i][2]);
  }
}

void draw() {
  background(255);
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  fill(255);
  for (int i = 0; i < n_atom; i++) {
    ellipse(pos[i][0], pos[i][1], 30,30);  // Draw white ellipse using RADIUS mode
  }
}

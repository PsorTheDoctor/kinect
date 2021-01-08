import org.openkinect.processing.*;

Kinect kinect;

float angleX = 0;
float angleY = 0;
float angleZ = 0;
float dist = 2;

float tilt = 0;

PVector[] points = new PVector[8];

float[][] vecToMatrix(PVector v) {
  float[][] m = new float[3][1];
  m[0][0] = v.x;
  m[1][0] = v.y;
  m[2][0] = v.z;
  return m;
}

PVector matrixToVec(float[][] m) {
  PVector v = new PVector();
  v.x = m[0][0];
  v.y = m[1][0];
  
  if (m.length > 2) v.z = m[2][0];
  return v;
}

float[][] matmul(float[][] a, float[][] b) {
  int colsA = a[0].length;
  int rowsA = a.length;
  int colsB = b[0].length;
  int rowsB = b.length;
  
  if (colsA != rowsB) {
    return null;
  }
  float result[][] = new float[rowsA][colsB];
  
  for (int i = 0; i < rowsA; i++) {
    for (int j = 0; j < colsB; j++) {
      float sum = 0;
      for (int k = 0; k < colsA; k++) {
        sum += a[i][k] * b[k][j];
      }
      result[i][j] = sum;
    }
  }
  return result;
}

PVector matmul(float[][] a, PVector b) {
  float[][] m = vecToMatrix(b);
  return matrixToVec(matmul(a, m));
}

void setup() {
  size(512, 424);
  kinect = new Kinect(this);
  kinect.initDepth();
  tilt = kinect.getTilt();
  
  points[0] = new PVector(-0.5, -0.5, -0.5);
  points[1] = new PVector(0.5, -0.5, -0.5);
  points[2] = new PVector(0.5, 0.5, -0.5);
  points[3] = new PVector(-0.5, 0.5, -0.5);
  points[4] = new PVector(-0.5, -0.5, 0.5);
  points[5] = new PVector(0.5, -0.5, 0.5);
  points[6] = new PVector(0.5, 0.5, 0.5);
  points[7] = new PVector(-0.5, 0.5, 0.5);
}

void draw() { 
  background(0);
  translate(width/2, height/2);
  stroke(255);
  strokeWeight(16);
  noFill();
  
  kinect.setTilt(tilt);
  
  float[][] rotX = {
    {1, 0, 0},
    {0, cos(angleX), -sin(angleX)},
    {0, sin(angleX), cos(angleX)}
  };
  
  float[][] rotY = {
    {cos(angleY), 0, -sin(angleY)},
    {0, 1, 0},
    {sin(angleY), 0, cos(angleY)}
  };
  
  float[][] rotZ = {
    {cos(angleZ), -sin(angleZ), 0},
    {sin(angleZ), cos(angleZ), 0},
    {0, 0, 1}
  };
  
  PVector[] projected = new PVector[8];
  
  int idx = 0;
  for (PVector v : points) {
    PVector rotated = matmul(rotY, v);
    rotated = matmul(rotX, rotated);
    rotated = matmul(rotZ, rotated);
    
    float z = 1 / (dist - rotated.z);
    
    float[][] projection = {
      {z, 0, 0},
      {0, z, 0}
    };
    
    PVector projected2d = matmul(projection, rotated);
    projected2d.mult(200);
    projected[idx] = projected2d;
    idx++;
  }
  
  for (PVector v : projected) {
    stroke(255, 0, 0);
    strokeWeight(16);
    noFill();
    point(v.x, v.y);
  }
}

void mouseDragged() {
  float speed = 0.01;
  float verticalShift = (mouseX - pmouseX) * speed;
  float horizontalShift = (mouseY - pmouseY) * speed;
  
  if (mouseX != pmouseX) angleY += verticalShift;
  
  if (mouseY != pmouseY) angleX += horizontalShift;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  float zoom = 0.03;
  
  if (e > 0) {
    dist -= zoom;
  } else {
    dist += zoom;
  }
}

void keyPressed() {
  float step = 5;
  
  if (key == CODED) {
    if (keyCode == DOWN) {
      tilt -= step;
    } else if (keyCode == UP) {
      tilt += step;
    }
  }
}

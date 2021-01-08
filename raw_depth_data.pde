import org.openkinect.processing.*;

Kinect kinect;

float angleX = 0;
float angleY = 0;
float dist = -2250;
float tilt = 0;

static class CameraParams {
  static float cx = 254.878f;
  static float cy = 205.395f;
  static float fx = 365.456f;
  static float fy = 365.456f;
  static float k1 = 0.0905474f;
  static float k2 = -0.26819f;
  static float k3 = 0.0950862f;
  static float p1 = 0.0f;
  static float p2 = 0.0f;
}

void setup() {
  size(800, 600, P3D);
  kinect = new Kinect(this);
  kinect.initDepth();
  tilt = kinect.getTilt();
}

void draw() {
  background(0);
  pushMatrix();
  translate(width/2, height/2, dist);
  rotateX(angleX);
  rotateY(angleY);
  
  kinect.setTilt(tilt);
  
  int depthWidth = 640;
  int depthHeight = 480;
  int skip = 4;
  
  int[] depth = kinect.getRawDepth();
  
  stroke(255);
  strokeWeight(2);
  beginShape(POINTS);
  
  for (int x = 0; x < depthWidth; x+=skip) {
    for (int y = 0; y < depthHeight; y+=skip) {
      int offset = x + y * depthWidth;
      int d = depth[offset];
      
      PVector point = depthToPointCloudPos(x, y, d);
      vertex(point.x, point.y, point.z);
    }
  }
  endShape();
  popMatrix();
  fill(255);
}

void mouseDragged() {
  float speed = 0.01;
  float verticalShift = (mouseX - pmouseX) * speed;
  float horizontalShift = (mouseY - pmouseY) * speed;
  
  if (mouseX != pmouseX) angleY += verticalShift;
  
  if (mouseY != pmouseY) angleX -= horizontalShift;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  float zoom = 100;
  
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

PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

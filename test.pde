import org.openkinect.processing.*;

Kinect kinect;

void setup() {
  size(600, 400, P2D);
  kinect = new Kinect(this);
  kinect.initVideo();
  kinect.initDepth();
}

void draw() {
  background(0);
  image(kinect.getVideoImage(), 0, 0, 300, 200);
  image(kinect.getDepthImage(), 300, 0, 300, 200);
  
  fill(255);
  text("Framerate: " + (int)(frameRate), 10, 515);
}

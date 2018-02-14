/*  motion tracking, servo motor, arduino & processing serial communication
 
 There are 2 parts in this sketch. 
 The first part is motion tracking, which I follow the online tutorial by Daniel Shiffman,
 Learning Processing, http://www.learningprocessing.com
 Exercise 16-7: Create a sketch that looks for the average location of motion. 
 
 For the second part, I use the example file from the Arduino(Firmata) library, 
 and adapt it to work with the motion tracking,
 so that the servo motor will follow the motion, where a cloud is floating.
 
 */



import processing.video.*;
import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
PImage img;



////////////// motion capture code: adapted from Daniel Shiffman, Learning Processing, ////////////// 
////////////// Exercise 16-7: Create a sketch that looks for the average location of motion. //////////////
Capture video;// Variable for capture device
PImage prevFrame;// Previous Frame
float threshold = 50;// How different must a pixel be to be a "motion" pixel


void setup() {
  fullScreen();
  img = loadImage("ball.png");//image source:http://pngimg.com/img/nature/cloud

  video = new Capture(this, width, height);  // Using the default capture device:webcam
  video.start();


  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);
  arduino = new Arduino(this, Arduino.list()[4], 57600);
 // arduino.pinMode(9, Arduino.SERVO);
  arduino.pinMode(10, Arduino.SERVO);
  arduino.pinMode(11, Arduino.SERVO);
 
}


// New frame available from camera
void captureEvent(Capture video) {
  // Save previous frame for motion detection!!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();  
  video.read();
}



void draw() {
  background(0);

  //reverse the image, so it's like a mirror
  pushMatrix();
  scale(-1, 1);
  image(video, -width, 0);
  popMatrix();

  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  // These are the variables we'll need to find the average X and Y
  float sumX = 0;
  int motionCount = 0; 

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      // What is the current color
      color current = video.pixels[x+y*video.width];
      // What is the previous color
      color previous = prevFrame.pixels[x+y*video.width];

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current);
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous);
      float b2 = blue(previous);

      // Motion for an individual pixel is the difference between the previous color and current color.
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // If it's a motion pixel add up the x's and the y's
      if (diff > threshold) {
        sumX += x;
        motionCount++;
      }
    }
  }
  
  // average location is total location divided by the number of motion pixels.
  float motion = sumX / (motionCount*1.2); 



////////////// load a cloud image around the motion////////////// 
  //reverse the image for the mirror effect
  image(img, (width-motion-100), height/2);

////////////// control the servo, the angle between 0 to 180 is determined by the motion////////////// 
   arduino.servoWrite(9, int (motion));
  arduino.servoWrite(10, int (motion));

  delay(100);//delay 100 to make the motion not move too frequently.
}
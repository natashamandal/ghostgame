//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

/**
 * A basic physics based game
 */

// audio stuff

Maxim maxim;
AudioPlayer droidSound, wallSound, ghostSound;
AudioPlayer[] crateSounds;


Physics physics; // The physics handler: we'll see more of this later
// rigid bodies for the droid and two crates
Body droid;
Body [] crates;
Body ghosts;
// the start point of the catapult 
Vec2 startPoint;
// a handler that will detect collisions
CollisionDetector detector; 

int crateSize = 80;
int ballSize = 60;

PImage crateImage, ballImage, tip, ghostImage;

int score = 0;

boolean dragging = false;

// this is used to remember that the user 
// has triggered the audio on iOS... see mousePressed below
boolean userHasTriggeredAudio = false;

booolean hit[];
boolean end = false;
int press=0;

Button Pause, Stop, New, FB;
boolean displayGUI = true;
boolean pause = false;
boolean post = false;


void setup() {
  size(1040, 1040);
  frameRate(60);


  tip = loadImage("night.png");
  crateImage = loadImage("brick.png");
  ballImage = loadImage("tux_droid2.png");
  ghostImage = loadImage("ghost.png");
  imageMode(CENTER);

  //initScene();

  /*
   * Set up a physics world. This takes the following parameters:
   * 
   * parent The PApplet this physics world should use
   * gravX The x component of gravity, in meters/sec^2
   * gravY The y component of gravity, in meters/sec^2
   * screenAABBWidth The world's width, in pixels - should be significantly larger than the area you intend to use
   * screenAABBHeight The world's height, in pixels - should be significantly larger than the area you intend to use
   * borderBoxWidth The containing box's width - should be smaller than the world width, so that no object can escape
   * borderBoxHeight The containing box's height - should be smaller than the world height, so that no object can escape
   * pixelsPerMeter Pixels per physical meter
   */
  physics = new Physics(this, width, height, 0, -10, width*2, height*2, width*1.5, height, 100);
  // this overrides the debug render of the physics engine
  // with the method myCustomRenderer
  // comment out to use the debug renderer 
  // (currently broken in JS)
  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  physics.setDensity(20.0);

  // set up the objects
  // Rect parameters are the top left 
  // and bottom right corners
  crates = new Body[23];
  //ghosts = new Body[2];
  hit = new boolean[crates.length];
  
  for(int i=0; i<crates.length; i++){
    hit[i] = false;
  }
  
  physics.setDensity(0.0);
  crates[0] = physics.createRect((width/2)-(crateSize/2), height-crateSize, (width/2)+(crateSize/2), height);
  crates[1] = physics.createRect(width-crateSize, (height/2)-(crateSize/2),width, (height/2)+(crateSize/2));
  crates[2] = physics.createRect(0, (height/2)-(crateSize/2),crateSize, (height/2)+(crateSize/2));
  crates[3] = physics.createRect((width/2)-(crateSize/2), 0, (width/2)+(crateSize/2), crateSize);
  crates[4] = physics.createRect((width/2)-(crateSize/2), (height/2)-(crateSize/2), (width/2)+(crateSize/2), (height/2)+(crateSize/2));
 
  physics.setDensity(20.0);
  crates[5] = physics.createRect((width/2)-(crateSize/2), height-2*crateSize, (width/2)+(crateSize/2), height-crateSize);
  crates[6] = physics.createRect((width/2)-(crateSize/2), height-3*crateSize, (width/2)+(crateSize/2), height-2*crateSize);
  crates[7] = physics.createRect((width/2)-(crateSize/2), height-4*crateSize, (width/2)+(crateSize/2), height-3*crateSize);
  crates[8] = physics.createRect((width/2)-(crateSize/2), height-5*crateSize, (width/2)+(crateSize/2), height-4*crateSize);
  crates[9] = physics.createRect((width/2)-(crateSize/2), height-6*crateSize, (width/2)+(crateSize/2), height-5*crateSize);
  crates[10] = physics.createRect((width/2)-(crateSize/2), crateSize, (width/2)+(crateSize/2), 2*crateSize);
  crates[11] = physics.createRect((width/2)-(crateSize/2), 2*crateSize, (width/2)+(crateSize/2), 3*crateSize);
  crates[12] = physics.createRect((width/2)-(crateSize/2), 3*crateSize, (width/2)+(crateSize/2), 4*crateSize);
  crates[13] = physics.createRect((width/2)-(crateSize/2), 4*crateSize, (width/2)+(crateSize/2), 5*crateSize);
  crates[14] = physics.createRect((width/2)-(crateSize/2), 5*crateSize, (width/2)+(crateSize/2), 6*crateSize);
  
  physics.setDensity(0.0);
  crates[15] = physics.createRect(crateSize, (height/2)-(crateSize/2),2*crateSize, (height/2)+(crateSize/2));
  crates[16] = physics.createRect(2*crateSize, (height/2)-(crateSize/2),3*crateSize, (height/2)+(crateSize/2));
  crates[17] = physics.createRect(4*crateSize, (height/2)-(crateSize/2),5*crateSize, (height/2)+(crateSize/2));
  crates[18] = physics.createRect(5*crateSize, (height/2)-(crateSize/2),6*crateSize, (height/2)+(crateSize/2));
  crates[19] = physics.createRect(width-2*crateSize, (height/2)-(crateSize/2),width-crateSize, (height/2)+(crateSize/2));
  crates[20] = physics.createRect(width-3*crateSize, (height/2)-(crateSize/2),width-2*crateSize, (height/2)+(crateSize/2));
  crates[21] = physics.createRect(width-5*crateSize, (height/2)-(crateSize/2),width-4*crateSize, (height/2)+(crateSize/2));
  crates[22] = physics.createRect(width-6*crateSize, (height/2)-(crateSize/2),width-5*crateSize, (height/2)+(crateSize/2));
  ghosts = physics.createRect(int(random(0,width-300)), int(random(0,height-300)), int(random(300,width)), int(random(300,height)));
  //ghosts[1] = physics.createRect(int(random(0,width-300)), int(random(0,height-300)), int(random(300,width)), int(random(300,height)));
  //ghosts.setSensor(false);
  physics.setDensity(20.0);
  
  startPoint = new Vec2(width/4, height/4);
  // this converst from processing screen 
  // coordinates to the coordinates used in the
  // physics engine (10 pixels to a meter by default)
  startPoint = physics.screenToWorld(startPoint);

  // circle parameters are center x,y and radius
  droid = physics.createCircle(width/4, width/4, ballSize/2);
  // sets up the collision callbacks
  detector = new CollisionDetector (physics, this);

  maxim = new Maxim(this);
  droidSound = maxim.loadFile("droid.wav");
  wallSound = maxim.loadFile("wall.wav");
  ghostSound = maxim.loadFile("ghostsound.wav");

  droidSound.setLooping(false);
  droidSound.volume(1.0);
  wallSound.setLooping(false);
  wallSound.volume(1.0);
  // now an array of crate sounds
  crateSounds = new AudioPlayer[crates.length];
  for (int i=0;i<crateSounds.length;i++) {
    crateSounds[i] = maxim.loadFile("crate2.wav");
    crateSounds[i].setLooping(false);
    crateSounds[i].volume(1);
  }
  
  Pause = new Button("Pause",width - 100, 0, 100, 50);
  Stop = new Button("Stop",width - 100, 50, 100, 50);
  FB = new Button("Post",width - 100, 100, 100, 50);
  //tint = color(0, 100, 200);
}

void draw() {

  
   // we can call the renderer here if we want 
  // to run both our renderer and the debug renderer
  //myCustomRenderer(physics.getWorld());

  fill(255);
  text("Score: " + score, 20, 20);
  

  
  if(end==true){
  fill(255);
  text("GAME OVER", 20, 60);
  exit(0);
  }
  
   
  if(displayGUI==true)
  {
  Pause.display();
  Stop.display();
  FB.display();
  }
  
  if (post)
    {
       
      postToPHP();
      post = false;
    }

  
  
}

/** on iOS, the first audio playback has to be triggered
* directly by a user interaction
* so the first time they tap the screen, 
* we play everything once
* we could be nice and mute it first but you can do that... 
*/
void mousePressed() {
  press++;
  if (!userHasTriggeredAudio) {
    droidSound.play();
    wallSound.play();
    ghostSound.play();
    for (int i=0;i<crates.length;i++) {
      crateSounds[i].play();
    }
    userHasTriggeredAudio = true;
  }
  
 
    
  
}

void mouseDragged()
{
  // tie the droid to the mouse while we are dragging
  dragging = true;
  droid.setPosition(physics.screenToWorld(new Vec2(mouseX, mouseY)));
}

// when we release the mouse, apply an impulse based 
// on the distance from the droid to the catapult
void mouseReleased()
{
  
  dragging = false;
  Vec2 impulse = new Vec2();
  impulse.set(startPoint);
  impulse = impulse.sub(droid.getWorldCenter());
  impulse = impulse.mul(75);
  droid.applyImpulse(impulse, droid.getWorldCenter());

  if(Pause.mouseReleased())
  {
   
    pause = !pause;
    
    
  } 
  
  if(Stop.mouseReleased())
  {
    end = true;
  }  
  
  if(FB.mouseReleased())
  {
   
   post = true;
   displayGUI = !displayGUI; 
    
  }  
   
}

// this function renders the physics scene.
// this can either be called automatically from the physics
// engine if we enable it as a custom renderer or 
// we can call it from draw
void myCustomRenderer(World world) {
  if(!pause)
  {
  pushStyle();
  int r, g, b;
  r = 0;
  g = (int)map(mouseX, 0, width, 0, 255);
  b = (int)map(mouseY, 0, width, 0, 255);
  tint(r,g,b,50);
  image(tip, width/2, height/2, width, height);
  popStyle();
  stroke(0);

  Vec2 screenStartPoint = physics.worldToScreen(startPoint);
  strokeWeight(8);
  line(screenStartPoint.x, screenStartPoint.y, screenStartPoint.x, 0);

  // get the droids position and rotation from
  // the physics engine and then apply a translate 
  // and rotate to the image using those values
  // (then do the same for the crates)
  Vec2 screenDroidPos = physics.worldToScreen(droid.getWorldCenter());
  float droidAngle = physics.getAngle(droid);
  pushMatrix();
  translate(screenDroidPos.x, screenDroidPos.y);
  rotate(radians(droidAngle));
  image(ballImage, 0, 0, ballSize, ballSize);
  popMatrix();


  for (int i = 0; i < crates.length; i++)
  {
    Vec2 worldCenter = crates[i].getWorldCenter();
    Vec2 cratePos = physics.worldToScreen(worldCenter);
    float crateAngle = physics.getAngle(crates[i]);
    pushMatrix();
    translate(cratePos.x, cratePos.y);
    rotate(crateAngle);
    image(crateImage, 0, 0, crateSize, crateSize);
    popMatrix();
  }
  
  //for (int i=0; i < ghosts.length; i++){
    //pushMatrix();
    
    image(ghostImage, int(random(0,width)),int(random(0,height)), 100, 100);
    //popMatrix();
  

  if (dragging)
  {
    strokeWeight(2);
    line(screenDroidPos.x, screenDroidPos.y, screenStartPoint.x, screenStartPoint.y);
  }
  }
 
   
}

// This method gets called automatically when 
// there is a collision
void collision(Body b1, Body b2, float impulse)
{
  if ((b1 == droid && b2.getMass() > 0)
    || (b2 == droid && b1.getMass() > 0))
  {
    if (impulse > 1.0)
    {
      score += (int)(impulse/(100*(press/2)));
    }
    droidSound.cue(0);
    droidSound.speed(impulse / 1000);
    droidSound.play();
  }
  
 if((b1 == droid && b2.getMass() == 0 && b2!=ghosts)|| (b2 == droid && b1.getMass() == 0 && b1!=ghosts))
 { 
   if (impulse > 1.0)
    {
      score += (int)(impulse/(200*(press/2)));
    }
    wallSound.cue(0);
    wallSound.speed(impulse / 1000);
    wallSound.play();
   }
 

  
  if (b1 == ghosts || b2 == ghosts) {
    ghostSound.cue(0);
    ghostSound.play();
  }

  for (int i=0;i<crates.length;i++) {
    if (b1 == crates[i] || b2 == crates[i]) {// its a crate
      crateSounds[i].cue(0);
      crateSounds[i].speed(0.25 + (impulse / 250));// 10000 as the crates move slower??
      crateSounds[i].play();
      if(hit[i]==false)
      {
        hit[i]=true;
      } 
    }
  }
  
  int j=0;
  
  while(hit[j]==true&&j<crates.length)
  {
    j++;
    
    if(j==(crates.length-1))
    {
      end=true;
    } 
    
  } 
  
}



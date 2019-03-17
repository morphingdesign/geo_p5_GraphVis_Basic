// CLOCK LOCK SKETCH/PROGRAM
// by Hans Palacios
// for SCAD ITGM 719 Course
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/** PROJECT DESCRIPTION
    This interactive sketch is composed of a dynamic set of shapes representing 
    cogs and bolts with a safe door.  The center of the safe door is a series of 
    cogs depicting the hour, minute, and second, with each one updating live.  Upon
    clicking the start button in the guide user interface, the safe's bolts become 
    partially unlocked to represent a system malfunction in the safe door operation.
    Clicking on the highlighted broken cog in the center allows the system to fully
    open the safe and revealing the safe's contents.
    --------------------------------------------------------------------------------
    REFERENCED CODE
    Code referenced from online sources are identified with comments and delineated
    with the following syntax:
    
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
        Referenced code located here along with cited web link.
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
        
    Currently, the only referenced code is located within the Bolt() class.    
    --------------------------------------------------------------------------------    
    IMAGES
    The PNG images used for the safe content within this program and located in the
    accompanying 'data' folder were created by Hans Palacios.  Each were modeled, 
    textured, and rendered in SideFX Houdini.
**/

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Global variables
/** The majority of these global variables are used and defined to creat consistency 
    throughout the sketch and its contents built from various classes.  
**/

Scene mainScene;                         // Static graphics
Portal safeDoor;                         // Dynamics safe door graphics
GameAsset clockLockGame;                 // Game interactivity

// Positions
float safeXPos = width/2;                // This defines the center of the safe door which
float safeYPos = height/2;               // opens by moving from center to the right
float xPos;
float yPos;
float speed = 1;                         // Used to control the speed of the cog rotations
float reverseSpeed = speed * -1;

// Colors
// Colors are all managed here to universally define the color scheme.
color colorWhite = color(255);
color colorBlack = color(0);
color colorDarkTeal = color(0, 147, 170);
color colorLightTeal = color(51, 182, 203);
color colorDarkBrown = color(102, 69, 6);
color colorLightBrown = color(161, 130, 71);
color colorLightTan = color(255, 211, 129);
color colorDarkTan = color(129, 84, 0);
color colorOrange = color(255, 167, 0);
color colorGradient = color(195, 135, 20);
color colorButtonLight = color(175);
color colorButtonDark = color(120);          

// Game toggles
/** Booleans are used to define the state of the game as it progresses and applied to 
    various functions and methods to initiate shape changes
**/    
boolean startGame = false;
boolean gameInPlay = false;
boolean winGame = false;
boolean resetGame = false;
boolean openPartSafe = false;
boolean openFullSafe = false;
boolean cogSelected = false;

// Game Content
float retraction;                        // Defines the state of bolt retraction for opening safe
PImage[] safeContent = new PImage[4];    // Array of images can increase to add additional images
int safeImageCounter = 0;                // Keeps track of the index for the safe content images

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

void setup() {
  size(1000, 1000);

  clockLockGame = new GameAsset();                 // Initiates a new game with internal game logic
  mainScene = new Scene();                         // Initiates a new object for all static graphics
  safeContent[0] = loadImage("safeContent1.png");  // Images saved in the accompanying 'data' folder
  safeContent[1] = loadImage("safeContent2.png");
  safeContent[2] = loadImage("safeContent3.png");
  safeContent[3] = loadImage("safeContent4.png");  // Add new additional images here as needed for the array 
  safeDoor = new Portal();                         // Safe door that moves and drawn above the safe content
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

void draw() {
  background(colorDarkTeal);
  
  // Game logic
  clockLockGame.gameState();       // Store and track game state as draw() is called
  clockLockGame.activateGame();    // Initiate game with UI guide and begin interactivity
  
  // Create scene elements
  mainScene.createBkgdCogs();      // Rotating cogs in background
  mainScene.createSafeFrame();     // Static background frame of the safe
  mainScene.createSafeContent();   // Static image depicting inner contents of safe
  safeDoor.create();               // Door to the safe
  
  // Game actions
  clockLockGame.showGameScreen();  // Displays the UI with guide and start/reset buttons
  safeDoor.portalInPlay();         // Initiates the safe door dynamics when game starts
}




// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


// Class for all bolt construction and animation
class Bolt {
  
  // Class Variables 
  float boltRadius = 288;    // Since all bolts are the same size, the dimensions are defined
  float boltLength = 110;    // here locally within the class
  float boltWidth = 40;
  
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Constructor
  
  Bolt(){
  }

  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Bolt Class Methods

  // *******************************************************
  // Construct an individual bolt composed of rectangles that are either static or retract   
  void radialBolt(float x, float y, float angle, boolean retractBolt){
    float centerXPos = x;
    float centerYPos = y;
    float xPos = boltRadius * cos(angle);
    float yPos = boltRadius * sin(angle);
    pushMatrix();
    translate(centerXPos + xPos, centerYPos + yPos);        // Defines new origin
    rotate(angle);
    createBolt(boltLength, boltWidth);                      // Create main bolt rect
    if(retractBolt){                                        // Option to create retracting bolts
      translate(boltLength * retraction, 0);                // Retraction variable moves bolt in/out
      createBolt(boltLength * 0.6, boltWidth * 0.8);        // Create retracting bolt rect
    }
    else{                                                   // Default option to create static bolts
      translate((boltLength / -2) - 2, 0);
      for(int i=1; i < 4; i++){
         createBolt(2, boltWidth * (1 - ((2 * i) * 0.1)));  // Create small rectangles at bolt base 
         translate(-3, 0);                                  
      }
    }
    popMatrix();
  }  
  
  // *******************************************************
  // Create shape and gradient for an individual bolt rectangle
  void createBolt(float createBoltLength, float createBoltWidth){
    noStroke();                                            
    fill(255);                                             
    rectMode(CENTER);                                      // Create solid white background rectangle behind the gradient
    rect(0, 0, createBoltLength, createBoltWidth);         // to hide any gaps between lines in the following gradient array
    pushMatrix(); 
    translate(createBoltLength / -2, createBoltWidth / -2);
    strokeWeight(2.0);
    strokeCap(SQUARE);
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
    /** The following for loop block of code is referenced from Processing Reference Guide example 
        of lerpColor() function. Link: https://processing.org/examples/lineargradient.html
        It applies a gradient to rect along short axis using an array of lines each with a variation 
        of a color defined by a color gradient range.
    **/    
    for(int i=0; i < createBoltWidth; i++){
      float gradRange = map(i, 0, createBoltWidth, 0.0, 1.0);
      //color gradient = lerpColor(createBoltColor1, createBoltColor2, gradRange);
      color gradient = lerpColor(colorWhite, colorGradient, gradRange);
      stroke(gradient);
      line(0, i , createBoltLength, i);
    }
    // End of referenced code block
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    popMatrix();
  }
}



// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



// Class for all cog construction and animation
class Cog {
  
  // Class Variables
  float rSpeed;               // Specifies the rotation speed for each individual cog
  int cogDiameterOuter;       // With the many variations of cogs, each can be defined with
  int cogDiameterInner;       // these diameter and teeth variables
  int numOfTeeth;
  float cogTeethProject;      // Defines how far the teeth project beyond the cog diameter
  color cogColor;             // Main color for the cog
  color bkgdColor;            // Color used to fill in the internal ellipse within each cog
  float rotationOffset;       // Variable used to offset the rotation angle so that adjacent cogs' teeth align
  int detailOption;           // Variable used to define which of the detail options applied to cog
  
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Constructor
  // Used to construct an instance of the Cog object.  The parameters passed through define the type of cog and its behavior
  Cog(float speed, int diameterOuter, int diameterInner, int nCogs, float teethProj, color cColor, color bColor, float rOffset, int detailOpt){
    rSpeed = speed;
    cogDiameterOuter = diameterOuter;
    cogDiameterInner = diameterInner;
    numOfTeeth = nCogs;
    cogTeethProject = teethProj;
    cogColor = cColor;
    bkgdColor = bColor;
    rotationOffset = rOffset;
    detailOption = detailOpt;
  }

  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Methods
  
  // *******************************************************
  // Change cog color  
  void updateCogColor(color updateColor){
    cogColor = updateColor;
  }
  
  // *******************************************************
  // Change cog color at periodic intervals to appear blinking
  void illuminateCog(color lightColor, color baseColor){
    if(int(second()) % 2 == 1){
      cogColor = lightColor;      // Color that cog changes to 
    }
    else{
      cogColor = baseColor;       // Color that cog reverts to
    }
  }  

  // *******************************************************
  // Create cog based on unique origin and polar coordinates in sketch and rotation criteria
  void rotateCog(float x, float y, float radius, float angle){
    float centerXPos = x;                                            
    float centerYPos = y;
    float xPos = radius * cos(angle);
    float yPos = radius * sin(angle);
    pushMatrix();
    translate(centerXPos + xPos, centerYPos + yPos);    // Define new origin based on input parameters
    createCog();                                        // Create a single cog based on new origin
    popMatrix(); 
  }
  
  // *******************************************************
  // Basic building block for use in creating a wide variety of static or rotating cogs based 
  // on size, teeth, color, and any applicable detail option.
  void createCog(){
    float rotateSpeed = 0;
    if(rSpeed != 0){                                              
      rotateSpeed = (TWO_PI / QUARTER_PI * (second() * (rSpeed)));
    }      
    rotate(radians(rotateSpeed));                       // Dynamic rotation initiated, if applicable
    noStroke();
    fill(cogColor);
    pushMatrix();
    rectMode(CENTER);                                   // Create cog teeth
    for(int i = 0; i < (numOfTeeth / 2); i++){
      rotate((TWO_PI + rotationOffset) / numOfTeeth);
      rect(0, 0, (cogDiameterOuter / 2) * (TWO_PI / (numOfTeeth * 2)), cogDiameterOuter + 2 * cogTeethProject);  
    }
    ellipseMode(CENTER);                                // Create center detail circles of wheel
    ellipse(0, 0, cogDiameterOuter, cogDiameterOuter);    
    fill(bkgdColor);
    ellipse(0, 0, cogDiameterInner, cogDiameterInner);    
    if(detailOption == 1){                              // Specify which of the 2 detail options is applied, if any
      createCogDetail(cogDiameterOuter, 30, cogColor);
    }
    else if(detailOption == 2){
      createCogDetail(cogDiameterOuter, 15, cogColor);
    }
    else{
    }
    popMatrix();
  }
  
  // ******************************************************* 
  // Create cog design detail options of radial arcs
  void createCogDetail(int diameter, int angle, color createCogColor){
    noStroke();
    fill(createCogColor);
    rotate(radians((angle / 2)));                       // Rotate pie to align to axis
    diameter = int(diameter * 0.8);
    for(int i = 360; i >= 0; i = i - (2 * angle)){
      int firstAngle = i - angle;
      int secondAngle = i;
      arc(0, 0, diameter, diameter, radians(firstAngle), radians(secondAngle));    // Create pie slices
    }
    fill(createCogColor);
    ellipse(0, 0, diameter / 2, diameter / 2);          // Create inner pie fill circle
  }
}






// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



// Class for interactivity
class GameAsset {
  
  // Class Variables
  int titleBoxX = 140;      // Position of title box used for user guide
  int titleBoxY = 40;
  int titleBoxW = 240;      // Size of box used for user guide
  int titleBoxH = 40;
  int guideBoxH = 100;
  int roundCorner = 5;      // Int used to define rectangles' rounded corners
  int margin = 10;          // Used to separate text boxes
  int alpha = 220;          // Add a bit of transparency to text box rectangles
  color colorStartButton = color(colorDarkTeal, alpha);
  boolean hoverStartButton = false;
  String startTitle = "CLOCK LOCK";
  String startGuide = "The safe has partially unlocked with a malfunction. Click START and the highlighted broken center cog to open the safe.";
  String resetGuide = "Click the highlighted center cog to open the safe. Click RESET to start again and reveal other contents in the safe.";
  
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Constructor
  
  GameAsset(){
  }
  
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Methods
  
  // *******************************************************
  // Manages the state of the game, including the position and open state of the safe door
  void gameState(){
    if(gameInPlay){
      openPartSafe = true;
      if(winGame){
        openFullSafe = true;
        if(resetGame){
          resetState();       // Resets conditions so that game can start as new after win has been achieved
        }
      }
    }
    else{
      openPartSafe = false;
      resetGame = false;
    }
  }
  
  // *******************************************************
  // Activates reset conditions so that game can start as new
  void resetState(){
    startGame = false;          
    gameInPlay = false;
    winGame = false;
    openPartSafe = false;
    openFullSafe = false;
    hoverStartButton = false;   
    safeImageCounter ++;        // Increment to show the next image for the safe contents the next time game is played
  }
  
  // *******************************************************
  // Activates game play and reset states by evaluating state of start/reset buttons
  void activateGame(){                      
     if(hoverStartButton && mousePressed){
       if(winGame){  
         resetGame = true;               // Reset game state when reset button activated
       }
       else{
         startGame = true;               // Start game when start button activated
         gameInPlay = true;
       }
     }
  }

  // *******************************************************
  // Displays the user guide and start/reset button based on game conditions
  void showGameScreen(){
    if(!startGame){                     // Display the start button and guide only when game is neither in play nor being reset
      splashScreenContent(startGuide);
      startButton("START");
    }
    else{                               // In all other conditions, display the reset button and reset guide
      splashScreenContent(resetGuide);
      startButton("RESET");
    }
  }
  
  // *******************************************************
  // Create text and bounding box for use with sketch title and UI
  // Includes string parameter to allow method to be reused between "Start" and "Reset" located in same coordinates 
  void splashScreenContent(String splashText){
    noStroke();
    stroke(colorOrange);
    pushMatrix();
    fill(colorDarkTeal, alpha);                       // Alpha parameter included to allow potential variation in transparency
    rectMode(CENTER);
    translate(titleBoxX, titleBoxY);
    rect(0, 0, titleBoxW, titleBoxH, roundCorner);    // Create title bounding box
    
    fill(colorOrange);
    textSize(30);
    textAlign(CENTER, CENTER);
    text(startTitle, 0, -5);                          // Create title text within title bounding box
    popMatrix();
    
    pushMatrix();
    fill(colorDarkTeal, alpha);
    translate(titleBoxX, titleBoxY + titleBoxH / 2 + margin + guideBoxH / 2);
    rect(0, 0, titleBoxW, guideBoxH, roundCorner);    // Create guide bounding box
    
    fill(255);
    textSize(14);
    textAlign(LEFT);
    text(splashText, margin / 2, margin / 2, titleBoxW - margin, guideBoxH);   // Create guide text within guide bounding box
    popMatrix();
  }

  // *******************************************************
  // Create start button geometry and logic for button functionality
  // Includes string parameter to allow button to be reused between "Start" and "Reset" located in same coordinates
  void startButton(String buttonText){     
    
    // Local variables for use within startButton relating its size to the adjacent text box
    int startButtonW = 140;
    int startButtonX = titleBoxX - titleBoxW / 2;
    int startButtonY = titleBoxY + titleBoxH / 2 + guideBoxH + margin * 2;
    
    pushMatrix();
    if(hoverStartButton){        // Reads state of boolean when mouse hovers over start button
      stroke(colorBlack);        // Change color of button stroke and fill upon hover
      fill(colorDarkTeal);
    }
    else{                        // Default state and color for button when not hovered
      noStroke();                
      stroke(colorOrange);
      fill(colorStartButton);
    }
    rectMode(CORNER);      
    translate(startButtonX, startButtonY);
    rect(0, 0, startButtonW, titleBoxH, roundCorner);       // Create button shape
    fill(colorOrange);
    textSize(30);
    textAlign(CENTER, CENTER);
    text(buttonText, startButtonW / 2, titleBoxH / 2 - 5);  // Create text within button shape
    updateStartButton(startButtonX, startButtonY, startButtonW, titleBoxH);    // Pass button coordinates to method for testing if in hover state
    popMatrix();
  }

  // *******************************************************
  // Method using a boolean to identify if mouse is hovering over its geometry
  void updateStartButton(int bX, int bY, int bW, int bH){
    if(hoverButton(bX, bY, bW, bH)){      
      hoverStartButton = true;
    }
    else{
      hoverStartButton = false;
    }
  }

  // *******************************************************
  // Method returns boolean state identifying if mouse position is hovering over unique coordinates
  boolean hoverButton(int x, int y, int w, int h){
    if(mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h){
      return true;          
    }
    else{
      return false;
    }
  }
}




// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



// Class for creating safe door
class Portal {

  // Class Arrays
  Cog[] safeDoorCogs = new Cog[7];              // Single cogs aligned to sketch center to create safe door
  Cog[] cogRadialSec = new Cog[12];             // Radial array of cogs depicting time in seconds
  Cog[] cogRadialMin = new Cog[12];             // Radial array of cogs depicting time in minutes
  Cog[] cogRadialHr = new Cog[12];              // Radial array of cogs depicting time in hours
  Cog[] cogRadialOutRing1 = new Cog[24];        // Radial array of cogs for outer ring 1
  Cog[] cogRadialOutRing2 = new Cog[24];        // Radial array of cogs for outer ring 2
  Cog[] cogRadialOutRing1Detail = new Cog[24];  // Radial array of cogs for outer ring 1 with inner detail option
  Cog[] cogRadialOutRing2Detail = new Cog[24];  // Radial array of cogs for outer ring 2 with inner detail option
  Bolt[] boltRadial = new Bolt[24];             // Radial array of retractable bolts

  // Class Variables 
  float safeXPos = width/2;
  float safeYPos = height/2;
  int randCog1;
  int randCog2;
  int centerCogDiaOut = 68;
  GameAsset centerCogButton;                    // Used to treat the center cog as a button
  boolean centerCogState = false;               // Defines state for center cog as an interactive button
  boolean retractBolt = true;                   // Sets option for static or retracting bolts
  color brokenCogLight = colorLightTan;
  color brokenCogDark = colorWhite;

  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Constructor

  Portal() {
    // Construct cogs in the center of sketch to depict safe door
    /** The Cog() function requires the following parameters: Cog(float Speed, int CogDiameterOuter,
        int CogDiameterInner, int NumberOfTeeth, float CogTeethProjection, color MainColor, 
        color InnerColor, float RotationOffset, int DesignOption). RotationOffset is to align adjacent 
        cogs with each other Design options range from 1 - 2; 0 is no design option.
    **/  
    safeDoorCogs[0] = new Cog(reverseSpeed, 350, 10, 96, 3, colorLightTan, colorDarkBrown, 0, 0);
    safeDoorCogs[1] = new Cog(reverseSpeed, 323, 10, 96, 3, colorDarkBrown, colorDarkBrown, 0, 0);
    safeDoorCogs[2] = new Cog(speed, 228, 10, 48, 3.75, colorLightTan, colorDarkBrown, 0, 0);
    safeDoorCogs[3] = new Cog(speed, 196, 10, 48, 3.75, colorDarkBrown, colorDarkBrown, 0, 0);
    safeDoorCogs[4] = new Cog(reverseSpeed, 135, 10, 48, 2.5, colorLightTan, colorDarkBrown, 0, 0);
    safeDoorCogs[5] = new Cog(reverseSpeed, 107, 10, 48, 2.5, colorDarkBrown, colorDarkBrown, 0, 0);
    safeDoorCogs[6] = new Cog(speed / 4, centerCogDiaOut, 30, 24, 2.5, brokenCogLight, colorDarkBrown, 0, 0);

    // Construct central pattern of radial cogs for clock
    for (int i=0; i < cogRadialSec.length; i++) {                                                        // Ring for seconds
      cogRadialSec[i] = new Cog(reverseSpeed * 2, 15, 8, 6, 2.5, colorOrange, colorDarkBrown, 0, 0);
    }
    for (int i=0; i < cogRadialMin.length; i++) {                                                        // Ring for minutes
      cogRadialMin[i] = new Cog(speed, 25, 17, 6, 2.5, colorOrange, colorDarkBrown, 0, 0);
    }
    for (int i=0; i < cogRadialHr.length; i++) {                                                         // Ring for hours
      cogRadialHr[i] = new Cog(reverseSpeed * 4, 40, 25, 12, 2.5, colorOrange, colorDarkBrown, 0, 0);
    }

    // Construct central pattern of radial cogs for 2 rings around clock
    for (int i=0; i < cogRadialOutRing1.length; i++) {                                                   
      cogRadialOutRing1[i] = new Cog(speed * 4, 30, 22, 12, 2.5, colorOrange, colorDarkBrown, 0, 0);  // Outer ring 1
      cogRadialOutRing1Detail[i] = new Cog(speed * 4, 15, 8, 12, 2.5, colorOrange, colorWhite, 0, 1); // Outer ring 1 detail option
    }
    for (int i=0; i < cogRadialOutRing2.length; i++) {                                                   
      cogRadialOutRing2[i] = new Cog(speed * 2, 34, 24, 18, 2.5, colorOrange, colorDarkBrown, 0, 0);  // Outer ring 2
      cogRadialOutRing2Detail[i] = new Cog(speed * 2, 15, 8, 18, 2.5, colorOrange, colorWhite, 0, 2); // Outer ring 2 detail option
    }

    // Construct ring of retractable bolts
    for (int i=0; i < boltRadial.length; i++) {
      boltRadial[i] = new Bolt();
    }

    // Construct button for center cog
    centerCogButton = new GameAsset();
  }

  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Methods

  // *******************************************************
  // Create geometry depicting the safe door
  void create() {
    
    // Create background for safe door
    noStroke();
    fill(colorLightTeal);
    ellipse(safeXPos, safeYPos, 719, 719); 
    fill(colorDarkBrown);
    ellipse(safeXPos, safeYPos, 480, 480);

    // Create central cogs
    for (int i=0; i < safeDoorCogs.length; i++) {            // For loops sort array order from background to foreground
      safeDoorCogs[i].rotateCog(safeXPos, safeYPos, 0, 0);
    }

    // Create central pattern of radial cogs for clock: Seconds
    float angle = radians(270);                              // Angle rotation to align 0 with the top of the clock
    float radius = 45;                                       // Radius from center of the safe origin
    for (int i=0; i < cogRadialSec.length; i++) {
      cogRadialSec[i].rotateCog(safeXPos, safeYPos, radius, angle);
      angle += TWO_PI / cogRadialSec.length;                 // Rotate origin angle to create next iteraction of cog
      int s = second();
      if (i == s/5) {                                        // Cog color changes when it syncs with sec
        cogRadialSec[i].updateCogColor(colorLightTeal);
      } else {
        cogRadialSec[i].updateCogColor(colorOrange);
      }
    }

    // Create central pattern of radial cogs for clock: Minutes
    radius = 85;                                             // Radius from center of the safe origin
    for (int i=0; i < cogRadialMin.length; i++) {
      cogRadialMin[i].rotateCog(safeXPos, safeYPos, radius, angle);
      angle += TWO_PI / cogRadialMin.length;                 // Rotate origin angle to create next iteraction of cog
      int m = minute();
      if (i == m/5) {                                        // Cog color changes when it syncs with min
        cogRadialMin[i].updateCogColor(colorLightTeal);
      } else {
        cogRadialMin[i].updateCogColor(colorOrange);
      }
    }

    // Create central pattern of radial cogs for clock: Hours
    radius = 140;                                           // Radius from center of the safe origin  
    for (int i=0; i < cogRadialHr.length; i++) {
      cogRadialHr[i].rotateCog(safeXPos, safeYPos, radius, angle);
      angle += TWO_PI / cogRadialHr.length;                 // Rotate origin angle to create next iteraction of cog
      int h = hour();
      if (h > 12) {
        h -= 12;                                           // Convert 24 hr system to 12 hour system
      }
      if (i == h) {                                        // Cog color changes when it syncs with hr
        cogRadialHr[i].updateCogColor(colorLightTeal);
      } else {
        cogRadialHr[i].updateCogColor(colorOrange);
      }
    }

    // Create outer rings
    angle = 0;                                             // Reset angle to align with default radial coordinate of 0
    for (int i=0; i < cogRadialOutRing1.length; i++) {
      cogRadialOutRing1[i].rotateCog(safeXPos, safeYPos, 195, angle);          // Create the innermost of the 2 rings
      cogRadialOutRing1Detail[i].rotateCog(safeXPos, safeYPos, 195, angle);    // Create the inset cog within each larger cog
      angle += TWO_PI / cogRadialOutRing1.length;          // Rotate origin angle to create next iteraction of cog
    }
    angle = 25;                                            // Offset outer ring angle so that cogs align with cogs in inner ring
    for (int i=0; i < cogRadialOutRing2.length; i++) {
      cogRadialOutRing2[i].rotateCog(safeXPos, safeYPos, 220, angle);          // Create the outermost of the 2 rings
      cogRadialOutRing2Detail[i].rotateCog(safeXPos, safeYPos, 220, angle);    // Create the inset cog within each larger cog
      angle += TWO_PI / cogRadialOutRing2.length;          // Rotate origin angle to create next iteraction of cog
    }

    // Illuminate random cogs in the 2 outer rings of cogs so they appear to be blinking sporadically
    randCog1 = int(random(0, cogRadialOutRing1.length));                       // Random number generated from within array length
    cogRadialOutRing1[randCog1].illuminateCog(colorLightTeal, colorOrange);
    randCog2 = int(random(0, cogRadialOutRing2.length)); 
    cogRadialOutRing2[randCog2].illuminateCog(colorLightTeal, colorOrange);

    // Create radial pattern of bolts based on safe door full/partial/not open state
    if (openPartSafe) {
      if (openFullSafe) {
        retraction = 0.3;    // Bolts retracted fully to depict fully open safe door
        allBolts();
      } else {
        retraction = 0.6;    // Bolts retracted partially to depict a malfunctioned safe door
        allBolts();
      }
    } else {
      retraction = 0.8;      // Default state of bolts depicting fully locked safe door
      allBolts();
    }
  }

  // *******************************************************
  // Create radial array of bolts
  void allBolts() {  
    float angle = 0;
    for (int i=0; i < boltRadial.length; i++) {
      boltRadial[i].radialBolt(safeXPos, safeYPos, angle, retractBolt);    // Create the rectangle with retraction functionality
      boltRadial[i].radialBolt(safeXPos, safeYPos, angle, !retractBolt);   // Create the base static rectangles for the bolt
      angle += TWO_PI / boltRadial.length;                                 // Rotate origin angle to create next bolt in for loop
    }
  }

  // *******************************************************
  // Manage state of safe door throughout game play
  void portalInPlay() {
    if (startGame) {                          // Conditional to control position of safeDoor after game start
      centerCogButton();                      // Enable center cog button for opening door
      if (winGame) {                          // Conditional to control position of safeDoor only after successful center cog button click
        safeDoorCogs[6].updateCogColor(brokenCogLight);    // Reset center cog color back to its base default color
        for (int i=0; i < safeDoorCogs.length; i++) {
          if (resetGame) {
            safeXPos = width/2;               // Reset safe door back to its original position
          }
          else{
            safeXPos += 1;                    // Move safe door from origin to the right
          }
        }
        translate(safeXPos, safeYPos);  
      }
    }
  }

  // *******************************************************
  // Define state of center cog when enabled as a button
  void centerCogButton() {
    updateCenterCogState(int(safeXPos - centerCogDiaOut/2), int(safeYPos - centerCogDiaOut/2), centerCogDiaOut, centerCogDiaOut);
    if (centerCogState) {                                // Reads state of boolean when mouse hovers over center cog
      safeDoorCogs[6].updateCogColor(colorLightTeal);    // Highlights cog color when mouse hovers over center cog
      if (mousePressed) {                                // State of winGame and cog color when mouse is clicked over cog
        winGame = true;                                  // Declares game state of successful completion 
        safeDoorCogs[6].updateCogColor(colorBlack);
      }
    } else {                                             
      safeDoorCogs[6].illuminateCog(brokenCogDark, brokenCogLight);    // Center cog changes color to appear blinking 
    }
  }

  // *******************************************************
  // Method using a boolean to identify if mouse is hovering over its geometry
  void updateCenterCogState(int bX, int bY, int bW, int bH) {
    if (centerCogButton.hoverButton(bX, bY, bW, bH)) {    // Uses Game().hoverButton method to modify state of boolean for mouse hover
      centerCogState = true;
    } else {
      centerCogState = false;
    }
  }
}



// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




// Class for creating the static background content of the sketch
class Scene {
  
  // Class Arrays
  Cog[] cogBkgd = new Cog[4];      // Background pattern of cogs
  Cog[] safeFrame = new Cog[3];    // Cogs aligned to the center of the sketch used to create the safe
  
  // Class Variables 
  int cogBkgdDiameterOuter = 100;  // Used for consistent size of the background cogs
  int cogBkgdDiameterInner = 75;       
  int numOfTeeth = 18;             // Used for consistent number of teeth in the background cogs
  
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Constructor
  
  Scene(){
    // Construct cogs for use in the background pattern
    /** The Cog() function requires the following parameters: Cog(float Speed, int CogDiameterOuter,
        int CogDiameterInner, int NumberOfTeeth, float CogTeethProjection, color MainColor, 
        color InnerColor, float RotationOffset, int DesignOption). RotationOffset is to align adjacent 
        cogs with each other Design options range from 1 - 2; 0 is no design option.
    **/      
    cogBkgd[0] = new Cog(speed * 2, cogBkgdDiameterOuter, cogBkgdDiameterInner, numOfTeeth, 5, colorLightBrown, colorDarkTeal, 0, 0);
    cogBkgd[1] = new Cog(speed * 2, int(cogBkgdDiameterOuter * 0.6), int(cogBkgdDiameterInner * 0.6), numOfTeeth, 3, colorLightBrown, colorWhite, 0, 1);
    cogBkgd[2] = new Cog(reverseSpeed * 2, cogBkgdDiameterOuter, cogBkgdDiameterInner, numOfTeeth, 5, colorDarkBrown, colorDarkTeal, radians(5), 0);
    cogBkgd[3] = new Cog(reverseSpeed * 2, int(cogBkgdDiameterOuter * 0.6), int(cogBkgdDiameterInner * 0.6), numOfTeeth, 3, colorDarkBrown, colorWhite, radians(5), 2);
  
    // Construct cogs for the shape of the safe
    safeFrame[0] = new Cog(0, 725, 719, 24, 60, colorWhite, colorWhite, 0, 0);                    // White backdrop
    safeFrame[1] = new Cog(0, 720, 719, 24, 60, colorDarkTan, colorLightTeal, 0, 0);              // Stationary back cog
    safeFrame[2] = new Cog(0, 480, 10, 0, 80, colorDarkBrown, colorDarkBrown, 0, 0);              // Stationary cog
  }

  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Class Methods
  
  // *******************************************************
  // Create background pattern of rotating cogs
  /** Create the columns of rotating cogs serving as the background for the sketch. Each cog is created
      using 2 separate cogs: a large background cog and a smaller inner cog with a variation of details, 
      as defined in its constructor parameter.
  **/
  void createBkgdCogs(){
    for(float i = 0; i < width + (cogBkgdDiameterOuter * cos(radians(30))); i += ((cogBkgdDiameterOuter * cos(radians(30))) * 2)){
      for(float j = (cogBkgdDiameterOuter * cos(radians(50))); j < height + (cogBkgdDiameterOuter * cos(radians(30))); j += (cogBkgdDiameterOuter * cos(radians(50))) * 2){
        pushMatrix();
        translate(i, j);        
        cogBkgd[0].createCog();  // Large outer cog
        cogBkgd[1].createCog();  // Small inner cog with detail
        popMatrix();
      }
    } 
    for(float i = ((cogBkgdDiameterOuter * cos(radians(30))) * 1); i < width + (cogBkgdDiameterOuter * cos(radians(30))); i += ((cogBkgdDiameterOuter * cos(radians(30))) * 2)){
      for(float j = 0; j < height + (cogBkgdDiameterOuter * cos(radians(30))); j += (cogBkgdDiameterOuter * cos(radians(50))) * 2){
        pushMatrix();
        translate(i, j);
        cogBkgd[2].createCog();  // Large outer cog
        cogBkgd[3].createCog();  // Small inner cog with detail
        popMatrix();
      }
    }
  }

  // *******************************************************
  // Create safe frame
  /** Create the frame for the safe using a series of static cogs located in the center of the sketch and 
      serving as a background for the safe contents and safe door.
  **/
  void createSafeFrame(){
    for(int i=0; i < safeFrame.length; i++){
       safeFrame[i].rotateCog(width/2, height/2, 0, 0);
    }
  }

  // *******************************************************
  // Create safe contents
  /** Create content within the opened safe using PNG images located in the accompanying data folder. The 
      safeImageCounter changes with each game reset so that a different image appears each time that the game 
      is played.  Images are loaded into the main setup() function and called within this function. The PNG 
      image format allows for the transparency to hide portions of the image so that only the safe contents 
      appear.
  **/
  void createSafeContent(){
    if(winGame){
      if(safeImageCounter >= safeContent.length){
         safeImageCounter = 0;
      }
      int imageSize = 720;
      pushMatrix();
      translate(width/2, height/2);
      image(safeContent[safeImageCounter], imageSize/-2, imageSize/-2, imageSize, imageSize);
      popMatrix();
    }
  }
}







// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

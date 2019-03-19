//**********************************************************************************
// Declare variables

// GUI
let gui;

// GUI library requires the use of 'var' to define variables, and not 'let'
var bgColor = [0, 25, 50];         // Dark blue color
var ptSize = 1;
var ptColor = [255, 255, 255];
var density = .1;
var zoom = 10;
var speed = 0.01;

// Declare particle generator
var particleGen;

// Color declaration
let blackSolid, whiteSolid, redSolid, greenSolid, blueSolid;
// Used for particles
let blackAlpha10, blackAlpha50, blackAlpha100, blackAlpha150, blackAlpha200;

let depth = 100;
let scalar;

// Setup of pseudonyms for ctrl panel labels
let iteration;
let geoSizeMultiple;

let u, v;

//**********************************************************************************
// Setup function
function setup(){

    // Setup canvas
    createCanvas(windowWidth, windowHeight, WEBGL);

    // Color initialization
    whiteSolid = color(255, 255, 255);
    blackSolid = color(0, 0, 0);
    redSolid = color(255, 0, 0);
    greenSolid = color(0, 255, 0);
    blueSolid = color(0, 0, 255);
    // Use for particles
    blackAlpha10 = color(0, 0, 0, 10);
    blackAlpha50 = color(0, 0, 0, 50);
    blackAlpha100 = color(0, 0, 0, 100);
    blackAlpha150 = color(0, 0, 0, 150);
    blackAlpha200 = color(0, 0, 0, 200);

    // Initialize GUI
    // Parameters include: (label (which can be wrapped text), x-pos from left,
    // y-pos from top)
    gui = createGui('Control Panel (Double-click menu to expand/collapse', 20, 20);

    // slider range controls
    /** sliderRange() function parameters include:
     * (bottom of range, top of range, density)
     * Colors do not require the parameters since they automatically include the
     * range of color values. Labels are defined by the var name, so pseudonyms
     * can be created to reassign labels.  See ex. iteration/density & geoSizeMultiple/zoom.
    **/

    // set ptSize range
    // include ptColor
    sliderRange(1, 10, 1);
    gui.addGlobals('ptSize', 'ptColor');

    // set density range
    sliderRange(0.05, 0.2, 0.01);
    gui.addGlobals('density');

    // set geoSizeMultiple range
    sliderRange(8, 20, .01);
    gui.addGlobals('zoom');

    // set speed range
    sliderRange(0.001, 0.05, 0.001);
    gui.addGlobals('speed');

    // set bgColor
    sliderRange(0, 255, 1);
    gui.addGlobals('bgColor');

    // only call draw when then gui is changed
    //noLoop();

    // Variable with user-defined data to initiate particles
    var t =
        {
            name: "test",
            // Colors array is based on the particle's lifetime
            colors: [blackAlpha10, blackAlpha200],
            // Gravity draws the particles back down based on lifetime parameter
            gravity: .1,
            // Lifetime is number of steps for each particle to live
            lifetime: 300,
            angle: [260,280],
            // Size is range of randomness in particle size
            size: [2,8],
            speed: 14,
            speedx: 1,
            //40 at .1 probability/step
            //then 200 steps at 10 particles/step
            rate: [500,10],
            // xPos of source, fraction of screen width
            x: 0,
            // yPos of source, fraction of screen width
            y: .5
        };

    // Initiate particle generator
    particleGen = new Fountain(null, t);

}

//**********************************************************************************
// Draw function
function draw() {

    // The following pseudonyms were declared before setup() but then initialized in
    // draw() so that they can be updated as the var values are updated in setup().
    iteration = density;
    geoSizeMultiple = zoom;

    scalar = windowHeight / geoSizeMultiple;
    background(bgColor);
    // Canvas border
    //noFill();
    //stroke(blackSolid);
    //strokeWeight(1);
    //rect(-width/2, -height/2, width - 1, height - 1);

    push();
    translate(0, 0, 0);
    //rotateX(mouseX/(windowWidth/2) + (frameCount * speed));
    //rotateY(mouseY/(windowHeight/2) + (frameCount * speed));
    rotateX(frameCount * speed);
    rotateY(frameCount * speed);
    rotateZ(frameCount * speed);
    // Point mesh
    stroke(ptColor);
    strokeWeight(ptSize);
    for(u = -PI; u < PI; u+=iteration) {
        for(v = -PI; v < PI; v+=iteration) {
            let ptX = (2 * sin(3 * u) / (2 + cos(v))) * scalar;
            let ptY = (2 * (sin(u) + 2 * sin(2 * u)) / (2 + cos(v + 2 * PI / 3))) * scalar;
            let ptZ = ((cos(u) - 2 * cos(2 * u)) * (2 + cos(v)) * (2 + cos(v + 2 * PI / 3)) / 4) * scalar;
            point(ptX, ptY, ptZ);
            //print("pts[" + i + "]: " + "(" + pts[i].x + ", " + pts[i].y + ", " + pts[i].z + ")");
        }
    }
    pop();

    // Drawing of generated particles
    particleGen.Draw();
    particleGen.Create();
    particleGen.Step();
    noStroke();
    text(particleGen.length, width/2, 20);
    stroke(0);

}

// Dynamically adjust the canvas to the window
function windowResized() {
    resizeCanvas(windowWidth, windowHeight);
}
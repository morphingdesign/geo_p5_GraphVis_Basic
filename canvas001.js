//**********************************************************************************
// Declare variables

// GUI
let gui;

// GUI library requires the use of 'var' to define variables, and not 'let'
var bgColor = [0, 0, 0];
var ptSize = 1;
var ptColor = [255, 255, 255];
var density = .1;
var zoom = 10;
var speed = 0.01;

// Color declaration
let blackSolid, whiteSolid, redSolid, greenSolid, blueSolid;

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

    // Initialize GUI
    gui = createGui('Control Panel');

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

}

// Dynamically adjust the canvas to the window
function windowResized() {
    resizeCanvas(windowWidth, windowHeight);
}
//**********************************************************************************
// Declare variables

// GUI
let gui;
var bgColor = [0, 0, 0];
var opacity = 150;

var ptColor = [0, 0, 0];
// Color declaration
let blackSolid, whiteSolid, redSolid, greenSolid, blueSolid;


let depth = 100;
let scalar;
let speed = 0.01;
let iteration = .1;
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
    gui = createGui('slider-range-2');
    // set opacity range
    sliderRange(0, 255, 1);
    gui.addGlobals('opacity', 'bgColor');

    sliderRange(0, 255, 1);
    gui.addGlobals('ptColor');

    // only call draw when then gui is changed
    //noLoop();
}

//**********************************************************************************
// Draw function
function draw() {


    scalar = windowHeight / 10;
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
    strokeWeight(1);
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
    /**
     noStroke();
    if(mouseIsPressed) {
        fill(redSolid);
    } else{
        fill(blueSolid);
    }
    ellipse(mouseX, mouseY, 80, 80);
     **/
}

// Dynamically adjust the canvas to the window
//function windowResized() {
//    resizeCanvas(windowWidth, windowHeight);
//}
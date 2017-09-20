int worldResX = 1000;
int worldResY = 1000;
int tilesX;
int tilesY;
int tileFill = 50;
float cameraPosX;
float cameraPosY;
int zoom = 40;
float playerSpeed = 0.05;
long prev;
boolean isLoading = false;
int loadCalcs = 0;
int worldIterations = 3;
int maxCalcs;
float playerPosX;
float playerPosY;

boolean goUp = false;
boolean goDown = false;
boolean goLeft = false;
boolean goRight = false;

Tile[][] tile;
int[][] levelDataRaw;

void setup() {
  size(500,500,P2D);
  frameRate(500);
  maxCalcs = (worldResX*worldResY*2)+(worldIterations*(worldResX*worldResY*2));
  tile = new Tile[worldResX][worldResY];
  levelDataRaw = new int[worldResX][worldResY];
  for(int yPos = 0; yPos < (worldResY); yPos++) {
    for(int xPos = 0; xPos < (worldResX); xPos++) {
      tile[xPos][yPos] = new Tile(xPos, yPos);
    }
  }
  noStroke();
}

void draw() {
  background(0);
  drawTiles();
  updatePlayer();
  updateCam();
  drawPlayer();
  drawLoader(loadCalcs,isLoading);
  //println(levelDataRaw[round(playerPosX-0.5)][round(playerPosY-0.5)]);
}

void drawLoader(float percent,boolean isLoading) {
  if(isLoading){
    fill(0);
    rect(0,0,width,height);
    fill(255);
    textSize(50);
    text(round(percent/maxCalcs*100)+"%",width/2,height/2);
  }
}

void drawTiles() {
  for(int yPos = (int(cameraPosY)/zoom)-(height/zoom/2)-1; yPos <= (cameraPosY/zoom)+(height/zoom/2)+1; yPos++) {
    for(int xPos = (int(cameraPosX)/zoom)-(width/zoom/2)-1; xPos <= (cameraPosX/zoom)+(width/zoom/2)+1; xPos++) {
      if(xPos>0&&xPos<worldResX&&yPos>0&&yPos<worldResY){
        if(levelDataRaw[xPos][yPos]==1){
          fill(0);
        }else{
          fill(255);
        }
        rect((xPos*zoom)-(cameraPosX-width/2),(yPos*zoom)-(cameraPosY-height/2),zoom,zoom);
      }
    }
  }
}

void updateCam() {
  cameraPosX-=(cameraPosX-(playerPosX*zoom)-zoom/2)/50;
  cameraPosY-=(cameraPosY-(playerPosY*zoom)-zoom/2)/50;
  if(mousePressed){
    cameraPosX += pmouseX-mouseX;
    cameraPosY += pmouseY-mouseY;
  }
}

void updatePlayer() {
  double delta = (-prev + (prev = frameRateLastNanos))/1e6d;
  if(goUp && colUp()){
    playerPosY-=playerSpeed/10*(float)delta;
  }
  if(goDown && colDown()){
    playerPosY+=playerSpeed/10*(float)delta;
  }
  if(goLeft && colLeft()){
    playerPosX-=playerSpeed/10*(float)delta;
  }
  if(goRight && colRight()){
    playerPosX+=playerSpeed/10*(float)delta;
  }
}

boolean colUp() {
  if(levelDataRaw[round(playerPosX-0.4)][round(playerPosY-0.5)]==1||levelDataRaw[round(playerPosX+0.4)][round(playerPosY-0.5)]==1){
    return false;
  }else{
    return true;
  }
}

boolean colRight() {
  if(levelDataRaw[round(playerPosX+0.5)][round(playerPosY-0.4)]==1||levelDataRaw[round(playerPosX+0.5)][round(playerPosY+0.4)]==1){
    return false;
  }else{
    return true;
  }
}

boolean colLeft() {
  if(levelDataRaw[round(playerPosX-0.5)][round(playerPosY-0.4)]==1||levelDataRaw[round(playerPosX-0.5)][round(playerPosY+0.4)]==1){
    return false;
  }else{
    return true;
  }
}

boolean colDown() {
  if(levelDataRaw[round(playerPosX-0.4)][round(playerPosY+0.5)]==1||levelDataRaw[round(playerPosX+0.4)][round(playerPosY+0.5)]==1){
    return false;
  }else{
    return true;
  }
}

void drawPlayer() {
  fill(#F09438);
  rect((playerPosX*zoom)-(cameraPosX-width/2),(playerPosY*zoom)-(cameraPosY-height/2),zoom,zoom);
}

void randomize() {
  for(int yPos = 0; yPos < (worldResY); yPos++) {
    for(int xPos = 0; xPos < (worldResX); xPos++) {
      levelDataRaw[xPos][yPos]=tile[xPos][yPos].randomize(tileFill);
      loadCalcs++;
    }
  }
}

void iterate() {
  for(int yPos = 0; yPos < (worldResY); yPos++) {
    for(int xPos = 0; xPos < (worldResX); xPos++) {
      tile[xPos][yPos].iterate();
      loadCalcs++;
    }
  }
  for(int yPos = 0; yPos < (worldResY); yPos++) {
    for(int xPos = 0; xPos < (worldResX); xPos++) {
      levelDataRaw[xPos][yPos]=tile[xPos][yPos].updateData();
      loadCalcs++;
    }
  }
}

void invert() {
  for(int yPos = 0; yPos < (worldResY); yPos++) {
    for(int xPos = 0; xPos < (worldResX); xPos++) {
      if(levelDataRaw[xPos][yPos]==0){
        levelDataRaw[xPos][yPos]=1;
      }else{
        levelDataRaw[xPos][yPos]=0;
      }
    }
  }
}

void generateWorld() {
  isLoading = true;
  loadCalcs = 0;
  clearWorld();
  randomize();
  for(int i=0;i<worldIterations;i++) {
    iterate();
  }
  isLoading = false;
}

void clearWorld() {
  for(int yPos = 0; yPos < (worldResY); yPos++) {
    for(int xPos = 0; xPos < (worldResX); xPos++) {
      levelDataRaw[xPos][yPos]=0;
      loadCalcs++;
    }
  }
}

void keyPressed() {
  if(key=='w'){goUp = true;}
  if(key=='s'){goDown = true;}
  if(key=='a'){goLeft = true;}
  if(key=='d'){goRight = true;}
  if(key=='g'){
    thread("generateWorld");
  }
}

void keyReleased() {
  if(key=='w'){goUp = false;}
  if(key=='s'){goDown = false;}
  if(key=='a'){goLeft = false;}
  if(key=='d'){goRight = false;}
}
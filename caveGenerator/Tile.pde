class Tile {
  int xPos;
  int yPos;
  int currentState;
  int neighbors;
  Tile(int xpos_,int ypos_) {
    xPos = xpos_;
    yPos = ypos_;
  }
  
  int randomize(int density) {
    if(random(100)<density) {
      return(1);
    }else{
      return(0);
    }
  }
  
  void iterate() {
    neighbors=0;
    for(int y=-1;y<=1;y++) {
      for(int x=-1;x<=1;x++) {
        if((xPos+x)>=0 && (xPos+x)<worldResX&&(yPos+y)>=0 &&(yPos+y)<worldResY){
          if(levelDataRaw[xPos+x][yPos+y]==1){
            neighbors++;
          }
        }else{
          neighbors++;
        }
      }
    }
    neighbors--;
    if(neighbors >= 4){
      currentState = 1;
    }else{
      currentState = 0;
    }
  }
  
  int updateData() {
    return currentState;
  }
}
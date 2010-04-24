class Arc{ 
  Node v; 
  Node u;
  String tag;
  float weight = 1;
  boolean needsUpdate = false;
  int updateTicksRemaining = 0;
  color highlightStart = #FFFF00;
  color lastUpdateColor = #FFFF00;
  color defaultColor = #00FF00;
  
  // HACK this is a giant hack!!!
  ArrayList updateUQueue = new ArrayList(); // this is such a fucking hack
  
  Arc(Node _s, Node _e){ 
    v=_s; 
    u=_e;
  }
  
  Arc(Node _s, Node _e, String _tag) {
    v = _s;
    u = _e;
    tag = _tag;
  }
   
  void draw(){ 
    /*int r=(int)((red(v.mycolor)+red(u.mycolor))/2); 
        int g=(int)((green(v.mycolor)+green(u.mycolor))/2); 
        int b=(int)((blue(v.mycolor)+blue(u.mycolor))/2);*/

    /*color c = color(r, g, b);*/
    
    color c = defaultColor;

    
    if (tag.equals("work")) {
      c = #0000FF;
    }     
    
    // really lame flashing animation.
    if (updateTicksRemaining > 0) {
      lastUpdateColor = blendColor(c, lastUpdateColor, BLEND);
      c = lastUpdateColor;
      updateTicksRemaining--;
      
      // HACK
      // This is a terrible way to handle the animation.
      if (updateUQueue.size() > 0) {
       int ticksLeftBeforeUpdate = ((Integer)updateUQueue.remove(0)).intValue();
       if (ticksLeftBeforeUpdate > 1) {
         ticksLeftBeforeUpdate--;
         updateUQueue.add(0, new Integer(ticksLeftBeforeUpdate));
       } else {
         u.lastUpdateColor = u.highlightStart;
         u.updateTicksRemaining += frameRate;
       }
      }
    }
    stroke(c);
    strokeWeight(weight);
    //stroke(r,g,b); 
    line(v.pos.x,v.pos.y,u.pos.x,u.pos.y); 
    bezier(v.pos.x,v.pos.y,v.oldpos[2].x,v.oldpos[2].y,u.oldpos[2].x,u.oldpos[2].y,u.pos.x,u.pos.y);     
    noStroke(); 
  } 
} 


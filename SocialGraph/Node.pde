class Node{ 
  Vector2D pos; 
  Vector2D disp; 
  Vector2D[] oldpos; 
  float mass; 
  float newmass; 
  color mycolor; 
  boolean trail; 
  boolean ball;
  int node_id;
  
  Node(float _x, float _y,float _mass, int _node_id){ 
    pos=new Vector2D(_x,_y); 
    disp=new Vector2D(); 
    mass=_mass; 
    oldpos=new Vector2D[8]; 
    for(int i=0;i<oldpos.length;i++) 
      oldpos[i]=pos.clone(); 
      mycolor=color(random(240,280),61,5,random(100,254)); 
// mycolor=color(20+random(215),20+random(215),20+random(215));
    ball=true; 
    trail=true;
    node_id = _node_id; 
  } 
  void incrMass(float nm){ 
    newmass=mass+nm; 
  } 
  void setBall(boolean ball){ 
    this.ball=ball; 
  } 
  void setTrail(boolean trail){ 
    this.trail=trail; 
  } 
  void update(){ 
    for(int i=oldpos.length-1;i>0;i--) 
      oldpos[i]=oldpos[i-1]; 
    oldpos[0]=pos.clone();   
    pos.addSelf(disp); 
    disp.clear(); 
  }   
  void draw(){
    int node_id = -1; 
    if (mass<newmass) 
      mass+=4; 
//    if (trail)  
//      for(int i=0;i<oldpos.length;i++){ 
//        float perc=(((float)oldpos.length-i)/oldpos.length); 
//        fill(245,184,0,254); 
//        ellipse(oldpos[i].x,oldpos[i].y,mass*perc,mass*perc);
//               // fill(254,254,254,100); 
//               // ellipse(oldpos[i].x,oldpos[i].y,1*mass*perc,2*mass*perc); 
//      } 
    if (ball)  { 
      fill(mycolor); 
      ellipse(pos.x,pos.y,mass*1.5,mass*1.5); 
      fill(240,240,240); 
      ellipse(pos.x,pos.y,mass*1.5,mass*1.5); 
      fill(mycolor);
      ellipse(pos.x,pos.y,mass,mass);
      fill(0);
      text("TEST", pos.x - mass*1.5/2, pos.y /*- mass*1.5/2*/, mass*1.5, mass*1.5);    
    } 
  } 
  void costrain(float x0, float x1,float y0, float y1){ 
    pos.x=min(x1,max(x0,pos.x)); 
    pos.y=min(y1,max(y0,pos.y)); 
  } 
  String toString(){ 
    return pos+""; 
  } 
} 


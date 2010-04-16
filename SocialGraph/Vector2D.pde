class Vector2D{ 
  float x; 
  float y; 
  Vector2D(){ 
    this(0,0); 
  } 
  void set(float _x,float _y){x=_x;y=_y;} 
  Vector2D(float _x, float _y){ 
    x=_x; 
    y=_y; 
  } 
  void clear(){x=0;y=0;} 
  Vector2D add(Vector2D v){ 
    return new Vector2D(x+=v.x,y+=v.y); 
  } 
  Vector2D add(float x, float y){ 
    return new Vector2D(x+=x,y+=y); 
  } 
  Vector2D addSelf(Vector2D v){ 
    x+=v.x; 
    y+=v.y; 
    return this; 
  }   
  Vector2D addSelf(float _x, float _y){ 
    x+=_x; 
    y+=_y; 
    return this; 
  }   
  Vector2D sub(float x, float y){ 
    return new Vector2D(x-=x,y-=y); 
  } 
  Vector2D sub(Vector2D v){ 
    return new Vector2D(x-v.x,y-v.y); 
  } 
  Vector2D subSelf(Vector2D v){ 
    x-=v.x; 
    y-=v.y; 
    return this; 
  } 
  Vector2D subSelf(float _x, float _y){ 
    x-=_x; 
    y-=_y; 
    return this; 
  } 
  Vector2D mult(float alpha){ 
    return new Vector2D(x*alpha,y*alpha); 
  } 
  Vector2D multSelf(float alpha){ 
    x*=alpha; 
    y*=alpha; 
    return this; 
  } 
  Vector2D div(float alpha){ 
    return new Vector2D(x/alpha,y/alpha); 
  } 
  Vector2D divSelf(float alpha){ 
    x/=alpha; 
    y/=alpha; 
    return this; 
  } 
  float norm(){ 
    return sqrt(pow(x,2)+pow(y,2)); 
  } 
  Vector2D versor(){ 
    return new Vector2D(x/norm(),y/norm()); 
  } 
  Vector2D versorSelf(){ 
    x/=norm(); 
    y/=norm(); 
    return this; 
  } 
  Vector2D clone(){ 
    return new Vector2D(x,y); 
  } 
  String toString(){ 
    return "["+x+","+y+"]"; 
  } 
} 


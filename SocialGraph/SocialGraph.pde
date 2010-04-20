/* THIS IS BASED OFF OF ORANGENETWORK FROM PROCESSING.ORG */


/*there is a movie export and image function built in that has been commented out
 *you can restore the movie export option by searching for "mm" in the main tab and uncommenting those lines and importing processing.video.*
 *you can restore the image export by uncommenting the saveFrame line (near the end)
 *the VAST MAsJORITY of this code, including the algorithm for rendering the networks is taken from Lorenzo Marchi's Force Directed Placement
 *http://www.openprocessing.org/visuals/?visualID=177
 *licensed under creative commons and taken from OpenProcessing.org
 *the "shower" tab is from Multiple Particle Systems by  Daniel Shiffman
 */

//import processing.video.*;

//MovieMaker mm;

import processing.net.*; // for server

float mouseMass=30; 
 
boolean renderTrail=true; 
boolean renderArcs=true; 
boolean mouseAttract=false; 
boolean mouseRepulse=false; 
boolean renderBalls=true; 

 
int vel=15; 
int mode=FREE; 
ArrayList ns; 
ArrayList as; 
float k,k2; 
int t; 
float tMass; 
int curn,nn; 
float curMass; 
static final int RANDOM=0; 
static final int POLYNET=1;
static final int FREE = 2; 
int im;

// so used to _ instead of camel case :(
Server sgDataListener; // listen for changes to the sg here

// NO FANCY MODES PLZ.
// void keyPressed(){ 
//   if (key=='a'){ 
//     nn++; 
//     return; 
//   } 
//   else if (key=='t'){ 
//     renderTrail=!renderTrail; 
//     return; 
//   } 
//   else if (key=='b'){ 
//     renderBalls=!renderBalls; 
//     return; 
//   }
//    // else if (key=='r'){ 
//    //   renderArcs=!renderArcs; 
//    //   return; 
//    // } 
//   if (mode==RANDOM) 
//     mode=POLYNET; 
//   else 
//     mode=RANDOM; 
//   prepare();
//  /* if (key == 'q') {
//     // Finish the movie if space bar is pressed
//     mm.finish();
//     // Quit running the sketch once the file is written
//     exit();
//   }*/  
// } 
 
void setup(){ 
  size(400,400,JAVA2D);   
  smooth(); 
//  frameRate(1); 
  ns=new ArrayList(); 
  as=new ArrayList(); 
  prepare(); 
  curMass=mouseMass; 
  tMass=1; 
  curn=0;
  //mm = new MovieMaker(this, width, height, "fdp_v3_export-###.mov");
  psystems = new ArrayList();
  
  // setup the server (should this be configurable? (probably)) 
  sgDataListener = new Server(this, 5204);
} 
 
// void mousePressed(){ 
//   curMass=0; 
//   tMass=0; 
//   redraw();
//    psystems.add(new ParticleSystem(int(random(5,25)),new Vector3D(mouseX,mouseY))); 
// } 

void prepare(){ 
  ns.clear(); 
  as.clear(); 
  switch(mode){ 
  case RANDOM: 
    nn=150; 
    k=sqrt(min(width,height)/nn)*.05; 
    ns.add(new Node(random(width/2-width/8,width/2+width/8),random(height/2-height/8,height/2+height/8),4, "" + (ns.size()+1))); 
    break; 
  case POLYNET: 
    nn = 5; 
    k=sqrt(width*height/nn)*.5; 
    k2=k*.2;
    ns.add(new Node(random(width/2-width/8,width/2+width/8),random(height/2-height/8,height/2+height/8),10, "" + (ns.size()+1))); 
    break; 
  }   
  curn=0; 
} 
float fa(float m1, float m2, float z){ 
  return .0001*pow(k-m1-m2-z,2);     
  //return .1*pow(m1*m2,2)/pow(z,2); 
} 
float fr(float m1, float m2, float z){ 
  return .5*pow(m1+m2+k,2)/pow(z,2);     
  //return 20*(m1*m2)/pow(z,2); 
}

void addNode(float width, float height, float mass, String id) {

 float prob=random(1); 
 Node newn=null; 
 newn=new Node(random(width),random(height),10, id);           
 ns.add(newn); 
 
 k=sqrt(width*height/ns.size())*.5; 
 k2=k*.2;
 
}

void addEdge(String from_id, String to_id, String tag) {

  if (from_id.equals(to_id))
    return;

  Node from = null;
  Node to = null;

  for(Iterator it = ns.iterator(); it.hasNext();) {
    Node n = (Node)it.next();
    if (from == null && n.node_id.equals(from_id)) {
      from = n;
      continue;
    } else if (to == null && n.node_id.equals(to_id)) {
      to = n;
    }
  
    if (from != null && to != null)
      break;
  }
  
  if (from == null) {
    println("ERROR: Could not find from node");
  } else if (to == null) {
    println("ERROR: Could not frim to node");
  }
  
  as.add(new Arc(from, to, tag));
  
  println("Number of edges is now: " + as.size());
  
  /*for(Iterator it2=ns.iterator();it2.hasNext();){ 
     Node m=(Node)it2.next();           
     if (newn==m) continue; 
     as.add(new Arc(newn,m));*/
}

/*void linkAllNodes() {
  for(Iterator it2=ns.iterator();it2.hasNext();){ 
     Node m=(Node)it2.next();           
     if (newn==m) continue; 
     as.add(new Arc(newn,m));
   }
}*/

Node findNode(String id) {
  for(Iterator it = ns.iterator(); it.hasNext();) {
    Node n = (Node)it.next();
    
    if (n.node_id.equals(id))
      return n;
  }
  
  return null;
}

Arc findEdge(Node from, Node to, String tag) {
  println("Searching for edge {u, v, t}: " + from.node_id + ", " + to.node_id + ", " + tag);
  for (Iterator it = as.iterator(); it.hasNext();) {
    Arc e = (Arc)it.next();
    if (e.v.equals(from) && e.u.equals(to) && e.tag.equals(tag)) {
       println("Found the edge we were looking for!");
       return e;
     }
  }
    
  return null;
}

void updateEdge(Arc e, float weight) {
  e.weight = weight;
  
  // make sure this edge gets drawn.
  int idx = as.indexOf(e);
  as.remove(e);
  as.add(e);
}
 
void draw(){ 
  if (ns.size() > 0  && (t++%vel)==0 && curn<nn){  
    curn++; 
    int r=(int)(random(1,ns.size()-1))-1; 
    int s=0; 
    boolean gen=false; 
//    if (random(1)<.1) 
  //    gen=true; 
    if (ns.size()>5 && gen){ 
      s=(int)(random(1,ns.size()-1))-1; 
      while(r==s) 
        s=(int)(random(1,ns.size()-1))-1; 
    } 
    Node nr=(Node)ns.get(r); 
    Node ss=(Node)ns.get(s); 
    Node newn=null; 
    switch(mode){ 
    // case RANDOM: 
    //    newn=new Node(nr.pos.x+random(nr.mass,nr.mass+10),nr.pos.y+random(nr.mass,nr.mass+10),4, ns.size()+1); 
    //    ns.add(newn); 
    //    as.add(new Arc(newn,nr)); 
    //    newn.incrMass(2); 
    //    nr.incrMass(2); 
    //    if (ns.size()>5 && gen){ 
    //      as.add(new Arc(newn,ss)); 
    //      newn.incrMass(2); 
    //      ss.incrMass(2); 
    //    }   
    //    break; 
    case POLYNET: 
      addNode(width, height, 10, "" + (ns.size() + 1));
      //linkAllNodes();
//      float prob=random(1); 
//                newn=new Node(random(width),random(height),10, ns.size() + 1);           
//                ns.add(newn); 
//                for(Iterator it2=ns.iterator();it2.hasNext();){ 
//                  Node m=(Node)it2.next();           
//                  if (newn==m) continue; 
//                  as.add(new Arc(newn,m)); 
//                } 
//      break; 
    }     
  } 
  
  background(254); 
  if (tMass<1){ 
    tMass+=.1; 
    curMass=sin(PI*tMass)*600*(1-tMass); 
    //     
  } 
 
  curMass=max(curMass,mouseMass); 
 
 
  noStroke(); 
  for(Iterator it=ns.iterator();it.hasNext();){ 
    Node u=(Node)it.next(); 
    for(Iterator it2=ns.iterator();it2.hasNext();){ 
      Node v=(Node)it2.next();       
      if (u!=v){ 
        Vector2D delta=v.pos.sub(u.pos); 
        if (delta.norm()!=0){ 
          v.disp.addSelf( delta.versor().mult( fr(v.mass,u.mass,delta.norm()) ) ); 
          //        System.out.println(v.pos); 
        } 
      } 
    } 
  } 
 
  for(Iterator it=as.iterator();it.hasNext();){ 
    Arc e=(Arc)it.next(); 
    Vector2D delta=e.v.pos.sub(e.u.pos); 
    if (delta.norm()!=0){ 
      e.v.disp.subSelf( delta.versor().mult( fa(e.v.mass,e.u.mass,delta.norm()) ) ); 
      e.u.disp.addSelf( delta.versor().mult( fa(e.v.mass,e.u.mass,delta.norm()) ) );     
    } 
  }   
  for(Iterator it=ns.iterator();it.hasNext();){ 
    Node u=(Node)it.next(); 
    if (mouseAttract){ 
      Vector2D mousepos=new Vector2D(mouseX,mouseY);   
      Vector2D delta=u.pos.sub(mousepos); 
      if (delta.norm()!=0){ 
        u.disp.subSelf( delta.versor().mult( fa(u.mass,curMass,delta.norm()) ) ); 
        stroke(0,0,0,20); 
        line(u.pos.x,u.pos.y,mouseX,mouseY); 
        noStroke(); 
      }   
    } 
    if (mouseRepulse){ 
      Vector2D mousepos=new Vector2D(mouseX,mouseY);   
      Vector2D delta=u.pos.sub(mousepos); 
      if (delta.norm()<curMass+u.mass+100){ 
        u.disp.addSelf( delta.versor().mult( fr(u.mass,curMass,delta.norm()) ) ); 
      }   
    } 
    u.update();    
    u.costrain(0,width,0,height); 
  } 
  if (renderArcs) 
    for(Iterator it=as.iterator();it.hasNext();){ 
      Arc a=(Arc)it.next(); 
      a.draw(); 
    }   
  for(Iterator it=ns.iterator();it.hasNext();){ 
    Node u=(Node)it.next(); 
    if (renderTrail) 
      u.setTrail(true); 
    else 
      u.setTrail(false);   
    if (renderBalls) 
      u.setBall(true); 
    else 
      u.setBall(false);   
    u.draw(); 
 
    /* 
    fill(128); 
     PFont fontA = loadFont("CourierNew36.vlw"); 
     textFont(fontA, 10); 
     textAlign(CENTER); 
     text("Node "+u, u.pos.x, u.pos.y+u.mass*2); 
     noFill(); 
     */ 
  } 
   for (int i = psystems.size()-1; i >= 0; i--) {
    ParticleSystem psys = (ParticleSystem) psystems.get(i);
    psys.run();
    if (psys.dead()) {
      psystems.remove(i);
    }
  }
  noFill(); 
  stroke(200,100,0,20); 
  ellipse(mouseX,mouseY,curMass,curMass);
    //mm.addFrame();
  
 // saveFrame("processing_sketch_saveFrame_test-####.png");
 //sgDataListener.write("There are: " + ns.size() + " nodes being visualized...");
 Client client = sgDataListener.available();
  if (client != null) {
    String msg = client.readString();
    if (msg != null) {
      println(client.ip() + ": " + msg);
      println("msg.length() = " + msg.length());
      msg = msg.trim();
      println("msg.length() (post trim)= " + msg.length());
      /*println("\"addNode\".length = " + "addNode".length());
            char a[] = msg.toCharArray();
            for (int ii = 0; ii < msg.length(); ii++) {
              println("msg[" + ii + "] = " + int(a[ii]));
            }*/

      String r_addNode = "add_node ([a-zA-Z0-9_-]+)";
      String r_addEdge = "add_edge ([a-zA-Z0-9_-]+) ([a-zA-Z0-9_-]+) ([a-zA-Z]+)";
      String r_updateEdge = "update_edge ([a-zA-Z0-9_-]+) ([a-zA-Z0-9_-]+) ([a-zA-Z]+) ([0-9]+.[0-9]+)";
      
      Pattern p_addNode = Pattern.compile(r_addNode);
      Pattern p_addEdge = Pattern.compile(r_addEdge);
      Pattern p_updateEdge = Pattern.compile(r_updateEdge);
      
      // regexes in java are pretty crappy... or i'm doing something wrong
      if (Pattern.matches(r_addNode, msg)) {
        
        println("New node requested: [" + msg + "]");

        Matcher m = p_addNode.matcher(msg);

        m.find();
        String node_id = m.group(1);
        println("node_id = " + node_id);
        
        addNode(width, height, 10, node_id);
      }
      else if (Pattern.matches(r_addEdge, msg)) {
        
        println("New edge requested: [" + msg + "]");
        
        Matcher m = p_addEdge.matcher(msg);
        
        m.find();
        String from_id = m.group(1);
        String to_id = m.group(2);
        String tag = m.group(3);
        
        println("from_id = " + from_id);
        println("to_id = " + to_id);
        println("tag = " + tag);
        
        addEdge(from_id, to_id, tag);
      }
      else if (Pattern.matches(r_updateEdge, msg)) {
        
        println("Edge update requested: [" + msg + "]");
        
        Matcher m = p_updateEdge.matcher(msg);
        
        m.find();
        String from_id = m.group(1);
        String to_id = m.group(2);
        String tag = m.group(3);
        float weight = Float.parseFloat(m.group(4));
        
        println("from_id = " + from_id);
        println("to_id = " + to_id);
        println("tag = " + tag);
        println("weight = " + weight);
        
        Arc e = findEdge(findNode(from_id), findNode(to_id), tag);
        updateEdge(e, weight);
        
      }
    }
  }
} 

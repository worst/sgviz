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
boolean centerAttract = false;
boolean quadrantAttract = true;
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
String peers[] = {null, null, null, null};
color peer_colors[] = {#FF3300, #00CCCC, #9966FF, #FF00FF};
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
  size(1024, 768, JAVA2D);   
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
    ns.add(new Node(random(width/2-width/8,width/2+width/8),random(height/2-height/8,height/2+height/8),4, "" + (ns.size()+1), "P1")); 
    break; 
  case POLYNET: 
    nn = 5; 
    k=sqrt(width*height/nn)*.5; 
    k2=k*.2;
    ns.add(new Node(random(width/2-width/8,width/2+width/8),random(height/2-height/8,height/2+height/8),10, "" + (ns.size()+1), "P1")); 
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

void setTrusted(Node n) {
  n.on_trusted_peer = true;
  int peer = -1;
  for (int i = 0; i < peers.length; i++) {
    // do we already know about this peer?
    // do we have empty room for the peer?
    if (peers[i] == null) {
      peers[i] = n.peer_id;
      peer = i;
      println("Found unused quadrant");
      break;
    }
    
    if (peers[i].equals(n.peer_id)) {
      peer = i;
      println("Found known quadrant");
      break;
    }
    
    
  }
  
  if (peer < 0) {
    println("UNABLE TO FIND A SUITABLE PEER TO SEGREGATE THIS WITHIN!!!");
    return;
  }
  
  n.mycolor = peer_colors[peer];
}

void addNode(float width, float height, float mass, String id, String peer_id) {
  // first check to make sure that the node id is unique
  for (Iterator it = ns.iterator(); it.hasNext();) {
    Node n = (Node)it.next();
    if (n.peer_id.equals(peer_id) && n.node_id.equals(id)) {
      return;
    }
  }
  float prob = random(1); 

  // check to see if we already know about this peer...
  // if not, set it up...
  // fuck this is a hack i should probably be using an arraylist...
  println("Searching for a known or unused quadrant...");
  boolean found_peer = false;
  int peer = -1;
  for (int i = 0; i < peers.length; i++) {
    // do we already know about this peer?
    // do we have empty room for the peer?
    if (peers[i] == null) {
      peers[i] = peer_id;
      peer = i;
      println("Found unused quadrant");
      break;
    }
    
    if (peers[i].equals(peer_id)) {
      peer = i;
      println("Found known quadrant");
      break;
    }
    
    
  }
  
  if (peer < 0) {
    println("UNABLE TO FIND A SUITABLE PEER TO SEGREGATE THIS WITHIN!!!");
    return;
  }
  
  Node newn = null;
  /*float x, y;*/
  newn = new Node(random(width), random(height), mass, id, peer_id);           
  ns.add(newn);
  //newn.mycolor = peer_colors[peer];
  newn.mycolor = color(240,240,240);
 
  k=sqrt(width*height/ns.size())*.5; 
  k2=k*.2;
 
}

void addEdge(String peer_id, String from_id, String to_id, String tag, float weight) {

  // no self edges
  if (from_id.equals(to_id))
    return;
    
  // check to make sure an edge between the two nodes doesn't already exist
  /*for (Iterator it = as.iterator(); it.hasNext();) {
    Edge e = 
  }*/

  Node from = findNode(peer_id, from_id);
  Node to = findNode(peer_id, to_id);
  
  
  /*for(Iterator it = ns.iterator(); it.hasNext();) {
     Node n = (Node)it.next();
     if (from == null && n.node_id.equals(from_id)) {
       from = n;
       continue;
     } else if (to == null && n.node_id.equals(to_id)) {
       to = n;
     }
   
     if (from != null && to != null)
       break;
   }*/
  
  if (from == null) {
    println("ERROR: Could not find from node");
    return;
  } else if (to == null) {
    println("ERROR: Could not frim to node");
    return;
  }
  
  // check to make sure that an edge doesn't already exist between these two
  // nodes in the specified direction with a given tag
  for (Iterator it = as.iterator(); it.hasNext();) {
    Arc e = (Arc)it.next();
    if (e.v.equals(from) && e.u.equals(to) && e.tag.equals(tag))
      return;
  }
  Arc e = new Arc(from, to, tag);
  e.weight = weight;
  as.add(e);
  flashEdge(e);
  
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

Node findNode(String peer_id, String id) {
  for(Iterator it = ns.iterator(); it.hasNext();) {
    Node n = (Node)it.next();
    
    if (n.node_id.equals(id) && n.peer_id.equals(peer_id))
      return n;
  }
  
  return null;
}

Arc findEdge(Node from, Node to, String tag) {
  if (from == null || to == null || tag == null)
    return null;
    
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

ArrayList findEdges(Node from, Node to) {
  println("in findEdges");
  ArrayList ret = new ArrayList();
  for (Iterator it = as.iterator(); it.hasNext();) {
    Arc e = (Arc)it.next();
    if (e.v.equals(from) && e.u.equals(to)) {
      ret.add(e);
    }
  }
  println("Returning found edges");
  return ret;
}
void visit(Node from, Node to) {
  println("in visit()");
  ArrayList edges = findEdges(from, to);
  Collections.sort(edges, new Comparator() {
    public int compare(Object obj1, Object obj2) {
      Arc e1 = (Arc)obj1;
      Arc e2 = (Arc)obj2;
      if (e1.weight < e2.weight) {
        return -1;
      } else if (e1.weight > e2.weight) {
        return 1;
      } else {
        return 0;
      }
    }
  });
  
  println("done sorting edges");
  
  flashEdge((Arc)edges.get(edges.size() - 1));
  print("done flashing edges");
}
void flashEdge(Arc e) {
  e.lastUpdateColor = e.highlightStart;
  e.updateTicksRemaining += frameRate*2;
  
  e.v.lastUpdateColor = e.v.highlightStart;
  e.v.updateTicksRemaining += frameRate;
  
  e.updateUQueue.add(new Integer(int(frameRate)));
  
}
void updateEdge(Arc e, float weight) {
  e.weight = weight;
  
  // make sure this edge gets drawn.
  int idx = as.indexOf(e);
  as.remove(e);
  as.add(e);
  //Collections.rotate(as, 0 - idx);
  
  flashEdge(e);

  /*e.v.lastUpdateColor = e.v.highlightStart;
  e.v.updateTicksRemaining += frameRate; 
  
  e.u.lastUpdateColor = e.u.highlightStart;
  e.u.updateTicksRemaining += frameRate;*/

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
      addNode(width, height, 40, "" + (ns.size() + 1), "P1");
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
    if (centerAttract) {
      Vector2D centerpos=new Vector2D(width/2,height/2);   
      Vector2D delta=u.pos.sub(centerpos); 
      if (delta.norm()!=0){ 
        u.disp.subSelf( delta.versor().mult( fa(u.mass,curMass,delta.norm()) ) ); 
        stroke(0,0,0,20); 
        //line(u.pos.x,u.pos.y,mouseX,mouseY); 
        noStroke(); 
      }
    }
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
    
    if (quadrantAttract) {
      String peer = u.peer_id;
      int quadrant = -1;
      for (int i = 0; i < peers.length; i++) {
        if (peers[i].equals(peer)) {
          quadrant = i;
          break;
        }
      }
      
      if (quadrant < 0) {
        println("Tried to center node " + u.node_id + " on peer " + u.peer_id + " but can't find the correct quadrant!");
        break;
      } else {
        Vector2D quadPos = null; //=new Vector2D(width/2,height/2);   

        
        // wow, this is terrible :(
        // an attempt is made to have these follow unit circle...
        // probably should be clockwise not counter clockwise, but whatever
        switch (quadrant) {
          case 0:
            quadPos = new Vector2D((float)width * 3.0/4.0, (float)height * 1.0/4.0);
            break;
          case 1:
            quadPos = new Vector2D((float)width * 1.0/4.0 , (float)height * 1.0/4.0);
            break;
          case 2:
            quadPos = new Vector2D((float)width * 1.0/4.0 , (float)height * 3.0/4.0);
            break;
          case 3:
            quadPos = new Vector2D((float)width * 3.0/4.0 , (float)height * 3.0/4.0);
            break;
        }
        Vector2D delta = u.pos.sub(quadPos); 
        if (delta.norm()!=0){ 
          u.disp.subSelf( delta.versor().mult( fa(u.mass,curMass,delta.norm()) ) ); 
          stroke(0,0,0,20); 
          //line(u.pos.x,u.pos.y,mouseX,mouseY); 
          noStroke(); 
        }
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
  
  // draw lines to separate the quadrants
  stroke(0, 0, 0);
  strokeWeight(1);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);
  
  for (int i = 0; i < peers.length; i++) {
    if (peers[i] == null)
      break;
    
    textSize(20);
    switch (i) {
      case 0:
        fill(peer_colors[i]);
        text(peers[i], width/2 + 15, 25);
        break;
      case 1:
        fill(peer_colors[i]);
        text(peers[i], 15, 25);
        break;
      case 2:
        fill(peer_colors[i]);
        text(peers[i], 15, height/2 + 25);
        break;
      case 3:
        fill(peer_colors[i]);
        text(peers[i], width/2 + 15, height/2 + 25);
        break;
    }
    textSize(12);
  }
  
  // FOR DEBUGGING PURPOSES DRAW THE CENTER OF EACH QUADRANT
  fill(0, 0, 0);
  ellipse((float)width * 3.0/4.0, (float)height * 1.0/4.0, 10, 10);
  ellipse((float)width * 1.0/4.0, (float)height * 1.0/4.0, 10, 10);
  ellipse((float)width * 1.0/4.0, (float)height * 3.0/4.0, 10, 10);
  ellipse((float)width * 3.0/4.0, (float)height * 3.0/4.0, 10, 10);
  
  noFill(); 
  stroke(200,100,0,20);
  
   
  //ellipse(mouseX,mouseY,curMass,curMass);
    //mm.addFrame();
  
 // saveFrame("processing_sketch_saveFrame_test-####.png");
 //sgDataListener.write("There are: " + ns.size() + " nodes being visualized...");
 Client client = sgDataListener.available();
  if (client != null) {
    String msg = client.readStringUntil(10);
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

      String r_addNode = "add_node ([a-zA-Z0-9_\\.-]+) ([a-zA-Z0-9_-]+)";
      String r_addEdge = "add_edge ([a-zA-Z0-9_\\.-]+) ([a-zA-Z0-9_-]+) ([a-zA-Z0-9_-]+) ([a-zA-Z]+) ([0-9]+.[0-9]+)";
      String r_updateEdge = "update_edge ([a-zA-Z0-9_\\.-]+) ([a-zA-Z0-9_-]+) ([a-zA-Z0-9_-]+) ([a-zA-Z]+) ([0-9]+.[0-9]+)";
      String r_setTrusted = "set_trusted ([a-zA-Z0-9_\\.-]+) ([a-zA-Z0-9_-]+)";
      String r_visit = "visit ([a-zA-Z0-9_\\.-]+) ([a-zA-Z0-9_-]+) ([a-zA-Z0-9_-]+)";
      
      Pattern p_addNode = Pattern.compile(r_addNode);
      Pattern p_addEdge = Pattern.compile(r_addEdge);
      Pattern p_updateEdge = Pattern.compile(r_updateEdge);
      Pattern p_setTrusted = Pattern.compile(r_setTrusted);
      Pattern p_visit = Pattern.compile(r_visit);
      
      // regexes in java are pretty crappy... or i'm doing something wrong
      if (Pattern.matches(r_addNode, msg)) {
        
        println("New node requested: [" + msg + "]");

        Matcher m = p_addNode.matcher(msg);

        m.find();
        String peer_id = m.group(1);
        String node_id = m.group(2);
        println("peer_id = " + peer_id);
        println("node_id = " + node_id);
        
        addNode(width, height, 20, node_id, peer_id);
      }
      else if (Pattern.matches(r_addEdge, msg)) {
        
        println("New edge requested: [" + msg + "]");
        
        Matcher m = p_addEdge.matcher(msg);
        
        m.find();
        String peer_id = m.group(1);
        String from_id = m.group(2);
        String to_id = m.group(3);
        String tag = m.group(4);
        float weight = Float.parseFloat(m.group(5));
        
        println("peer_id = " + peer_id);
        println("from_id = " + from_id);
        println("to_id = " + to_id);
        println("tag = " + tag);
        println("weight = " + weight);
        
        addEdge(peer_id, from_id, to_id, tag, weight);
      }
      else if (Pattern.matches(r_updateEdge, msg)) {
        
        println("Edge update requested: [" + msg + "]");
        
        Matcher m = p_updateEdge.matcher(msg);
        
        m.find();
        String peer_id = m.group(1);
        String from_id = m.group(2);
        String to_id = m.group(3);
        String tag = m.group(4);
        float weight = Float.parseFloat(m.group(5));
        
        println("peer_id = " + peer_id);
        println("from_id = " + from_id);
        println("to_id = " + to_id);
        println("tag = " + tag);
        println("weight = " + weight);
        
        Arc e = findEdge(findNode(peer_id, from_id), findNode(peer_id, to_id), tag);
        if (e != null)
          updateEdge(e, weight);
        
      } else if (Pattern.matches(r_setTrusted, msg)) {
         println("Set trust requested: [" + msg + "]");
         
         Matcher m = p_setTrusted.matcher(msg);
         
         m.find();
         
         String peer_id = m.group(1);
         String node_id = m.group(2);
         
         Node n = findNode(peer_id, node_id);
         
         if (n != null) {
           setTrusted(n);
         }
      } else if (Pattern.matches(r_visit, msg)) {
        println("Visit request: [" + msg + "]");
        
        
        Matcher m = p_visit.matcher(msg);
        
        m.find();
        
        String peer_id = m.group(1);
        String from_id = m.group(2);
        String to_id = m.group(3);
        
        Node from = findNode(peer_id, from_id);
        Node to = findNode(peer_id, to_id);
        
        if (from != null && to != null) {
          visit(from, to);
        }
        
      } else {
        println("NO MATCHING COMMAND FOUND");
      }
    }
  }

/*  println("number of nodes: " + ns.size());
  println("number of edges: " + as.size());*/
} 

/**
 NyARToolkit for proce55ing/1.0.0
 (c)2008-2011 nyatla
 airmail(at)ebony.plala.or.jp
 
 This sample proglam handles 2 ARToolKit marker.
 The markers are "patt.hiro" and "patt.kanji"
 */
import processing.video.*;
import jp.nyatla.nyar4psg.*;
import oscP5.*;
import netP5.*;

Capture cam;
MultiMarker nya;
OscP5 oscP5; 

///////////////////////

String receive;
int mAccount;
int pNumber;
PVector marker[];
PVector cordinate[];
int markerSize;
///////////////////////

NetAddress myBroadcastLocation;

///////////////////////

void setup() {
  //size(1280, 720, P3D);
  //size(640, 360, P3D);
  size(640, 480, P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION); 
  //ARToolKit
  cam=new Capture(this, width, height);
  nya=new MultiMarker(this, width, height, "PinkCamera.dat", NyAR4PsgConfig.CONFIG_PSG);  
  
  //change marker&size !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
  markerSize = 80;
  nya.addARMarker("o3.pat", markerSize);//id=0
  nya.addARMarker("ta3.pat", markerSize);//id=1
  nya.addARMarker("se3.pat", markerSize);//id=2
  //nya.addARMarker("marker00.pat", 40);//id=3
  cam.start();

  //ghowl change port !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!111
  oscP5 = new OscP5(this, 419); 
  myBroadcastLocation = new NetAddress("localhost", 4355);

  //number of points !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
  pNumber = 48;
  
  //number of markers !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  mAccount = 3;
  
  cordinate = new PVector[pNumber];
  for (int i=0; i<pNumber; i++) {
    PVector temp=new PVector(0,0,0);
    cordinate[i]=temp;
  }
  
  //set markers cordinates  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  marker = new PVector[mAccount];
  PVector temp1 = new PVector(0,0,0);
  PVector temp2 = new PVector(0,390,0);
  PVector temp3 = new PVector(-390,0,0);
  marker[0] = temp1;
  marker[1] = temp2;
  marker[2] = temp3;

}

void draw()
{ 
  
  //ARToolKit
  if (cam.available() !=true) {
    return;
  }
  cam.read();
  nya.detect(cam);
  background(0);
  nya.drawBackground(cam);//frustumを考慮した背景描画
  int n = 0;
  
  for (int i=0; i<mAccount; i++) {
    if ((!nya.isExist(i))) {
      continue;
    }

    ///////////////////////////////
    nya.beginTransform(i);
    
    stroke(255,0,0);
    fill(255,0,0,50);
    float sphereSize = 1.0;
    //translate(0, 0, boxSize/2);
    translate(0, 0, 0);
    box(markerSize,markerSize, 1);
    if(n == 0){
      for(int j=0;j<pNumber;j++){
        
        //draw thing !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        translate(cordinate[j].x - marker[i].x,cordinate[j].y - marker[i].y,cordinate[j].z);

        sphere(sphereSize);
        
        
        translate(-1*cordinate[j].x + marker[i].x,-1*cordinate[j].y + marker[i].y,-1*cordinate[j].z + marker[i].z);
      }
    }
    //nya.endTransform();
    ///////////////////////////////


    nya.setARPerspective();
/*
    PMatrix3D temp=nya.getMarkerMatrix(i);
    x=temp.m03;
    y=temp.m13;
    z=temp.m23;

    //myArray[0][0]=new PVector(x, y, z);
    myArray[i].x = x;
    myArray[i].y = y;
    myArray[i].z = z;
**/
    nya.endTransform();
    
    if(nya.isExist(i)){
      n ++;
    }
    
  }

}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message:   ");
  receive = theOscMessage.get(0).stringValue();
  println(receive);
  String[] splitReceive = split(receive , "&");
  int pNumberNew = splitReceive.length;
  
  if(pNumberNew != pNumber){
    println("Number Wrong");
  }
  
  for(int i = 0; i<pNumber; i++){
  String[] cordinatesString = split(splitReceive[i] , ",");
  
    if(cordinatesString.length != 3){
    println("Vector Number" + i + "wrong");
    continue;
    }
  
  float[] c = float(cordinatesString);
  cordinate[i].set(-c[0],c[1],c[2]);
  println(cordinate[i].x + "," + cordinate[i].y + "," + cordinate[i].z);
  }
  
}
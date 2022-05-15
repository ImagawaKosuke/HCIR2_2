import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

Capture cam;
OpenCV opencv;
Rectangle[] faces;
Rectangle[] eyes;

PImage facemask;

float scale;
float Angle;

Star star, star2;

int MaxColor= width;

int set = 0;

int mode=0;//ボタン処理の変数

int cursol_x;//カーソルx座標
int cursol_y;//カーソルy座標

int[] modes = new int[4]; //ボタン処理用の配列

void setup(){
  size(640, 480);
  String[] cameras = Capture.list();
  cam = new Capture(this,640,480, cameras[99]);//自分用のUSBカメラ
  //cam = new Capture(this, 640, 480, "Intel(R) RealSense(TM) Depth Camera 415  RGB", 60);//演習室のカメラ
  
  cam.start();
  
  colorMode(HSB, MaxColor);
  for(int i=0;i<4;i++){
      modes[i]=0;
  }
}

void draw(){
    println(mode);
  if(cam.available() == true){
    cam.read();
    
    image(cam, 0, 0);
 
    opencv = new OpenCV(this, cam);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); //顔認識の準備
    faces = opencv.detect();
    
    opencv.loadCascade(OpenCV.CASCADE_EYE); //目認識の準備
    eyes = opencv.detect();
    

    
    float theta = radians(45);
    int s = second(); 
     for(int i = 0; i < eyes.length; i++){
            //ellipse(eyes[i].x+eyes[i].width/2, eyes[i].y+10+eyes[i].height/2, eyes[i].height, eyes[i].width);
                if(mode!=0&&modes[2]>0){facedrawing(i,theta,s);}
                fill(0,50,1000);
                if(i>0&&i<2 && abs(eyes[i-1].x-eyes[i].x)<200 && abs(eyes[i-1].y-eyes[i].y)<50 ){
                  cursol_x=320-(320-(eyes[i-1].x+eyes[i].x)/2)*2;
                  cursol_y=240-(240-(eyes[i-1].y+eyes[i].x)/2)*2;
                  if(cursol_x<0){cursol_x=15;}
                  if(cursol_y<0){cursol_y=15;}
                  if(cursol_x<0){cursol_x=width-15;}
                  if(cursol_y<0){cursol_y=height-15;}//カーソルが画面外に行った場合
                  ellipse(cursol_x,cursol_y,15,15);//カーソルの描画
                  eyebuttoncontroller(cursol_x,cursol_y);//ボタンの描画
              }
              
     }
     if(mode!=0&&modes[3]>0){animal();}
  }
  
  println(mode);
}

void circle(int x,int y) { //渦巻き作成用の関数
  Angle += 20;
  scale+=1;
  if(scale>100){scale=0;}
  pushMatrix();
  translate(x, y);
  ellipse(((scale) * cos(radians(Angle))), ((scale) * sin(radians(Angle))),25, 25);
  popMatrix();
}

void facedrawing(int i, float theta,int s)
{
    if(i<2)
        {
         if (eyes[i].x<200){
             fill(mouseX/7,1000,1000); 
             circle(eyes[i].x+10,eyes[i].y+10);
         }
         else if(eyes[i].x>=320){
                
             for(int j = 0;j<8;j++){//円状の星を描画
                 fill(mouseX/7,1000,1000);
                 star = new Star(eyes[i].x+eyes[i].width/2 - cos(theta*j)*50*(s%4), eyes[i].y+10+eyes[i].height/2 + sin(theta*j)*50*(s%4));
                 star.draw(20,5);
             }
         }
         else{
             fill(mouseX/7,1000,1000); //マウスの移動に応じて色が変化
             star2 = new Star(eyes[i].x+eyes[i].width/2, eyes[i].y+10+eyes[i].height/2);
             star2.draw(15*(s%6),5);
         }
     }
}

void animal(){ //動物の耳と鼻を描画
    for(int i=0; i<faces.length; i++){
      rect(faces[i].x, faces[i].y-20, 30, 30);
      rect(faces[i].x + faces[i].width-20, faces[i].y-20, 30, 30);
      fill(0,0,0);
      ellipse(faces[i].x + faces[i].width/2,faces[i].y+faces[i].height/2 + 20,30,10);
    }    
}

void eyebuttoncontroller(float x, float y){
      String[] button = {"Normal", "Capture","Draw", "AnimalDraw"}; //ボタンの実装
      for(int i=0;i<=3;i++){
      if(x<=70 && 80*(1+i)+20<=y && 80*(1+i)+70>=y){
          fill(100,100,500);
          if (mousePressed == true) {
            mode = i;
          }
      }
      else{fill(100,10,100);}
      rect(0,80*(1+i)+30,70,50);
      fill(0,0,0);
      textAlign(CENTER,CENTER);
      text(button[i],38 ,60 + 80*(1+i));
  }
    if(mode==0){
        for(int i = 0;i<4;i++){
            modes[i]=0;
        }
    }
    else if(mode==1){
        PImage img = createImage(width, height, RGB);
     
        //画面を画像にコピー
        loadPixels();
        img.pixels = pixels;
        img.updatePixels();
        if ((keyPressed == true)&&key=='s') {
            //画像のピクセル情報を切り出して保存
            img = img.get(70, 0, width, height);
            img.save("drawing.png"); //撮影
            mode=0; //初期化
        }
    }
    else if(mode==2){modes[2]++;}
    else if(mode==3){modes[3]++;}
}
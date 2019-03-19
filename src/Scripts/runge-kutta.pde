float g = 6.67408*pow(10,-11);
float s = 0.000000001;
boolean lower = false;
float ts = 60*60*12;
float[] faks = {7, 10};
Vector o = new Vector(0,0,0);
PlanetSystem sys;
PlanetSystem[] h1;
PlanetSystem sys2;
PlanetSystem[] h2;
MassPoint[] planets;
float t = 0;
int pSize = 500;
boolean running = false;
int counter = 0;
int speed = 1;

void setup(){
  
  size(pSize,pSize);
  frameRate(60);
  planets = new MassPoint[3];
  planets[0] = new MassPoint(new Vector(0,0,384400000), new Vector(0,29780+1023,0), 7.349*pow(10,22), 0);
  planets[1] = new MassPoint(o,new Vector(0,29780,0),5.9723*pow(10,24),1);
  planets[2] = new MassPoint(new Vector(0,0,-149600000000.0), new Vector(0,0,0), 1.989*pow(10,30),2);
  //planets[0] = new MassPoint(new Vector(0,0,1), new Vector(0,-1,0), faks[0]*pow(10, faks[1]), 1);
  //planets[1] = new MassPoint(new Vector(0,0,-1), new Vector(0,1,0), faks[0]*pow(10, faks[1]), 2);
  //planets[2] = new MassPoint(new Vector(0,10,0), new Vector(0,0,0.8), 0.1*faks[0]*pow(10, faks[1]), 2);
  sys = new PlanetSystem(planets, 0);
  h1 = new PlanetSystem[1];
  h1[0] = sys.mult(1);
  sys2 = new PlanetSystem(planets, 1);
  h2 = new PlanetSystem[1];
  h2[0] = sys2.mult(1);
}

void keyPressed()
{
  if(key == 't'|| key =='T')
  {
    running = !running;
  }
  if(key == 'r'|| key =='R')
  {
    setup();
  }
  if(key == 'w'|| key =='W')
  {
    if(speed > 1)
    {
      speed = speed/2;
    }
  }
  if(key == 'e'|| key =='E')
  {
    speed = speed*2;
  }
}

void draw(){
  if(running)
  {
    translate(0.5, 0.5);
    for(int i = 0; i<speed; i++)
    { //<>//
      sys.step(ts);
      
      for(int j = 0; j < 4; j++)
      {
        sys2.step(ts/4)
      }
      if(counter > 8)
      {
        h1 = append(h1, sys.mult(1));
        h2 = append(h2, sys2.mult(1));
        counter = 0; 
      }
      counter ++; 
    }
    t += ts;
    //println(t/(60*60*24));
    background(0);
    Vector avg = sys.calcAvg();

    

    stroke(255,0,0);
    drawPath(h1,avg.data[1], avg.data[2]);

    stroke(0,119,255);
    drawPath(h2,avg.data[1], avg.data[2]);

    stroke(255,0,0);
    fill(255,0,0);
    sys.show();

    stroke(0,119,255);
    fill(0,119,255);
    sys2.show();
  }
}

void drawPath(PlanetSystem[] path, double x, double y)
{
  for(int i = 1; i < path.length; i++)
  {
    for(int j = 0; j < path[i].bodys.length; j++){
      Vector pos = path[i-1].bodys[j].pos;
      Vector pos2 = path[i ].bodys[j].pos;
      line((float)(pos.data[1]-x)*s+(pSize/2),(float)(pos.data[2]-y)*s+(pSize/2),(float)(pos2.data[1]-x)*s+(pSize/2),(float)(pos2.data[2]-y)*s+(pSize/2));
    }
  }
}

class PlanetSystem {
  MassPoint[] bodys;
  int mode;
  boolean[] focus;
  
  PlanetSystem(MassPoint[] ps, int m)
  {
    bodys = new MassPoint[ps.length];
    focus = new boolean[ps.length]; 
    for(int i= 0; i< ps.length; i++)
    {
      bodys[i] = ps[i].mult(1);
      focus[i] = true;
    }
    mode = m;
  }
  
  void step(float timestep)
  {
    switch (mode) {
      case 1:
        rungeKutta(timestep);
        break;
      default:
        this.bodys = this.add(g().mult(timestep)).bodys;
        break;
    }
  }
  
  void rungeKutta(float timestep)
  {
    PlanetSystem c1 = this.g();
    PlanetSystem s1 = this.add(c1.mult(timestep/2));
    PlanetSystem c2 = s1.g();
    PlanetSystem s2 = this.add(c2.mult(timestep/2));
    PlanetSystem c3 = s2.g();
    PlanetSystem s3 = this.add(c3.mult(timestep));
    PlanetSystem c4 = s3.g();
    
    bodys = this.add(c1.mult(timestep/6)).add(c2.mult(timestep/3)).add(c3.mult(timestep/3)).add(c4.mult(timestep/6)).bodys;
     //<>//
  }
  
  PlanetSystem mult(float timestep)
  {
    MassPoint[] mps = new MassPoint[this.bodys.length];
    for (int i = 0; i < this.bodys.length; i++)
    {
      mps[i] = bodys[i].mult(timestep);
    }
    
    return new PlanetSystem(mps, mode);
  }
  
  Vector calcAvg() {
    Vector avg = new Vector(0,0,0);
    float massSum = 0;
    for(int i = 0; i < bodys.length; i++)
    {
      MassPoint mp = bodys[i];
      if(focus[i]){
        avg = avg.add(mp.pos.mult(mp.mass*pow(10,-10)));
        massSum += mp.mass*pow(10,-10);
      }
    }
    avg = avg.mult(1/massSum);
    
    return avg;
  }
  
  void show() {
    Vector avg = calcAvg();
    //avg.prnt();
    for(MassPoint mp : bodys)
    {
      mp.show(avg.data[1],avg.data[2]);
    }
  }
  
  PlanetSystem add(PlanetSystem p)
  {
    MassPoint[] mps = new MassPoint[this.bodys.length];
    for (int i = 0; i < this.bodys.length; i++)
    {
      mps[i] = bodys[i].add(p.bodys[i]);
    }
    
    return new PlanetSystem(mps, mode);
  }
  
  PlanetSystem g()
  {
    MassPoint[] newPS = new MassPoint[bodys.length];
    for (int i = 0; i<newPS.length; i++)
    {
      newPS[i] = bodys[i].gp(bodys);
    }
    
    return new PlanetSystem(newPS, mode);
  }
}

class MassPoint {
  int id;
  float mass;
  Vector pos;
  Vector vel;
  
  MassPoint(Vector pos, Vector vel, float mass, int id) {
    this.id = id;
    this.pos = pos;
    this.mass = mass;
    this.vel = vel;
  }
  
  Vector getAcc(MassPoint mp){
    return pos.sub(mp.pos).mult(-g*mp.mass/pow(pos.sub(mp.pos).norm(),3));
  }
  
  void show(float xo, float yo) {
    //circle((pos.data[1]-xo)*s+(pSize/2),(pos.data[2]-yo)*s+(pSize/2),15);
    ellipse((pos.data[1]-xo)*s+(pSize/2), (pos.data[2]-yo)*s+(pSize/2), 15, 15);
    
  }
  
  Vector getAccs(MassPoint[] mps)
  {
    Vector a = new Vector(0,0,0);
    for(MassPoint p : mps)
    {
      if(this.id != p.id)
      {
        a = a.add(this.getAcc(p));
      }
    }
    return a;
  }
  
  MassPoint add(MassPoint mp)
  {
    return new MassPoint(this.pos.add(mp.pos), this.vel.add(mp.vel) ,this.mass, this.id);
  }
  
  MassPoint mult(float timestep)
  {
    return new MassPoint(this.pos.mult(timestep), this.vel.mult(timestep), this.mass, this.id);
  }
  
  MassPoint gp(MassPoint[] mps)
  {
    return new MassPoint(this.vel,this.getAccs(mps), this.mass, this.id);
  }
}

class Vector {
  float[] data;
  public Vector(float[] v)
  {
    data = v;
  }
  public Vector(float x, float y, float z)
  {
    data = new float[3];
    data[0] = x;
    data[1] = y;
    data[2] = z;
  }
  
  Vector add(Vector v)
  {
    float[] res = new float[data.length];
    for(int i = 0; i < data.length; i++)
    {
      res[i] = data[i]+v.data[i];
    }
    return new Vector(res);
  }
  
  Vector mult(float k)
  {
    float[] res = new float[this.data.length];
    for(int i = 0; i< this.data.length; i++)
    {
      res[i] = this.data[i]*k;
    }
    return new Vector(res);
  }
  
  Vector sub(Vector v)
  {
    return this.add(v.mult(-1));
  }
  
  float dot(Vector v)
  {
    float res = 0;
    for(int i = 0; i<data.length; i++)
    {
      res += data[i]*v.data[i];
    }
    return res;
  }
  
  float norm()
  {
    return sqrt(this.dot(this));
  }
  
  float dist(Vector v)
  {
    return this.sub(v).norm();
  }
  
  Vector normalize()
  {
    return this.mult(1/this.norm());
  }
  
  void prnt()
  {
    print("|\t");
    for(float v : data)
    {
      print(v);
      print("|\t");
    }
    println();
  }
}

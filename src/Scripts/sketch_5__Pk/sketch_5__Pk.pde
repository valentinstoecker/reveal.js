float g = 6.67408*pow(10,-11);
float s = 0.000000002;
boolean lower = false;
float ts = 0;
float[] faks = {7, 10};
Vector o = new Vector(0,0,0);
PlanetSystem sys;
Hist h1;
PlanetSystem sys2;
Hist h2;
MassPoint[] planets;
float t = 0;

void setup(){
  size(1000,1000);
  frameRate(1200);
  planets = new MassPoint[3];
  planets[0] = new MassPoint(new Vector(0,0,384400000), new Vector(0,29780+1023,0), 7.349*pow(10,22), 0);
  planets[1] = new MassPoint(o,new Vector(0,29780,0),5.9723*pow(10,24),1);
  planets[2] = new MassPoint(new Vector(0,0,-149600000000.0), new Vector(0,0,0), 1.989*pow(10,30),2);
  //planets[0] = new MassPoint(new Vector(0,0,1), new Vector(0,-1,0), faks[0]*pow(10, faks[1]), 1);
  //planets[1] = new MassPoint(new Vector(0,0,-1), new Vector(0,1,0), faks[0]*pow(10, faks[1]), 2);
  //planets[2] = new MassPoint(new Vector(0,10,0), new Vector(0,0,0.8), 0.1*faks[0]*pow(10, faks[1]), 2);
  sys = new PlanetSystem(planets, 0);
  h1 = new Hist(sys.mult(1));
  sys2 = new PlanetSystem(planets, 1);
  h2 = new Hist(sys2.mult(1));
}

void draw(){
 for(int i = 0; i<1; i++)
 { //<>//
   sys2.step(60*60*12);
   sys.step(60*60*12);
 }
 t += 60*60*24;
 //println(t/(60*60*24));
 background(0);
 Vector avg = sys.avg();
 stroke(255,0,0);
 fill(255,0,0);
 sys.show();
 h1.add(sys.mult(1));
 h1.draw(avg.data[1], avg.data[2]);
 stroke(0,0,255);
 fill(0,0,255);
 sys2.show();
 h2.add(sys2.mult(1));
 h2.draw(avg.data[1], avg.data[2]);
}

class Hist {
  PlanetSystem p;
  Hist next;
  Hist(PlanetSystem p) {
    this.p = p;
    next = null;
  }
  
  void add(PlanetSystem p) //<>//
  {
    if(next == null) //<>//
    {
      next = new Hist(p);
    } else {
      next.add(p);
    }
  }
  
  void draw(double x, double y) //<>//
  {
    if(next != null) //<>//
    {
      for(int i = 0; i < p.bodys.length; i++)
      {
        Vector pos = p.bodys[i].pos;
        Vector pos2 = next.p.bodys[i].pos;
        line((float)(pos.data[1]-x)*s+500,(float)(pos.data[2]-y)*s+500,(float)(pos2.data[1]-x)*s+500,(float)(pos2.data[2]-y)*s+500);
      }
      next.draw(x,y);
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
  
  Vector avg() {
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
    Vector avg = avg();
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
      newPS[i] = bodys[i].g(bodys);
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
    circle((pos.data[1]-xo)*s+500,(pos.data[2]-yo)*s+500,15);
    
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
  
  MassPoint g(MassPoint[] mps)
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
  public Vector(int l)
  {
    data = new float[l];
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
    float[] res = new float[data.length];
    for(int i = 0; i< data.length; i++)
    {
      res[i] = data[i]*k;
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

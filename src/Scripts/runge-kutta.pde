double gConst = 6.67408*pow(10,-11);
double s = 0.000000001;
boolean lower = false;
double ts = 60*60*12;
double[] faks = {7, 10};
Vector o = new Vector(0,0,0);
PlanetSystem sys;
PlanetSystem[] h1;
PlanetSystem sys2;
PlanetSystem[] h2;
MassPoint[] planets;
double t = 0;
int pSize = 500;
boolean running = false;
int counter = 0;
int speed = 1;

void setup(){
  t = 0;
  size(pSize,pSize);
  frameRate(60);
  planets = new MassPoint[3];
  planets[0] = new MassPoint(new Vector(0,30000000000,-149600000000.0), new Vector(0,0,-33000), 1.989*pow(10,30), 0);
  planets[1] = new MassPoint(o,new Vector(0,44000,0),5.9723*pow(10,24),1);
  planets[2] = new MassPoint(new Vector(0,-30000000000,-149600000000.0), new Vector(0,0,33000), 1.989*pow(10,30),2);
  //planets[0] = new MassPoint(new Vector(0,0,1), new Vector(0,-1,0), faks[0]*pow(10, faks[1]), 1);
  //planets[1] = new MassPoint(new Vector(0,0,-1), new Vector(0,1,0), faks[0]*pow(10, faks[1]), 2);
  //planets[2] = new MassPoint(new Vector(0,10,0), new Vector(0,0,0.8), 0.1*faks[0]*pow(10, faks[1]), 2);
  sys = new PlanetSystem(planets, 0);
  h1 = new PlanetSystem[1];
  h1[0] = sys.mult(1);
  sys2 = new PlanetSystem(planets, 1);
  h2 = new PlanetSystem[1];
  h2[0] = sys2.mult(1);
  textSize(20);
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
      
      sys2.step(ts);
      if(counter >= 8)
      {
        h1 = append(h1, sys.mult(1));
        h2 = append(h2, sys2.mult(1));
        counter = 0; 
      }
      counter ++;
      t += ts; 
    }
    
    //println(t/(60*60*24));
    background(0);
    Vector avg = sys.calcAvg();

    

    stroke(255,0,0);
    drawPath(h1,avg.data[1], avg.data[2]);

    stroke(0,119,255);
    drawPath(h2,avg.data[1], avg.data[2]);

    stroke(255);
    fill(255);
    rect(0, 0, 90, 35);
    textAlign(RIGHT);
    stroke(255,0,0);
    fill(255,0,0);
    sys.show();
    text(sys.getEnergyError()*100, 80, 15 );

    stroke(0,119,255);
    fill(0,119,255);
    sys2.show();
    text(sys2.getEnergyError()*100, 80, 30);

    stroke(255);
    fill(255);
    text(t/(60*60*24*365.25), 500, 15);
  }
}

void drawPath(PlanetSystem[] path, double x, double y)
{
  for(int i = 1; i < path.length; i++)
  {
    for(int j = 0; j < path[i].bodys.length; j++){
      Vector pos = path[i-1].bodys[j].pos;
      Vector pos2 = path[i ].bodys[j].pos;
      line((double)(pos.data[1]-x)*s+(pSize/2),(double)(pos.data[2]-y)*s+(pSize/2),(double)(pos2.data[1]-x)*s+(pSize/2),(double)(pos2.data[2]-y)*s+(pSize/2));
    }
  }
}

class PlanetSystem {
  MassPoint[] bodys;
  int mode;
  boolean[] focus;
  double initialEnergy;
  
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
    initialEnergy = getEnergy();
  }

  double getEnergyError()
  {
    return abs((getEnergy()-initialEnergy)/initialEnergy);
  }
  
  void step(double timestep)
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
  
  void rungeKutta(double timestep)
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
  
  PlanetSystem mult(double timestep)
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
    double massSum = 0;
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

  double getEnergy()
  {
    double energy = 0;
    double mTotal = 0;
    Vector comVelocity = new Vector(0,0,0);
    for(int i = 0; i < bodys.length; i++)
    {
      energy += bodys[i].getEnergy(bodys);
      mTotal += bodys[i].mass;
      comVelocity = comVelocity.add(bodys[i].vel.mult(bodys[i].mass));
    }
    comVelocity = comVelocity.mult(1/mTotal);

    energy += 0.5*mTotal*comVelocity.norm()*comVelocity.norm();
    return energy;
  }
}

class MassPoint {
  int id;
  double mass;
  Vector pos;
  Vector vel;
  
  MassPoint(Vector pos, Vector vel, double mass, int id) {
    this.id = id;
    this.pos = pos;
    this.mass = mass;
    this.vel = vel;
  }
  
  Vector getAcc(MassPoint mp){
    return pos.sub(mp.pos).mult(-gConst*mp.mass/pow(pos.sub(mp.pos).norm(),3));
  }
  
  void show(double xo, double yo) {
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

  double getEnergy(MassPoint[] mps)
  {
    double e = 0;
    for(MassPoint p : mps)
    {
      if(p.id != this.id)
      {
        e += -0.5*gConst*this.mass*p.mass*(1/this.pos.dist(p.pos));
      }
    }
    e += 0.5*mass*vel.norm()*vel.norm();
    return e;
  }
  
  MassPoint add(MassPoint mp)
  {
    return new MassPoint(this.pos.add(mp.pos), this.vel.add(mp.vel) ,this.mass, this.id);
  }
  
  MassPoint mult(double timestep)
  {
    return new MassPoint(this.pos.mult(timestep), this.vel.mult(timestep), this.mass, this.id);
  }
  
  MassPoint gp(MassPoint[] mps)
  {
    return new MassPoint(this.vel,this.getAccs(mps), this.mass, this.id);
  }
}

class Vector {
  double[] data;
  public Vector(double[] v)
  {
    data = v;
  }
  public Vector(double x, double y, double z)
  {
    data = new double[3];
    data[0] = x;
    data[1] = y;
    data[2] = z;
  }
  
  Vector add(Vector v)
  {
    double[] res = new double[data.length];
    for(int i = 0; i < data.length; i++)
    {
      res[i] = data[i]+v.data[i];
    }
    return new Vector(res);
  }
  
  Vector mult(double k)
  {
    double[] res = new double[this.data.length];
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
  
  double dot(Vector v)
  {
    double res = 0;
    for(int i = 0; i<data.length; i++)
    {
      res += data[i]*v.data[i];
    }
    return res;
  }
  
  double norm()
  {
    return sqrt(this.dot(this));
  }
  
  double dist(Vector v)
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
    for(double v : data)
    {
      print(v);
      print("|\t");
    }
    println();
  }
}

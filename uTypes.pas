{
  “ипы.
}
unit uTypes;

interface
uses
  OpenGL, uGlobal;
type
  PPoint3f = ^TPoint3f;
  TPoint3f = record
    x,y,z:single;
  end;

  PPoint2f = ^TPoint2f;
  TPoint2f = record
    x,z:Single;
  end;

  PVector3f = ^TVector3f;
  {TVector3f = record
    nx,ny,nz:single;
  end;}

  PVector2f = ^TVector2f;
  TVector2f = record
    x,z : Single;
  end;

  PVectorA2f = ^TVectorA2f;
  TVectorA2f = record
    ang : GLfloat;
    v   : GLfloat;
  end;

  TRect4f = record
    x1,z1,x2,z2:GLfloat;
  end;

TVector3f=record 
  x:glfloat;
  y:glfloat;
  z:glfloat;
end;
 

rTriangle=record
  V:array [0..2] of TVector3f;
end;

procedure  Normalize3f (var a:TVector3f);
function  Distance3f(P1,P2:TPoint3f)   :glfloat;
procedure GenVector(xang : PGLfloat; vec : PVector2f);
procedure NormalizeVector(vec : PVector2f);
function lineln(d1,d2:PPoint2f):GLfloat;
function AngbPoints(x0,y0,x1,y1:GLfloat):GLfloat;
procedure vGen3fv(dest:PPoint3f; src : Pointer);
function cwCos(a:GLfloat):GLfloat;
function cwSin(a:GLfloat):GLfloat;
function FPSsynSpeed(mps : GLfloat):GLfloat;
function Signf(n:Single):Shortint;
function KphToFPS(kph : GLfloat):GLfloat;
function Chetvert(var ang : GLfloat):Byte;
function DoTheNormal(A, B, C : TVector3f):TVector3f;

implementation

procedure Normalize3f(var a:TVector3f);
  var d:glfloat;
begin
  d:=sqrt(sqr(a.x)+sqr(a.y)+sqr(a.z));
  if d = 0 then d :=1;
  a.x:=a.x/d;
  a.y:=a.y/d;
  a.z:=a.z/d;
end;

function DoTheNormal(A, B, C : TVector3f):TVector3f;
var
  vx1,vy1,vz1,vx2,vy2,vz2:GLfloat;
begin
{
vx1 = A.x - B.x
vy1 = A.y - B.y
vz1 = A.z - B.z

vx2 = B.x - C.x
vy2 = B.y - C.y
vz2 = B.z - C.z

ѕусть координаты интересующего нас вектора (ну он же нормаль) будут N.x, N.y и N.z, тогда
их можно посчитать так:

N.x = (vy1 * vz2 - vz1 * vy2)
N.y = (vz1 * vx2 - vx1 * vz2)
N.z = (vx1 * vy2 - vy1 * vx2)
}
vx1 := A.x - B.x;
vy1 := A.y - B.y;
vz1 := A.z - B.z;

vx2 := B.x - C.x;
vy2 := B.y - C.y;
vz2 := B.z - C.z;

Result.x := vy1 * vz2 - vz1 * vy2;
Result.y := vz1 * vx2 - vx1 * vz2;
Result.z := vx1 * vy2 - vy1 * vx2;

Normalize3f(Result);
end;


function Distance3f(P1,P2:TPoint3f):GLfloat;
begin
  Result := sqrt(sqr(P2.x-P1.x)+sqr(p2.y-p1.y)+sqr(p2.z-p1.z));
end;

function Chetvert(var ang : GLfloat):Byte;
begin
  Result := 1;
  if ang<0 then ang := 360+ang;
  if ang>360 then ang := 0;
  if (ang>=0)  and  (ang<90) then Result := 1;
  if (ang>=90) and (ang<180) then Result := 2;
  if (ang>=180)and (ang<270) then Result := 3;
  if (ang>=270)and(ang<=360) then Result := 4;
end;


function Signf(n:Single):Shortint;
begin
  if n=0 then Result := 1 else
    Result := Trunc(n) div abs(Trunc(n));
end;

function FPSsynSpeed(mps : GLfloat):GLfloat;
begin
  Result := mps/64;
end;

function KphToFPS(kph : GLfloat):GLfloat;
var
  a:GLfloat;
begin
  a := ((kph*1000)/60/60)/64;
  Result :=a;
end;

procedure vGen3fv(dest:PPoint3f; src : Pointer);
begin
  dest^ := TPoint3f(src^);
end;


function cwSin(a:GLfloat):GLfloat;
begin
  Result := Sin(a/RAD);
end;

function cwCos(a:GLfloat):GLfloat;
begin
  Result := Cos(a/RAD);
end;

function Squer(x:GLfloat):GLfloat;
begin
  Result := x*x;
end;

procedure GenVector(xang : PGLfloat; vec : PVector2f);
begin
  vec^.x := sin(xang^/(180/pi));
  vec^.z := cos(xang^/(180/pi));
end;

procedure NormalizeVector(vec : PVector2f);
var
  n:single;
begin
  n := sqrt(sqr(vec.x)+sqr(vec.z));
  vec.x := vec.x/n;
  vec.z := vec.z/n;  
end;

function lineln(d1,d2:PPoint2f):GLfloat;
begin
  Result := Sqrt(squer(d2^.x-d1^.x)+squer(d2.z-d1.z));
end;

function AngbPoints(x0,y0,x1,y1:GLfloat):GLfloat;
var
  a:glfloat;
begin
  x1 := x1-x0;
  y1 := y1-y0;

  if(x1=0)then
  begin
    if y1>0 then a:=90;
    if y1<0 then a:=270;
  end else
  begin
    a := (y1/x1);
    a := abs(arctan(a))*(180/pi);
  end;

  if (x1<0)and(y1>0)then a:=180-a;
  if (x1<0)and(y1<0)then a:=180+a;
  if (x1>0)and(y1<0)then a:=360-a;

  Result := a;

end;


end.

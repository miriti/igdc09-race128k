{
  Машинки. Физика, ИИ, коллизи, рендер...
}
unit uBCar;

interface
uses
  uTypes, OpenGL, uModels, uTextures, uGlobal, uLog;

const
  AIR_B = 0.1/64;
  TRM_B = 0.5/64;
  {}
  T_R   = -1;
  T_N   = 0;
  T_1   = 1;
  T_2   = 2;
  T_3   = 3;
  T_4   = 4;

type
  TCarCtrl = (go_frw, go_bak, go_left, go_right, go_brk, go_hbr);
  TCarCtrls = set of TCarCtrl;

  TCar = class
    name   : string[32]; {Имя игрока}
    rmp    : GLfloat;  {Обороты}
    transm : Shortint; {передача}
    mass   : GLfloat;  {Масса}
    damage : GLfloat;  {Повреждение}
    {BACK WHEELS}
    b_pos  : TPoint3f; {Положение}
    b_xang : GLfloat;  {Поворот}
    b_mang : GLfloat;  {Движение}
    b_a    : GLfloat;  {Ускорение}
    b_vec_a: GLfloat;
    b_vec_v: GLfloat;
    b_vec  : TVector3f;
    {FRONT WHEELS}
    f_pos  : TPoint3f;
    f_dxang: GLfloat;
    f_a    : GLfloat;
    f_vec_a: GLfloat;
    f_vec_v: GLfloat;
    f_vec  : TVector3f;
    {OTHER POWERS}
{    f_col_ang : GLfloat;
    f_col_v   : GLfloat;
    b_col_ang : GLfloat;
    b_col_v   : GLfloat; }
    {CONTROLS}
    ctrls  : TCarCtrls;
    color  : array[0..2] of GLfloat;
    a_korob: Boolean;
    {else}
    k_ang   : GLfloat;
    h_break : Boolean;
    blowed  : Boolean;
    y_speed : GLfloat;
    ccp     : Integer;
    {TEST}
    is_finish : Boolean;
    fin_time  : Cardinal;
  public
    constructor Create;
    destructor  Destroy;
    procedure   Render;
    procedure   DoMove;
    procedure   Control;
    procedure   PushButton(button : TCarCtrl);
    procedure   AddTransmiss;
    procedure   DecTransmiss;
    procedure   AIControl;
    procedure   AutoKorobka;
  end;

  TCarEngine = class
    cars     : array of TCar;
    main_car : TCar;
    constructor Create;
    destructor Destroy;
  public
    procedure DoAI;
    procedure DoControl;
    procedure DoMove;
    procedure DoRender;
    procedure AddCar(x,z:GLfloat);
    procedure DoCollision;
  end;

var
  CarEngine : TCarEngine;
  trees : array[0..200] of TPoint3f; {2,494}
  
implementation
uses
  uTrack;

destructor TCar.Destroy;
begin
  LogStr('Car Destroy', 2);
  inherited Destroy;
end;

destructor TCarEngine.Destroy;
var
  i:Integer;
begin
  LogStr('CarEngine.Destroy', 1);
  for i := 0 to length(cars)-1 do
    cars[i].Destroy;

  inherited Destroy;
end;

procedure TCarEngine.DoCollision;
const
  TEMP_CONSTANT = 0.5;
  DISTANT = 3.5;
var
  i,j:Integer;
  p,p1:TPoint2f;
  pi,pj:TPoint3f;
begin
  for i := 0 to length(cars)-2 do
  begin
    for j := i+1 to length(cars)-1 do
    begin
      if Distance3f(cars[i].b_pos, cars[j].b_pos)<DISTANT then
      begin
        pi.x := cars[j].b_pos.x+cwSin(AngbPoints(cars[j].b_pos.z, cars[j].b_pos.x, cars[i].b_pos.z, cars[i].b_pos.x))*DISTANT;
        pi.z := cars[j].b_pos.z+cwCos(AngbPoints(cars[j].b_pos.z, cars[j].b_pos.x, cars[i].b_pos.z, cars[i].b_pos.x))*DISTANT;

        pj.x := cars[i].b_pos.x+cwSin(AngbPoints(cars[i].b_pos.z, cars[i].b_pos.x, cars[j].b_pos.z, cars[j].b_pos.x))*DISTANT;
        pj.z := cars[i].b_pos.z+cwCos(AngbPoints(cars[i].b_pos.z, cars[i].b_pos.x, cars[j].b_pos.z, cars[j].b_pos.x))*DISTANT;

        cars[i].b_pos := pi;
        cars[j].b_pos := pj;

        cars[i].b_vec_a := AngbPoints(cars[j].b_pos.z, cars[j].b_pos.x, cars[i].b_pos.z, cars[i].b_pos.x);
        cars[j].b_vec_a := AngbPoints(cars[i].b_pos.z, cars[i].b_pos.x, cars[j].b_pos.z, cars[j].b_pos.x);
        cars[i].b_vec_v := cars[j].b_a*2;
        cars[j].b_vec_v := cars[i].b_a*2;

      end;
      if Distance3f(cars[i].b_pos, cars[j].f_pos)<DISTANT then
      begin
        pi.x := cars[j].f_pos.x+cwSin(AngbPoints(cars[j].f_pos.z, cars[j].f_pos.x, cars[i].b_pos.z, cars[i].b_pos.x))*DISTANT;
        pi.z := cars[j].f_pos.z+cwCos(AngbPoints(cars[j].f_pos.z, cars[j].f_pos.x, cars[i].b_pos.z, cars[i].b_pos.x))*DISTANT;

        pj.x := cars[i].b_pos.x+cwSin(AngbPoints(cars[i].b_pos.z, cars[i].b_pos.x, cars[j].f_pos.z, cars[j].f_pos.x))*DISTANT;
        pj.z := cars[i].b_pos.z+cwCos(AngbPoints(cars[i].b_pos.z, cars[i].b_pos.x, cars[j].f_pos.z, cars[j].f_pos.x))*DISTANT;

        cars[i].b_pos := pi;
        cars[j].f_pos := pj;

        cars[i].b_vec_a := AngbPoints(cars[j].f_pos.z, cars[j].f_pos.x, cars[i].b_pos.z, cars[i].b_pos.x);
        cars[j].f_vec_a := AngbPoints(cars[i].b_pos.z, cars[i].b_pos.x, cars[j].f_pos.z, cars[j].f_pos.x);
        cars[i].b_vec_v := cars[j].b_a*2;
        cars[j].f_vec_v := cars[i].b_a*2;

      end;
      if Distance3f(cars[i].f_pos, cars[j].b_pos)<DISTANT then
      begin
        pi.x := cars[j].b_pos.x+cwSin(AngbPoints(cars[j].b_pos.z, cars[j].b_pos.x, cars[i].f_pos.z, cars[i].f_pos.x))*DISTANT;
        pi.z := cars[j].b_pos.z+cwCos(AngbPoints(cars[j].b_pos.z, cars[j].b_pos.x, cars[i].f_pos.z, cars[i].f_pos.x))*DISTANT;

        pj.x := cars[i].f_pos.x+cwSin(AngbPoints(cars[i].f_pos.z, cars[i].f_pos.x, cars[j].b_pos.z, cars[j].b_pos.x))*DISTANT;
        pj.z := cars[i].f_pos.z+cwCos(AngbPoints(cars[i].f_pos.z, cars[i].f_pos.x, cars[j].b_pos.z, cars[j].b_pos.x))*DISTANT;

        cars[i].f_pos := pi;
        cars[j].b_pos := pj;

        cars[i].f_vec_a := AngbPoints(cars[j].b_pos.z, cars[j].b_pos.x, cars[i].f_pos.z, cars[i].f_pos.x);
        cars[j].b_vec_a := AngbPoints(cars[i].f_pos.z, cars[i].f_pos.x, cars[j].b_pos.z, cars[j].b_pos.x);
        cars[i].f_vec_v := cars[j].b_a*2;
        cars[j].b_vec_v := cars[i].b_a*2;

      end;
      if Distance3f(cars[i].f_pos, cars[j].f_pos)<DISTANT then
      begin
        pi.x := cars[j].f_pos.x+cwSin(AngbPoints(cars[j].f_pos.z, cars[j].f_pos.x, cars[i].f_pos.z, cars[i].f_pos.x))*DISTANT;
        pi.z := cars[j].f_pos.z+cwCos(AngbPoints(cars[j].f_pos.z, cars[j].f_pos.x, cars[i].f_pos.z, cars[i].f_pos.x))*DISTANT;

        pj.x := cars[i].f_pos.x+cwSin(AngbPoints(cars[i].f_pos.z, cars[i].f_pos.x, cars[j].f_pos.z, cars[j].f_pos.x))*DISTANT;
        pj.z := cars[i].f_pos.z+cwCos(AngbPoints(cars[i].f_pos.z, cars[i].f_pos.x, cars[j].f_pos.z, cars[j].f_pos.x))*DISTANT;

        cars[i].f_pos := pi;
        cars[j].f_pos := pj;

        cars[i].f_vec_a := AngbPoints(cars[j].f_pos.z, cars[j].f_pos.x, cars[i].f_pos.z, cars[i].f_pos.x);
        cars[j].f_vec_a := AngbPoints(cars[i].f_pos.z, cars[i].f_pos.x, cars[j].f_pos.z, cars[j].f_pos.x);
        cars[i].f_vec_v := cars[j].b_a*2;
        cars[j].f_vec_v := cars[i].b_a*2;
      end;
    end;
  end;

  for i := 0 to length(cars)-1 do
  begin

    for j := 0 to 200 do
    begin
      if Distance3f(cars[i].f_pos, trees[j])<5.494 then
      begin
        cars[i].f_pos.x := trees[j].x+cwSin(AngbPoints(trees[j].z, trees[j].x, cars[i].f_pos.z, cars[i].f_pos.x))*5.5;
        cars[i].f_pos.z := trees[j].z+cwCos(AngbPoints(trees[j].z, trees[j].x, cars[i].f_pos.z, cars[i].f_pos.x))*5.5;
      end;
      if Distance3f(cars[i].b_pos, trees[j])<5.494 then
      begin
        cars[i].b_pos.x := trees[j].x+cwSin(AngbPoints(trees[j].z, trees[j].x, cars[i].b_pos.z, cars[i].b_pos.x))*5.5;
        cars[i].b_pos.z := trees[j].z+cwCos(AngbPoints(trees[j].z, trees[j].x, cars[i].b_pos.z, cars[i].b_pos.x))*5.5;
      end;
    end;

    p := Track.fin_crd[0];
    p1.x := cars[i].f_pos.x;
    p1.z := cars[i].f_pos.z;

    if not cars[i].is_finish then
    begin
    while true do
    begin
      if abs(lineln(@p, @p1))<1 then
      begin
        Track.AddFinisher(cars[i]);
        cars[i].is_finish := True;
        cars[i].fin_time  := race_time;
        break;
      end;

      if (Track.fin_crd[1].x>Track.fin_crd[0].x) then
      begin
        if p.x > Track.fin_crd[1].x then
        begin
          if (Track.fin_crd[1].z>Track.fin_crd[0].z) then
            if p.z > Track.fin_crd[1].z then
              break;
          if (Track.fin_crd[1].z<Track.fin_crd[0].z) then
            if p.z < Track.fin_crd[1].z then
              break;
        end;
      end;

      if (Track.fin_crd[1].x<Track.fin_crd[0].x) then
      begin
        if p.x < Track.fin_crd[1].x then
        begin
          if (Track.fin_crd[1].z>Track.fin_crd[0].z) then
            if p.z > Track.fin_crd[1].z then
              break;
          if (Track.fin_crd[1].z<Track.fin_crd[0].z) then
            if p.z < Track.fin_crd[1].z then
              break;
        end;
      end;

      p.x := p.x + Track.fin_v.x*0.01;
      p.z := p.z + Track.fin_v.z*0.01;
      
    end;
    end;

  end;
end;

procedure TCarEngine.DoAI;
var
  i:Integer;
begin
  for i := 1 to length(cars)-1 do
  begin
    cars[i].AIControl;
  end;
end;

procedure TCarEngine.AddCar(x,z:GLfloat);
begin
  SetLength(cars, length(cars)+1);
  cars[length(cars)-1] := TCar.Create;
  cars[length(cars)-1].b_pos.x := x;
  cars[length(cars)-1].b_pos.z := z;
  cars[length(cars)-1].f_pos.x := x;
  cars[length(cars)-1].f_pos.z := z;
  cars[length(cars)-1].a_korob := True;
end;

procedure TCarEngine.DoRender;
var
  i:Integer;
begin
  for i := 0 to length(cars)-1 do
    cars[i].Render;
end;

procedure TCarEngine.DoMove;
var
  i:Integer;
begin
  for i := 0 to length(cars)-1 do
    cars[i].DoMove;
end;

procedure TCarEngine.DoControl;
var
  i:Integer;
begin
  for i := 0 to length(cars)-1 do
    cars[i].Control;
end;

constructor TCarEngine.Create;
begin
  LogStr(PChar(#9 + 'CarEngine.Create'));
  SetLength(cars, 1);
  cars[0] := TCar.Create;
  cars[0].a_korob := True;
  main_car := cars[0];
  main_car.name := 'Player';
end;

{====================================}

procedure TCar.AutoKorobka;
begin
  if transm <> T_R then
  begin
    if transm = T_N then  transm := T_1;
    if rmp>=7800 then AddTransmiss;
  end;
end;

procedure TCar.AIControl;
var
  d:GLfloat;
begin
  if ccp<>Track.t_length-1 then
  begin
    if Distance3f(f_pos, Track.chpts[ccp])>ROAD_WDT then
    begin
    //d := AngbPoints(b_pos.z, b_pos.x, Track.chpts[ccp].z, Track.chpts[ccp].x);

{      if d-b_xang<180 then
        f_dxang := f_dxang - 2 else f_dxang := f_dxang + 2;}

    d := AngbPoints(f_pos.z, f_pos.x, Track.chpts[ccp].z, Track.chpts[ccp].x);
    if d>315 then d := -(360-d);
    if (d<180)and(d>45) then d := 45;
    if d<=45  then d := d;
    if (d>180)and(d<315) then d := -45;

    f_dxang := d;

    if((f_dxang>15)and(f_dxang>-15))or(b_a<FPSsynSpeed(100))then
      ctrls := ctrls + [go_frw];
    if(abs(f_dxang)>15)and(b_a<FPSsynSpeed(30)) then ctrls := [go_hbr];

    end else
    begin
      inc(ccp, 1); {TODO : AI}
      if ccp>Track.t_length-1 then ccp := Track.t_length-1;
    end;
  end else
  begin
    ctrls := [go_hbr];
  end;
 
end;

procedure TCar.AddTransmiss;
begin
  if transm<>4 then
  begin
    inc(transm);
    rmp := rmp/2;
  end;
end;

procedure TCar.DecTransmiss;
begin
  if transm <> -1 then
  begin
    Dec(transm);
  end;
end;

procedure TCar.PushButton(button : TCarCtrl);
begin
  ctrls := ctrls + [button];
end;

procedure TCar.Control;
var
  dr:GLfloat;
begin
  if not blowed then
  begin
    if a_korob then AutoKorobka;

    if (transm = 0)or(transm=-1) then
    begin
      dr := 1;
    end else
    begin
      dr := transm;
    end;

    if go_left  in ctrls then f_dxang := f_dxang + 2;
    if go_right in ctrls then f_dxang := f_dxang - 2;
    if go_frw   in ctrls then rmp := rmp + 40/dr; //b_a     := b_a + FPSsynSpeed(1);
    if go_bak   in ctrls then rmp := rmp - 40/dr; //b_a     := b_a - FPSsynSpeed(1);
    if go_hbr   in ctrls then
    begin
      h_break := True;
      rmp := rmp - 100;
    end else h_break := False;
    ctrls := [];
  end;
end;

procedure TCar.DoMove;
const
  DZ = 2;
var
  d : Single;
begin
  if damage = 0 then
  begin
    blowed := True;
    y_speed := 1;
    rmp := 0;
  end;

  if h_break then
  begin
    if b_a>0 then
      b_a := b_a - TRM_B;
    if b_a<0 then
      b_a := b_a + TRM_B;
  end;
  {TEST}
  if rmp < 0 then rmp := 0;
  if rmp > 8000 then rmp := 8000;
  if abs(f_dxang)>40 then f_dxang := 40*Signf(f_dxang);

  case transm of
    T_R : if b_a > -KphToFPS(40)*(rmp/8000) then b_a := b_a - FPSsynSpeed(0.5);
    T_N : {Neitral};
    T_1 : if b_a < KphToFPS(45)*(rmp/8000)  then b_a := b_a + FPSsynSpeed(1.5);
    T_2 : if b_a < KphToFPS(90)*(rmp/8000)  then b_a := b_a + FPSsynSpeed(1);
    T_3 : if b_a < KphToFPS(180)*(rmp/8000) then b_a := b_a + FPSsynSpeed(0.5);
    T_4 : if b_a < KphToFPS(200)*(rmp/8000) then b_a := b_a + FPSsynSpeed(0.25);
  end;

  f_a := b_a;

  {gen vectors}

  b_vec.x := cwSin(b_mang)*(b_a*2);
  b_vec.z := cwCos(b_mang)*(b_a*2);
  b_vec.x := b_vec.x + cwSin(b_vec_a)*b_vec_v;
  b_vec.z := b_vec.z + cwCos(b_vec_a)*b_vec_v;

  f_vec.x := cwSin(b_xang + f_dxang)*(f_a*2);
  f_vec.z := cwCos(b_xang + f_dxang)*(f_a*2);
  f_vec.x := f_vec.x + cwSin(f_vec_a)*f_vec_v;
  f_vec.z := f_vec.z + cwCos(f_vec_a)*f_vec_v;

  {RULE}
  b_pos.x := b_pos.x + b_vec.x; {v}
  b_pos.z := b_pos.z + b_vec.z; {v}

  f_pos.x := f_pos.x + f_vec.x; {v}
  f_pos.z := f_pos.z + f_vec.z; {v}

  b_xang := Angbpoints(b_pos.z, b_pos.x, f_POS.z, f_POS.x);

  f_pos.x := b_pos.x + cwSin(b_xang)*3.8;
  f_pos.z := b_pos.z + cwCos(b_xang)*3.8;

  {after TEST}

 {TODO : Zanos}
  b_mang := b_xang;
  if b_mang>360 then b_mang := b_mang-360;
  if b_mang<0   then b_mang := 360+b_mang;

  if f_dxang>0 then f_dxang := f_dxang - 1;
  if f_dxang<0 then f_dxang := f_dxang + 1;
  if b_a>0 then b_a := b_a - AIR_B;

  if f_vec_v > 0 then f_vec_v := f_vec_v - 0.01;
  if f_vec_v < 0.01 then f_vec_v := 0;
  if b_vec_v > 0 then b_vec_v := b_vec_v - 0.01;
  if b_vec_v < 0.01 then b_vec_v := 0;

{  if b_col_v > 0 then b_col_v := b_col_v - 0.01;
  if f_col_v > 0 then f_col_v := f_col_v - 0.01;}

  rmp := rmp - 5;
end;

procedure TCar.Render;
begin
  k_ang := k_ang + b_a*64;
  if k_ang >=360 then k_ang := 0;
  
  glMatrixMode(GL_MODELVIEW);
  glColor3f(0.0, 0.0, 0.0);

  {LEFT BACK WHEEL}
  glLoadIdentity;
  glTranslatef(b_pos.x, b_pos.y+0.500, b_pos.z);
  glRotatef(b_xang, 0.0, 0.1, 0.0);
  glTranslatef(-1.3, 0.0, 0.0);
  glRotatef(k_ang, 0.1, 0.0, 0.0);
  glCallList(MOD_WHEEL);

  {RIGHT BACK WHEEL}
  glLoadIdentity;
  glTranslatef(b_pos.x, b_pos.y+0.500, b_pos.z);
  glRotatef(b_xang, 0.0, 0.1, 0.0);
  glTranslatef(1.3, 0.0, 0.0);
  glRotatef(k_ang, 0.1, 0.0, 0.0);
  glCallList(MOD_WHEEL);

  {LEFT FRONT WHEEL}
  glLoadIdentity;
  glTranslatef(f_pos.x, f_pos.y+0.500, f_pos.z);
  glRotatef(b_xang, 0.0, 0.1, 0.0);
  glTranslatef(-1.3, 0, 0);
  glRotatef(f_dxang, 0.0, 0.1, 0.0);
  glRotatef(k_ang, 0.1, 0.0, 0.0);
  glCallList(MOD_WHEEL);

  {RIGHT FRONT WHEEL}
  glLoadIdentity;
  glTranslatef(f_pos.x, f_pos.y+0.500, f_pos.z);
  glRotatef(b_xang, 0.0, 0.1, 0.0);
  glTranslatef(1.3, 0, 0);
  glRotatef(f_dxang, 0.0, 0.1, 0.0);
  glRotatef(k_ang, 0.1, 0.0, 0.0);
  glCallList(MOD_WHEEL);

  {KARDAN}
  glColor3f(0.4, 0.4, 0.4);
  glLoadIdentity;
  glTranslatef(b_pos.x, b_pos.y+0.500, b_pos.z);
  glRotatef(b_xang, 0.0, 0.1, 0.0);
  glCallList(MOD_KARDAN);

  {KUZOV}
  glColor3fv(@color);
  glLoadIdentity;
  glTranslatef(b_pos.x, b_pos.y+0.5, b_pos.z);
  glRotatef(b_xang, 0.0, 0.1, 0.0);
  glCallList(MOD_KUZOV);

  {------------------------ DEBUG --------------------}
{  glLoadIdentity;
  glTranslatef(b_pos.x, b_pos.y+1, b_pos.z);
  glRotatef(b_xang, 0.0, 0.1, 0.0);
  glScalef(1.5, 1, 3);
  glColor3f(1.0, 0.0, 0.0);
  glCallList(MOD_QUBE);

  glLoadIdentity;
  glTranslatef(b_pos.x, b_pos.y+1, b_pos.z);
  glRotatef(b_mang, 0.0, 0.1, 0.0);
  glScalef(1.5, 1, 3);
  glColor3f(1.0, 0.0, 0.0);
  glCallList(MOD_QUBE);   }
  {------------------------ /DEBUG --------------------}
end;

constructor TCar.Create;
const
  av_chrs : array[0..26] of Char =
  ('a', 'b', 'c', 'd', 'e', 'f',
   'g', 'h', 'i', 'j', 'k', 'l',
   'm', 'n', 'o', 'p', 'q', 'r',
   's', 't', 'u', 'v', 'w', 'x',
   'y', 'z', ' ');
var
  i:Integer;
begin
  damage := 1000;
  mass   := 1000;
  {TODO : Car color}
  color[0] := random(255)/255;
  color[1] := random(255)/255;
  color[2] := random(255)/255;
  f_pos.z := b_pos.z + 3.8;
  b_xang := 0;
  f_dxang := 0;
  rmp := 0;
  transm := 0;
  b_a := 0;
  f_a := 0;
{  f_col_ang := 0;
  f_col_v := 0;
  b_col_ang := 0;
  b_col_v := 0;}
  ctrls := [];
  is_finish := false;
  for i := 0 to random(16) do
    name := name + av_chrs[random(26)];

  LogStr(PChar('Car - ' + String(name)), 2);
end;

end.

{
  Трасса, генерация, вейпоинты....
}
unit uTrack;

interface
uses
  uTypes, OpenGL, uTextures, uBCar, uText, uSysUtils, uGlobal, uModels;
  
type
  TTrack = class
    ch_pnt : GLuint;
    trak   : GLuint;
    chpts  : array of TPoint3f;
    t_length : Cardinal;
    fin_crd: array[0..1] of TPoint2f;
    finished : array of TCar;
    fin_v  : TVector2f;
    m_mast,m_x,m_y : GLfloat;
  public
    procedure AddFinisher(c:TCar);
    constructor Create;
    procedure _render;
    procedure _table;
    procedure _map(x,z:GLfloat);
  end;

const
  TRACK_LN = 500;
  ROAD_WDT = 20;
  TRN_SPEED = 10;
  ROAD_U  = 6;
  ROAD_V  = 1;

var
  Track : TTrack;

implementation

procedure TTrack._map(x,z:GLfloat);
var
  i:Integer;
begin

  glDisable(GL_LIGHTING);

  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  gluOrtho2D(0, S_WIDTH, S_HEIGHT, 0);
  glColor3f(1.0, 0.0, 0.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  glTranslatef(m_x, m_y, 0);

  for i := 0 to length(CarEngine.cars)-1 do
  begin
    glColor3fv(@CarEngine.cars[i].color);
    glBegin(GL_QUADS);
      glVertex3f((-CarEngine.cars[i].b_pos.x*m_mast)-5, (-CarEngine.cars[i].b_pos.z*m_mast)-5, 1);
      glVertex3f((-CarEngine.cars[i].b_pos.x*m_mast)+5, (-CarEngine.cars[i].b_pos.z*m_mast)-5, 1);
      glVertex3f((-CarEngine.cars[i].b_pos.x*m_mast)+5, (-CarEngine.cars[i].b_pos.z*m_mast)+5, 1);
      glVertex3f((-CarEngine.cars[i].b_pos.x*m_mast)-5, (-CarEngine.cars[i].b_pos.z*m_mast)+5, 1);
    glEnd;
  end;

  glBegin(GL_LINES);
  for i := 0 to TRACK_LN-2 do
  begin
    glVertex2f(-(chpts[i].x)*m_mast,   -(chpts[i].z)*m_mast);
    glVertex2f(-(chpts[i+1].x)*m_mast, -(chpts[i+1].z)*m_mast);
  end;
  glEnd;

  glEnable(GL_LIGHTING);
  //glMatrixMode(GL_PROJECTION);
  //glPopMatrix;
end;

procedure TTrack._table;
var
  i:Integer;
begin
  for i := 0 to length(finished)-1 do
  begin
    glWrite((S_WIDTH div 2)-(8*16), ((S_HEIGHT div 2)-(length(finished) div 2)*18)-i*18, inttostr(i+1) + '. ' + finished[i].name + ' [' + DoTime(finished[i].fin_time) + ']', finished[i].color[0], finished[i].color[1], finished[i].color[2]);
  end;
end;

procedure TTrack.AddFinisher(c:TCar);
begin
  SetLength(finished, length(finished)+1);
  finished[length(finished)-1] := c;
end;

procedure TTrack._render;
var
  i:integer;
begin
  glMatrixMode(GL_MODELVIEW);
  glCallList(trak);
end;

constructor TTrack.Create;
var
  i:integer;
  a:GLfloat;
  field_rect : TRect4f;
  p : TPoint3f;
begin
  FillChar(field_rect, sizeof(TRect4f), 0);
  SetLength(chpts, TRACK_LN);
  chpts[0].x := 0;
  chpts[0].z := 0;
  a := 0;
  m_mast := 1.0;
  m_x := S_WIDTH/2;
  m_y := S_HEIGHT/2;

  t_length := TRACK_LN;
  {Generation way}

  Randomize;
  trak := glGenLists(1);
  glNewList(trak, GL_COMPILE);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glEnable(GL_TEXTURE_2D);
  glDisable(GL_LIGHTING);
  glColor3f(1, 1, 1);
  glBindTexture(GL_TEXTURE_2D, TEX_ROAD);
  glBegin(GL_QUADS);
  for i := 1 to TRACK_LN-1 do
  begin
    glTexCoord2f(0, 0); glVertex3f(chpts[i-1].x+cwCos(a)*ROAD_WDT, 0, chpts[i-1].z-cwSin(a)*ROAD_WDT);
    glTexCoord2f(ROAD_U, 0); glVertex3f(chpts[i-1].x-cwCos(a)*ROAD_WDT, 0, chpts[i-1].z+cwSin(a)*ROAD_WDT);

{    if(chpts[i-1].x+cwCos(a)*ROAD_WDT<field_rect.x1)then field_rect.x1 := chpts[i-1].x+cwCos(a)*ROAD_WDT;
    if(chpts[i-1].z-cwSin(a)*ROAD_WDT<field_rect.z1)then field_rect.z1 := chpts[i-1].z-cwSin(a)*ROAD_WDT;
    if(chpts[i-1].x-cwCos(a)*ROAD_WDT<field_rect.x1)then field_rect.x1 := chpts[i-1].x-cwCos(a)*ROAD_WDT;
    if(chpts[i-1].z+cwSin(a)*ROAD_WDT<field_rect.z1)then field_rect.z1 := chpts[i-1].z+cwSin(a)*ROAD_WDT;}

    chpts[i].x := chpts[i-1].x + cwSin(a)*10;
    chpts[i].z := chpts[i-1].z + cwCos(a)*10;

    if chpts[i].x<field_rect.x1 then field_rect.x1 := chpts[i].x;
    if chpts[i].z<field_rect.z1 then field_rect.z1 := chpts[i].z;

    if chpts[i].x>field_rect.x2 then field_rect.x2 := chpts[i].x;
    if chpts[i].z>field_rect.z2 then field_rect.z2 := chpts[i].z;

    a := a + random(TRN_SPEED)*(1-(random(3)));
    if a>360 then a := a-360;
    if a<0   then a := 360+a;

    glTexCoord2f(ROAD_U, ROAD_V); glVertex3f(chpts[i].x-cwCos(a)*ROAD_WDT, 0, chpts[i].z+cwSin(a)*ROAD_WDT);
    glTexCoord2f(0, ROAD_V); glVertex3f(chpts[i].x+cwCos(a)*ROAD_WDT, 0, chpts[i].z-cwSin(a)*ROAD_WDT);
  end;
  glEnd;

  field_rect.x1 := field_rect.x1 - 100;
  field_rect.z1 := field_rect.z1 - 100;
  field_rect.x2 := field_rect.x2 + 100;
  field_rect.z2 := field_rect.z2 + 100;

  glBindTexture(GL_TEXTURE_2D, TEX_GRASS);

  glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex3f(field_rect.x1, -0.02, field_rect.z1);

    glTexCoord2f(field_rect.x1/10, 0);
    glVertex3f(field_rect.x2, -0.02, field_rect.z1);

    glTexCoord2f(field_rect.x1/10, field_rect.z2/10);
    glVertex3f(field_rect.x2, -0.02, field_rect.z2);

    glTexCoord2f(0, field_rect.z2/10);
    glVertex3f(field_rect.x1, -0.02, field_rect.z2);
  glEnd;
  {FINISH}
  fin_crd[0].x := chpts[t_length-1].x-cwCos(a)*ROAD_WDT;
  fin_crd[0].z := chpts[t_length-1].z+cwSin(a)*ROAD_WDT;

  fin_crd[1].x := chpts[t_length-1].x+cwCos(a)*ROAD_WDT;
  fin_crd[1].z := chpts[t_length-1].z-cwSin(a)*ROAD_WDT;

  fin_v.x := fin_crd[1].x - fin_crd[0].x;
  fin_v.z := fin_crd[1].z - fin_crd[0].z;

  NormalizeVector(@fin_v);

  glBindTexture(GL_TEXTURE_2D, TEX_FINISH);
  glBegin(GL_QUADS);
    glTexCoord2f(1, 0); glVertex3f(chpts[t_length-1].x-cwCos(a)*ROAD_WDT, 5, chpts[t_length-1].z+cwSin(a)*ROAD_WDT);
    glTexCoord2f(0, 0); glVertex3f(chpts[t_length-1].x+cwCos(a)*ROAD_WDT, 5, chpts[t_length-1].z-cwSin(a)*ROAD_WDT);
    glTexCoord2f(0, 1); glVertex3f(chpts[t_length-1].x+cwCos(a)*ROAD_WDT, 10, chpts[t_length-1].z-cwSin(a)*ROAD_WDT);
    glTexCoord2f(1, 1); glVertex3f(chpts[t_length-1].x-cwCos(a)*ROAD_WDT, 10, chpts[t_length-1].z+cwSin(a)*ROAD_WDT);
  glEnd;

  glDisable(GL_TEXTURE_2D);
  glEnable(GL_LIGHTING);
  glMatrixMode(GL_MODELVIEW);
  for i := 0 to 200 do
  begin
      glLoadIdentity;

      p.x := random(trunc(field_rect.x2-field_rect.x1));
      p.z := random(trunc(field_rect.z2-field_rect.z1));

      trees[i] := p;

      glTranslatef(p.x, 0, p.z);
      glCallList(MOD_ELKA);
  end;

  glEndList;
end;

end.

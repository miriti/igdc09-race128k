{
  усд
}
unit uHUD;

interface
uses
  OpenGL, uGlobal, uTypes, uText, uSysUtils, uLog;

type
  THUD = class
    tablo : GLuint;
    tran  : GLuint;
    procedure hudBegin;
    procedure hudEnd;
    procedure hudSpeedOMeter(fmps : GLfloat; x,y:Integer);
    procedure hudTransmission(t:Shortint);
    procedure hudDamage(dam : GLfloat);
    constructor Create;
  end;

implementation

procedure THUD.hudDamage(dam : GLfloat);
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(0, S_WIDTH, S_HEIGHT, 0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  glTranslatef(S_WIDTH-180, 50, 0);
  glColor3f(0.0, 0.5, 0.0);
  glWrite(0, 0, FloatToStr(dam));
{  glBegin(GL_QUADS);
    glVertex2f(0, 0);
    glVertex2f(150, 0);
    glVertex2f(150, 16);
    glVertex2f(0, 16);
  glEnd;
  glColor3f(0.0, 1.0, 0.0);
  glBegin(GL_QUADS);
    glVertex2f(3, 3);
    glVertex2f(147*(dam/100), 3);
    glVertex2f(147*(dam/100), 13);
    glVertex2f(1, 13);
  glEnd; }
end;

procedure THUD.hudTransmission(t:Shortint);
var
  trm : Char;
begin
  case t of
    -1 : trm := 'R';
    0  : trm := 'N';
    1  : trm := '1';
    2  : trm := '2';
    3  : trm := '3';
    4  : trm := '4';
  end;
  glWrite2(S_WIDTH-100, 10, trm);
end;

procedure THUD.hudSpeedOMeter(fmps : GLfloat; x,y:Integer);
  procedure Needle;
  begin
    glBegin(GL_TRIANGLES);
      glVertex2i(-2, 0);
      glVertex2i(2, 0);
      glVertex2i(0, 49);
    glEnd;
  end;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(0, S_WIDTH, S_HEIGHT, 0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(x, y, 0);
  glCallList(tablo);
  glRotatef(fmps, 0.0, 0.0, 0.1);
  Needle;
  glWrite(x, S_HEIGHT - y, FloatToStr(fmps));
end;

constructor THUD.Create;
var
  i:Integer;
begin
  LogStr(PChar(#9 + 'HUD'));
  tablo := glGenLists(1);
  glNewList(tablo, GL_COMPILE);
  glBegin(GL_POINTS);
  for i := 0 to 90 do
  begin
    glVertex2f(cwCos(i*4)*50, cwSin(i*4)*50);
  end;
  glEnd;
  glEndList;
end;

procedure THUD.hudEnd;
begin

end;

procedure THUD.hudBegin;
begin

end;

end.

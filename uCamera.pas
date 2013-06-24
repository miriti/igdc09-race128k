{
  Камера
}

unit uCamera;

interface
uses
  uTypes, OpenGL;
type
  TCamera  = class
    targ : PPoint3f;
    pos  : TPoint3f;
    fov  : single;
    dist : Single;
    stay_over : Boolean;
  public
    procedure Look;
  end;

implementation

procedure SetFog;
var
  fogColor : Array [0..3] of GLFloat;
begin
  glDisable(GL_FOG);
  fogColor[0]:=0.0;
  fogColor[1]:=0.0;
  fogColor[2]:=0.0;
  fogColor[3]:=0.0;
  glEnable(GL_FOG);
  glFogi  (GL_FOG_MODE, GL_LINEAR);
  glHint  (GL_FOG_HINT, GL_NICEST);
  glFogf  (GL_FOG_START, 1);
  glFogf  (GL_FOG_END, 100);
  glFogfv (GL_FOG_COLOR, @fogColor);
end;

procedure TCamera.Look;
begin

  if stay_over then
  begin
    pos := targ^;
    pos.y := 30;
    pos.z := pos.z - 0.01;
  end;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(fov, 4/3, 0.1, 10000.0);
  gluLookAt(pos.x, pos.y, pos.z, targ^.x, targ^.y, targ^.z, 0.0, 1.0, 0.0);
//  SetFog;
end;

end.

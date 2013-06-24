{
Вывод текста
//Взял у того кто взял у Darthman'а и подделано под собственные нужды
}
unit uText;

interface

uses
  Windows, openGl, uGlobal;

var
  fontbase, fontbase2 : GLuint;

procedure InitializeFont(h_DC : HDC);
procedure InitializeFont2(h_DC : HDC);
procedure glWrite(tx, ty : integer; text : String; r:single=1; g:single=1; b:single=1);
procedure glWrite2(tx, ty : integer; text : String);

implementation

//=============================================================================
// создаем простейший битмапный шрифт
//=============================================================================
procedure InitializeFont(h_DC : HDC);
var
  font : HFONT;
begin
  fontbase := glGenLists(96);
  font := CreateFont(18, 10, 0, 0, FW_NORMAL, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS,
    CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY	, FF_DONTCARE or DEFAULT_PITCH, 'Courier New');
  SelectObject(h_DC, font);
  wglUseFontBitmaps(h_DC, 32, 96, fontbase);
  DeleteObject(font);
end;

procedure InitializeFont2(h_DC : HDC);
var
  font : HFONT;
begin
  fontbase2 := glGenLists(96);
  font := CreateFont(38, 10, 0, 0, FW_BOLD, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS,
    CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY	, FF_DONTCARE or DEFAULT_PITCH, 'Courier New');
  SelectObject(h_DC, font);
  wglUseFontBitmaps(h_DC, 32, 96, fontbase2);
  DeleteObject(font);
end;

//=============================================================================
// вывести символ
//=============================================================================
procedure glPutchar(text : PChar);
begin
  if (text = '') then Exit;
  glPushAttrib(GL_LIST_BIT);
  glListBase(fontbase - 32);
  glCallLists(length(text), GL_UNSIGNED_BYTE, text);
  glPopAttrib();
end;

procedure glPutchar2(text : PChar);
begin
  if (text = '') then Exit;
  glPushAttrib(GL_LIST_BIT);
  glListBase(fontbase2 - 32);
  glCallLists(length(text), GL_UNSIGNED_BYTE, text);
  glPopAttrib();
end;

//=============================================================================
// Рисование заданного текста в координатах Х и У
//=============================================================================
procedure glWrite(tx, ty : integer; text : String; r:single=1; g:single=1; b:single=1);
begin
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glDisable(GL_TEXTURE_2D);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0, S_WIDTH, 0, S_HEIGHT, -1, 1);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glColor3f(r, g, b);
  glRasterPos2i(tx, ty);
  glPutchar(PChar(text));
  
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  glEnable(GL_TEXTURE_2D);
end;

procedure glWrite2(tx, ty : integer; text : String);
begin
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glDisable(GL_TEXTURE_2D);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  glOrtho(0, S_WIDTH, 0, S_HEIGHT, -1, 1);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();
  glColor3f(1, 1, 1);
  glRasterPos2i(tx, ty);
  glPutchar2(PChar(text));
  glMatrixMode(GL_PROJECTION);
  glPopMatrix();
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix();
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  glEnable(GL_TEXTURE_2D);
end;

end.

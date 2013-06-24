{
  ���������������� ��������
  � �� �������������
}
unit uTextures;

interface
uses
  OpenGL, uLog;
var
sky_bmp: array[0..12287] of byte = (
$20, 

































































































































































































































































































































































































finish_bmp: array[0..3071] of byte = (
$FF, 

































































































{�������������� �������:}
TEX_GRASS,
TEX_SKY,
TEX_ROAD,
TEX_FINISH   : GLuint;

bi_filter : Boolean = True;

function gluBuild2DMipmaps(Target: GLenum; Components, Width, Height: GLint; Format, atype: GLenum; Data: Pointer): GLint; stdcall; external glu32;
procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external 'opengl32.dll';
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external 'opengl32.dll';
procedure texInit;

implementation

function GenTexture(w,h:Integer; p:Pointer; mode:GLuint=GL_RGB; components : byte=3):GLuint;
begin
  glGenTextures(1, Result);
  glBindTexture(GL_TEXTURE_2D, Result);

  if bi_filter then
  begin
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  end else
  begin
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  end;

  gluBuild2DMipmaps(GL_TEXTURE_2D, components, w, h, mode, GL_UNSIGNED_BYTE, p);
end;

procedure texInit;
type
  TRndTexture = array[0..63, 0..63] of array[0..2] of Byte;
var
  road_tex,grass_tex : Pointer;
  i,j,c:Byte;
begin
  LogStr(PChar(#9 + 'Generating textures'));
  {���������� �������� ������}
  GetMem(road_tex, SizeOf(TRndTexture));
  for i := 0 to 63 do
  begin
    for j := 0 to 63 do
    begin
      c := 50+(random(40));
      TRndTexture(road_tex^)[i,j][0] := c;
      TRndTexture(road_tex^)[i,j][1] := c;
      TRndTexture(road_tex^)[i,j][2] := c;
    end;
  end;
  {������}
  for i := 20 to 45 do
  begin
    for j := 27 to 32 do
    begin
      TRndTexture(road_tex^)[i,j][0] := 255;
      TRndTexture(road_tex^)[i,j][1] := 255;
      TRndTexture(road_tex^)[i,j][2] := 200 + random(56);
    end;
  end;
  {����� ���� "�����" � ������ � �� �����������. � ��� ����}
  {/���������� �������� ������}

  GetMem(grass_tex, SizeOf(TRndTexture));

  for i := 0 to 63 do
  begin
    for j := 0 to 63 do
    begin
      TRndTexture(grass_tex^)[i,j][0] := 0;
      TRndTexture(grass_tex^)[i,j][1] := 64+random(128);
      TRndTexture(grass_tex^)[i,j][2] := 0;
    end;
  end;

  {������� � ������ ��� ��������� �������� �� ������}
  TEX_GRASS := GenTexture(64, 64, grass_tex);
  TEX_SKY   := GenTexture(64, 64, @sky_bmp);
  TEX_ROAD  := GenTexture(64, 64, road_tex);
  TEX_FINISH:= GenTexture(64, 16, @finish_bmp);

  if TEX_GRASS <> 0 then LogStr(PChar(#9#9 + 'TEX_GRASS - OK')) else LogStr(PChar(#9#9 + 'TEX_GRASS - FAILED!'));
  if TEX_SKY <> 0 then LogStr(PChar(#9#9 + 'TEX_SKY - OK')) else LogStr(PChar(#9#9 + 'TEX_SKY - FAILED!'));
  if TEX_ROAD <> 0 then LogStr(PChar(#9#9 + 'TEX_ROAD - OK')) else LogStr(PChar(#9#9 + 'TEX_ROAD - FAILED!'));
  if TEX_FINISH <> 0 then LogStr(PChar(#9#9 + 'TEX_FINISH - OK')) else LogStr(PChar(#9#9 + 'TEX_FINISH - FAILED!'));


  {������ ������ ��� ��� ��� ���� � ������}
  FreeMem(road_tex);
  FreeMem(grass_tex);
end;

end.
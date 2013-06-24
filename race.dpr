{$WARNINGS OFF}
{$HINTS OFF}

{
Для конкурса "Races" на code.rpro.ru
      14.08.2005 - 01.10.2005
+---------------------------------------+
| by     : Kefir[87]                    |
| e-mail : reel_geek@km.ru,             |
|          cwdev.km.ru                  |
| web    : cwdev.mykm.ru (может 403 8)) |
+---------------------------------------+
Замечание
---------
Читайте DevelopersLog.pas 8)
}
program race;

uses
  Windows, {Творение конторы била гейтса}
  OpenGL, {ОпенДжиЭль}
  Messages, {Сообщения}
  uModels       in 'uModels.pas',       {Модельки, массивы с ними и нициализация}
  uTypes        in 'uTypes.pas',        {Всякие, там, разные типы}
  uCamera       in 'uCamera.pas',       {Работа с камерой. У XProger'а интересней...}
  uTextures     in 'uTextures.pas',     {Текстурки, генерация их}
  uSysUtils     in 'uSysUtils.pas',     {Как говорил Ян Хорн: using SysUtils increase file size by 100K}
  uGlobal       in 'uGlobal.pas',       {Глобальные переменные и кажется константы там тоже есть...}
  DevelopersLog in 'DevelopersLog.pas', {8)))}
  uBCar         in 'uBCar.pas',         {Собственно все что связанно с машинками}
  uHUD          in 'uHUD.pas',          {UI}
  uText         in 'uText.pas',         {Вывод текста}
  uTrack        in 'uTrack.pas',        {Трасса: генерация... и еще что-то}
  uLog          in 'uLog.pas';          {Лог, опционально}

const
  Class_name = 'race_wnd';       {Имя класса окна}
  WND_TITLE  = 'CW 128k Racing'; {Заголовок окна}

type
  TGmOpt = (opt_fullscreen, opt_lowvideo, opt_hivideo, opt_nobilinear);   {Опции программы...}

  TGame = class // Главный класс программы
  public
    KEY_GAZ    : Byte;
    KEY_TORMOZ : Byte;
    KEY_LEFT   : Byte;
    KEY_RIGHT  : Byte;
    KEY_TPLUS  : Byte;
    KEY_TMINS  : Byte;
    KEY_HBRK   : Byte;
    KEY_CAM    : Byte;
    wnd_game : HWND;
    renderer : string;
    vendor   : string;
    extens   : string;
    constructor Create;
    destructor Destroy;
    procedure Loop;
    procedure cwKeyDown(key : Byte);
    procedure cwKeyUp(key : Byte);
    procedure cwRender;
  private
    DC       : HDC;
    RC       : HGLRC;
    msg      : TMsg;
    keys     : array [0..255] of Boolean;
    mein_cam : TCamera;
    hud      : THUD;
    mode     : Byte;
    Options  : set of TGmOpt;
    s_m      : Shortint;
    s_k      : Shortint;
    s_o      : Shortint;
    n_cars   : Byte;
    is_key   : Boolean;
    is_race  : Boolean;
    cnt_dwn  : Word;
    cam_mode : Byte;
    shd      : GLfloat;
    {TEMP!}
    procedure GoFullScreen(w,h:integer);
    function  cwWindow(w,h:Integer):HWND;
    procedure GoOpenGL;
    procedure GameScene;
    procedure MainMenu;
    procedure CtrlsMenu;
    procedure DefaultKeybrd;
    procedure GmOptions;
    procedure Final;
  end;

var
  Game : TGame;
  FPS,F: Word;
  fps_s : Boolean = True;

{/===========================/}

procedure TGame.Final;
begin
  Track._table;
end;

destructor TGame.Destroy;
begin
  LogStr('Game.Destroy');
  LogStr('Kill timer 1', 1);
  KillTimer(wnd_game, 1);
  LogStr('Kill timer 2', 1);
  KillTimer(wnd_game, 2);
  LogStr('wglMakeCurrent(0, 0)', 1);
  wglMakeCurrent(0, 0);
  LogStr('wglDeleteContext(DC)', 1);
  wglDeleteContext(RC);

  CarEngine.Destroy;
  Track.Destroy;

  inherited Destroy;
end;

procedure CountFPS;
begin
  FPS := F;
  if fps_s then SetWindowText(Game.wnd_game, Pchar(Game.renderer)) else
    SetWindowText(Game.wnd_game, PChar(WND_TITLE + ' [' + IntToStr(FPS) + ']'));
  f := 0;
end;

procedure TGame.GmOptions;
const
  m_i = 0;
  menu : array[0..m_i] of string =
  ('Transmission      : ');{,
   'Num. of apponents : ');}
var
  i:Integer;
  inf:string;
begin
  glDisable(GL_LIGHTING);
  for i := 0 to m_i do
  begin

    case i of
      0:begin
          if CarEngine.main_car.a_korob then inf := 'auto' else
            inf := 'manual';
        end;
    end;

    if i = s_o then
      glWrite((S_WIDTH div 2)-100, ((S_HEIGHT div 2)+100)-i*18, '> ' + menu[i] + inf) else
            glWrite((S_WIDTH div 2)-100, ((S_HEIGHT div 2)+100)-i*18, '  ' + menu[i] + inf);
  end;
  glEnable(GL_LIGHTING);
end;

procedure TGame.DefaultKeybrd;
begin
  KEY_GAZ    := ord('W');
  KEY_TORMOZ := ord('S');
  KEY_LEFT   := ord('A');
  KEY_RIGHT  := ord('D');
  KEY_TPLUS  := ord('Q');
  KEY_TMINS  := ord('E');
  KEY_HBRK   := ord(' ');
  KEY_CAM    := ord('C');
end;

procedure TGame.CtrlsMenu;
  function DisplKey(key : byte):string;
  begin
    Result := chr(key);
    if key = VK_RETURN then Result := 'RETURN' else
    if key = VK_SPACE  then Result := 'SPACE' else
    if key = VK_UP     then Result := 'UP ARROW' else
    if key = VK_DOWN   then Result := 'DWN ARROW' else
    if key = VK_LEFT   then Result := 'LFT ARROW' else
    if key = VK_RIGHT  then Result := 'RGT ARROW' else
    if key = VK_TAB    then Result := 'TAB';
  end;
const
  menu : array [0..8] of string =
  ('Acselerator : ',
   'Brake       : ',
   'Turn left   : ',
   'Turn right  : ',
   'Transm. +   : ',
   'Transm. -   : ',
   'Hand break  : ',
   'Camera      : ',
   '[LOAD DEFAULTS]');
var
  i:Byte;
  s:string;
begin
  glDisable(GL_LIGHTING);
  if is_key then
    glWrite(0, 10, 'Press a key... To cancel press ESC');
  for i := 0 to 8 do
  begin
    case i of
      0:s := DisplKey(KEY_GAZ);
      1:s := DisplKey(KEY_TORMOZ);
      2:s := DisplKey(KEY_LEFT);
      3:s := DisplKey(KEY_RIGHT);
      4:s := DisplKey(KEY_TPLUS);
      5:s := DisplKey(KEY_TMINS);
      6:s := DisplKey(KEY_HBRK);
      7:s := DisplKey(KEY_CAM);
      8:s := '';
    end;
    if s_k = i then
    begin
      if not is_key then
        glWrite((S_WIDTH div 2)-100, ((S_HEIGHT div 2)+100)-i*18, '> ' + menu[i] + s) else
          if not odd(TickCount div 200) then glWrite((S_WIDTH div 2)-100, ((S_HEIGHT div 2)+100)-i*18, '> ' + menu[i]);
    end else
        glWrite((S_WIDTH div 2)-100, ((S_HEIGHT div 2)+100)-i*18, '  ' + menu[i] + s);
  end;
  glEnable(GL_LIGHTING);
end;

procedure TGame.GameScene;
const
  cam_speed = 0.05;
begin
//  glEnable(GL_FOG);
  //if length(Track.finished) = length(CarEngine.cars) then mode := 4;
  if CarEngine.main_car.is_finish then mode := 4;
  if is_race then
  begin
    if keys[KEY_LEFT]   then CarEngine.main_car.PushButton(go_left);
    if keys[KEY_RIGHT]  then CarEngine.main_car.PushButton(go_right);
    if keys[KEY_GAZ]    then CarEngine.main_car.PushButton(go_frw);
    if keys[KEY_TORMOZ] then CarEngine.main_car.PushButton(go_bak);
    if keys[KEY_HBRK]   then CarEngine.main_car.PushButton(go_hbr);
    if keys[ord('M')]   then
    begin
      Track._map(CarEngine.main_car.b_pos.x, CarEngine.main_car.b_pos.z);
      if keys[ord('J')] then Track.m_mast := Track.m_mast + 0.01;
      if keys[ord('K')] then Track.m_mast := Track.m_mast - 0.01;

      if keys[VK_LEFT]  then Track.m_x    := Track.m_x    - 1;
      if keys[VK_RIGHT] then Track.m_x    := Track.m_x    + 1;
      if keys[VK_UP]    then Track.m_y    := Track.m_y    + 1;
      if keys[VK_DOWN]  then Track.m_y    := Track.m_y    - 1;
    end;
  end;

  {SKY BOX}
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(mein_cam.pos.x, mein_cam.pos.y, mein_cam.pos.z);
  glCallList(MOD_SKY);
  {/SKY BOX}

  glEnable(GL_LIGHTING);
    if is_race then
    begin
      CarEngine.DoAI;
      CarEngine.DoCollision;
      CarEngine.DoControl;
      CarEngine.DoMove;
    end;
    CarEngine.DoRender;

  Track._render;

  if is_race then glWrite(0, S_HEIGHT-50, 'Race time : ' + DoTime(race_time)) else
  begin
    if cnt_dwn <> 0 then
      glWrite2(S_WIDTH div 2, S_HEIGHT div 2, inttostr(cnt_dwn)) else
        glWrite2(S_WIDTH div 2, S_HEIGHT div 2, 'GO!!!');
  end;

  glWrite(0, 0, 'FPS : ' + inttostr(FPS));

  case cam_mode of
  0:begin
      mein_cam.stay_over := False;
      mein_cam.pos.x := CarEngine.main_car.b_pos.x - cwSin(CarEngine.main_car.b_xang)*mein_cam.dist;
      mein_cam.pos.y := 2;
      mein_cam.pos.z := CarEngine.main_car.b_pos.z - cwCos(CarEngine.main_car.b_xang)*mein_cam.dist;
    end;
  1:begin
      mein_cam.stay_over := False;
      mein_cam.pos.x := CarEngine.main_car.b_pos.x - cwSin(CarEngine.main_car.b_xang)*mein_cam.dist;
      mein_cam.pos.y := 5;
      mein_cam.pos.z := CarEngine.main_car.b_pos.z - cwCos(CarEngine.main_car.b_xang)*mein_cam.dist;
    end;
  2:begin
      mein_cam.stay_over := False;
      mein_cam.pos.x := CarEngine.main_car.b_pos.x + cwSin(CarEngine.main_car.b_xang)*mein_cam.dist;
      mein_cam.pos.y := 2;
      mein_cam.pos.z := CarEngine.main_car.b_pos.z + cwCos(CarEngine.main_car.b_xang)*mein_cam.dist;
    end;
  3:begin
      mein_cam.stay_over := False;
      mein_cam.pos.x := CarEngine.main_car.b_pos.x + cwSin(CarEngine.main_car.b_xang)*mein_cam.dist;
      mein_cam.pos.y := 5;
      mein_cam.pos.z := CarEngine.main_car.b_pos.z + cwCos(CarEngine.main_car.b_xang)*mein_cam.dist;
    end;
  4:begin
      mein_cam.stay_over := True;
    end;
  end;

  hud.hudSpeedOMeter(abs(((CarEngine.main_car.b_a*64)/1000)*(60*60)), S_WIDTH-70, S_HEIGHT-50);
  hud.hudSpeedOMeter(CarEngine.main_car.rmp/50, S_WIDTH-170, S_HEIGHT-50);
  hud.hudTransmission(CarEngine.main_car.transm);
  
  if (TickCount mod 1000)=0 then
  begin
    if not is_race then
    begin
      if cnt_dwn = 0 then is_race := true;
      dec(cnt_dwn);
    end;
  end;

  if (is_race) then
  begin
    inc(race_time);
  end;
  
  mein_cam.Look;
//  glDisable(GL_FOG);
end;

procedure TGame.MainMenu;
const
  menu : array [0..3] of string =
  ('PLAY', 'Controls', 'Game Options', 'Exit');
var
  i : Byte;
begin
  glDisable(GL_LIGHTING);
  glWrite(0, S_HEIGHT-50, '* ClockWork 128k Racing by Kefir for code.rpro.ru.');
  glWrite(0, 10, '* UP, DOWN - Move coursor; ENTER, SPACE - select');
  for i := 0 to 3 do
  begin
    if i=s_m then
      glWrite((S_WIDTH div 2)-50, (S_HEIGHT div 2)-i*18, '> ' + menu[i]) else
        glWrite((S_WIDTH div 2)-50, (S_HEIGHT div 2)-i*18, '  ' + menu[i]);
  end;
  glEnable(GL_LIGHTING);
end;

{WINDOW PROC}
function WindowProc(hwnd, msg, wparam, lparam: longint): longint; stdcall;
begin
  Result := DefWindowProc(hwnd, msg, wparam, lparam);
  case msg of
    WM_DESTROY : PostQuitMessage(0);
    WM_KEYDOWN : Game.cwKeyDown(wparam);
    WM_KEYUP   : Game.cwKeyUp(wparam);
    WM_TIMER   : Game.cwRender;
  end;
end;
{/WINDOW PROC}

procedure TGame.GoFullScreen(w,h:integer);
var
  DevMode : _devicemodeA;
begin
  LogStr(PChar('GoFullScreen (' + inttostr(w) + 'x' + inttostr(h) + 'x' + inttostr(S_BITCNT) + ')'), 1);
  with DevMode do
  begin
    dmSize := SizeOf(DevMode);
  	dmBitsPerPel := S_BITCNT;
	  dmPelsWidth := w;
  	dmPelsHeight := h;
	  dmFields := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;
  end;

  if(ChangeDisplaySettingsA(DevMode, CDS_FULLSCREEN)=DISP_CHANGE_SUCCESSFUL)then
  begin
    LogStr(PChar(#9#9 + 'OK'));
		SetWindowLong(wnd_game, GWL_STYLE, WS_POPUP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS);
		SetWindowLong(wnd_game, GWL_EXSTYLE, WS_EX_APPWINDOW);
		SetWindowPos(wnd_game, HWND_TOPMOST, 0, 0, w, h, SWP_SHOWWINDOW);
    glViewport(0, 0, w, h);
  end else
    LogStr(PChar(#9#9 + 'FAILED'));

end;

{---+======== ////  RENDER  \\\\ =========------}
procedure TGame.cwRender;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  case mode of
    0 : MainMenu;
    1 : GameScene;
    2 : CtrlsMenu;
    3 : GmOptions;
    4 : Final;
  end;
  SwapBuffers(DC);

  inc(f);
//  inc(TickCount);
//  if (TickCount mod 1000)=0 then fps_s := not fps_s;
end;

procedure TGame.cwKeyUp(key:Byte);
begin
  keys[key] := False;
end;

procedure TGame.cwKeyDown(key:byte);
begin
 //  if key = 27 then PostQuitMessage(0);

  if mode = 0 then
  begin
    if key = VK_DOWN then
    begin
      inc(s_m);
      if s_m > 3 then s_m := 0;
    end;
    if key = VK_UP then
    begin
      dec(s_m);
      if s_m < 0 then s_m := 3;
    end;
    if (key = VK_RETURN)or(key = VK_SPACE) then
    begin
      case s_m of
        0:mode := 1;
        1:mode := 2;
        2:mode := 3;
        3:PostQuitMessage(0);
      end;
    end;
  end;

  if mode = 1 then
  begin
    if key = 27 then mode := 0;
    if key = KEY_CAM then
    begin
      inc(cam_mode);
      if cam_mode>4 then cam_mode := 0;
    //mein_cam.stay_over := not mein_cam.stay_over;
    end;
    if key = KEY_TPLUS then CarEngine.main_car.AddTransmiss;
    if key = KEY_TMINS then CarEngine.main_car.DecTransmiss;
  end;

  if mode = 2 then
  begin
    if is_key then
    begin
      if key = 27 then
      begin
        is_key := false;
        exit;
      end;
      case s_k of
        0:KEY_GAZ := key;
        1:KEY_TORMOZ := key;
        2:KEY_LEFT := key;
        3:KEY_RIGHT := key;
        4:KEY_TPLUS := key;
        5:KEY_TMINS := key;
        6:KEY_HBRK  := key;
        7:KEY_CAM   := key;
      end;
      is_key := False;
    end else
    begin
      if key = 27 then mode := 0;
      if key = VK_DOWN then
      begin
        inc(s_k);
        if s_k > 8 then s_k := 0;
      end;
      if key = Vk_UP then
      begin
        dec(s_k);
        if s_k < 0 then s_k := 8;
      end;
      if (key = VK_SPACE)or(Key = VK_RETURN) then
      begin
        if s_k = 8 then DefaultKeybrd else
          is_key := TRUE;
      end;
    end;
  end;

  if mode=3 then
  begin
    if key = 27 then mode := 0;
    if key = VK_DOWN then
    begin
      inc(s_o);
      if(s_o>0)then s_o := 0;
    end;
    if key=VK_UP then
    begin
      dec(s_o);
      if s_o<0 then s_o := 0;
    end;
    if key = VK_SPACE then
    begin
      case s_o of
        0:CarEngine.main_car.a_korob := not CarEngine.main_car.a_korob;
        1:;
      end;
    end;
  end;

  keys[key] := True;
end;

procedure TGame.Loop;
begin
  while msg.message<>WM_QUIT do
  begin
    if(GetMessage(msg, 0, 0, 0)) then
    begin
      TranslateMessage(msg);
      DispatchMessage(msg);
    end;
  end;
end;

procedure TGame.GoOpenGL;
const
  l_pos : array[0..2] of GLfloat =
  (1000, -2000, 1000);
  l_col : array[0..2] of GLfloat =
  (1.0, 1.0, 0.5);
  f_col : array[0..2] of GLfloat =
  (0.5, 0.5, 0.5);
var
  pfd : TPixelFormatDescriptor;
  n   : Integer;
begin
  FillChar(pfd, sizeof(pfd), 0);

  with pfd do
  begin
    nSize      := sizeof(pfd);
    nVersion   := 1;
    dwFlags    := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    iPixelType := PFD_TYPE_RGBA;
    cColorBits := S_BITCNT;
    cDepthBits := 16;
    iLayerType := PFD_MAIN_PLANE;
  end;

  n := ChoosePixelFormat(DC, @pfd);

  if(SetPixelFormat(DC, n, @pfd))then
    LogStr(PChar(#9#9 + 'SetPixelFormat - OK')) else
      LogStr(PChar(#9#9 + 'SetPixelFormat - FAILED!'));

  if DescribePixelFormat(DC, n, sizeof(pfd), pfd) then
    LogStr(PChar(#9#9 + 'DescribePixelFormat - OK')) else
      LogStr(PChar(#9#9 + 'DescribePixelFormat - FAILED'));

  RC := wglCreateContext(DC);
  wglMakeCurrent(DC, RC);

  glClearColor(0.0745098039215686,0,0.607843137254902, 1.0);
  glViewport(0, 0, S_WIDTH, S_HEIGHT);

  glEnable(GL_DEPTH_TEST);

  {glEnable(GL_FOG);
  glFogi (GL_FOG_MODE, GL_EXP2);
  glFogfv(GL_FOG_COLOR, @f_col);
  glFogf (GL_FOG_DENSITY, 0.05);}


  glEnable(GL_COLOR_MATERIAL);

  glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 50.0);
  glLightfv(GL_LIGHT0, GL_POSITION, @l_pos);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @l_col);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @l_col);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);

  glShadeModel(GL_SMOOTH);

end;

constructor TGame.Create;
  procedure GetParamOpts;
  var
    s:string;
    i:Integer;
  begin
    Options := [];
    if ParamCount <> 0 then
    begin
      for i := 0 to ParamCount-1 do
      begin
        LogStr(Pchar(Paramstr(i+1)), 2);
        s := s + ParamStr(i+1);
      end;
      if Pos('-fullscreen', s)<>0 then Options := Options + [opt_fullscreen];
      if Pos('-lowvideo', s)<>0   then Options := Options + [opt_lowvideo];
      if Pos('-hivideo', s)<>0    then
      begin
        Options := Options - [opt_lowvideo];
        Options := Options + [opt_hivideo];
      end;
      if pos('-nobilinear', s)<>0 then Options := Options + [opt_nobilinear];
    end else LogStr('No parametrs', 2);
  end;
var
  i:Byte;
begin

  LogStr('Game.Create', 0);

  shd := 0.0;
  LogStr('GetParamOpts', 1);
  GetParamOpts;

  if opt_lowvideo in Options then
  begin
    S_WIDTH  := 640;
    S_HEIGHT := 480;
    S_BITCNT := 16;
  end;

  if opt_hivideo in Options then
  begin
    S_WIDTH  := 1024;
    S_HEIGHT := 768;
    S_BITCNT := 32;
  end;

  bi_filter := not(opt_nobilinear in Options);
  LogStr(PChar(#9 + 'Create window : ' + inttostr(S_WIDTH) + 'x' + inttostr(S_HEIGHT)));
  wnd_game := cwWindow(S_WIDTH, S_HEIGHT);
  DC       := GetDC(wnd_game);
  LogStr(PChar(#9 + 'GoOpenGL'));
  GoOpenGL;

  renderer := PChar(glGetString(GL_RENDERER));
  vendor   := PChar(glGetString(GL_VENDOR));
  extens   := PChar(glGetString(GL_EXTENSIONS));

  LogStr(PChar(#9 + 'OpenGL ver.: ' + PChar(glGetString(GL_VERSION))));
  LogStr(PChar(#9 + 'Vendor     : ' + vendor));
  LogStr(PChar(#9 + 'Renderer   : ' + renderer));
  //LogStr(PChar(#9 + 'Extensions : ' + extens));
  


  if opt_fullscreen in Options then GoFullScreen(S_WIDTH, S_HEIGHT);

  texInit; {Создать все текстуры}
  InitModels; {Создать модели}

  Track := TTrack.Create;
  Track.m_mast := 0.1;

  CarEngine := TCarEngine.Create;

  for i := 1 to 5 do
  begin
    CarEngine.AddCar(-(i div 2)*4, -((i mod 2)*10));
  end;

  mein_cam := TCamera.Create;
  with mein_cam do
  begin
    targ := @CarEngine.main_car.b_pos;
    fov := 90.0;
    pos.y := 5;
    pos.z := -5;
    dist  := 5;
  end;

  hud := THUD.Create;

  LogStr(PChar(#9 + 'SetTimer for WM_TIMER'));
  SetTimer(wnd_game, 1, 10, nil);
  LogStr(PChar(#9 + 'SetTimer for CountFPS'));
  SetTimer(0, 2, 1000, @CountFPS);

  InitializeFont(DC);  {шрифт 1 - Courier New}
  InitializeFont2(DC); {шрифт 2 - Courier New большой и толстый 8)}

  DefaultKeybrd;
  is_key := False;
  cnt_dwn := 3;
end;

function TGame.cwWindow(w,h:integer):HWND;
var
  wc : WNDCLASS;
begin
  with wc do
  begin
    style := 0;
    lpfnWndProc := @WindowProc;
    cbClsExtra := 0;
    cbWndExtra := 0;
    hInstance := 0;
    hIcon := 0;
    hCursor := 0;
    hbrBackground := COLOR_BTNFACE + 1;
    lpszMenuName := Class_name;
    lpszClassName := Class_name;
  end;

  RegisterClass(wc);
  Result := CreateWindow(Class_name,
                         WND_TITLE,
                         WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
                         (GetSystemMetrics(SM_CXSCREEN)-w) div 2,
                         (GetSystemMetrics(SM_CYSCREEN)-h) div 2,
                         w,
                         h,
                         0,
                         0,
                         0,
                         nil);

  ShowCursor(False);

  if Result<>0 then
  begin
    ShowWindow(Result, SW_NORMAL);
    UpdateWindow(Result);
  end;
end;


begin
  InitLog;
  Game := TGame.Create;
  LogStr('Game.Loop');
  Game.Loop;
  Game.Destroy;
  CloseLog;
end.

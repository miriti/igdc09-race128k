//{$DEFINE EN_LOG} //Раскоментировать чтоб писался лог

unit uLog;

interface
{$IFDEF EN_LOG}
uses
  Classes;
{$ENDIF}

type
  tr_log_str = array[0..0] of Char;

{$IFDEF EN_LOG}
var
  Log : TFileStream;
{$ENDIF}

const
  LOG_FILE = 'race_log.txt';

procedure InitLog;
procedure LogStr(s:Pchar; level : integer = 0);
procedure CloseLog;

implementation

uses SysUtils;

procedure LogStr(s:PChar; level : integer=0);
  function _len(p:Pointer):Integer;
  var
    x:Integer;
  begin
    Result := 0;
    x      := 0;
    while true do
    begin
      if tr_log_str(p^)[x]=#0 then break;
      inc(Result);
      inc(x);
    end;
  end;
  function DoLevel:String;
  var
    i:Integer;
  begin
    for i := 0 to level-1 do
      Result := Result + #9;
  end;
const
  el = #10#13;
var
  l:PChar;
begin
  {$IFDEF EN_LOG}
//  s := s + #10#13;
  l := PChar(DateTimeToStr(now()) + ' : ' + DoLevel + s);
  Log.WriteBuffer(l^, _len(l));
  Log.WriteBuffer(el, 2);
  {$ENDIF}
end;

procedure InitLog;
begin
  {$IFDEF EN_LOG}
  Log := TFileStream.Create(LOG_FILE, $FFFF or $0001);
  LogStr('Log activated on ' + LOG_FILE, 0);
  {$ENDIF}
end;

procedure CloseLog;
begin
  {$IFDEF EN_LOG}
  LogStr('Log closed!', 0);
  Log.Free;
  {$ENDIF}
end;

end.

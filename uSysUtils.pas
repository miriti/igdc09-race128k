{
   ак говоритс€
  а сто килабай-то не лишние!
}
unit uSysUtils;

interface

function IntToStr(n:Integer; digs:byte=0):string;
function FloatToStr(f:single):string;
function DoTime(time : Cardinal):string;
function StrPas(Str : PChar):string;

implementation

function StrPas(Str : PChar):String;
begin
  Result := Str;
end;

procedure _tm(var s:string);
var
  i:Integer;
begin
  for i := 1 to length(s)-1 do
  begin
    if s[i] = ' ' then s[i] := '0';
  end;
end;

function DoTime(time : Cardinal):string;
var
  m,s,mm:string;
begin
  s := inttostr(time div 64, 2);
  mm := inttostr(time mod 64, 2);
  m := inttostr((time div 64) div 60, 2);
  s := inttostr((time div 64) mod 60, 2);
{  str((time div 60):2, s);
  _tm(s);
  str((time mod 60):2, mm);
  _tm(mm);}
  Result := m + ':' + s + ':' + mm;
end;

function IntToStr(n:Integer;digs:byte=0):string;
begin
  Str(n:digs, Result);
  _tm(Result);
end;

function FloatToStr(f:single):string;
begin
  Str(f:3:3, Result);
end;

end.

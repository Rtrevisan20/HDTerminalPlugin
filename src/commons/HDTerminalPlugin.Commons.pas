(*
***********************************************************************
  HDTerminalPlugin v0.1.1
***********************
  Por Renato Trevisan
***********************
  Proposta: Como a IDE do delphi ainda não tem um terminal integrado,
  fiz uma implementação simples de um terminal integrado, usando alguns
  recursos externos e internos da IDE.
***********************************************************************
MIT License

Copyright (c) 2024 Renato Trevisan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*)
unit HDTerminalPlugin.Commons;

interface

uses
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Vcl.Forms;

type
  THDTerminalCommons = class
    class procedure RegisterFormClassForTheming(const AFormClass: TCustomFormClass;
                                                const Component : TComponent); static;
    class function FindConsoleByProcessId(AProcessId: DWORD): HWND; static;
  end;

var
  Cs: TCriticalSection;

implementation

uses
  ToolsAPI,
  System.SysUtils;

type
  TEnumData = record
    TargetProcessId: DWORD;
    FoundHandle: HWND;
  end;
  PEnumData = ^TEnumData;

function EnumWindowsProc(AHandle: HWND; AParam: LPARAM): BOOL; stdcall;
var
  Data: PEnumData;
  WindowProcessId: DWORD;
  ClassName: array[0..255] of Char;
begin
  Data := PEnumData(AParam);
  GetWindowThreadProcessId(AHandle, @WindowProcessId);
  if WindowProcessId = Data.TargetProcessId then
  begin
    GetClassName(AHandle, ClassName, 256);
    if ClassName = 'ConsoleWindowClass' then
    begin
      Data.FoundHandle := AHandle;
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

class function THDTerminalCommons.FindConsoleByProcessId(AProcessId: DWORD): HWND;
var
  Data: TEnumData;
begin
  Data.TargetProcessId := AProcessId;
  Data.FoundHandle := 0;
  EnumWindows(@EnumWindowsProc, LPARAM(@Data));
  Result := Data.FoundHandle;
end;


class procedure THDTerminalCommons.RegisterFormClassForTheming(
  const AFormClass: TCustomFormClass;
  const Component: TComponent);
var
 ITS: IOTAIDEThemingServices;
begin
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) then
  begin
    if ITS.IDEThemingEnabled then
    begin
      ITS.RegisterFormClass(AFormClass);
      if Assigned(Component) then
        ITS.ApplyTheme(Component);
    end;
  end;
end;

initialization
  Cs := TCriticalSection.Create;
finalization
  Cs.Free;

end.

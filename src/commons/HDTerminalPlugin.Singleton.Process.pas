(*
***********************************************************************
  HDTerminalPlugin v0.0.1
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
unit HDTerminalPlugin.Singleton.Process;

interface

uses
  HDTerminalTabSheetCustom,
  System.Classes,
  System.Generics.Collections,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Winapi.Windows;

type
  THDProcessPriority = (
      cpDefault,  // use default priority (see Win API docs for details)
      cpHigh,     // use for time-critical tasks: processor intensive
      cpNormal,   // normal process with no specific scheduling needs
      cpIdle,     // run only when system idle
      cpRealTime  // highest possible priority: pre-empts all threads inc. OS
  );

  TPageList     = TObjectDictionary<string, TCustomTabSheet>;
  TListHandle   = TObjectDictionary<string, NativeInt>;
  TListButtons  = TObjectDictionary<string, TObject>;

  TSingletonProcess = class
  private
    FPageList       : TPageList;    // Lista de paginas do controlist
    FListHandle     : TListHandle;  // Lista dos Handles de terminais
    FListButtons    : TListButtons; // Lista de buttons criados
    FIndexComponent : integer;
    FTerminate      : Boolean;
    FProcessInfo    : TProcessInformation;
    FVisible        : Boolean;
    FPriority       : THDProcessPriority;
    FErrorCode      : LongWord;
    FErrorMessage   : string;
    FError          : Boolean;
    FCmmdLine       : string;
    FCurrentDir     : string;
    FControlList    : TWinControl;
    FPageControl    : TWinControl;
    FActivePage     : TTabSheet;
    constructor Create;
    procedure ZeroProcessInfo;
    procedure RecordWin32Error;
    procedure ResetError;

    procedure CloseBtnClick (Sender: TObject);
    procedure KillProcess   (hWindowHandle: HWND);
    procedure ShowAppEmbedded(FWindowHandle: THandle; FContainer: TWinControl);
    function  GetContainer(var AName: string; AHandle: THandle): TTabSheet;
    function  StartProcess(const ACmdLine, ACurrentDir: string; out AProcessInfo: TProcessInformation): Boolean;
    { Class Methods }
    class var FInstance       : TSingletonProcess;
    class function GetInstance: TSingletonProcess; static;
  public
    class property Instance: TSingletonProcess read GetInstance;
    destructor Destroy; override;
    property   PageControl: TWinControl     read FPageControl write FPageControl;
    property   ControlList: TWinControl     read FControlList write FControlList;
    property   CmmdLine: string             read FCmmdLine    write FCmmdLine;
    property   CurrentDir: string           read FCurrentDir  write FCurrentDir;
    property   ActivePage: TTabSheet        read FActivePage  write FActivePage default nil;
    property   Error: Boolean               read FError       write FError      default False;
    property   Visible: Boolean             read FVisible     write FVisible    default False;
    property   Priority: THDProcessPriority read FPriority    write FPriority   default cpDefault;
    procedure  NewProcess;
    procedure  TerminateAllProcess;
    procedure  DoResize(Sender: TObject);
    procedure  SelfShow(Sender: TObject);
    procedure  SetFocusHandle(AHandle: THandle);
  end;

{$REGION 'Constants'}

const
  // Maps Visible property to required windows flags
  cShowFlags: array[Boolean] of integer = (SW_HIDE, SW_SHOWMINIMIZED);

  // Maps Priority property to creation flags
  cPriorityFlags: array[THDProcessPriority] of DWORD =
      (0, HIGH_PRIORITY_CLASS, NORMAL_PRIORITY_CLASS, IDLE_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS);

  xCarExt: array[1..51] of string = (
      '<',
      '>',
      '!',
      '@',
      '#',
      '$',
      '%',
      '¨',
      '&',
      '*',
      '(',
      ')',
      '+',
      '=',
      '{',
      '}',
      '[',
      ']',
      '?',
      ';',
      ':',
      ',',
      '|',
      '*',
      '"',
      '~',
      '^',
      '´',
      '`',
      '¨',
      'æ',
      'Æ',
      'ø',
      '£',
      'Ø',
      'ƒ',
      'ª',
      'º',
      '¿',
      '®',
      '½',
      '¼',
      'ß',
      'µ',
      'þ',
      'ý',
      'Ý',
      '.',
      '/',
      '-',
      ' '
  );

{$ENDREGION}

implementation

uses
  HDTerminalLabel,
  HDTerminalSVGImage,
  FMX.Dialogs,
  HDTerminalPlugin.Commons,
  HDTerminalPlugin.Consts,
  HDTerminalPlugin.Resources.SVG,
  HDTerminalPlugin.Resources.SVG.Consts,
  HDTerminalPlugin.View.Config,
  System.SysUtils,
  Vcl.Buttons,
  Vcl.ControlList,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.Messages;

procedure TSingletonProcess.CloseBtnClick(Sender: TObject);
var
  VCloseBtn : TCustomBtnTab;
begin
  if Sender is TCustomBtnTab then
    VCloseBtn := TCustomBtnTab(Sender) else
    Exit;

  KillProcess(FListHandle.Items[VCloseBtn.Tab.Name]);
  FListHandle.Remove(VCloseBtn.Tab.Name);
  FPageList.Remove(VCloseBtn.Tab.Name);
end;

constructor TSingletonProcess.Create;
begin
  inherited;
  FTerminate := False;
  FPriority := cpDefault;
  FVisible := True;
  FIndexComponent := 0;
end;

destructor TSingletonProcess.Destroy;
begin
  if Assigned(FPageList) then
    FPageList.Free;
  if (Assigned(FListHandle)) and (FListHandle.Count <> 0) then begin
    var ListEnum := FListHandle.GetEnumerator;
    while ListEnum.MoveNext do
      KillProcess(ListEnum.Current.Value);

    ListEnum.Free;
    FListHandle.Free;
  end else
    FListHandle.Free;

  if Assigned(FListButtons) then
    FListButtons.Free;
  inherited;
end;

function TSingletonProcess.GetContainer(var AName: string; AHandle: THandle): TTabSheet;
var
  VPage   : TCustomTabSheet;
begin
  Cs.Enter;
  if not Assigned(FPageList)   then FPageList   := TObjectDictionary<string, TCustomTabSheet>.Create;
  if not Assigned(FListHandle) then FListHandle := TObjectDictionary<string, NativeInt>.Create;

  if FPageList.ContainsKey(AName) then begin
    Inc(FIndexComponent, 1);
    AName := AName + '_' + FIndexComponent.ToString;
  end;

  VPage                   := TCustomTabSheet.Create(TPageControl(FPageControl));
  VPage.PageControl       := TPageControl(FPageControl);
  VPage.Align             := alClient;
  VPage.TabVisible        := True;
  VPage.Name              := AName;
  VPage.Caption           := FIndexComponent.ToString +' - ' +TSingletonSettings.Instance.Caption;
  VPage.AlignWithMargins  := False;
  VPage.Tag               := AHandle;

  TPageControl(FPageControl).ActivePage  := VPage;
  VPage.AfterCaption;
  VPage.OnClickClose := CloseBtnClick;
  FPageList.Add(  AName, VPage);
  FListHandle.Add(AName, AHandle);

  Result := VPage;


  Cs.Leave;
end;

class function TSingletonProcess.GetInstance: TSingletonProcess;
begin
  if not Assigned(FInstance) then
    FInstance := TSingletonProcess.Create;

  Result := FInstance;
end;

procedure TSingletonProcess.KillProcess(hWindowHandle: HWND);
var
  FhprocessID: integer;
  FprocessHandle: THandle;
begin
  SendNotifyMessage(hWindowHandle, WM_CLOSE, 0, 2);
  if isWindow(hWindowHandle) then begin
    { Obter o identificador do processo para a janela }
    GetWindowThreadProcessID(hWindowHandle, @FhprocessID);
    if FhprocessID <> 0 then begin
      { Obtenha o identificador do processo }
      FprocessHandle := OpenProcess(PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION, False, FhprocessID);
      if FprocessHandle <> 0 then begin
        { Encerrar o processo }
        TerminateProcess(FprocessHandle, 0);
        CloseHandle(FprocessHandle);
      end;
    end;
  end;
end;

procedure TSingletonProcess.NewProcess;
var
  VProcessInfo: TProcessInformation;
  VAppState   : DWORD;
  FName       : string;
  FHandle     : integer;
  FIndexFor   : integer;
begin
  FTerminate := False;
  ResetError;
  ZeroProcessInfo;

  if StartProcess(FCmmdLine, FCurrentDir, VProcessInfo) then begin
    try
      Sleep(1200); // Folga de processamento
      FName := ExtractFileName(FCurrentDir);
      for FIndexFor := 1 to 51 do
        FName := StringReplace(FName, xCarExt[FIndexFor], '_', [rfreplaceall]);

      FHandle := FindWindow(CClassConsole, nil);
      ShowAppEmbedded(FHandle, GetContainer(FName, FHandle));

      repeat
        VAppState := WaitForSingleObject(VProcessInfo.hProcess, 50);
        Application.ProcessMessages;
      until (VAppState <> WAIT_TIMEOUT) or FTerminate;

    finally
      if (Assigned(FListHandle)) and (FListHandle.Count <> 0) then
        if FListHandle.ContainsKey(FName) then begin
          KillProcess(FListHandle.Items[FName]);
          FListHandle.Remove(FName);
        end;

      if (Assigned(FPageList)) and (FListHandle.Count <> 0) then
        if (FPageList.ContainsKey(FName)) then begin
          FPageList.Items[FName].Free;
          FPageList.Remove(FName);
        end;
      ZeroProcessInfo;
      CloseHandle(VProcessInfo.hProcess);
      CloseHandle(VProcessInfo.hThread);
    end;
  end
  else begin
    RecordWin32Error;
    ZeroProcessInfo;
  end;
end;

procedure TSingletonProcess.DoResize(Sender: TObject);
begin
  if (Assigned(FListHandle)) and (FListHandle.Count <> 0) then begin
    var ListEnum := FListHandle.GetEnumerator;
    while ListEnum.MoveNext do begin
      var FHandle := ListEnum.Current.Value;
      SetWindowPos(FHandle,0,0,0,
                    TPageControl(PageControl).Width -5,
                    TPageControl(PageControl).Height-5,
                    SWP_NOZORDER);
      SetForegroundWindow(ListEnum.Current.Value);
    end;
    ListEnum.Free;
    Application.ProcessMessages;
  end;
end;

procedure TSingletonProcess.SelfShow(Sender: TObject);
begin
  if ActivePage <> nil then
    TSingletonProcess.Instance.SetFocusHandle(ActivePage.Tag);
end;

procedure TSingletonProcess.RecordWin32Error;
begin
  FError := True;
  FErrorCode := GetLastError;
  FErrorMessage := SysErrorMessage(FErrorCode);
end;

procedure TSingletonProcess.ResetError;
begin
  FError := False;
  FErrorCode := 0;
  FErrorMessage := '';
end;

procedure TSingletonProcess.SetFocusHandle(AHandle: THandle);
begin
  Winapi.Windows.SetFocus(AHandle);
end;

procedure TSingletonProcess.ShowAppEmbedded(FWindowHandle: THandle; FContainer: TWinControl);
var
  WindowStyle: integer;
  FAppThreadID: Cardinal;
begin
  { Defina estilos de janela de aplicativo em execução. }
  WindowStyle := GetWindowLong(FWindowHandle, GWL_STYLE);
  WindowStyle := WindowStyle - WS_CAPTION - WS_BORDER - WS_OVERLAPPED - WS_THICKFRAME;
  SetWindowLong(FWindowHandle, GWL_STYLE, WindowStyle);
  { Anexa o thread de entrada do aplicativo contêiner
    ao thread de entrada do aplicativo em execução, para que
    o aplicativo em execução receba a entrada do usuário. }
  FAppThreadID := GetWindowThreadProcessID(FWindowHandle, nil);
  AttachThreadInput(GetCurrentThreadId, FAppThreadID, True);
  { Alterando o pai do aplicativo em execução
    para nosso controle de contêiner fornecido }
  Winapi.Windows.SetParent(FWindowHandle, FContainer.Handle);
  SendMessage(FContainer.Handle, WM_UPDATEUISTATE, UIS_INITIALIZE, 0);
  UpdateWindow(FWindowHandle);
  { Isso evita que o controle pai
    redesenhe a área de suas janelas filhas
    (o aplicativo em execução) }
  SetWindowLong(FContainer.Handle, GWL_STYLE, GetWindowLong(FContainer.Handle, GWL_STYLE) or WS_CLIPCHILDREN);
  { Faça com que o aplicativo em execução
    preencha toda a área do cliente do contêiner }
  SetWindowPos(FWindowHandle, 0, 0, 0, FContainer.ClientWidth, FContainer.ClientHeight, SWP_NOZORDER);
  SetForegroundWindow(FWindowHandle);
  ShowWindow(FWindowHandle, SW_SHOW);
end;

function TSingletonProcess.StartProcess(
    const ACmdLine, ACurrentDir: string;
    out AProcessInfo: TProcessInformation
): Boolean;
var
  StartInfo: TStartupInfo; // information about process from OS
  CurDir: PChar; // stores current directory
  CreateFlags: DWORD; // creation flags
  SafeCmdLine: string; // stores unique string containing command line
begin
  CurDir := nil;
  SafeCmdLine := ACmdLine;
  UniqueString(SafeCmdLine);
  // Set up startup information structure
  FillChar(StartInfo, Sizeof(StartInfo), #0);
  StartInfo.cb          := Sizeof(StartInfo);
  StartInfo.dwFlags     := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := cShowFlags[FVisible];
  // Set up process info structure
  ZeroProcessInfo;
  // Set creation flags
  CreateFlags := cPriorityFlags[FPriority];
  // Set current directory
  if ACurrentDir <> '' then
    CurDir := PChar(ACurrentDir);
  // Try to create the process
  Result :=
      CreateProcess(
          nil,                // no application name: we use command line instead
          PChar(SafeCmdLine), // command line
          nil,                // security attributes for process
          nil,                // security attributes for thread
          True,               // we inherit inheritable handles from calling process
          CreateFlags,        // creation flags
          nil,                // environment block for new process
          CurDir,             // current directory
          StartInfo,          // informs how new process' window should appear
          AProcessInfo        // receives info about new process
      );
end;

procedure TSingletonProcess.TerminateAllProcess;
begin
  FTerminate := True;
end;

procedure TSingletonProcess.ZeroProcessInfo;
begin
  FillChar(FProcessInfo, Sizeof(FProcessInfo), 0);
end;

end.

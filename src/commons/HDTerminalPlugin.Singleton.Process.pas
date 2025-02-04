unit HDTerminalPlugin.Singleton.Process;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Winapi.Windows;

type
  THDProcessPriority = (
    cpDefault,    // use default priority (see Win API docs for details)
    cpHigh,       // use for time-critical tasks: processor intensive
    cpNormal,     // normal process with no specific scheduling needs
    cpIdle,       // run only when system idle
    cpRealTime    // highest possible priority: pre-empts all threads inc. OS
  );

  TPageList     = TObjectDictionary<string, TTabSheet>;
  TListHandle   = TObjectDictionary<string, NativeInt>;
  TListButtons  = TObjectDictionary<string, TObject>;

  TSingletonProcess = class
  private
    FPageList       : TPageList;    //Lista de paginas do controlist
    FListHandle     : TListHandle;  //Lista dos Handles de terminais
    FListButtons    : TListButtons; //Lista de buttons criados
    FIndexComponent : integer;
    FTerminate      : Boolean;
    FProcessInfo    : TProcessInformation;
    FVisible        : Boolean;
    FPriority       : THDProcessPriority;
    FErrorCode      : LongWord;
    FErrorMessage   : string;
    FError          : boolean;
    FCmmdLine       : string;
    FCurrentDir     : string;
    FControlList    : TWinControl;
    FPageControl    : TWinControl;
    FActivePage     : TTabSheet;
    constructor Create;
    procedure   ZeroProcessInfo;
    procedure   RecordWin32Error;
    procedure   ResetError;

   {$REGION 'Events of the Buttons'}
    procedure ImgDeleteEnter    (Sender: TObject);
    procedure ImgDeleteLeave    (Sender: TObject);
    procedure ImgDeleteClick    (Sender: TObject);
    procedure LabelNameAbaEnter (Sender: TObject);
    procedure LabelNameAbaLeave (Sender: TObject);
    procedure LabelNameAbaClick (Sender: TObject);
   {$ENDREGION}

    procedure KillProcess     (hWindowHandle: HWND);
    procedure NextPage;
    procedure RecalculateHeightControlList;
    procedure ShowAppEmbedded (FWindowHandle: THandle; FContainer: TWinControl);
    function  GetContainer    (var AName: string; AHandle : THandle): TTabSheet;
    procedure CreateButton    (AIndex: integer);
    function  StartProcess    (const ACmdLine, ACurrentDir: string;
                               out AProcessInfo: TProcessInformation): Boolean;

    {Class Methods}
    class var FInstance        : TSingletonProcess;
    class function GetInstance : TSingletonProcess; static;   
  public                       
    class property Instance : TSingletonProcess  read GetInstance;
    destructor Destroy; override;
    property   PageControl  : TWinControl        read FPageControl   write FPageControl;
    property   ControlList  : TWinControl        read FControlList   write FControlList;
    property   CmmdLine     : string             read FCmmdLine      write FCmmdLine;
    property   CurrentDir   : string             read FCurrentDir    write FCurrentDir;
    property   ActivePage   : TTabSheet          read FActivePage    write FActivePage  default nil;
    property   Error        : boolean            read FError         write FError       default False;
    property   Visible      : Boolean            read FVisible       write FVisible     default False;
    property   Priority     : THDProcessPriority read FPriority      write FPriority    default cpDefault;
    procedure  NewProcess;
    procedure  TerminateAllProcess;
    procedure  DoResize      (Sender: TObject);
    procedure  SelfShow        (Sender: TObject);
    procedure  SetFocusHandle(AHandle : THandle);
  end;

{$REGION 'Constants'}

const
  // Maps Visible property to required windows flags
  cShowFlags: array[Boolean] of Integer = (SW_HIDE, SW_SHOWMINIMIZED);

  // Maps Priority property to creation flags
  cPriorityFlags: array[THDProcessPriority] of DWORD =
                       (0, HIGH_PRIORITY_CLASS,
                           NORMAL_PRIORITY_CLASS,
                           IDLE_PRIORITY_CLASS,
                           REALTIME_PRIORITY_CLASS);

  xCarExt: array[1..51] of string =(
                        '<','>','!','@','#','$','%','¨','&','*',
                        '(',')','+','=','{','}','[',']','?',
                        ';',':',',','|','*','"','~','^','´','`',
                        '¨','æ','Æ','ø','£','Ø','ƒ','ª','º','¿',
                        '®','½','¼','ß','µ','þ','ý','Ý','.','/','-',' '
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
  Vcl.ControlList,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.Messages;

constructor TSingletonProcess.Create;
begin
  inherited;
  FTerminate      := False;
  FPriority       := cpDefault;
  FVisible        := True;
  FIndexComponent := 0;
end;

procedure TSingletonProcess.CreateButton(AIndex: integer);
begin
 if not Assigned(FListButtons) then
   FListButtons := TObjectDictionary<string, TObject>.Create;

{$REGION 'VPanelContainer'}
  var VPanelContainer  := TPanel.Create(TPageControl(FPageControl).Pages[AIndex]);
    with VPanelContainer do
     begin
      Name              := CPnContainer + AIndex.ToString;
      Parent            := TControlList(ControlList);
      Align             := alTop;
      Caption           := EmptyStr;
      Height            := 30;
      BevelEdges        := [];
      BevelKind         := bkNone;
      BevelOuter        := bvNone;
      ParentBackground  := True;
      ParentColor       := True;
      Color             := CClSecundary;
      ParentBackground  := False;
      AlignWithMargins  := True;
      Margins.SetBounds(0,0,3,5);
     end;
{$ENDREGION}

  FListButtons.Add(VPanelContainer.Name, VPanelContainer);
  ControlList.Height := ControlList.Height + VPanelContainer.Height + 2;

{$REGION 'VLabelNameAba'}
  var VLabelNameAba := TLabelCustom.Create(VPanelContainer);
    with VLabelNameAba do
     begin
      Margins.SetBounds (1,0,1,0);
      Parent            := VPanelContainer;
      AlignWithMargins  := True;
      Transparent       := True;
      Name              := CLblNameAba + AIndex.ToString;
      Align             := alClient;
      Alignment         := taCenter;
      Layout            := tlCenter;
      Caption           := TSingletonSettings.Instance.Caption;
      Font.Charset      := DEFAULT_CHARSET;
      Font.Color        := clWindowText;
      Font.Height       := -12;
      Font.Size         := 9;
      Font.Name         := 'Segoe UI';
      Font.Style        := [];
      ParentFont        := False;
      Cursor            := crHandPoint;
      AutoSize          := False;
      WordWrap          := True;
      Tag               := AIndex;
      TabName           := TPageControl(FPageControl).Pages[AIndex].Name;
      TabObject         := TPageControl(FPageControl).Pages[AIndex];
      OnClick           := LabelNameAbaClick;
      OnMouseEnter      := LabelNameAbaEnter;
      OnMouseLeave      := LabelNameAbaLeave;
     end;
{$ENDREGION}

{$REGION 'VSvgImageSVG'}
  var VSvgImageSVG := TSVGImageCustom.Create(VPanelContainer);
    with VSvgImageSVG do
     begin
      SVG.LoadFromText(THDTerminalSVG.GetSVG(TSVGTrash));
      SVG.FillColor     := CClDeleteDefault;
      Parent            := VPanelContainer;
      Align             := alRight;
      AlignWithMargins  := True;
      Margins.SetBounds (2,2,2,2);
      Width             := 25;
      Visible           := True;
      Cursor            := crHandPoint;
      Proportional      := True;
      Center            := True;
      Name              := CImgDelete + AIndex.ToString;
      NameParent        := VPanelContainer.Name;
      TabObject         := TPageControl(FPageControl).Pages[AIndex];
      OnClick           := ImgDeleteClick;
      OnMouseEnter      := ImgDeleteEnter;
      OnMouseLeave      := ImgDeleteLeave;
      Repaint;
     end;
{$ENDREGION}

end;

destructor TSingletonProcess.Destroy;
begin
  if Assigned(FPageList) then FPageList.Free;
  if (Assigned(FListHandle)) and (FListHandle.Count <> 0 ) then
   begin
    var ListEnum := FListHandle.GetEnumerator;
     while ListEnum.MoveNext do
      KillProcess(ListEnum.Current.Value);

    ListEnum.Free;
    FListHandle.Free;
   end else FListHandle.Free;

  if Assigned(FListButtons) then FListButtons.Free;
  inherited;
end;

function TSingletonProcess.GetContainer(var AName: string; AHandle: THandle): TTabSheet;
var
  VPage : TTabSheet;
begin
  Cs.Enter;
  if not Assigned(FPageList)    then FPageList    := TObjectDictionary<string, TTabSheet>.Create;
  if not Assigned(FListHandle)  then FListHandle  := TObjectDictionary<string, NativeInt>.Create;

  if FPageList.ContainsKey(AName) then
   begin
    Inc(FIndexComponent, 1);
    AName := AName + '_' + FIndexComponent.ToString;
   end;

  VPage                   := TTabSheet.Create(TPageControl(FPageControl));
  VPage.PageControl       := TPageControl(FPageControl);
  VPage.Align             := alClient;
  VPage.TabVisible        := False;
  VPage.Name              := AName;
  VPage.Caption           := TSingletonSettings.Instance.Caption;
  VPage.AlignWithMargins  := False;
  VPage.Tag               := AHandle;

  TPageControl(FPageControl).ActivePage  := VPage;
  ActivePage := VPage;
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
  FhprocessID    : INTEGER;
  FprocessHandle : THandle;
begin
  SendNotifyMessage(hWindowHandle,WM_CLOSE,0,2);
  if isWindow(hWindowHandle) then
   begin
    { Obter o identificador do processo para a janela }
    GetWindowThreadProcessID(hWindowHandle, @FhprocessID);
    if FhprocessID <> 0 then
     begin
      { Obtenha o identificador do processo }
      FprocessHandle := OpenProcess(PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION,
        False, FhprocessID);
      if FprocessHandle <> 0 then
       begin
        { Encerrar o processo }
        TerminateProcess(FprocessHandle, 0);
        CloseHandle(FprocessHandle);
       end;
     end;
   end;
end;

procedure TSingletonProcess.NewProcess;
var
  VProcessInfo    : TProcessInformation;
  VAppState       : DWORD;
  FName           : string;
  FHandle         : integer;
  FIndexFor       : integer;
begin
  FTerminate := False;
  ResetError;
  ZeroProcessInfo;

  if StartProcess(FCmmdLine, FCurrentDir, VProcessInfo) then
    begin
     try
      Sleep(1500); // Folga de processamento
      //xCarExt
      FName := ExtractFileName(FCurrentDir);
      for FIndexFor:= 1 to 51 do
        FName := StringReplace(FName, xCarExt[FIndexFor], '_', [rfreplaceall]);

      FHandle   := FindWindow(CClassConsole, nil);
      ShowAppEmbedded(FHandle, GetContainer(FName, FHandle));

      repeat
       VAppState := WaitForSingleObject(VProcessInfo.hProcess, 50);
       Application.ProcessMessages;
      until (VAppState <> WAIT_TIMEOUT) or FTerminate;

     finally
      if (Assigned(FListHandle)) and (FListHandle.Count <> 0) then
       if FListHandle.ContainsKey(FName) then
        begin
         KillProcess(FListHandle.Items[FName]);
         FListHandle.Remove(FName);
        end;

      if (Assigned(FPageList)) and (FListHandle.Count <> 0) then
       if (FPageList.ContainsKey(FName)) then
        begin
          FPageList.Items[FName].Free;
          FPageList.Remove(FName);
        end;
      ZeroProcessInfo;
      CloseHandle(VProcessInfo.hProcess);
      CloseHandle(VProcessInfo.hThread);
     end;
    end
  else
    begin
     RecordWin32Error;
     ZeroProcessInfo;
    end;
end;

procedure TSingletonProcess.NextPage;
begin
  if TPageControl(FPageControl).PageCount <> 0 then
   begin
    for var FIndexFor := 0 to Pred(TPageControl(FPageControl).PageCount) do
     begin
      TPageControl(FPageControl).ActivePageIndex := FIndexFor;
      ActivePage := TPageControl(FPageControl).ActivePage;
      Exit;
     end;
   end else ActivePage := nil;
end;

procedure TSingletonProcess.DoResize(Sender: TObject);
begin
  if (Assigned(FListHandle)) and (FListHandle.Count <> 0) then
   begin
    var ListEnum := FListHandle.GetEnumerator;
    while ListEnum.MoveNext do
     begin
      var FHandle  := ListEnum.Current.Value;
      SetWindowPos(FHandle,0,0,0,
                 PageControl.ClientWidth,
                 PageControl.ClientHeight,
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
  begin
   TSingletonProcess.Instance.SetFocusHandle(ActivePage.Tag);
   ShowMessage('TDockFormSingleton.DoShow ' + ActivePage.Name);
  end;
end;

procedure TSingletonProcess.RecalculateHeightControlList;
var
  VControlList  : TControlList;
  VIndex        : Integer;
  VHeight       : Integer;
begin
  VHeight := 0;
  VControlList :=  TControlList(ControlList);
  for VIndex := 0 to Pred(VControlList.ControlCount) do
   begin
    VHeight := VHeight + VControlList.Controls[VIndex].Height;
   end;
  VControlList.Height := VHeight;
end;

procedure TSingletonProcess.RecordWin32Error;
begin
  FError        := True;
  FErrorCode    := GetLastError;
  FErrorMessage := SysErrorMessage(fErrorCode);
end;

procedure TSingletonProcess.ResetError;
begin
  FError        := False;
  FErrorCode    := 0;
  FErrorMessage := '';
end;

procedure TSingletonProcess.SetFocusHandle(AHandle: THandle);
begin
  Winapi.Windows.SetFocus(AHandle);
//  SetForegroundWindow(AHandle);
end;

procedure TSingletonProcess.ShowAppEmbedded(FWindowHandle: THandle; FContainer: TWinControl);
var
  WindowStyle   : Integer;
  FAppThreadID  : Cardinal;
begin
  {Defina estilos de janela de aplicativo em execução.}
  WindowStyle := GetWindowLong(FWindowHandle, GWL_STYLE);
  WindowStyle := WindowStyle
                 - WS_CAPTION
                 - WS_BORDER
                 - WS_OVERLAPPED
                 - WS_THICKFRAME;
  SetWindowLong(FWindowHandle,GWL_STYLE,WindowStyle);
  {Anexe o thread de entrada do aplicativo contêiner
   ao thread de entrada do aplicativo em execução, para que
   o aplicativo em execução receba a entrada do usuário.}
  FAppThreadID := GetWindowThreadProcessId(FWindowHandle, nil);
  AttachThreadInput(GetCurrentThreadId, FAppThreadID, True);
  {Alterando o pai do aplicativo em execução
   para nosso controle de contêiner fornecido}
  Winapi.Windows.SetParent(FWindowHandle, FContainer.Handle);
  SendMessage(FContainer.Handle, WM_UPDATEUISTATE, UIS_INITIALIZE, 0);
  UpdateWindow(FWindowHandle);
  {Isso evita que o controle pai
   redesenhe a área de suas janelas filhas
   (o aplicativo em execução)}
  SetWindowLong(FContainer.Handle, GWL_STYLE,
                GetWindowLong(FContainer.Handle, GWL_STYLE) or WS_CLIPCHILDREN);
  {Faça com que o aplicativo em execução
   preencha toda a área do cliente do contêiner}
  SetWindowPos(FWindowHandle,0,0,0,
               FContainer.ClientWidth,
               FContainer.ClientHeight, SWP_NOZORDER);
  SetForegroundWindow(FWindowHandle);

  CreateButton(TTabSheet(FContainer).PageIndex);
  ShowWindow(FWindowHandle, SW_SHOW);
end;

function TSingletonProcess.StartProcess(
          const ACmdLine, ACurrentDir: string;
          out AProcessInfo: TProcessInformation): Boolean;
var
  StartInfo   : TStartupInfo;  // information about process from OS
  CurDir      : PChar;         // stores current directory
  CreateFlags : DWORD;         // creation flags
  SafeCmdLine : string;        // stores unique string containing command line
begin
  CurDir      := nil;
  SafeCmdLine := ACmdLine;
  UniqueString(SafeCmdLine);
  // Set up startup information structure
  FillChar(StartInfo, Sizeof(StartInfo), #0);
  StartInfo.cb              := SizeOf(StartInfo);
  StartInfo.dwFlags         := STARTF_USESHOWWINDOW or STARTF_USEFILLATTRIBUTE;
  StartInfo.wShowWindow     := cShowFlags[FVisible];
  StartInfo.dwFillAttribute := DWORD(014);
  // Set up process info structure
  ZeroProcessInfo;
  // Set creation flags
  CreateFlags := cPriorityFlags[FPriority];
  // Set current directory
  if ACurrentDir <> '' then CurDir := PChar(ACurrentDir);
  // Try to create the process
  Result := CreateProcess(
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
  FillChar(FProcessInfo, SizeOf(FProcessInfo), 0);
end;

{$REGION 'Events of the Buttons'}
procedure TSingletonProcess.ImgDeleteClick(Sender: TObject);
begin
  var FImage      := (Sender as TSVGImageCustom);
  var FNameParent := FImage.NameParent;
  var VPage       := TTabSheet(FImage.TabObject);

  TPanel(FListButtons.Items[FNameParent]).Free;
  FListButtons.Remove(FNameParent);

  {Termino o processo do teminal, e limpo o handle da lista}
  KillProcess(FListHandle.Items[VPage.name]);
  FListHandle.Remove(VPage.name);

  {Removo a pagina da lista, e limpo da memória}
  FPageList.Remove(VPage.name);
  VPage.Free;
  RecalculateHeightControlList;
  NextPage;
  ActivePage := nil;
end;

procedure TSingletonProcess.ImgDeleteEnter(Sender: TObject);
begin
  if Sender is TSVGImageCustom then
   begin
    (Sender as TSVGImageCustom).SVG.FillColor := CClDeleteSecundary;
    (Sender as TSVGImageCustom).Repaint;
   end;
end;

procedure TSingletonProcess.ImgDeleteLeave(Sender: TObject);
begin
  if Sender is TSVGImageCustom then
   begin
    (Sender as TSVGImageCustom).SVG.FillColor := CClDeleteDefault;//clBlack;
    (Sender as TSVGImageCustom).Repaint;
   end;
end;

procedure TSingletonProcess.LabelNameAbaClick(Sender: TObject);
var
  VLabel : TLabelCustom;
begin
  if Sender is TLabelCustom then
   begin
    VLabel                      := (Sender as TLabelCustom);
    VLabel.Font.Style           := [fsUnderline];
    TPageControl(FPageControl).ActivePage      := TTabSheet(VLabel.TabObject);
   end;
end;

procedure TSingletonProcess.LabelNameAbaEnter(Sender: TObject);
var
  VLabel : TLabelCustom;
begin
  if Sender is TLabel then
   begin
    VLabel                      := (Sender as TLabelCustom);
    VLabel.Font.Style           := [fsUnderline];
    TPanel(VLabel.Parent).Color := CClSecundary;
   end;
end;

procedure TSingletonProcess.LabelNameAbaLeave(Sender: TObject);
var
  VLabel : TLabelCustom;
begin
  if Sender is TLabel then
   begin
    VLabel                      := (Sender as TLabelCustom);
    VLabel.Font.Style           := [];
    TPanel(VLabel.Parent).Color := CClDefault;
   end;
end;

{$ENDREGION}

end.

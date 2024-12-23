unit HDTerminalPlugin.View.Main.Frame;

interface

uses
  ToolsAPI,
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  System.Variants,
  Vcl.ComCtrls,
  Vcl.ControlList,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Winapi.Messages,
  Winapi.Windows;

type
  TMainFrame = class(TFrame)
    pnlButtons    : TPanel;
    pnTerminal    : TPanel;
    PageControl   : TPageControl;
    pnMenuLateral : TPanel;
    ScrollBox     : TScrollBox;
    ControlList   : TControlList;
    Splitter: TSplitter;
    pnlConsole: TPanel;
    procedure FrameResize(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
  private
    procedure MouseEnterMenu    (Sender: TObject);
    procedure MouseLeaveMenu    (Sender: TObject);
    procedure ConfigClick       (Sender: TObject);
    procedure NewConsoleClick   (Sender: TObject);
    procedure CreateButtonConfig;
    procedure CreateButtonNewConsole;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  HDTerminalLabel,
  HDTerminalSVGImage,
  HDTerminalPlugin.Commons,
  HDTerminalPlugin.Consts,
  HDTerminalPlugin.Resources.SVG,
  HDTerminalPlugin.Singleton.Process,
  HDTerminalPlugin.View.Config,
  System.IOUtils,
  System.TypInfo;

{$R *.dfm}

{$REGION 'TMainFrame'}

procedure TMainFrame.CreateButtonConfig;
begin
  var VPanelContainer  := TPanel.Create(pnlButtons);
    with VPanelContainer do
     begin
      Parent            := pnlButtons;
      Align             := alRight;
      Caption           := EmptyStr;
      Width             := 25;
      BevelEdges        := [];
      BevelKind         := bkNone;
      BevelOuter        := bvNone;
      ParentBackground  := True;
      ParentColor       := True;
      AlignWithMargins  := True;
      Margins.SetBounds (0,2,15,0);
     end;

  var imgConfig := TSVGImageCustom.Create(VPanelContainer);
    with imgConfig do
     begin
      SVG.LoadFromText  (THDTerminalSVG.GetSVG(TSVGConfig));
      SVG.FillColor     := CColorMenuLeave;
      Parent            := VPanelContainer;
      Align             := alClient;
      Width             := 25;
      Visible           := True;
      Cursor            := crHandPoint;
      Proportional      := True;
      Center            := True;
      AlignWithMargins  := False;
      OnMouseEnter      := MouseEnterMenu;
      OnMouseLeave      := MouseLeaveMenu;
      OnClick           := ConfigClick;
      ParentBackground  := True;
      ParentColor       := True;
      Margins.SetBounds (1,1,1,1);
      Repaint;
     end;
end;

procedure TMainFrame.CreateButtonNewConsole;
begin
  var VPanelContainer  := TPanel.Create(pnlButtons);
    with VPanelContainer do
     begin
      Parent            := pnlButtons;
      Align             := alRight;
      Caption           := EmptyStr;
      Width             := 25;
      BevelEdges        := [];
      BevelKind         := bkNone;
      BevelOuter        := bvNone;
      ParentBackground  := True;
      AlignWithMargins  := True;
      ParentColor       := True;
      Margins.SetBounds (0,2,10,0);
     end;

  var imgConfig := TSVGImageCustom.Create(VPanelContainer);
    with imgConfig do
     begin
      SVG.LoadFromText  (THDTerminalSVG.GetSVG(TSvgNewConsole));
      SVG.FillColor     := CColorMenuLeave;
      Parent            := VPanelContainer;
      Align             := alRight;
      Width             := 25;
      Visible           := True;
      Cursor            := crHandPoint;
      Proportional      := True;
      Center            := True;
      AlignWithMargins  := False;
      ParentBackground  := True;
      ParentColor       := True;
      OnMouseEnter      := MouseEnterMenu;
      OnMouseLeave      := MouseLeaveMenu;
      OnClick           := NewConsoleClick;
      Margins.SetBounds (1,1,1,1);
      Repaint;
     end;
end;

procedure TMainFrame.FrameResize(Sender: TObject);
begin
  TSingletonProcess.Instance.DoResize(Sender);
end;

procedure TMainFrame.MouseEnterMenu(Sender: TObject);
begin
  if Sender is TSVGImageCustom then
   begin
    (Sender as TSVGImageCustom).SVG.FillColor := CColorMenuEnter;
    (Sender as TSVGImageCustom).Repaint;
   end;
end;

procedure TMainFrame.MouseLeaveMenu(Sender: TObject);
begin
  if Sender is TSVGImageCustom then
   begin
    (Sender as TSVGImageCustom).SVG.FillColor := CColorMenuLeave;
    (Sender as TSVGImageCustom).Repaint;
   end;
end;

procedure TMainFrame.NewConsoleClick(Sender: TObject);
var
  VModuleServices: IOTAModuleServices;
  VDiretorio     : string;
begin
  VModuleServices := (BorlandIDEServices as IOTAModuleServices);
  if Assigned(VModuleServices.CurrentModule) then
   VDiretorio := ExtractFileDir(VModuleServices.CurrentModule.FileName) else
   VDiretorio := TSingletonSettings.Instance.PathDefault;

  TSingletonProcess.Instance.Visible      := False;
  TSingletonProcess.Instance.Priority     := cpDefault;
  TSingletonProcess.Instance.CmmdLine     := TSingletonSettings.Instance.ConsolePath;
  TSingletonProcess.Instance.CurrentDir   := VDiretorio;
  TSingletonProcess.Instance.PageControl  := PageControl;
  TSingletonProcess.Instance.ControlList  := ControlList;
  TSingletonProcess.Instance.NewProcess;
end;

procedure TMainFrame.SplitterMoved(Sender: TObject);
begin
  TSingletonProcess.Instance.DoResize(Sender);
  PageControl.Repaint;
end;

constructor TMainFrame.Create(AOwner: TComponent);
begin
  inherited;
  ControlList.ParentColor := True;
  CreateButtonNewConsole;
  CreateButtonConfig;
end;

procedure TMainFrame.ConfigClick(Sender: TObject);
var
  ViewSettings: TViewSettings;
begin
  ViewSettings := TViewSettings.Create(nil);
  try
    //Aplica tema da IDE
    THDTerminalCommons.RegisterFormClassForTheming(TViewSettings, ViewSettings);
    ViewSettings.Position := poMainFormCenter;
    ViewSettings.ShowModal;
  finally
    ViewSettings.Free;
  end;
end;

{$ENDREGION}

end.

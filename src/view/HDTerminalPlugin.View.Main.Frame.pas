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
  Winapi.Windows, System.ImageList, Vcl.ImgList;

type
  TMainFrame = class(TFrame)
    pnlButtons    : TPanel;
    pnTerminal    : TPanel;
    PageControl   : TPageControl;
    pnlConsole    : TPanel;
    pnLineSup     : TPanel;
    procedure FrameResize(Sender: TObject);
  private
    procedure MouseEnterMenu(Sender: TObject);
    procedure MouseLeaveMenu(Sender: TObject);
    procedure ConfigClick(Sender: TObject);
    procedure NewConsoleClick(Sender: TObject);
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
  var VPanelContainer := TPanel.Create(pnlButtons);
    with VPanelContainer do begin
      Parent            := pnlButtons;
      Align             := alRight;
      Caption           := EmptyStr;
      Width             := 30;
      BevelEdges        := [];
      BevelKind         := bkNone;
      BevelOuter        := bvNone;
      ParentBackground  := True;
      ParentColor       := True;
      AlignWithMargins  := True;
      Margins.SetBounds(0, 0, 15, 0);
    end;

  var imgConfig := TSVGImageCustom.Create(VPanelContainer);
    with imgConfig do begin
      SVG.LoadFromText(THDTerminalSVG.GetSVG(TSVGConfig));
      SVG.FillColor     := CColorMenuLeave;
      Parent            := VPanelContainer;
      Align             := alClient;
      Width             := 30;
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
      Margins.SetBounds(1, 1, 1, 1);
      Repaint;
    end;

end;

procedure TMainFrame.CreateButtonNewConsole;
begin
  var VPanelContainer := TPanel.Create(pnlButtons);
    with VPanelContainer do begin
      Parent            := pnlButtons;
      Align             := alLeft;
      Caption           := EmptyStr;
      Width             := 30;
      BevelEdges        := [];
      BevelKind         := bkNone;
      BevelOuter        := bvNone;
      ParentBackground  := True;
      AlignWithMargins  := True;
      ParentColor       := True;
      Margins.SetBounds(15, 0, 0, 0);
    end;

  var imgConfig := TSVGImageCustom.Create(VPanelContainer);
    with imgConfig do begin
      SVG.LoadFromText(THDTerminalSVG.GetSVG(TSvgNewConsole));
      SVG.FillColor     := CColorMenuLeave;
      Parent            := VPanelContainer;
      Align             := alClient;
      Width             := 30;
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
      Margins.SetBounds(1, 1, 1, 1);
      Repaint;
    end;
end;

procedure TMainFrame.FrameResize(Sender: TObject);
begin
  Cs.Enter;
  TSingletonProcess.Instance.DoResize(Sender);
  Cs.Leave;
end;

procedure TMainFrame.MouseEnterMenu(Sender: TObject);
begin
  if Sender is TSVGImageCustom then begin
    (Sender as TSVGImageCustom).SVG.FillColor := CColorMenuEnter;
    (Sender as TSVGImageCustom).Repaint;
  end;
end;

procedure TMainFrame.MouseLeaveMenu(Sender: TObject);
begin
  if Sender is TSVGImageCustom then begin
    (Sender as TSVGImageCustom).SVG.FillColor := CColorMenuLeave;
    (Sender as TSVGImageCustom).Repaint;
  end;
end;

procedure TMainFrame.NewConsoleClick(Sender: TObject);
var
  VModuleServices: IOTAModuleServices;
  VDiretorio: string;
  VProject: IOTAProject;
begin
  Cs.Enter;

  {Capturo o caminho do projeto atual...}
  VModuleServices := (BorlandIDEServices as IOTAModuleServices);
  if Assigned(VModuleServices.CurrentModule) then begin
    VProject := VModuleServices.GetActiveProject;
    VDiretorio := ExtractFileDir(VProject.FileName);
  end else
    VDiretorio := TSingletonSettings.Instance.PathDefault;

  TSingletonProcess.Instance.Visible      := False;
  TSingletonProcess.Instance.Priority     := cpDefault;
  TSingletonProcess.Instance.CmmdLine     := TSingletonSettings.Instance.ConsolePath;
  TSingletonProcess.Instance.CurrentDir   := Pchar(VDiretorio);
  TSingletonProcess.Instance.PageControl  := PageControl;
  TSingletonProcess.Instance.NewProcess;
  Cs.Leave;
end;

constructor TMainFrame.Create(AOwner: TComponent);
begin
  inherited;
  CreateButtonConfig;
  CreateButtonNewConsole;
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

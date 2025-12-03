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
unit HDTerminalTabSheetCustom;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.StdCtrls;

Type
  TCustomTabSheet = class;

  TCustomBtnTab = class(TSpeedButton)
  private
    FTab: TCustomTabSheet;
    procedure SetTab(const Value: TCustomTabSheet);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; Override;
    property Tab: TCustomTabSheet read FTab write SetTab;
  end;

  TCustomTabSheet = class(TTabSheet)
  private
    FCloseBtn     : TCustomBtnTab;
    FOnClickClose : TNotifyEvent;
    procedure SetupInternalBtn;
    procedure SetBtnPosition;
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure DoShow; override;
    procedure DoHide; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AfterCaption;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    property OnClickClose: TNotifyEvent read FOnClickClose write FOnClickClose;
  end;

implementation

uses
  Vcl.Graphics,
  HDTerminalSVGImage;

{$Region 'TCustumBtnTab'}
procedure TCustomBtnTab.Click;
begin
  inherited;
  if Assigned(FTab) then
    begin
      FTab.OnClickClose(Self);
      FTab.Destroy;
    end;
end;

constructor TCustomBtnTab.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TCustomBtnTab.SetTab(const Value: TCustomTabSheet);
begin
  FTab := Value;
end;
{$ENDRegion}

{$Region 'TCustomTabSheet'}
procedure TCustomTabSheet.AfterCaption;
begin
  if Length(Caption) > 0 then
   Caption := Caption + '      ';
   SetBtnPosition;
end;

constructor TCustomTabSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetupInternalBtn;
end;

procedure TCustomTabSheet.DoHide;
begin
  inherited;
end;

procedure TCustomTabSheet.DoShow;
begin
  inherited;
end;

procedure TCustomTabSheet.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FCloseBtn) and (Operation = opRemove) then
    FCloseBtn := nil;
end;

procedure TCustomTabSheet.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  SetBtnPosition;
end;

procedure TCustomTabSheet.SetBtnPosition;
var
  VRec : TRect;
begin
  if not Assigned(PageControl) then Exit;
  VRec := Self.PageControl.TabRect(Self.PageIndex);
  FCloseBtn.SetBounds(VRec.Right - FCloseBtn.Width - 1, VRec.Top, FCloseBtn.Width, FCloseBtn.Height);
end;

procedure TCustomTabSheet.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);;
  if FCloseBtn = nil then Exit;
  FCloseBtn.Parent := AParent;
  FCloseBtn.Visible := True;
end;

procedure TCustomTabSheet.SetupInternalBtn;
begin
  if Assigned(FCloseBtn) then exit;
  FCloseBtn := TCustomBtnTab.Create(Self);
  with FCloseBtn do
   begin
      FreeNotification(Self);
      Caption     := 'X';
      Height      := 19;
      Width       := 20;
      Flat        := True;
      Tab         := Self;
      Font.Name   := 'JetBrains Mono Medium';//'Sego  e UI Semibold';
      Font.Height := -12;
      Font.Size   := 9;
      Margin      := 6;
   end;
end;
{$ENDRegion}

end.

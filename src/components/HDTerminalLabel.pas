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
unit HDTerminalLabel;

interface

uses
  Vcl.StdCtrls,
  System.Classes;

type
  TLabelCustom = class(TLabel)
  strict private
    FTabName  : string;
    FTabObject: TObject;
    FPanelObject: TObject;
    procedure SetTabName    (const Value: string);
    procedure SetTabObject  (const Value: TObject);
    procedure SetPanelObject(const Value: TObject);
  public
    destructor  Destroy; override;
    constructor Create(AOwner: TComponent); override;
  published
    property TabName      : string    read FTabName     write SetTabName;
    property TabObject    : TObject   read FTabObject   write SetTabObject;
    property PanelObject  : TObject   read FPanelObject write SetPanelObject;
    property OnClick;
    property OnDblClick;
    property OnMouseEnter;
  end;

implementation

constructor TLabelCustom.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TLabelCustom.Destroy;
begin
  inherited;
end;

procedure TLabelCustom.SetPanelObject(const Value: TObject);
begin
  FPanelObject := Value;
end;

procedure TLabelCustom.SetTabName(const Value: string);
begin
  FTabName := Value;
end;

procedure TLabelCustom.SetTabObject(const Value: TObject);
begin
  FTabObject := Value;
end;

end.

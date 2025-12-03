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
Créditos:
  SVG Image in TPicture
  home page: http://www.mwcs.de
  email    : martin.walter@mwcs.de
***********************************

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
unit HDTerminalSVGImage;

interface

uses
  SVG,
  System.Classes,
  Vcl.Controls,
  System.SysUtils;

type
{$REGION 'Class TSVGImage'}
  TSVGImageCustom = class(TGraphicControl)
  strict private
    FSVGImage     : TSVG;
    FStream       : TMemoryStream;
    FCenter       : Boolean;
    FProportional : Boolean;
    FStretch      : Boolean;
    FAutoSize     : Boolean;
    FScale        : Double;
    FOpacity      : Byte;
    FFileName     : TFileName;
    FImageIndex   : Integer;
    FNameParent   : string;
    procedure SetCenter       (Value  : Boolean);
    procedure SetProportional (Value  : Boolean);
    procedure SetOpacity      (Value  : Byte);
    procedure ReadData        (Stream : TStream);
    procedure WriteData       (Stream : TStream);
    procedure SetFileName     (const Value: TFileName);
    procedure SetImageIndex   (const Value: Integer);
    procedure SetStretch      (const Value: Boolean);
    procedure SetScale        (const Value: Double);
    procedure SetAutoSizeImage(const Value: Boolean);
    procedure SetNameParent   (const Value: string);
  private
    FTabObject: TObject;
    procedure SetTabObject(const Value: TObject);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure CheckAutoSize;
  public
    destructor  Destroy; override;
    constructor Create        (AOwner: TComponent); override;
    procedure   LoadFromFile  (const FileName: string);
    procedure   LoadFromStream(Stream: TStream);
    procedure   Assign        (Source: TPersistent); override;
    procedure   Clear;
    function    Empty: Boolean;
    procedure   Paint; override;
    property    SVG: TSVG read FSVGImage;
  published
    property AutoSize     : Boolean   read FAutoSize      write SetAutoSizeImage;
    property Center       : Boolean   read FCenter        write SetCenter;
    property Proportional : Boolean   read FProportional  write SetProportional;
    property Stretch      : Boolean   read FStretch       write SetStretch;
    property Opacity      : Byte      read FOpacity       write SetOpacity;
    property Scale        : Double    read FScale         write SetScale;
    property FileName     : TFileName read FFileName      write SetFileName;
    property ImageIndex   : Integer   read FImageIndex    write SetImageIndex;
    property NameParent   : string    read FNameParent    write SetNameParent;
    property TabObject    : TObject   read FTabObject     write SetTabObject;
    property Enabled;
    property Visible;
    property Constraints;
    property Anchors;
    property Align;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseUp;
{$ENDREGION}
  end;

implementation

uses
  Winapi.GDIPAPI,
  Vcl.Graphics;

{$REGION 'TSVGImage Implement'}

procedure TSVGImageCustom.Assign(Source: TPersistent);
var
  SVG: TSVG;
begin
  if (Source is TSVGImageCustom) then
   begin
    SVG := (Source as TSVGImageCustom).FSVGImage;
    FSVGImage.LoadFromText(SVG.Source);
    FImageIndex := -1;
    CheckAutoSize;
   end;

  if (Source.ClassType = TSVG) then
   begin
    SVG := TSVG(Source);
    FSVGImage.LoadFromText(SVG.Source);
    FImageIndex := -1;
   end;
  Repaint;
end;

procedure TSVGImageCustom.CheckAutoSize;
begin
  if FAutoSize and (FSVGImage.Width > 0) and (FSVGImage.Height > 0) then
  begin
    SetBounds(Left, Top,  Round(FSVGImage.Width), Round(FSVGImage.Height));
  end;
end;

procedure TSVGImageCustom.Clear;
begin
  FSVGImage.Clear;
  FFileName := '';
  Repaint;
end;

constructor TSVGImageCustom.Create(AOwner: TComponent);
begin
  inherited;
  FSVGImage     := TSVG.Create;
  FProportional := False;
  FCenter       := True;
  FStretch      := True;
  FOpacity      := 255;
  FScale        := 1;
  FImageIndex   := -1;
  FStream       := TMemoryStream.Create;
end;

procedure TSVGImageCustom.DefineProperties(Filer: TFiler);
begin
  Filer.DefineBinaryProperty('Data', ReadData, WriteData, True);
end;

destructor TSVGImageCustom.Destroy;
begin
  FSVGImage.Free;
  FStream.Free;
  inherited;
end;

function TSVGImageCustom.Empty: Boolean;
begin
  Empty := FSVGImage.Count = 0;
end;

procedure TSVGImageCustom.LoadFromFile(const FileName: string);
begin
  if csLoading in ComponentState then
    Exit;
  try
    FStream.Clear;
    FStream.LoadFromFile(FileName);
    FSVGImage.LoadFromStream(FStream);
    FFileName := FileName;
  except
    Clear;
  end;
  CheckAutoSize;
  Repaint;
end;

procedure TSVGImageCustom.LoadFromStream(Stream: TStream);
begin
  try
    FFileName := '';
    FStream.Clear;
    FStream.LoadFromStream(Stream);
    FSVGImage.LoadFromStream(FStream);
  except
  end;
  CheckAutoSize;
  Repaint;
end;

procedure TSVGImageCustom.Paint;
var
  Bounds: TGPRectF;
  SVG   : TSVG;

{$REGION 'procedure CalcWidth'}
 procedure CalcWidth(const ImageWidth, ImageHeight: Double);
  var R: Double;
  begin
    Bounds.Width := ImageWidth * FScale;
    Bounds.Height := ImageHeight * FScale;

    if FProportional then
    begin
      if ImageHeight > 0 then
        R :=  ImageWidth / ImageHeight
      else
        R := 1;

      if Width / Height > R then
      begin
        Bounds.Width := Height * R;
        Bounds.Height := Height;
      end else
      begin
        Bounds.Width := Width;
        Bounds.Height := Width / R;
      end;
      Exit;
    end;

    if FStretch then
    begin
      Bounds := MakeRect(0.0, 0, Width, Height);
      Exit;
    end;
  end;
{$ENDREGION}

{$REGION 'procedure CalcOffset'}
 procedure CalcOffset;
  begin
    Bounds.X := 0;
    Bounds.Y := 0;
    if FCenter then
    begin
      Bounds.X := (Width - Bounds.Width) / 2;
      Bounds.Y := (Height - Bounds.Height) / 2;
    end;
  end;
{$ENDREGION}
begin
  SVG := FSVGImage;
  if SVG.Count > 0 then
   begin
    CalcWidth(SVG.Width, SVG.Height);
    CalcOffset;

    SVG.SVGOpacity := FOpacity / 255;
    SVG.PaintTo(Canvas.Handle, Bounds, nil, 0);
    SVG.SVGOpacity := 1;
   end;

  if csDesigning in ComponentState then
   begin
    Canvas.Brush.Style  := bsClear;
    Canvas.Pen.Style    := psDash;
    Canvas.Pen.Color    := clBlack;
    Canvas.Rectangle(0, 0, Width, Height);
   end;
end;

procedure TSVGImageCustom.ReadData(Stream: TStream);
var
  Size: LongInt;
begin
  Stream.Read(Size, SizeOf(Size));
  FStream.Clear;
  if Size > 0 then
  begin
    FStream.CopyFrom(Stream, Size);
    FSVGImage.LoadFromStream(FStream);
  end else
    FSVGImage.Clear;
end;

procedure TSVGImageCustom.SetAutoSizeImage(const Value: Boolean);
begin
  if (Value = FAutoSize) then
    Exit;
  FAutoSize := Value;

  CheckAutoSize;
end;

procedure TSVGImageCustom.SetCenter(Value: Boolean);
begin
  if Value = FCenter then
    Exit;

  FCenter := Value;
  Repaint;
end;

procedure TSVGImageCustom.SetFileName(const Value: TFileName);
begin
  if Value = FFileName then
    Exit;

  LoadFromFile(Value);
end;

procedure TSVGImageCustom.SetImageIndex(const Value: Integer);
begin
  if FImageIndex = Value then
    Exit;
  FImageIndex := Value;
  CheckAutoSize;
  Repaint;
end;

procedure TSVGImageCustom.SetNameParent(const Value: string);
begin
  FNameParent := Value;
end;

procedure TSVGImageCustom.SetOpacity(Value: Byte);
begin
  if Value = FOpacity then
    Exit;

  FOpacity := Value;
  Repaint;
end;

procedure TSVGImageCustom.SetProportional(Value: Boolean);
begin
  if Value = FProportional then
    Exit;

  FProportional := Value;
  Repaint;
end;

procedure TSVGImageCustom.SetScale(const Value: Double);
begin
  if Value = FScale then
    Exit;
  FScale := Value;
  FAutoSize := False;
  Repaint;
end;

procedure TSVGImageCustom.SetStretch(const Value: Boolean);
begin
  if Value = FStretch then
    Exit;

  FStretch := Value;
  if FStretch then
    FAutoSize := False;
  Repaint
end;

procedure TSVGImageCustom.SetTabObject(const Value: TObject);
begin
  FTabObject := Value;
end;

procedure TSVGImageCustom.WriteData(Stream: TStream);
var
  Size: LongInt;
begin
  Size := FStream.Size;
  Stream.Write(Size, SizeOf(Size));
  FStream.Position := 0;
  if FStream.Size > 0 then
    FStream.SaveToStream(Stream);
end;
{$ENDREGION}

end.


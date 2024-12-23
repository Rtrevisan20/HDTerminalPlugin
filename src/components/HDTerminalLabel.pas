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
    procedure SetTabName  (const Value: string);
    procedure SetTabObject(const Value: TObject);
  public
    destructor  Destroy; override;
    constructor Create(AOwner: TComponent); override;
  published
    property TabName   : string    read FTabName    write SetTabName;
    property TabObject : TObject   read FTabObject  write SetTabObject;
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

procedure TLabelCustom.SetTabName(const Value: string);
begin
  FTabName := Value;
end;

procedure TLabelCustom.SetTabObject(const Value: TObject);
begin
  FTabObject := Value;
end;

end.

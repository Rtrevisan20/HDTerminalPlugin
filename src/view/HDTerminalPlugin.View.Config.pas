unit HDTerminalPlugin.View.Config;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Win.Registry,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Winapi.Messages,
  Winapi.Windows;

type
  TSingletonSettings = class
  private
    FCaption                  : string;
    FConsolePath              : string;
    FPathDefault              : string;
    FApplicationIcon          : Vcl.Graphics.TBitmap;
    class var FInstance       : TSingletonSettings;
    class function GetInstance: TSingletonSettings; static;
    constructor Create;
    function    GetFolder(const Directory: string): string;
    function    LoadFromRegistry  : TSingletonSettings;
    function    GetDiretorio      : string;
    function    GetApplicationIcon: Vcl.Graphics.TBitmap;
  public
    class property Instance : TSingletonSettings  read GetInstance;
    property ApplicationIcon: Vcl.Graphics.TBitmap read GetApplicationIcon;
    property Caption        : string              read FCaption     write FCaption;
    property ConsolePath    : string              read FConsolePath write FConsolePath;
    property PathDefault    : string              read FPathDefault write FPathDefault;
    property Diretorio      : string              read GetDiretorio;
  end;

  TViewSettings = class(TForm)
    GroupBox1   : TGroupBox;
    Label1      : TLabel;
    edtPath     : TEdit;
    Button1     : TButton;
    pnContainer : TPanel;
    Label2      : TLabel;
    edtCaption  : TEdit;
    Btn_Save    : TButton;
    Btn_Close   : TButton;
    OpenDialog  : TOpenDialog;
    Label3: TLabel;
    edtPathDefault: TEdit;
    imgIcone: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Btn_SaveClick(Sender: TObject);
    procedure Btn_CloseClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure LoadSettings;
    procedure SaveSettings;
  public

  end;

implementation

uses
  ToolsAPI,
  HDTerminalPlugin.Consts,
  System.IOUtils;

{$R *.dfm}

procedure TViewSettings.Btn_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TViewSettings.Btn_SaveClick(Sender: TObject);
begin
  SaveSettings;
  Close;
end;

procedure TViewSettings.Button1Click(Sender: TObject);
begin
  if OpenDialog.Execute then
    edtPath.Text := OpenDialog.FileName;
end;

procedure TViewSettings.FormCreate(Sender: TObject);
begin
  LoadSettings;
  Self.imgIcone.Picture.Bitmap := TSingletonSettings.Instance.FApplicationIcon;
end;

procedure TViewSettings.LoadSettings;
begin
  var LvSetting := TSingletonSettings.Instance.LoadFromRegistry;

  edtPath.Text        := LvSetting.FConsolePath;
  edtCaption.Text     := LvSetting.FCaption;
  edtPathDefault.Text := LvSetting.FPathDefault;
end;

procedure TViewSettings.SaveSettings;
var
  LvRegistry: TRegistry;
begin
  if not FileExists(edtPath.Text) then
   begin
     ShowMessage(Format(CMsgErroExe , [edtPath.Text]));
     Exit;
   end;
  LvRegistry := TRegistry.Create;
  try
    LvRegistry.RootKey := HKEY_CURRENT_USER;
    if LvRegistry.OpenKey(CKeyRegistry + CKeyConfigRegistry, True) then
    begin
      var LvSetting := TSingletonSettings.Instance;

      LvSetting.FCaption      := edtCaption.Text;
      LvSetting.FConsolePath  := edtPath.Text;
      LvSetting.PathDefault   := edtPathDefault.Text;

      LvRegistry.WriteString(CKeyCaption, LvSetting.FCaption);
      LvRegistry.WriteString(CConsolePath,    LvSetting.FConsolePath);
      LvRegistry.WriteString(CPathDefault,LvSetting.FPathDefault);
      LvRegistry.CloseKey;
    end;
  finally
    LvRegistry.Free;
  end;
end;

{$REGION 'TSingletonSettings'}

constructor TSingletonSettings.Create;
begin
  inherited;
  LoadFromRegistry;
end;

function TSingletonSettings.GetApplicationIcon: Vcl.Graphics.TBitmap;
begin
  if not Assigned(FApplicationIcon) then
    FApplicationIcon := Vcl.Graphics.TBitmap.Create;

  FApplicationIcon.LoadFromResourceName(hInstance, 'SPLASH');
  Result := FApplicationIcon;
end;

function TSingletonSettings.GetDiretorio: string;
var
  ModuleServices: IOTAModuleServices;
begin
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if Assigned(ModuleServices.CurrentModule) then
    Result := GetFolder(ExtractFileDir(ModuleServices.CurrentModule.FileName));
end;

function TSingletonSettings.GetFolder(const Directory: string): string;
var
  Files: TArray<string>;
begin
  Result := '';
  Files  := TDirectory.GetFiles(Directory, '*.dproj', TSearchOption.soAllDirectories);
  Result := TDirectory.GetParent(Directory);
  while Length(Files) = 0 do
   begin
    Result := TDirectory.GetParent(Result);
    Files  := TDirectory.GetFiles(Result, '*.dproj', TSearchOption.soAllDirectories);
   end;
end;

class function TSingletonSettings.GetInstance: TSingletonSettings;
begin
  if not Assigned(FInstance) then
    FInstance := TSingletonSettings.Create;
  Result := FInstance;
end;

function TSingletonSettings.LoadFromRegistry: TSingletonSettings;
var
  LvRegistry: TRegistry;
begin
  Result := FInstance;
  LvRegistry := TRegistry.Create;
  try
    LvRegistry.RootKey := HKEY_CURRENT_USER;
    if LvRegistry.OpenKeyReadOnly(CKeyRegistry + CKeyConfigRegistry) then
    begin
      FCaption      := LvRegistry.ReadString(CKeyCaption);
      FConsolePath  := LvRegistry.ReadString(CConsolePath);
      FPathDefault  := LvRegistry.ReadString(CPathDefault);
      LvRegistry.CloseKey;
    end
    else
    begin //Default settings
      FConsolePath := 'C:\Windows\system32\cmd.exe';
      FCaption     := 'CMD';
    end;
  finally
    LvRegistry.Free;
  end;
end;

{$ENDREGION}

end.

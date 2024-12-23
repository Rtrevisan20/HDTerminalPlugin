unit HDTerminalPlugin.Creator.MenuIDE;

interface

uses
  Vcl.Menus,
  ToolsAPI;

type
  THDTerminalPluginMenuWizard = class(TInterfacedObject, IOTAWizard)
  private
    procedure TerminalMenuClick     (Sender: TObject);
    procedure ConfiguracaoMenuClick (Sender: TObject);
  public
    FRootMenu       : TMenuItem;
    FTerminal       : TMenuItem;
    FTerminalConfig : TMenuItem;
    constructor Create;
    function    GetIDString : string;
    function    GetName     : string;
    function    GetState    : TWizardState;
    procedure   Execute;
    procedure   AfterSave;
    procedure   BeforeSave;
    procedure   Destroyed;
    procedure   Modified;
  end;

implementation

uses
  HDTerminalPlugin.Commons,
  HDTerminalPlugin.Creator,
  HDTerminalPlugin.Singleton.DockForm,
  HDTerminalPlugin.View.Config,
  HDTerminalPlugin.View.Main.Frame,
  Vcl.Dialogs,
  Vcl.Forms;

procedure THDTerminalPluginMenuWizard.AfterSave;
begin
//Do noting yet, its created by interface force!
end;

procedure THDTerminalPluginMenuWizard.BeforeSave;
begin
//Do noting yet, its created by interface force!
end;

procedure THDTerminalPluginMenuWizard.ConfiguracaoMenuClick(Sender: TObject);
var
  ViewSettings: TViewSettings;
begin
  ViewSettings := TViewSettings.Create(nil);
   try
    {Registro a class para aplicar o tema da IDE}
    THDTerminalCommons.RegisterFormClassForTheming(TViewSettings, ViewSettings);
    ViewSettings.Position := poMainFormCenter;
    ViewSettings.ShowModal;
   finally
    ViewSettings.Free;
   end;
end;

constructor THDTerminalPluginMenuWizard.Create;
var
  LvMainMenu: TMainMenu;
begin
  if not Assigned(FTerminal) then
   begin
    FTerminal         := TMenuItem.Create(nil);
    FTerminal.Name    := 'Mnu_Console';
    FTerminal.Caption := 'Terminal (Dockable)';
    FTerminal.OnClick := TerminalMenuClick;
    FTerminal.ShortCut:= TextToShortCut('Ctrl+Alt+\');
   end;

  if not Assigned(FTerminalConfig) then
   begin
    FTerminalConfig         := TMenuItem.Create(nil);
    FTerminalConfig.Name    := 'Mnu_ConfigConsole';
    FTerminalConfig.Caption := 'Configurações';
    FTerminalConfig.OnClick := ConfiguracaoMenuClick;
   end;

  if not Assigned(FRootMenu) then
   begin
    FRootMenu         := TMenuItem.Create(nil);
    FRootMenu.Caption := 'Terminal';
    FRootMenu.Name    := 'TerminalConsole';
    FRootMenu.Add(FTerminal);
    FRootMenu.Add(FTerminalConfig);
   end;

  if not Assigned((BorlandIDEServices as INTAServices).MainMenu
                  .Items.Find('TerminalConsole')) then
   begin
    LvMainMenu := (BorlandIDEServices as INTAServices).MainMenu;
    LvMainMenu.Items.Insert(LvMainMenu.Items.Count - 1, FRootMenu);
    FRootMenuIndex := LvMainMenu.Items.IndexOf(FRootMenu);
   end;
end;

procedure THDTerminalPluginMenuWizard.Destroyed;
begin
  if Assigned(FRootMenu)        then FRootMenu.Free;
  if Assigned(FTerminalConfig)  then FTerminalConfig.Free;
  if Assigned(FTerminal)        then FTerminal.Free;
end;

procedure THDTerminalPluginMenuWizard.Execute;
begin
//Do noting yet, its created by interface force!
end;

function THDTerminalPluginMenuWizard.GetIDString: string;
begin
  Result := 'HDTerminalIdString';
end;

function THDTerminalPluginMenuWizard.GetName: string;
begin
  Result := 'HDTerminal';
end;

function THDTerminalPluginMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure THDTerminalPluginMenuWizard.Modified;
begin
//Do noting yet, its created by interface force!
end;

procedure THDTerminalPluginMenuWizard.TerminalMenuClick(Sender: TObject);
begin
  TDockFormSingleton.Instance.ShowDockableMainFrame;
end;

end.

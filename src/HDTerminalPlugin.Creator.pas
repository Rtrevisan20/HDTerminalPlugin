unit HDTerminalPlugin.Creator;

interface

uses
  ToolsAPI,
  HDTerminalPlugin.Creator.MenuIDE,
  Winapi.Windows;

type
  TStyleNotifier = class(TNotifierObject, IOTANotifier, INTAIDEThemingServicesNotifier)
  private
    procedure ChangingTheme;
    procedure ChangedTheme;
  end;

  THDPluginCreator = class
  public
    class procedure PlugInStartup;
    class function  PlugInFinish: boolean;
    class procedure RemoveWizards;
  end;

{$REGION 'Consts, Variaveis e resourcestring'}
const
  WizardFail = -1;
  HdT_VERSION = '- V 0.0.1';
var
  FTHDMenuWizard  : THDTerminalPluginMenuWizard;
  FMainMenuIndex  : Integer = WizardFail;
  FRootMenuIndex  : Integer = WizardFail;
  FStylingNotifierIndex: Integer = WizardFail;
  FShouldApplyTheme: boolean = False;

resourcestring
  resPackageName      = 'HDTerminal ' + HdT_VERSION;
  resLicense          = 'Open Source - Free Version';
  resAboutTitle       = 'Terminal Integrate';
  resAboutDescription = 'https://github.com/Rtrevisan20';

{$ENDREGION}

procedure register;
function  Terminated: boolean;
procedure PluginSplash;

implementation

uses
  HDTerminalPlugin.Singleton.DockForm,
  HDTerminalPlugin.Singleton.Process,
  HDTerminalPlugin.View.Config,
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Menus;

{$REGION 'Register and Terminated'}
procedure register;
begin
  THDPluginCreator.PlugInStartup;
end;

function Terminated: boolean;
begin
  if THDPluginCreator <> nil then
    Result := THDPluginCreator.PlugInFinish else
    Result := True;
end;

procedure PluginSplash;
var
  LvSplashService : IOTASplashScreenServices;
  VBmp: Vcl.Graphics.TBitmap;
begin
 if Supports(SplashScreenServices, IOTASplashScreenServices, LvSplashService) then
  begin
   VBmp := TBitmap.Create;
   try
    VBmp.LoadFromResourceName(hInstance, 'SPLASH');
    LvSplashService.AddPluginBitmap(resPackageName, VBmp.Handle, False, resLicense, '');
   finally
    VBmp.Free;
   end;
  end;
end;
{$ENDREGION}

{$REGION 'TStyleNotifier'}
procedure TStyleNotifier.ChangedTheme;
var
  LvThemingService: IOTAIDEThemingServices;
begin
  if FShouldApplyTheme then
  begin
    if Assigned(TDockFormSingleton.Instance) and Supports(BorlandIDEServices,
      IOTAIDEThemingServices, LvThemingService) then
    begin
      LvThemingService.ApplyTheme(TDockFormSingleton.Instance);
    end;
    FTHDMenuWizard.FTerminal.Click;
  end;
end;

procedure TStyleNotifier.ChangingTheme;
begin
  if (Assigned(TDockFormSingleton.Instance)) and
    (TDockFormSingleton.Instance.Showing) then
  begin
    TDockFormSingleton.Instance.Close;
    FShouldApplyTheme := True;
  end;
end;
{$ENDREGION}

{$REGION 'THDPluginCreator'}
class function THDPluginCreator.PlugInFinish: boolean;
begin
  TSingletonProcess.Instance.TerminateAllProcess;
  Result := True;
end;

class procedure THDPluginCreator.PlugInStartup;
begin
  TSingletonSettings.Instance;
  TSingletonProcess.Instance;
  TDockFormSingleton.Instance;
  FTHDMenuWizard        := THDTerminalPluginMenuWizard.Create;
  FMainMenuIndex        := (BorlandIDEServices as IOTAWizardServices)
                            .AddWizard(FTHDMenuWizard);
  FStylingNotifierIndex := (BorlandIDEServices as IOTAIDEThemingServices)
                            .AddNotifier(TStyleNotifier.Create);
end;

class procedure THDPluginCreator.RemoveWizards;
var
  LvRootMenu: TMainMenu;
begin
  TSingletonProcess.Instance.Free;
  TDockFormSingleton.Instance.RemoveDockableMainFrame;

  LvRootMenu := (BorlandIDEServices as INTAServices).MainMenu;
  LvRootMenu.Items.Delete(FRootMenuIndex);

  if FMainMenuIndex        <> WizardFail then (BorlandIDEServices as IOTAWizardServices).RemoveWizard(FMainMenuIndex);
  if FStylingNotifierIndex <> WizardFail then (BorlandIDEServices as IOTAIDEThemingServices).RemoveNotifier(FStylingNotifierIndex);
end;
{$ENDREGION}

initialization
AddTerminateProc(Terminated);
PluginSplash;

finalization
THDPluginCreator.RemoveWizards;

end.

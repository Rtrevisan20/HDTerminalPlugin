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
    class function PlugInFinish: boolean;
    class procedure RemoveWizards;
  end;

{$REGION 'Consts, Variaveis e resourcestring'}
const
  WizardFail = -1;
  HDT_VERSION = '- V 0.0.1';
var
  FTHDMenuWizard: THDTerminalPluginMenuWizard;
  FMainMenuIndex: Integer         = WizardFail;
  FRootMenuIndex: Integer         = WizardFail;
  FStylingNotifierIndex: Integer  = WizardFail;
  FShouldApplyTheme: boolean      = False;

  resourcestring
  resPackageName      = 'HDTerminal ' + HDT_VERSION;
  resLicense          = 'Open Source - Free Version';
  resAboutTitle       = 'Terminal Integrate';
  resAboutDescription = 'https://github.com/Rtrevisan20';

{$ENDREGION}

procedure register;
function Terminated: boolean;
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
    Result := THDPluginCreator.PlugInFinish
  else
    Result := True;
end;

procedure PluginSplash;
var
  LvSplashService: IOTASplashScreenServices;
  VBmp: Vcl.Graphics.TBitmap;
begin
  if Supports(SplashScreenServices, IOTASplashScreenServices, LvSplashService) then begin
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
  if FShouldApplyTheme then begin
    if Assigned(TDockFormSingleton.Instance)
        and Supports(BorlandIDEServices, IOTAIDEThemingServices, LvThemingService) then
    begin
      LvThemingService.ApplyTheme(TDockFormSingleton.Instance);
    end;
    FTHDMenuWizard.FTerminal.Click;
  end;
end;

procedure TStyleNotifier.ChangingTheme;
begin
  if (Assigned(TDockFormSingleton.Instance)) and (TDockFormSingleton.Instance.Showing) then begin
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
  FTHDMenuWizard := THDTerminalPluginMenuWizard.Create;
  FMainMenuIndex := (BorlandIDEServices as IOTAWizardServices).AddWizard(FTHDMenuWizard);
  FStylingNotifierIndex := (BorlandIDEServices as IOTAIDEThemingServices).AddNotifier(TStyleNotifier.Create);
end;

class procedure THDPluginCreator.RemoveWizards;
var
  LvRootMenu: TMainMenu;
begin
  TSingletonProcess.Instance.Free;
  TDockFormSingleton.Instance.RemoveDockableMainFrame;

  LvRootMenu := (BorlandIDEServices as INTAServices).MainMenu;
  LvRootMenu.Items.Delete(FRootMenuIndex);

  if FMainMenuIndex <> WizardFail then
    (BorlandIDEServices as IOTAWizardServices).RemoveWizard(FMainMenuIndex);
  if FStylingNotifierIndex <> WizardFail then
    (BorlandIDEServices as IOTAIDEThemingServices).RemoveNotifier(FStylingNotifierIndex);
end;
{$ENDREGION}

initialization
  AddTerminateProc(Terminated);
  PluginSplash;

finalization
  THDPluginCreator.RemoveWizards;

end.

unit HDTerminalPlugin.Registration;

interface

uses
  Winapi.Windows;

var
  VbmSplashScreen: HBITMAP;

const
  HdT_VERSION = 'ver 0.0.1';

implementation

uses
  ToolsAPI, SysUtils, Vcl.Dialogs;

resourcestring
  resPackageName      = 'HDTerminal ' + HdT_VERSION;
  resLicense          = 'Open Source - Free Version';
  resAboutTitle       = 'Terminal Integrate';
  resAboutDescription = 'https://github.com/Rtrevisan20';

initialization
  VbmSplashScreen := LoadBitmap(hInstance, 'SPLASH');
  (SplashScreenServices as IOTASplashScreenServices)
    .AddPluginBitmap(resPackageName, VbmSplashScreen, False, resLicense);

end.


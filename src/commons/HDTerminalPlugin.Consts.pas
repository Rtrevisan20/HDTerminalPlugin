unit HDTerminalPlugin.Consts;

interface

uses
  Vcl.Graphics,
  Winapi.Messages;

const
  WM_UPDATE_MESSAGE             = WM_USER + 5874;
  WM_PROGRESS_MESSAGE           = WM_USER + 5875;
  WM_WRITESONIC_UPDATE_MESSAGE  = WM_USER + 5876;
  WM_YOUCHAT_UPDATE_MESSAGE     = WM_USER + 5877;



  CClassConsole = 'ConsoleWindowClass';

  CMsgErroExe = 'O executável %s não existe.';


  CPnContainer    = 'pnContainer';
  CLblNameAba     = 'lblNameAba';
  CPanelImg       = 'pnImgDelete';
  CImgDelete      = 'ImgDelete';


  CClDefault          = $00CCCCCC;//clWindow;
  CClSecundary        = $00A8A8A8;
  CClDeleteDefault    = $00546ee7;
  CClDeleteSecundary  = clRed;
  clAzulClaro         = $00b48145;

  CColorMenuEnter = $00698900;
  CColorMenuLeave = $00701919;


  //Consts Registry de Configuration
  CKeyRegistry        = '\Software\HDTerminalPlugin';
  CKeyConfigRegistry  = '\Config';
  CConsolePath        = 'ConsolePath';
  CPathDefault        = 'PathDefault';
  CKeyCaption         = 'Caption';

implementation

end.

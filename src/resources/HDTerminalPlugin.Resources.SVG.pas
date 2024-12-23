unit HDTerminalPlugin.Resources.SVG;

interface

type
  TSVGType = (TSVGTrash, TSVGAdd, TSVGConfig, TSvgNewConsole);

  THDTerminalSVG = class
  private
  public
    class function GetSVG(AType : TSVGType): string;
  end;

implementation

uses
  HDTerminalPlugin.Resources.SVG.Consts;

class function THDTerminalSVG.GetSVG(AType : TSVGType): string;
begin
  case AType of
    TSVGTrash       : Result := CSvgTrash;
    TSVGAdd         : Result := CSvgAdd;
    TSVGConfig      : Result := CSvgConfig;
    TSvgNewConsole  : Result := CSvgNewConsole;
  end;
end;

end.

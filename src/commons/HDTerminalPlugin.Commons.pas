unit HDTerminalPlugin.Commons;

interface

uses
  System.Classes,
  Vcl.Forms;

type
  THDTerminalCommons = class
    class procedure RegisterFormClassForTheming(const AFormClass: TCustomFormClass;
                                                const Component : TComponent); static;
  end;

implementation

uses
  ToolsAPI,
  System.SysUtils;


class procedure THDTerminalCommons.RegisterFormClassForTheming(
  const AFormClass: TCustomFormClass;
  const Component: TComponent);
var
 ITS: IOTAIDEThemingServices;
begin
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) then
  begin
    if ITS.IDEThemingEnabled then
    begin
      ITS.RegisterFormClass(AFormClass);
      if Assigned(Component) then
        ITS.ApplyTheme(Component);
    end;
  end;
end;

end.

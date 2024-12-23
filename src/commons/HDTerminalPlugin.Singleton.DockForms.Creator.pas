unit HDTerminalPlugin.Singleton.DockForms.Creator;

interface

type
  TBrowseAndDocItWizard = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  HDTerminalPlugin.Singleton.DockForms;

{O construtor do assistente principal conecta os
manipuladores de eventos para o formul�rio encaix�vel
(observe que o formul�rio j� foi criado neste ponto,
pois � chamado no m�todo IntialiseWizard � veja abaixo).}

constructor TBrowseAndDocItWizard.Create;
begin
 inherited Create;
  TfrmDockableModuleExplorer.CreateDockableModuleExplorer;
end;

{O destruidor do assistente principal remove o formul�rio encaix�vel.}
destructor TBrowseAndDocItWizard.Destroy;
begin
  TfrmDockableModuleExplorer.RemoveDockableModuleExplorer;
  inherited Destroy;
end;

initialization
{Por fim (sem trocadilhos), o formul�rio encaix�vel �
removido na se��o Finaliza��o do m�dulo principal do assistente.}
finalization
TfrmDockableModuleExplorer.RemoveDockableModuleExplorer;

end.

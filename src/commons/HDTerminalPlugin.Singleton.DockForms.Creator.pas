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
manipuladores de eventos para o formulário encaixável
(observe que o formulário já foi criado neste ponto,
pois é chamado no método IntialiseWizard – veja abaixo).}

constructor TBrowseAndDocItWizard.Create;
begin
 inherited Create;
  TfrmDockableModuleExplorer.CreateDockableModuleExplorer;
end;

{O destruidor do assistente principal remove o formulário encaixável.}
destructor TBrowseAndDocItWizard.Destroy;
begin
  TfrmDockableModuleExplorer.RemoveDockableModuleExplorer;
  inherited Destroy;
end;

initialization
{Por fim (sem trocadilhos), o formulário encaixável é
removido na seção Finalização do módulo principal do assistente.}
finalization
TfrmDockableModuleExplorer.RemoveDockableModuleExplorer;

end.

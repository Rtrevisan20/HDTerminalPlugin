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
unit HDTerminalPlugin.Singleton.DockForm;

interface

uses
  DockForm,
  Messages,
  SysUtils,
  Variants,
  Windows,
  HDTerminalPlugin.View.Main.Frame,
  System.Classes,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Graphics;

type
  TDockFormSingletonClass = Class of TDockFormSingleton;

  TDockFormSingleton = class(TDockableForm)
  private
    FMainFrame: TMainFrame;
    class var FDockableInstance: TDockFormSingleton;
    class procedure RegisterDockableForm(FormClass: TDockFormSingletonClass; var FormVar; Const FormName: String);
    class procedure UnRegisterDockableForm(var FormVar; Const FormName: String);
    class procedure CreateDockableForm(var FormVar: TDockFormSingleton; FormClass: TDockFormSingletonClass);
    class procedure FreeDockableForm(var FormVar: TDockFormSingleton);
    class procedure ShowDockableForm(Form: TDockFormSingleton);
    class function GetInstance: TDockFormSingleton; static;
  public
    class property Instance: TDockFormSingleton read GetInstance;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RemoveDockableMainFrame;
    procedure ShowDockableMainFrame;
  end;

implementation

uses
  DeskUtil,
  HDTerminalPlugin.Commons,
  HDTerminalPlugin.Singleton.Process,
  Vcl.ComCtrls;

class procedure TDockFormSingleton.RegisterDockableForm(
    FormClass: TDockFormSingletonClass;
    var FormVar;
    Const FormName: String);
begin
  if @RegisterFieldAddress <> nil then
    RegisterFieldAddress(FormName, @FormVar);
  RegisterDesktopFormClass(FormClass, FormName, FormName);
end;

class procedure TDockFormSingleton.UnRegisterDockableForm(var FormVar; Const FormName: String);
begin
  if @UnRegisterFieldAddress <> nil then
    UnRegisterFieldAddress(@FormVar);
end;

class procedure TDockFormSingleton.CreateDockableForm(
    var FormVar: TDockFormSingleton;
    FormClass: TDockFormSingletonClass
);
begin
  TCustomForm(FormVar) := FormClass.Create(Nil);
  RegisterDockableForm(FormClass, FormVar, TCustomForm(FormVar).Name);
end;

class procedure TDockFormSingleton.FreeDockableForm(var FormVar: TDockFormSingleton);
Begin
  if Assigned(FormVar) then begin
    UnRegisterDockableForm(FormVar, FormVar.Name);
    FreeAndNil(FormVar);
  end;
End;

class function TDockFormSingleton.GetInstance: TDockFormSingleton;
begin
  if not Assigned(FDockableInstance) then begin
    CreateDockableForm(FDockableInstance, TDockFormSingleton);
    {Registro a class para aplicar o tema da IDE}
    THDTerminalCommons.RegisterFormClassForTheming(TDockFormSingleton, FDockableInstance);
  end;

  Result := FDockableInstance;
end;

class procedure TDockFormSingleton.ShowDockableForm(Form: TDockFormSingleton);
begin
  if not Assigned(Form) then Exit;
  DeskUtil.ShowDockableForm(Form);
  DeskUtil.FocusWindow(Form);
end;

constructor TDockFormSingleton.Create(AOwner: TComponent);
begin
  inherited;
  DeskSection         := 'HDTerminal';
  Name                := 'HDTerminal';
  AutoSave            := True;
  SaveStateNecessary  := True;
  ClientHeight        := 500;
  ClientWidth         := 800;
  Caption             := 'Terminal';
  Position            := poMainFormCenter;
  FMainFrame          := TMainFrame.Create(Self);
  FMainFrame.Parent   := Self;
  FMainFrame.Align    := alClient;
  OnResize            := TSingletonProcess.Instance.DoResize;
  OnShow              := TSingletonProcess.Instance.SelfShow;
end;

destructor TDockFormSingleton.Destroy;
begin
  FMainFrame.Free;
  SaveStateNecessary := True;
  inherited;
end;

procedure TDockFormSingleton.RemoveDockableMainFrame;
begin
  FreeDockableForm(FDockableInstance);
end;

procedure TDockFormSingleton.ShowDockableMainFrame;
begin
  if Self.Showing then
   Self.Close else
   ShowDockableForm(GetInstance);
end;

end.

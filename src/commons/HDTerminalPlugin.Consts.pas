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
unit HDTerminalPlugin.Consts;

interface

uses
  Vcl.Graphics,
  Winapi.Messages;

const
  CClassConsole   = 'ConsoleWindowClass';
  CMsgErroExe     = 'O executável %s não existe.';

  CPnContainer    = 'pnContainer';
  CLblNameAba     = 'lblNameAba';
  CPanelImg       = 'pnImgDelete';
  CImgDelete      = 'ImgDelete';
  CShape          = 'shLine';
  CImgIndicator   = 'svgIndicator';

  CClDefault          = TColor($00CCCCCC);
//  CClSecundary        = TColor($00A8A8A8);
  CClTextColorDefault = TColor($00CCCCCC);
  CClSecundary        = TColor($000066cc);
  CClDeleteDefault    = TColor($00546ee7);
  CClDeleteSecundary  = clRed;
  CLAzulClaro         = TColor($00b48145);
  ClCinzaIDE          = TColor($004f5e6b);
  ClCinzaIDE2         = TColor($00b3b3b3);

  CColorMenuEnter = TColor($00698900);
  CColorMenuLeave = TColor($00701919);

  //Consts Registry de Configuration
  CKeyRegistry        = '\Software\HDTerminalPlugin';
  CKeyConfigRegistry  = '\Config';
  CConsolePath        = 'ConsolePath';
  CPathDefault        = 'PathDefault';
  CKeyCaption         = 'Caption';

implementation

end.

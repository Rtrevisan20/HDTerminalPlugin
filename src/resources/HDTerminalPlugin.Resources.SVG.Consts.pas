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
unit HDTerminalPlugin.Resources.SVG.Consts;

interface

const
  CSvgTrash =
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path '+
  'd="M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M7,'+
  '6H17V19H7V6M9,8V17H11V8H9M13,8V17H15V8H13Z" /></svg>';
  CSvgAdd = '<svg xmlns="http://www.w3.org/2000/svg" '+
  'viewBox="0 0 24 24"><path d="M20 14H14V20H10V14H4V10H10V4H14V10H20V14Z" /></svg>';
  CSvgConfig =
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'+
  '<path d="M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,'+
  '1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,'+
  '12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,'+
  '8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,'+
  '5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,'+
  '2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,'+
  '5.27L2.34,8.73C2.21,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,'+
  '12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.21,15.05 2.34,15.27L4.34,'+
  '18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,'+
  '21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,'+
  '18.67 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,'+
  '15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z" /></svg>';
  CSvgNewConsole =
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'+
  '<path d="M13,19V16H21V19H13M8.5,13L2.47,7H6.71L11.67,11.95C12.25,'+
  '12.54 12.25,13.5 11.67,14.07L6.74,19H2.5L8.5,13Z" /></svg>';
  CSvgIndicator =
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'+
  '<path d="M8,5.14V19.14L19,12.14L8,5.14Z" /></svg>';
implementation

end.

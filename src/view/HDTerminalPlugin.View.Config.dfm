object ViewSettings: TViewSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 169
  ClientWidth = 436
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnContainer: TPanel
    Left = 0
    Top = 0
    Width = 436
    Height = 169
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 432
    ExplicitHeight = 168
    DesignSize = (
      436
      169)
    object GroupBox1: TGroupBox
      Left = 0
      Top = 0
      Width = 436
      Height = 169
      Align = alClient
      Caption = 'Console App'
      TabOrder = 0
      ExplicitWidth = 432
      ExplicitHeight = 168
      object Label1: TLabel
        Left = 16
        Top = 27
        Width = 287
        Height = 15
        Caption = 'PATH .exe Example.: "C:\Program Files\Git\bin\git.exe"'
      end
      object Label2: TLabel
        Left = 16
        Top = 119
        Width = 45
        Height = 15
        Caption = 'Caption '
      end
      object Label3: TLabel
        Left = 16
        Top = 72
        Width = 70
        Height = 15
        Caption = 'PATH Default'
      end
      object imgIcone: TImage
        Left = 412
        Top = 8
        Width = 24
        Height = 24
      end
      object edtPath: TEdit
        Left = 16
        Top = 45
        Width = 407
        Height = 23
        TabOrder = 0
        Text = 'C:\Windows\system32\cmd.exe'
        TextHint = 'C:\Windows\system32\cmd.exe'
      end
      object Button1: TButton
        Left = 402
        Top = 47
        Width = 19
        Height = 19
        Cursor = crHandPoint
        Caption = '...'
        TabOrder = 1
        OnClick = Button1Click
      end
      object edtCaption: TEdit
        Left = 16
        Top = 137
        Width = 137
        Height = 23
        TabOrder = 2
        Text = 'CMD'
        TextHint = 'CMD'
      end
      object edtPathDefault: TEdit
        Left = 16
        Top = 90
        Width = 407
        Height = 23
        TabOrder = 3
        TextHint = 'C:\Dev'
      end
    end
    object Btn_Save: TButton
      Left = 304
      Top = 143
      Width = 64
      Height = 23
      Anchors = [akRight, akBottom]
      Caption = 'Save'
      TabOrder = 1
      OnClick = Btn_SaveClick
      ExplicitLeft = 300
      ExplicitTop = 142
    end
    object Btn_Close: TButton
      Left = 369
      Top = 143
      Width = 64
      Height = 23
      Anchors = [akRight, akBottom]
      Caption = 'Close'
      TabOrder = 2
      OnClick = Btn_CloseClick
      ExplicitLeft = 365
      ExplicitTop = 142
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'Aplication .exe|*.exe'
    Left = 192
    Top = 115
  end
end

object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Thoth Config sample'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object btnSaveConfig: TButton
    Left = 24
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Save config'
    TabOrder = 0
    OnClick = btnSaveConfigClick
  end
  object edtIpAddr: TEdit
    Left = 24
    Top = 24
    Width = 121
    Height = 23
    TabOrder = 1
    TextHint = 'Ip address'
  end
  object edtPort: TEdit
    Left = 24
    Top = 53
    Width = 75
    Height = 23
    TabOrder = 2
    TextHint = 'Port'
  end
end

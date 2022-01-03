object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Observable field sample'
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
  object TrackBar1: TTrackBar
    Left = 80
    Top = 72
    Width = 150
    Height = 45
    Max = 100
    TabOrder = 0
    OnChange = TrackBar1Change
  end
  object Edit1: TEdit
    Left = 80
    Top = 123
    Width = 121
    Height = 23
    TabOrder = 1
    Text = '0'
  end
  object Button1: TButton
    Left = 296
    Top = 72
    Width = 145
    Height = 25
    Caption = 'Change observable value'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 80
    Top = 152
    Width = 361
    Height = 201
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 3
  end
end

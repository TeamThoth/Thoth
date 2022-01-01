object frmObsFld: TfrmObsFld
  Left = 0
  Top = 0
  Caption = 'frmObsFld'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 24
    Top = 167
    Width = 34
    Height = 15
    Caption = 'Label1'
  end
  object Edit1: TEdit
    Left = 24
    Top = 24
    Width = 121
    Height = 23
    TabOrder = 0
    Text = 'Edit1'
  end
  object pnlParent: TPanel
    Left = 24
    Top = 53
    Width = 289
    Height = 108
    Caption = 'Parent'
    TabOrder = 1
    object pnlChild: TPanel
      Left = 56
      Top = 56
      Width = 185
      Height = 41
      Caption = 'Child'
      TabOrder = 0
    end
  end
  object Edit2: TEdit
    Left = 151
    Top = 24
    Width = 121
    Height = 23
    TabOrder = 2
    Text = 'Edit2'
  end
end

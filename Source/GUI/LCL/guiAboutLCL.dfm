object FormAbout: TFormAbout
  Left = 334
  Height = 300
  Top = 211
  Width = 430
  Caption = 'About YTD'
  ClientHeight = 300
  ClientWidth = 430
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Position = poOwnerFormCenter
  LCLVersion = '2.2.4.0'
  object LabelYTD: TLabel
    Left = 8
    Height = 23
    Top = 8
    Width = 43
    Caption = 'YTD'
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsUnderline]
    ParentColor = False
    ParentFont = False
  end
  object LabelVersionLabel: TLabel
    Left = 8
    Height = 14
    Top = 40
    Width = 46
    Caption = 'Version:'
    ParentColor = False
  end
  object LabelVersion: TLabel
    Left = 127
    Height = 14
    Top = 40
    Width = 80
    Caption = 'LabelVersion'
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object LabelNewestVersionLabel: TLabel
    Left = 8
    Height = 14
    Top = 56
    Width = 90
    Caption = 'Newest version:'
    ParentColor = False
  end
  object LabelNewestVersion: TLabel
    Left = 127
    Height = 14
    Top = 56
    Width = 62
    Caption = 'not found'
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    OnClick = LabelNewestVersionClick
  end
  object LabelHomepageLabel: TLabel
    Left = 8
    Height = 14
    Top = 73
    Width = 65
    Caption = 'Homepage:'
    ParentColor = False
  end
  object LabelHomepage: TLabel
    Left = 127
    Height = 14
    Top = 73
    Width = 157
    Caption = 'https://ibv.github.io/YTD/'
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    OnClick = LabelHomepageClick
  end
  object LabelMediaProviders: TLabel
    Left = 8
    Height = 14
    Top = 113
    Width = 93
    Caption = 'Media providers:'
    ParentColor = False
  end
  object LabelDefsVersion: TLabel
    Left = 210
    Height = 14
    Top = 40
    Width = 108
    Caption = 'LabelDefsVersion'
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object LabelNewestDefsVersion: TLabel
    Left = 210
    Height = 14
    Top = 56
    Width = 62
    Caption = 'not found'
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    OnClick = LabelNewestDefsVersionClick
  end
  object ListProviders: TListView
    Left = 8
    Height = 155
    Top = 127
    Width = 414
    Anchors = [akTop, akLeft, akRight, akBottom]
    Columns = <    
      item
        Caption = 'Provider'
        Width = 100
      end    
      item
        Caption = 'Components'
        Width = 299
      end>
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ScrollBars = ssVertical
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListProvidersData
  end
  object LabelYTD2: TLabel
    Left = 64
    Height = 14
    Top = 15
    Width = 29
    Caption = 'YTD2'
    ParentColor = False
  end
  object LabelSSLLabel: TLabel
    Left = 8
    Height = 14
    Top = 90
    Width = 54
    Caption = 'OpenSSL:'
    ParentColor = False
  end
  object LabelSSL: TLabel
    Left = 127
    Height = 14
    Top = 90
    Width = 10
    Caption = '--'
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    OnClick = LabelHomepageClick
  end
end

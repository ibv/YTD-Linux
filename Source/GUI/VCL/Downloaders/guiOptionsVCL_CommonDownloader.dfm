inherited FrameDownloaderOptionsPageCommon: TFrameDownloaderOptionsPageCommon
  Height = 252
  ClientHeight = 252
  object PanelCommonOptions: TPanel[0]
    Left = 0
    Height = 161
    Top = 0
    Width = 320
    Align = alTop
    BevelOuter = bvNone
    ClientHeight = 161
    ClientWidth = 320
    TabOrder = 0
    object LabelSecureToken: TLabel
      Left = 8
      Height = 13
      Top = 74
      Width = 71
      Caption = 'Secure &Token:'
      FocusControl = EditSecureToken
      ParentColor = False
    end
    object LabelUserName: TLabel
      Left = 8
      Height = 13
      Top = 106
      Width = 54
      Caption = '&User name:'
      FocusControl = EditUserName
      ParentColor = False
    end
    object LabelPassword: TLabel
      Left = 8
      Height = 13
      Top = 130
      Width = 49
      Caption = '&Password:'
      FocusControl = EditPassword
      ParentColor = False
    end
    object CheckDownloadSubtitles: TCheckBox
      Left = 8
      Height = 17
      Top = 0
      Width = 305
      Anchors = [akTop, akLeft, akRight]
      Caption = 'Download &subtitles if available'
      TabOrder = 0
    end
    object CheckConvertSubtitles: TCheckBox
      Left = 8
      Height = 17
      Top = 16
      Width = 305
      Anchors = [akTop, akLeft, akRight]
      Caption = '&Convert subtitles to .SRT format'
      TabOrder = 1
    end
    object CheckLiveStream: TCheckBox
      Left = 8
      Height = 17
      Top = 32
      Width = 305
      Caption = '&Live stream mode (much slower, but more stable)'
      TabOrder = 2
    end
    object EditSecureToken: TEdit
      Left = 112
      Height = 21
      Top = 72
      Width = 193
      Anchors = [akTop, akLeft, akRight]
      TabOrder = 3
    end
    object EditUserName: TEdit
      Left = 112
      Height = 21
      Top = 104
      Width = 193
      Anchors = [akTop, akLeft, akRight]
      TabOrder = 4
    end
    object EditPassword: TEdit
      Left = 112
      Height = 21
      Top = 128
      Width = 193
      Anchors = [akTop, akLeft, akRight]
      TabOrder = 5
    end
    object CheckRealtime: TCheckBox
      Left = 8
      Height = 17
      Top = 48
      Width = 305
      Caption = '&Realtime mode (may be slower, but doesn''t skip back)'
      TabOrder = 6
    end
  end
  object PanelSpecificOptions: TPanel[1]
    Left = 0
    Height = 91
    Top = 161
    Width = 320
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
end

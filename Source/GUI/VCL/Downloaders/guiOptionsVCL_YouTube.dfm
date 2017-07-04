inherited FrameDownloaderOptionsPage_YouTube: TFrameDownloaderOptionsPage_YouTube
  Height = 237
  ClientHeight = 237
  inherited PanelCommonOptions: TPanel
    inherited LabelSecureToken: TLabel
      Height = 15
      Width = 89
    end
    inherited LabelUserName: TLabel
      Height = 15
      Width = 75
    end
    inherited LabelPassword: TLabel
      Height = 15
      Width = 63
    end
    inherited CheckDownloadSubtitles: TCheckBox
      Height = 26
    end
    inherited CheckConvertSubtitles: TCheckBox
      Height = 26
    end
    inherited CheckLiveStream: TCheckBox
      Height = 26
      Width = 348
    end
    inherited CheckRealtime: TCheckBox
      Height = 26
      Width = 373
    end
  end
  inherited PanelSpecificOptions: TPanel
    Height = 76
    ClientHeight = 76
    object LabelPreferredLanguages: TLabel[0]
      Left = 8
      Height = 15
      Top = 0
      Width = 184
      Caption = '&Preferred subtitle languages:'
      FocusControl = EditPreferredLanguages
      ParentColor = False
    end
    object LabelMaximumVideoWidth: TLabel[1]
      Left = 8
      Height = 15
      Top = 24
      Width = 142
      Caption = 'Maximum video &width:'
      FocusControl = EditMaximumVideoWidth
      ParentColor = False
    end
    object LabelMaximumVideoHeight: TLabel[2]
      Left = 8
      Height = 15
      Top = 48
      Width = 149
      Caption = 'Maximum video &height:'
      FocusControl = EditMaximumVideoHeight
      ParentColor = False
    end
    object EditPreferredLanguages: TEdit[3]
      Left = 152
      Height = 21
      Top = 0
      Width = 153
      Anchors = [akTop, akLeft, akRight]
      TabOrder = 2
    end
    object EditMaximumVideoWidth: TEdit[4]
      Left = 152
      Height = 21
      Top = 24
      Width = 33
      TabOrder = 0
      Text = '0'
    end
    object EditMaximumVideoHeight: TEdit[5]
      Left = 152
      Height = 21
      Top = 48
      Width = 33
      TabOrder = 1
      Text = '0'
    end
    object CheckAvoidWebM: TCheckBox[6]
      Left = 8
      Height = 26
      Top = 72
      Width = 305
      Anchors = [akTop, akLeft, akRight]
      Caption = '&Avoid .webm format'
      TabOrder = 3
    end
  end
end

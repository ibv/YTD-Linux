inherited FrameDownloaderOptionsPage_EuroSeptik: TFrameDownloaderOptionsPage_EuroSeptik
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
    object LabelSubtitleHeaderText: TLabel[0]
      Left = 8
      Height = 15
      Top = 0
      Width = 131
      Caption = 'Subtitle &header text:'
      FocusControl = EditSubtitleHeaderText
      ParentColor = False
    end
    object EditSubtitleHeaderText: TEdit[1]
      Left = 112
      Height = 21
      Top = 0
      Width = 193
      TabOrder = 0
    end
  end
end

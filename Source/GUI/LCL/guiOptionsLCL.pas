(******************************************************************************

______________________________________________________________________________

YTD v1.00                                                    (c) 2009-12 Pepak
http://www.pepak.net/ytd                                  http://www.pepak.net
______________________________________________________________________________


Copyright (c) 2009-12 Pepak (http://www.pepak.net)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Pepak nor the
      names of his contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PEPAK BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

******************************************************************************)

unit guiOptionsLCL;
{$INCLUDE 'ytd.inc'}

interface

uses
  LCLIntf, LCLType, {LMessages,}

  {Messages,} SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, ComCtrls,
  {$IFDEF DELPHIXE4_UP}
  UITypes,
  {$ENDIF}
  uLanguages, uMessages, uOptions, {uDialogs,} uFunctions, guiFunctions,
  uDownloadClassifier, uDownloader, guiOptions,
  guiDownloaderOptions, guiOptionsLCL_Downloader, guiOptionsLCL_CommonDownloader;
  
type

  { TFormOptions }

  TFormOptions = class(TForm)
    actEndPlaySound: TAction;
    actFailPlaySound: TAction;
    actStartPlaySound: TAction;
    BtnFailSound: TButton;
    BtnStartSound: TButton;
    BtnEndSound: TButton;
    CheckFailSound: TCheckBox;
    CheckStartSound: TCheckBox;
    CheckEndSound: TCheckBox;
    EditFailSoundFile: TEdit;
    EditStartSoundFile: TEdit;
    EditEndSoundFile: TEdit;
    LabelOverwriteMode: TLabel;
    ComboOverwriteMode: TComboBox;
    LabelDownloadDir: TLabel;
    EditDownloadDir: TEdit;
    BtnDownloadDir: TButton;
    LabelConverter: TLabel;
    ComboConverter: TComboBox;
    BtnOK: TButton;
    btnCancel: TButton;
    ActionList: TActionList;
    actOK: TAction;
    actCancel: TAction;
    actDownloadDir: TAction;
    ODlg: TOpenDialog;
    PageOptions: TPageControl;
    TabMain: TTabSheet;
    CheckPortableMode: TCheckBox;
    CheckCheckNewVersions: TCheckBox;
    LabelLanguage: TLabel;
    EditLanguage: TEdit;
    TabDownloadOptions: TTabSheet;
    CheckSubtitlesEnabled: TCheckBox;
    TabNetworkOptions: TTabSheet;
    CheckUseProxy: TCheckBox;
    LabelProxyHost: TLabel;
    EditProxyHost: TEdit;
    EditProxyPort: TEdit;
    LabelProxyPort: TLabel;
    EditProxyUser: TEdit;
    LabelProxyUser: TLabel;
    EditProxyPass: TEdit;
    LabelProxyPass: TLabel;
    BtnDesktopShortcut: TButton;
    BtnStartMenuShortcut: TButton;
    actDesktopShortcut: TAction;
    actStartMenuShortcut: TAction;
    CheckMonitorClipboard: TCheckBox;
    CheckAutoTryHtmlParser: TCheckBox;
    CheckAutoDownload: TCheckBox;
    TabDownloaderOptions: TTabSheet;
    ListDownloaderOptions: TListBox;
    PanelDownloaderOptions: TPanel;
    CheckDownloadToTempFiles: TCheckBox;
    CheckDownloadToProviderSubdirs: TCheckBox;
    LabelRetryCount: TLabel;
    EditRetryCount: TEdit;
    CheckIgnoreOpenSSLWarning: TCheckBox;
    CheckIgnoreRtmpDumpWarning: TCheckBox;
    CheckIgnoreMSDLWarning: TCheckBox;
    CheckMinimizeToTray: TCheckBox;
    Label1: TLabel;
    ComboAddIndexToNames: TComboBox;
    CheckAutoDeleteFinishedDownloads: TCheckBox;
    procedure actEndPlaySoundExecute(Sender: TObject);
    procedure actFailPlaySoundExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actStartPlaySoundExecute(Sender: TObject);
    procedure CheckEndSoundChange(Sender: TObject);
    procedure CheckFailSoundChange(Sender: TObject);
    procedure CheckStartSoundChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actDownloadDirExecute(Sender: TObject);
    procedure ComboConverterChange(Sender: TObject);
    procedure actDesktopShortcutExecute(Sender: TObject);
    procedure actStartMenuShortcutExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListDownloaderOptionsClick(Sender: TObject);
  private
    fLoading: boolean;
    fOptions: TYTDOptionsGUI;
    {$IFDEF CONVERTERS}
    fConverterIndex: integer;
    {$ENDIF}
    fCurrentDownloaderOptionIndex: integer;
    procedure CreateDownloaderOptions;
    procedure DestroyDownloaderOptions;
    function GetDownloaderOptionsPageCount: integer;
    function GetDownloaderOptionsPages(Index: integer): TFrameDownloaderOptionsPage;
  protected
    procedure ShowDownloaderOptionsPage(Index: integer);
    property DownloaderOptionsPages[Index: integer]: TFrameDownloaderOptionsPage read GetDownloaderOptionsPages;
    property DownloaderOptionsPageCount: integer read GetDownloaderOptionsPageCount;
  public
    property Options: TYTDOptionsGUI read fOptions write fOptions;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF CONVERTERS}
    guiConverterLCL,
  {$ENDIF}
  {$IFDEF SETUP}
    uSetup,
  {$ENDIF}
  guiConsts;

procedure TFormOptions.FormCreate(Sender: TObject);
begin
  {$IFDEF GETTEXT}
  TranslateProperties(self);
  {$ENDIF}
  ComboOverwriteMode.Items.Clear;
  ComboOverwriteMode.Items.Add(OVERWRITEMODE_ASKUSER);
  ComboOverwriteMode.Items.Add(OVERWRITEMODE_OVERWRITE);
  ComboOverwriteMode.Items.Add(OVERWRITEMODE_SKIP);
  ComboOverwriteMode.Items.Add(OVERWRITEMODE_RENAME);
  ComboAddIndexToNames.Items.Clear;
  ComboAddIndexToNames.Items.Add(ADDINDEXTONAMES_NONE);
  ComboAddIndexToNames.Items.Add(ADDINDEXTONAMES_START);
  ComboAddIndexToNames.Items.Add(ADDINDEXTONAMES_END);
  PageOptions.ActivePageIndex := 0;
  DestroyDownloaderOptions;

  //BtnOK.Enabled := true;
  btnCancel.Enabled := true;
  //actCancel.Enabled := true;
end;

procedure TFormOptions.FormDestroy(Sender: TObject);
begin
  DestroyDownloaderOptions;
end;

procedure TFormOptions.FormShow(Sender: TObject);
const OverwriteMode: array [TOverwriteMode] of integer = (2, 1, 3, 0);
      AddIndexToNames: array[TIndexForNames] of integer = (0, 1, 2);
begin
  fLoading := True;
  try
    // Main options
    CheckPortableMode.Checked := Options.PortableMode;
    CheckCheckNewVersions.Checked := Options.CheckForNewVersionOnStartup;
    CheckMonitorClipboard.Checked := Options.MonitorClipboard;
    CheckIgnoreOpenSSLWarning.Checked := Options.IgnoreMissingOpenSSL;
    CheckIgnoreRtmpDumpWarning.Checked := Options.IgnoreMissingRtmpDump;
    CheckIgnoreMSDLWarning.Checked := Options.IgnoreMissingMSDL;
    ///CheckMinimizeToTray.Checked := Options.MinimizeToTray;
    EditLanguage.Text := Options.Language;
    // Download options
    CheckAutoDownload.Checked := Options.AutoStartDownloads;
    CheckAutoDeleteFinishedDownloads.Checked := Options.AutoDeleteFinishedDownloads;
    CheckAutoTryHtmlParser.Checked := Options.AutoTryHtmlParser;
    CheckSubtitlesEnabled.Checked := Options.SubtitlesEnabled;
    CheckDownloadToTempFiles.Checked := Options.DownloadToTempFiles;
    CheckDownloadToProviderSubdirs.Checked := Options.DownloadToProviderSubdirs;
    EditDownloadDir.Text := Options.DestinationPath;
    ComboOverwriteMode.ItemIndex := OverwriteMode[Options.OverwriteMode];
    EditRetryCount.Text := IntToStr(Options.DownloadRetryCount);

    CheckStartSound.Checked:= Options.StartSound;
    EditStartSoundFile.Text:= Options.StartSoundFile;
    EditStartSoundFile.Enabled:= CheckStartSound.Checked;
    BtnStartSound.Enabled:= CheckStartSound.Checked;

    CheckEndSound.Checked:= Options.EndSound;
    EditEndSoundFile.Text:= Options.EndSoundFile;
    EditEndSoundFile.Enabled:= CheckEndSound.Checked;
    BtnEndSound.Enabled:= CheckEndSound.Checked;

    CheckFailSound.Checked:= Options.FailSound;
    EditFailSoundFile.Text:= Options.FailSoundFile;
    EditFailSoundFile.Enabled:= CheckFailSound.Checked;
    BtnFailSound.Enabled:= CheckFailSound.Checked;

    {$IFDEF CONVERTERS}
    PrepareConverterComboBox(ComboConverter, Options, Options.SelectedConverterID);
    fConverterIndex := ComboConverter.ItemIndex;
    {$ELSE}
    LabelConverter.Visible := False;
    ComboConverter.Visible := False;
    {$ENDIF}
    ComboAddIndexToNames.ItemIndex := AddIndexToNames[Options.AddIndexToNames];
    // Network options
    CheckUseProxy.Checked := Options.ProxyActive;
    EditProxyHost.Text := Options.ProxyHost;
    EditProxyPort.Text := Options.ProxyPort;
    EditProxyUser.Text := Options.ProxyUser;
    EditProxyPass.Text := Options.ProxyPassword;

    // Downloader options
    CreateDownloaderOptions;
  finally
    fLoading := False;
    btnCancel.Enabled := true;
    end;
end;

procedure TFormOptions.CreateDownloaderOptions;
var
  i: integer;
  DC: TDownloadClassifier;
  FrameClass: TFrameDownloaderOptionsPageClass;
  Frame: TFrameDownloaderOptionsPage;
begin
  DestroyDownloaderOptions;
  DC := TDownloadClassifier.Create;
  try
    for i := 0 to Pred(DC.ProviderCount) do
      if DC.Providers[i] <> nil then
        begin
        FrameClass := DC.Providers[i].GuiOptionsClass;
        if FrameClass = nil then
          if (DC.Providers[i].Features <> []) and (DC.Providers[i].Features <> [dfDummy]) then
            FrameClass := TFrameDownloaderOptionsPageCommon;
        if FrameClass <> nil then
          if ListDownloaderOptions.Items.IndexOf(DC.Providers[i].Provider) < 0 then
            begin
            Frame := FrameClass.Create(Self);
            try
              Frame.Name := Format('DownloadOptionsPage%d', [i]);
              if Frame is TFrameDownloaderOptionsPageCommon then
                TFrameDownloaderOptionsPageCommon(Frame).DownloaderClass := DC.Providers[i];
              Frame.Provider := DC.Providers[i].Provider;
              Frame.Options := Self.Options;
              Frame.Visible := False;
              Frame.Parent := PanelDownloaderOptions;
              Frame.Align := alClient;
              Frame.LoadFromOptions;
              ListDownloaderOptions.Items.AddObject(DC.Providers[i].Provider, Frame);
            except
              FreeAndNil(Frame);
              Raise;
              end;
            end;
        end;
    if ListDownloaderOptions.Items.Count > 0 then
      begin
      ListDownloaderOptions.ItemIndex := 0;
      ShowDownloaderOptionsPage(ListDownloaderOptions.ItemIndex);
      end
    else
      begin
      TabDownloaderOptions.Visible := False;
      end;
  finally
    FreeAndNil(DC);
    end;
end;

procedure TFormOptions.DestroyDownloaderOptions;
var
  i: integer;
begin
  for i := 0 to Pred(ListDownloaderOptions.Items.Count) do
    begin
    TObject(ListDownloaderOptions.Items.Objects[i]).Free;
    ListDownloaderOptions.Items.Objects[i] := nil;
    end;
  ListDownloaderOptions.Items.Clear;
  fCurrentDownloaderOptionIndex := -1;
end;

function TFormOptions.GetDownloaderOptionsPageCount: integer;
begin
  Result := ListDownloaderOptions.Items.Count;
end;

function TFormOptions.GetDownloaderOptionsPages(Index: integer): TFrameDownloaderOptionsPage;
begin
  Result := ListDownloaderOptions.Items.Objects[Index] as TFrameDownloaderOptionsPage;
end;

procedure TFormOptions.actOKExecute(Sender: TObject);
const OverwriteMode: array[0..3] of TOverwriteMode = (omAsk, omAlways, omNever, omRename);
      AddIndexToNames: array[0..2] of TIndexForNames = (ifnNone, ifnStart, ifnEnd);
var
  i: integer;
  {$IFDEF CONVERTERS}
  NewID: string;
  {$ENDIF}
begin
  // Main options
  Options.PortableMode := CheckPortableMode.Checked;
  Options.CheckForNewVersionOnStartup := CheckCheckNewVersions.Checked;
  Options.Language := EditLanguage.Text;
  Options.MonitorClipboard := CheckMonitorClipboard.Checked;
  Options.IgnoreMissingOpenSSL := CheckIgnoreOpenSSLWarning.Checked;
  Options.IgnoreMissingRtmpDump := CheckIgnoreRtmpDumpWarning.Checked;
  Options.IgnoreMissingMSDL := CheckIgnoreMSDLWarning.Checked;
  ///Options.MinimizeToTray := CheckMinimizeToTray.Checked;
  // Download options
  Options.AutoStartDownloads := CheckAutoDownload.Checked;
  Options.StartSound := CheckStartSound.Checked;
  Options.EndSound := CheckEndSound.Checked;
  Options.FailSound := CheckFailSound.Checked;
  Options.StartSoundFile := EditStartSoundFile.Text;
  Options.EndSoundFile := EditEndSoundFile.Text;
  Options.FailSoundFile := EditFailSoundFile.Text;

  Options.AutoDeleteFinishedDownloads := CheckAutoDeleteFinishedDownloads.Checked;
  Options.AutoTryHtmlParser := CheckAutoTryHtmlParser.Checked;
  Options.SubtitlesEnabled := CheckSubtitlesEnabled.Checked;
  Options.DownloadToTempFiles := CheckDownloadToTempFiles.Checked;
  Options.DownloadToProviderSubdirs := CheckDownloadToProviderSubdirs.Checked;
  Options.DestinationPath := EditDownloadDir.Text;
  Options.OverwriteMode := OverwriteMode[ComboOverwriteMode.ItemIndex];
  Options.DownloadRetryCount := StrToIntDef(EditRetryCount.Text, Options.DownloadRetryCount);
  {$IFDEF CONVERTERS}
  if Options.ConvertersActivated then
    if DecodeConverterComboBox(ComboConverter, Options, NewID) then
      Options.SelectedConverterID := NewID;
  {$ENDIF}
  Options.AddIndexToNames := AddIndexToNames[ComboAddIndexToNames.ItemIndex];
  // Network
  Options.ProxyActive := CheckUseProxy.Checked;
  Options.ProxyHost := EditProxyHost.Text;
  Options.ProxyPort := EditProxyPort.Text;
  Options.ProxyUser := EditProxyUser.Text;
  Options.ProxyPassword := EditProxyPass.Text;
  // Downloaders
  for i := 0 to Pred(GetDownloaderOptionsPageCount) do
    begin
    DownloaderOptionsPages[i].Options := Options;
    DownloaderOptionsPages[i].SaveToOptions;
    end;
end;

procedure TFormOptions.actCancelExecute(Sender: TObject);
begin
  close;
end;

procedure TFormOptions.actEndPlaySoundExecute(Sender: TObject);
begin
   if ODlg.Execute then
        EditEndSoundFile.Text := Odlg.FileName;
end;

procedure TFormOptions.actFailPlaySoundExecute(Sender: TObject);
begin
   if ODlg.Execute then
         EditFailSoundFile.Text := Odlg.FileName;
end;

procedure TFormOptions.actStartPlaySoundExecute(Sender: TObject);
begin
  if ODlg.Execute then
        EditStartSoundFile.Text := Odlg.FileName;
end;

procedure TFormOptions.CheckEndSoundChange(Sender: TObject);
begin
  EditEndSoundFile.Enabled := CheckEndSound.Checked;
  BtnEndSound.Enabled:= CheckEndSound.Checked;
end;

procedure TFormOptions.CheckFailSoundChange(Sender: TObject);
begin
  EditFailSoundFile.Enabled := CheckFailSound.Checked;
  BtnFailSound.Enabled:= CheckFailSound.Checked;
end;

procedure TFormOptions.CheckStartSoundChange(Sender: TObject);
begin
  EditStartSoundFile.Enabled := CheckStartSound.Checked;
  BtnStartSound.Enabled:= CheckStartSound.Checked;
end;


procedure TFormOptions.actDownloadDirExecute(Sender: TObject);
var Dir: string;
begin
  Dir := EditDownloadDir.Text;
  if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
    EditDownloadDir.Text := Dir;
end;

procedure TFormOptions.ComboConverterChange(Sender: TObject);
begin
  {$IFDEF CONVERTERSMUSTBEACTIVATED}
  if not fLoading then
    if not Options.ConvertersActivated then
      begin
      MessageDlg(_(CONVERTERS_INACTIVE_WARNING), mtError, [mbOK], 0);
      ComboConverter.ItemIndex := fConverterIndex;
      Abort;
      end;
  {$ENDIF}
end;

procedure TFormOptions.actDesktopShortcutExecute(Sender: TObject);
begin
  ///CreateShortcut(APPLICATION_SHORTCUT, '', CSIDL_DESKTOPDIRECTORY, ParamStr(0), ''{SETUP_PARAM_GUI});
end;

procedure TFormOptions.actStartMenuShortcutExecute(Sender: TObject);
begin
  ///CreateShortcut(APPLICATION_SHORTCUT, '', CSIDL_PROGRAMS, ParamStr(0), ''{SETUP_PARAM_GUI});
end;

procedure TFormOptions.ShowDownloaderOptionsPage(Index: integer);
begin
  if (fCurrentDownloaderOptionIndex >= 0) and (fCurrentDownloaderOptionIndex < DownloaderOptionsPageCount) then
    DownloaderOptionsPages[fCurrentDownloaderOptionIndex].Visible := False;
  if (Index >= 0) and (Index < DownloaderOptionsPageCount) then
    begin
    DownloaderOptionsPages[Index].Visible := True;
    fCurrentDownloaderOptionIndex := Index;
    end
  else
    fCurrentDownloaderOptionIndex := -1;
end;

procedure TFormOptions.ListDownloaderOptionsClick(Sender: TObject);
begin
  ShowDownloaderOptionsPage(ListDownloaderOptions.ItemIndex);
end;

end.

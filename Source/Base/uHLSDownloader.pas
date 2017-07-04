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

unit uHLSDownloader;
{$INCLUDE 'ytd.inc'}

interface

uses
  SysUtils, Classes,
  {$ifdef mswindows}
    Windows
  {$ELSE}
    LCLIntf, LCLType, LMessages,
  {$ENDIF}
  uPCRE, uXml, uHttp, uCompatibility, HttpSend, blcksock,
  uDownloader, uCommonDownloader;

type
  THLSDownloader = class(TCommonDownloader)
    private
      fCookies: TStringList;
      fRetryCount: integer;
      fVideoDownloader: THttpSend;
      fFragments: TStringList;
      fFragmentsDownloaded: int64;
      fDownloadedThisFragment: int64;
      fDownloadedPreviousFragments: int64;
      fAborted: boolean;
    protected
      QualityRegExp: TRegExp;
    protected
      function CreateHttp: THttpSend; override;
      function GetTotalSize: int64; override;
      function GetDownloadedSize: int64; override;
      function GetContentUrl: string; override;
      procedure SockStatusMonitor(Sender: TObject; Reason: THookSocketReason; const Value: string); {$IFNDEF MINIMIZESIZE} virtual; {$ENDIF}
      function InitDownloadInfo: boolean;
      procedure CleanupDownloadInfo;
      property Cookies: TStringList read fCookies;
      property VideoDownloader: THttpSend read fVideoDownloader;
      property Fragments: TStringList read fFragments;
      property Aborted: boolean read fAborted write fAborted;
    public
      constructor Create(const AMovieID: string); override;
      destructor Destroy; override;
      function Prepare: boolean; override;
      function Download: boolean; override;
      procedure AbortTransfer; override;
      property RetryCount: integer read fRetryCount write fRetryCount;
    end;

implementation

uses
  SynaUtil, SynaCode,
  uLanguages, uMessages, uFunctions, uFiles;

const
  REGEXP_QUALITY = '^#.*?\bBANDWIDTH\s*=\s*(?P<QUALITY>\d+)';

{ THLSDownloader }

constructor THLSDownloader.Create(const AMovieID: string);
begin
  inherited;
  fCookies := TStringList.Create;
  fVideoDownloader := nil;
  fFragments := TStringList.Create;
  fRetryCount := 3;
  QualityRegExp := RegExCreate(REGEXP_QUALITY);
end;

destructor THLSDownloader.Destroy;
begin
  FreeAndNil(fCookies);
  FreeAndNil(fVideoDownloader);
  FreeAndNil(fFragments);
  RegExFreeAndNil(QualityRegExp);
  inherited;
end;

function THLSDownloader.CreateHttp: THttpSend;
begin
  Result := inherited CreateHttp;
  Result.Cookies.Assign(Cookies);
end;

function THLSDownloader.GetContentUrl: string;
begin
  Result := Format('HLS "%s"', [MovieURL]); 
end;

function THLSDownloader.InitDownloadInfo: boolean;
var
  Http: THttpSend;
  Playlist, BestPlaylistUrl, Line, sQuality: string;
  BestPlaylistQuality, Quality: integer;
  PlaylistStream: TTextStream;
begin
  Result := False;
  CleanupDownloadInfo;
  Http := CreateHttp;
  try
    if not DownloadPage(Http, MovieUrl, Playlist) then
      SetLastErrorMsg(ERR_FAILED_TO_DOWNLOAD_MEDIA_INFO_PAGE)
    else
      begin
      BestPlaylistUrl := '';
      BestPlaylistQuality := -1;
      PlaylistStream := TTextStream.Create(TStringStream.Create(Playlist), True);
      try
        while PlaylistStream.ReadLine(Line) do
          if GetRegExpVar(QualityRegExp, Line, 'QUALITY', sQuality) then
            begin
            Quality := StrToIntDef(sQuality, 0);
            if Quality > BestPlaylistQuality then
              while PlaylistStream.ReadLine(Line) do
                if Line <> '' then
                  if Line[1] <> '#' then
                    begin
                    BestPlaylistUrl := GetRelativeUrl(MovieUrl, Line);
                    BestPlaylistQuality := Quality;
                    Break;
                    end;
            end;
      finally
        FreeAndNil(PlaylistStream);
        end;
      if BestPlaylistUrl <> '' then
        if not DownloadPage(Http, BestPlaylistUrl, Playlist) then
          SetLastErrorMsg(ERR_FAILED_TO_DOWNLOAD_MEDIA_INFO_PAGE)
        else
          begin
          PlaylistStream := TTextStream.Create(TStringStream.Create(Playlist), True);
          try
            while PlaylistStream.ReadLine(Line) do
              if Line <> '' then
                if Line[1] <> '#' then
                  //if IsHttpProtocol(Line) then
                    begin
                    Fragments.Add(GetRelativeUrl(BestPlaylistUrl, Line));
                    if not Result then
                      begin
                      fVideoDownloader := CreateHttp;
                      fVideoDownloader.Cookies.Assign(Http.Cookies);
                      fVideoDownloader.Sock.OnStatus := SockStatusMonitor;
                      fDownloadedThisFragment := 0;
                      fDownloadedPreviousFragments := 0;
                      Result := True;
                      end;
                    end;
          finally
            FreeAndNil(PlaylistStream);
            end;
          end;
      end;
  finally
    FreeAndNil(Http);
    if not Result then
      CleanupDownloadInfo;
    end;
end;

procedure THLSDownloader.CleanupDownloadInfo;
begin
  Fragments.Clear;
  FreeAndNil(fVideoDownloader);
  Aborted := False;
end;

function THLSDownloader.Prepare: boolean;
begin
  Result := inherited Prepare;
  CleanupDownloadInfo;
end;

function THLSDownloader.Download: boolean;
var
  FinalFN, FN: string;
  Stream: TFileStream;
  FragmentDownloaded: boolean;
  FragmentData: AnsiString;
  i, Retry: integer;
begin
  inherited Download;
  Result := False;
  if MovieURL = '' then
    SetLastErrorMsg(ERR_DOWNLOAD_EMPTY_URL)
  else if not InitDownloadInfo then
    SetLastErrorMsg(ERR_DOWNLOAD_NOT_INITIALIZED)
  else if Fragments.Count < 1 then
    SetLastErrorMsg(ERR_INVALID_MEDIA_INFO_PAGE)
  else
    begin
    FinalFN := FileName;
    if Options.DownloadToTempFiles then
      FN := FinalFN + '.part'
    else
      FN := FinalFN;
    if FileExists(FN) then
      DeleteFile(PChar(FN));
    try
      SetLastErrorMsg(ERR_HTTP_NO_DATA_READ);
      Stream := nil;
      try
        for i := 0 to Pred(Fragments.Count) do
          begin
          FragmentDownloaded := False;
          Retry := RetryCount;
          while Retry >= 0 do
            if DownloadBinary(VideoDownloader, Fragments[i], FragmentData) then
              begin
              FragmentDownloaded := True;
              Inc(fFragmentsDownloaded);
              fDownloadedPreviousFragments := fDownloadedPreviousFragments + fDownloadedThisFragment;
              fDownloadedThisFragment := 0;
              if FragmentData <> '' then
                begin
                if Stream = nil then
                  begin
                  Stream := TFileStream.Create(FN, fmCreate);
                  {$IFDEF SHAREABLEFILES}
                  FreeAndNil(Stream);
                  Stream := TFileStream.Create(FN, fmOpenWrite or fmShareDenyWrite);
                  {$ENDIF}
                  end;
                Stream.WriteBuffer(FragmentData[1], Length(FragmentData));
                end;
              Break;
              end
            else
              Dec(Retry);
          if not FragmentDownloaded then
            Exit;
          end;
        Result := True;
      finally
        FreeAndNil(Stream);
        end;
    finally
      if Result then
        if FN <> FinalFN then
          begin
          if FileExists(FinalFN) then
            DeleteFile(PChar(FinalFN));
          if FileExists(FN) then
            if RenameFile(FN, FinalFN) then
              FN := FinalFN;
          end;
      end;
    end;
end;

procedure THLSDownloader.AbortTransfer;
begin
  inherited;
  Aborted := True;
  if (VideoDownloader <> nil) and (VideoDownloader.Sock <> nil) then
    VideoDownloader.Sock.AbortSocket;
end;

procedure THLSDownloader.SockStatusMonitor(Sender: TObject; Reason: THookSocketReason; const Value: string);
begin
  SetLastErrorMsg(_(SockStatusReasons[Reason]));
  if (Reason = HR_ReadCount) then
    fDownloadedThisFragment := fDownloadedThisFragment + StrToInt64(Value);
  if not (Reason in [HR_SocketClose, HR_Error]) then
    DoProgress;
end;

function THLSDownloader.GetDownloadedSize: int64;
begin
  Result := fDownloadedPreviousFragments + fDownloadedThisFragment;
end;

function THLSDownloader.GetTotalSize: int64;
var
  AverageSizePerFragment: int64;
begin
  Result := fDownloadedPreviousFragments;
  if (VideoDownloader <> nil) then
    begin
    Result := Result + VideoDownloader.DownloadSize;
    AverageSizePerFragment := Result div Succ(fFragmentsDownloaded);
    end
  else
    if fFragmentsDownloaded = 0 then
      AverageSizePerFragment := 0
    else
      AverageSizePerFragment := Result div fFragmentsDownloaded;
  Result := Result + (Fragments.Count - fFragmentsDownloaded) * AverageSizePerFragment;
end;

end.

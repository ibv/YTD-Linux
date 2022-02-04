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

unit uExternalDownloader;
{$INCLUDE 'ytd.inc'}

interface

uses
  SysUtils, Classes,
  {$ifdef mswindows}
    Windows,
  {$ENDIF}
  {$IFDEF fpc}
    LCLIntf, LCLType, FileUtil,
  {$ENDIF}
  uGUID, uFunctions, uSystem,
  uDownloader, uCommonDownloader;

type
  EExternalDownloaderError = class(EDownloaderError);

  TExternalDownloader = class(TCommonDownloader)
    private
      fAborted: boolean;
      fDownloadedBytes: int64;
      fTotalBytes: int64;
    protected
      function GetAnsiCompatibleFileName(const FileName: string): string;
      function GetTotalSize: int64; override;
      function GetDownloadedSize: int64; override;
      procedure PrepareDownload(const FinalFileName: string; out DownloadFileName, LogFileName: string);
      procedure FinalizeDownload(const FinalFileName: string; var DownloadFileName: string; DownloadSuccessful: boolean; MinimumSizeToKeep: int64 = 0);
      property DownloadedBytes: int64 read fDownloadedBytes write fDownloadedBytes;
      property TotalBytes: int64 read fTotalBytes write fTotalBytes;
      property Aborted: boolean read fAborted write fAborted;
    public
      constructor Create(const AMovieID: string); override;
      destructor Destroy; override;
      function Prepare: boolean; override;
      procedure AbortTransfer; override;
    end;

implementation

uses
  SynaCode,
  uStringConsts,
  uCompatibility;

constructor TExternalDownloader.Create(const AMovieID: string);
begin
  inherited;
end;

destructor TExternalDownloader.Destroy;
begin
  inherited;
end;

procedure TExternalDownloader.FinalizeDownload(const FinalFileName: string; var DownloadFileName: string; DownloadSuccessful: boolean; MinimumSizeToKeep: int64);
var
  FN: string;
begin
  if not DownloadSuccessful then
    ///if FileExists(DownloadFileName) and (GetFileSize(DownloadFileName) < MinimumSizeToKeep) then
    if FileExists(DownloadFileName) and (FileSize(DownloadFileName) < MinimumSizeToKeep) then
      SysUtils.DeleteFile(DownloadFileName);
  if {DownloadSuccessful} FileExists(DownloadFileName) then
    if (DownloadFileName <> FinalFileName) then
      begin
      FN := FinalFileName;
      if InternalValidateFileName(FN) then
        begin
        if FileExists(FN) then
          SysUtils.DeleteFile(FN);
        if RenameFile(DownloadFileName, FN) then
          DownloadFileName := FN;
        end;
      end;
end;

procedure TExternalDownloader.AbortTransfer;
begin
  inherited;
  Aborted := True;
end;

function TExternalDownloader.GetDownloadedSize: int64;
begin
  Result := DownloadedBytes;
end;

function TExternalDownloader.GetTotalSize: int64;
begin
  Result := TotalBytes;
end;

function TExternalDownloader.GetAnsiCompatibleFileName(const FileName: string): string;
var
  FN, Dir: string;
  i: integer;
begin
  Result := FileName;
  FN := ExtractFileName(Result);
  for i := 1 to Length(FN) do
    if (Ord(Char(FN[i])) < 32) or (Ord(Char(FN[i])) >= 128) or (Pos(Char(FN[i]), INVALID_FILENAME_CHARS) > 0) then
      begin
      if Options.DestinationPath = '' then
        Dir := ''
      else
        Dir := IncludeTrailingPathDelimiter(Options.DestinationPath);
      repeat
        FN := GenerateUuid + ExtractFileExt(FileName);
      until not FileExists(FN);
      Result := Dir + FN;
      Break;
      end;
end;

function TExternalDownloader.Prepare: boolean;
begin
  DownloadedBytes := 0;
  TotalBytes := -1;
  Result := inherited Prepare;
end;

procedure TExternalDownloader.PrepareDownload(const FinalFileName: string; out DownloadFileName, LogFileName: string);
var
  FN: string;
begin
  FN := GetAnsiCompatibleFileName(FinalFileName);
  DownloadFileName := FN;
  if Options.DownloadToTempFiles then
    DownloadFileName := DownloadFileName + '.part';
  LogFileName := GetTempDir + ExtractFileName(FN) + '.log';
  if FileExists(LogFileName) then
    SysUtils.DeleteFile(LogFileName);
end;

end.

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

unit guiOptionsLCL_CT;
{$INCLUDE 'ytd.inc'}

interface

uses 
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  uDownloader, guiOptionsLCL_Downloader, guiOptionsLCL_CommonDownloader;

type

  { TFrameDownloaderOptionsPage_CT }

  TFrameDownloaderOptionsPage_CT = class(TFrameDownloaderOptionsPageCommon)
    CheckDash: TCheckBox;
    Label1: TLabel;
    LabelMaximumVideoBitrate: TLabel;
    EditMaximumVideoBitrate: TEdit;
  private
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromOptions; override;
    procedure SaveToOptions; override;
  end;

implementation

{$R *.dfm}

uses
  downCT;

{ TFrameDownloaderOptionsPage_CT }

constructor TFrameDownloaderOptionsPage_CT.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFrameDownloaderOptionsPage_CT.Destroy;
begin
  inherited;
end;

procedure TFrameDownloaderOptionsPage_CT.LoadFromOptions;
begin
  inherited;
  EditMaximumVideoBitrate.Text := IntToStr(Options.ReadProviderOptionDef(Provider, OPTION_CT_MAX_VIDEO_WIDTH, OPTION_CT_MAX_VIDEO_WIDTH_DEFAULT));
  CheckDash.Checked := Options.ReadProviderOptionDef(Provider,OPTION_CT_DASH_SUPPORT,false);
end;

procedure TFrameDownloaderOptionsPage_CT.SaveToOptions;
begin
  inherited;
  Options.WriteProviderOption(Provider, OPTION_CT_MAX_VIDEO_WIDTH, StrToIntDef(EditMaximumVideoBitrate.Text, 0));
  Options.WriteProviderOption(Provider, OPTION_CT_DASH_SUPPORT, CheckDash.Checked);
end;

end.

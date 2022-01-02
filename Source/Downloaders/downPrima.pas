(******************************************************************************

______________________________________________________________________________

YTD v1.00                                                    (c) 2199 ibv
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

unit downPrima;
{$INCLUDE 'ytd.inc'}
{$DEFINE CONVERTSUBTITLES}
  // Convert subtitles to .srt format


interface

uses
  SysUtils, Classes,
  {$ifdef mswindows}
    Windows,
  {$ELSE}
    LCLIntf, LCLType, LMessages,
  {$ENDIF}
  {$IFDEF DELPHI6_UP} Variants, {$ENDIF}
  uPCRE, uXml, HttpSend, SynaUtil, synacode,
  uOptions,
  {$IFDEF GUI}
    guiDownloaderOptions,
    {$IFDEF GUI_WINAPI}
//      guiOptionsWINAPI_CT,
    {$ELSE}
      guiOptionsLCL_Prima,
    {$ENDIF}
  {$ENDIF}
  uDownloader, uCommonDownloader, {uHLSDownloader} uDASHdownloader;

type
  TDownloader_Prima = class(TDASHDownloader)
    private
      {$IFDEF MULTIDOWNLOADS}
      fNameList: TStringList;
      fUrlList: TStringList;
      fDownloadIndex: integer;
      access_token: string;
      username,password : string;
      {$ENDIF}
    protected
      StreamUrlRegExp: TRegExp;
      StreamTitleRegExp: TRegExp;
      ProductID1: TRegExp;
      ProductID2: TRegExp;
      StatusOK: TRegExp;
      Options: TRegExp;
      LoginForm: TRegExp;
      HLS : TRegExp;
      URLCODE : TRegExp;
      ATOKEN : TRegExp;
      {$IFDEF MULTIDOWNLOADS}
      property NameList: TStringList read fNameList;
      property UrlList: TStringList read fUrlList;
      property DownloadIndex: integer read fDownloadIndex write fDownloadIndex;
      {$ENDIF}
    protected
      function GetMovieInfoUrl: string; override;
      function GetFileNameExt: string; override;
      function AfterPrepareFromPage(var Page: string; PageXml: TXmlDoc; Http: THttpSend): boolean; override;
      function GetPlaylistInfo(Http: THttpSend; const Page: string; out Title: string): boolean;
      procedure SetOptions(const Value: TYTDOptions); override;
    public
      class function Provider: string; override;
      class function UrlRegExp: string; override;
      class function Features: TDownloaderFeatures; override;
      {$IFDEF GUI}
      class function GuiOptionsClass: TFrameDownloaderOptionsPageClass; override;
      {$ENDIF}
      constructor Create(const AMovieID: string); override;
      destructor Destroy; override;
      {$IFDEF MULTIDOWNLOADS}
      function Prepare: boolean; override;
      function ValidatePrepare: boolean; override;
      function First: boolean; override;
      function Next: boolean; override;
      {$ENDIF}
    end;


const
  OPTION_Prima_MAXBITRATE {$IFDEF MINIMIZESIZE} : string {$ENDIF} = 'max_video_width';
  OPTION_Prima_MAXBITRATE_DEFAULT = 0;
  OPTION_PRIMA_USERNAME {$IFDEF MINIMIZESIZE} : string {$ENDIF} = 'username';
  OPTION_PRIMA_USERNAME_DEFAULT = '';
  OPTION_PRIMA_PASSWORD {$IFDEF MINIMIZESIZE} : string {$ENDIF} = 'password';
  OPTION_PRIMA_PASSWORD_DEFAULT = '';
  OPTION_DASH_VIDEO_SUPPORT {$IFDEF MINIMIZESIZE} : string {$ENDIF} = 'dash_video_support';
  OPTION_DASH_AUDIO_SUPPORT {$IFDEF MINIMIZESIZE} : string {$ENDIF} = 'dash_audio_support';


implementation

uses
  uStringConsts,
  uStrings,
  uDownloadClassifier,
  uFunctions, uJSON, superobject,supertypes,
  uMessages;

const
  URLREGEXP_BEFORE_ID = '';
  URLREGEXP_ID =        REGEXP_COMMON_URL_PREFIX + '(?:iprima)\.cz/.+';
  URLREGEXP_AFTER_ID =  '';

const
  REGEXP_PRODUCTID1 = 'var productId = ''(?P<ID>.+?)'';';
  REGEXP_PRODUCTID2 = 'var pproduct_id = ''(?P<ID>.+?)'';';
  REGEXP_STATUS_CONTENT   = '^(?P<CONTENT>OK)$';
  REGEXP_OPTIONS_CONTENT  = '\bvar\s+\w*[pP]layerOptions\s*=\s*(?P<CONTENT>\{.*?\})\s*;';
  REGEXP_HLS_CONTENT      = 'tracks\s*:\s*\{\s*HLS\s*:\s*\[(?P<CONTENT>.+?)\]\s*,';
  REGEXP_STREAM_URL = 'src\s*:\s*''(?P<URL>https?://.+?)''';
  REGEXP_STREAM_TITLE = '<meta\s+(name|property)=(?P<QUOTE1>[''"])og:title(?P=QUOTE1)\s+(content|value)=(?P<QUOTE2>[''"])(?P<NAME>.*?)(?P=QUOTE2)';
  REGECXP_LOGIN_FORM = 'input type="hidden" name="(?P<NAME>.+?)" value="(?P<VALUE>.+?)">';
  REGECXP_URL_CODE = 'code=(?P<CODE>.+?)&';
  REGECXP_ACCESS_TOKEN = '"access_token":"(?P<TOKEN>.+?)",';

  _LOGIN_URL = 'https://auth.iprima.cz/oauth2/login';
  _TOKEN_URL = 'https://auth.iprima.cz/oauth2/token';


class function TDownloader_Prima.Provider: string;
begin
  Result := 'iPrima.cz';
end;

class function TDownloader_Prima.UrlRegExp: string;
begin
  Result := Format(REGEXP_BASE_URL, [URLREGEXP_BEFORE_ID, MovieIDParamName, URLREGEXP_ID, URLREGEXP_AFTER_ID]);
end;

class function TDownloader_Prima.Features: TDownloaderFeatures;
begin
  Result := inherited Features + [dfUserLogin];
end;


{$IFDEF GUI}
class function TDownloader_Prima.GuiOptionsClass: TFrameDownloaderOptionsPageClass;
begin
  Result := TFrameDownloaderOptionsPage_Prima;
end;
{$ENDIF}


constructor TDownloader_Prima.Create(const AMovieID: string);
begin
  inherited;
  {$IFDEF MULTIDOWNLOADS}
  fNameList := TStringList.Create;
  fUrlList := TStringList.Create;
  {$ENDIF}
  StreamUrlRegExp := RegExCreate(REGEXP_STREAM_URL);
  StreamTitleRegExp := RegExCreate(REGEXP_STREAM_TITLE);

  ProductID1 := RegExCreate(REGEXP_PRODUCTID1);
  ProductID2 := RegExCreate(REGEXP_PRODUCTID2);
  StatusOK   := RegExCreate(REGEXP_STATUS_CONTENT);
  Options    := RegExCreate(REGEXP_OPTIONS_CONTENT);
  HLS        := RegExCreate(REGEXP_HLS_CONTENT);

  LoginForm  := RegExCreate(REGECXP_LOGIN_FORM);
  URLCODE    := RegExCreate(REGECXP_URL_CODE);
  ATOKEN    := RegExCreate(REGECXP_ACCESS_TOKEN);

  access_token := '';

  Referer := GetMovieInfoUrl;
end;

destructor TDownloader_Prima.Destroy;
begin
  RegExFreeAndNil(StreamUrlRegExp);
  RegExFreeAndNil(StreamTitleRegExp);
  RegExFreeAndNil(ProductID1);
  RegExFreeAndNil(ProductID2);
  RegExFreeAndNil(StatusOK);
  RegExFreeAndNil(Options);
  RegExFreeAndNil(HLS);
  RegExFreeAndNil(LoginForm);
  RegExFreeAndNil(URLCODE);
  RegExFreeAndNil(ATOKEN);
  {$IFDEF MULTIDOWNLOADS}
  FreeAndNil(fNameList);
  FreeAndNil(fUrlList);
  {$ENDIF}
  inherited;
end;

function TDownloader_Prima.GetMovieInfoUrl: string;
begin
  Result := MovieID;
end;

function TDownloader_Prima.AfterPrepareFromPage(var Page: string; PageXml: TXmlDoc; Http: THttpSend): boolean;
var
  Title, ID1,ID2: string;
  i,j: integer;
  {$IFDEF MULTIDOWNLOADS}
  Urls: TStringArray;
  {$ELSE}
  Url: string;
  {$ENDIF}
  Url: string;
  csToken, csValue,ucode,Data:string;
  aryers: TSuperArray;
  o: ISuperObject;
begin
  inherited AfterPrepareFromPage(Page, PageXml, Http);
  Result := False;

  if access_token = '' then
  begin
  if not DownloadPage(Http,_LOGIN_URL, Data) then
     SetLastErrorMsg('Downloading login page failed')
  else if not GetRegExpVars(LoginForm, Data, ['NAME', 'VALUE'], [@csToken, @csValue]) then
     SetLastErrorMsg('Failed to locate media info page (idec).');
  if not DownloadPage(Http,_LOGIN_URL, ('_email='+username+'&_password='+password+'&'+csToken+'='+csValue),
                                       HTTP_FORM_URLENCODING_UTF8 ,
                                       [],
                                       Data,
                                       peUtf8 ) then
     SetLastErrorMsg('Login in failed')
  else if not GetRegExpVar(URLCODE, LastURL, 'CODE', ucode) then
     SetLastErrorMsg('Login code failed')
  else if not DownloadPage(Http,_TOKEN_URL ,
    ('scope=openid+email+profile+phone+address+offline_access&client_id=prima_sso&grant_type=authorization_code&code='+ucode+'&redirect_uri=https://auth.iprima.cz/sso/auth-check'),
     HTTP_FORM_URLENCODING_UTF8, [], Data, peUtf8)  then
    SetLastErrorMsg('Downloading token failed');

   if not GetRegExpVar(ATOKEN, Data, 'TOKEN', access_token) then
       SetLastErrorMsg('Getting token failed')
  end;

  if not GetPlaylistInfo(Http, Page, Title) then
    SetLastErrorMsg(ERR_FAILED_TO_LOCATE_MEDIA_INFO_PAGE)
  else if not GetRegExpVar(ProductID1, Page, 'ID', ID1) then
    else if not GetRegExpVar(ProductID2, Page, 'ID', ID2) then
      SetLastErrorMsg(ERR_FAILED_TO_DOWNLOAD_MEDIA_INFO_PAGE);
  if ID1='' then
    if ID2<>'' then ID1:=ID2
      else SetLastErrorMsg(ERR_FAILED_TO_DOWNLOAD_MEDIA_INFO_PAGE);

  Data:=Http.Cookies.values['prima_uuid'];
  ClearHttp(Http);
  Http.Headers.Add('X-OTT-Access-Token: '+access_token);
  Http.Headers.Add('X-OTT-Device: prima_slot_id_'+data);
  Http.Cookies.values['prima_uuid']:=data;

  if not DownloadPage(Http,'https://api.play-backend.iprima.cz/api/v1/products/id-'+ID1+'/play',Data, peUtf8,hmGet,false)
         then   SetLastErrorMsg(ERR_FAILED_TO_DOWNLOAD_MEDIA_INFO_PAGE);

  O:= SO(Data);
  aryers := o.O['streamInfos'].AsArray();
  for i := 0 to aryers.Length - 1 do
  begin
    if pos('cs',aryers[i].O['lang'].AsString()) <=0 then continue ;
    if pos('DASH',aryers[i].O['type'].AsString()) <=0 then continue ;
    Url := aryers[i].O['url'].AsString();
  end;

  if Title = '' then
      if not GetRegExpVar(StreamTitleRegExp, Page, 'NAME', Title) then
        SetLastErrorMsg(ERR_FAILED_TO_LOCATE_MEDIA_TITLE);
    Title := trim(AnsiEncodedUtf8ToString( {$IFDEF UNICODE} AnsiString {$ENDIF} (JSDecode(Title))));
    NameList.Add(Title);
    Name := Title;
    MovieURL := Url ;
    SetPrepared(True);
    Result := True;
    Urls:=nil;
end;



function TDownloader_Prima.GetFileNameExt: string;
begin
  Result := '.mpv';
end;


function TDownloader_Prima.GetPlaylistInfo(Http: THttpSend; const Page: string; out Title: string): boolean;
begin
  Result := GetRegExpVars(StreamTitleRegExp, Page, ['NAME'], [@Title]);
end;

{$IFDEF MULTIDOWNLOADS}

function TDownloader_Prima.Prepare: boolean;
begin
  NameList.Clear;
  UrlList.Clear;
  DownloadIndex := 0;
  Result := inherited Prepare;
end;

function TDownloader_Prima.ValidatePrepare: boolean;
var
  DownIndex: integer;
begin
  DownIndex := DownloadIndex;
  try
    Result := inherited ValidatePrepare;
  finally
    DownloadIndex := DownIndex;
    end;
end;

function TDownloader_Prima.First: boolean;
begin
  if ValidatePrepare then
    if UrlList.Count <= 0 then
      Result := MovieURL <> ''
    else
      begin
      DownloadIndex := -1;
      Result := Next;
      end
  else
    Result := False;
end;

function TDownloader_Prima.Next: boolean;
begin
  Result := False;
  if ValidatePrepare then
    begin
    DownloadIndex := Succ(DownloadIndex);
    if (DownloadIndex >= 0) and (DownloadIndex < UrlList.Count) then
      begin
      Name := NameList[DownloadIndex];
      SetFileName('');
      MovieURL := UrlList[DownloadIndex];
      Result := True;
      end;
    end;
end;

{$ENDIF}


procedure TDownloader_Prima.SetOptions(const Value: TYTDOptions);
var
  VWithRes: integer;
begin
  inherited;
  username := Value.ReadProviderOptionDef(Provider, OPTION_PRIMA_USERNAME, OPTION_PRIMA_USERNAME_DEFAULT);
  password := Value.ReadProviderOptionDef(Provider, OPTION_PRIMA_PASSWORD, OPTION_PRIMA_PASSWORD_DEFAULT);
  VWithRes := Value.ReadProviderOptionDef(Provider, OPTION_Prima_MAXBITRATE, OPTION_Prima_MAXBITRATE_DEFAULT);
  case VWithRes of
       512:  MaxVBitRate:=540672;
       640:  MaxVBitRate:=950272;
       768:  MaxVBitRate:=1155072;
      1024:  MaxVBitRate:=1667072;
      1280:  MaxVBitRate:=2310144;
      1920:  MaxVBitRate:=3334144;
      else   MaxVBitRate:=MaxInt;
  end;
end;


initialization
  RegisterDownloader(TDownloader_Prima);

end.


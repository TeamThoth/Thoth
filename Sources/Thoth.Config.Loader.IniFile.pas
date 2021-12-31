unit Thoth.Config.Loader.IniFile;

interface

uses
  Thoth.Config.Types,
  Thoth.Config.Loader,
  System.IniFiles,
  System.Rtti;

type
  /// <summary>
  ///  INI 파일을 이용해 설정값을 관리한다.
  /// </summary>
  TIniFileConfigLoader = class(TCustomConfigLoader)
  private
    FIniFile: TIniFile;
    FFilename: string;

    procedure CreateIniFile;
  protected
    procedure DoInitialize; override;

    function DoReadValue(const ASection, AKey: string; ADefault: TValue): TValue; override;
    procedure DoWriteValue(const ASection, AKey: string; AValue: TValue); override;

    procedure DoBeforeLoadConfig; override;
    procedure DoAfterLoadConfig; override;
    procedure DoBeforeSaveConfig; override;
    procedure DoAfterSaveConfig; override;

    procedure DoResetConfig; override;
  end;

implementation

uses
  System.Types, System.TypInfo, System.IOUtils, System.SysUtils,
  Thoth.Utils, Thoth.ResourceStrings;

{ TIniFileConfigLoader }

procedure TIniFileConfigLoader.CreateIniFile;
begin
  if Assigned(FIniFile) then
    Exit;
  FIniFile := TIniFile.Create(FFilename);
end;

procedure TIniFileConfigLoader.DoInitialize;
begin
  inherited;

  var LName := FConfig.ConfigName;

  if LName = '' then
    FFilename := ChangeFileExt(ParamStr(0), '.ini')
  else
    FFilename := ExtractFilePath(Paramstr(0)) + LName;

  if ExtractFileExt(FFilename).ToLower <> '.ini' then
    FFilename := FFilename + '.ini';
end;

procedure TIniFileConfigLoader.DoBeforeLoadConfig;
begin
  CreateIniFile;
end;

procedure TIniFileConfigLoader.DoAfterLoadConfig;
begin
  FIniFile.Free;
  FIniFIle := nil;
end;

procedure TIniFileConfigLoader.DoBeforeSaveConfig;
begin
  CreateIniFile;
end;

procedure TIniFileConfigLoader.DoAfterSaveConfig;
begin
  FIniFile.Free;
  FIniFIle := nil;
end;

procedure TIniFileConfigLoader.DoResetConfig;
begin
  if TFile.Exists(FFileName) then
    TFile.Delete(FFileName);
end;

function TIniFileConfigLoader.DoReadValue(const ASection, AKey: string;
  ADefault: TValue): TValue;
begin
  case ADefault.TypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      Result := TValue.From<string>(FIniFile.ReadString(ASection, AKey, ADefault.AsString));

    tkInteger:
      Result := TValue.From<Integer>(FIniFile.ReadInteger(ASection, AKey, ADefault.AsInteger));

    tkInt64:
      Result := TValue.From<Int64>(FIniFile.ReadInt64(ASection, AKey, ADefault.AsInt64));

    tkFloat:
      if ADefault.TypeInfo = TypeInfo(TDateTime) then
        Result := TValue.From<TDateTime>(FIniFile.ReadDateTime(ASection, AKey, ADefault.AsExtended))
      else
        Result := TValue.From<Double>(FIniFile.ReadFloat(ASection, AKey, ADefault.AsExtended));

    tkEnumeration:
      if ADefault.TypeInfo = TypeInfo(Boolean) then
        Result := TValue.From<Boolean>(FIniFile.ReadBool(ASection, AKey, ADefault.AsBoolean))
      else
      begin
        var IntVal := FIniFile.ReadInteger(ASection, AKey, ADefault.AsOrdinal);
        Result := TValue.FromOrdinal(ADefault.TypeInfo, IntVal);
      end
  else
    Result := TValue.Empty;
  end;
end;

procedure TIniFileConfigLoader.DoWriteValue(const ASection, AKey: string;
  AValue: TValue);
begin
  case AValue.TypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      FIniFile.WriteString(ASection, AKey, AValue.AsString);

    tkInteger:
      FIniFile.WriteInteger(ASection, AKey, AValue.AsInteger);

    tkInt64:
      FIniFile.WriteInt64(ASection, AKey, AValue.AsInt64);

    tkFloat:
      if AValue.TypeInfo = TypeInfo(TDateTime) then
        FIniFile.WriteDateTime(ASection, AKey, AValue.AsExtended)
      else
        FIniFile.WriteFloat(ASection, AKey, AValue.AsExtended);

    tkEnumeration:
      if AValue.TypeInfo = TypeInfo(Boolean) then
        FIniFile.WriteBool(ASection, AKey, AValue.AsBoolean)
      else
        FIniFile.WriteInteger(ASection, AKey, AValue.AsOrdinal);
  else
    raise Exception.CreateFmt(STypeNotSupported, [ClassName, AValue.TypeInfo.Name]);
  end;
end;

end.

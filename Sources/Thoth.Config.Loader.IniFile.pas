unit Thoth.Config.Loader.IniFile;

interface

uses
  Thoth.Config.Loader,
  System.SysUtils,
  System.IniFiles,
  System.Rtti;

type
  TIniFileConfigLoader = class(TCustomConfigLoader)
  private
    FIniFile: TIniFile;
    FFilename: string;

    procedure CreateIniFile;
  protected
    function ReadValue(const ASection, AIdent: string; ADefault: TValue): TValue; override;
    procedure WriteValue(const ASection, AIdent: string; AValue: TValue); override;

    procedure DoLoadConfigBefore; override;
    procedure DoSaveConfigAfter; override;
  end;

implementation

uses
  System.Types, System.TypInfo,
  Thoth.Utils, Thoth.ResourceStrings;

{ TIniFileConfigLoader }

procedure TIniFileConfigLoader.CreateIniFile;
var
  LName: string;
begin
  if Assigned(FIniFile) then
    Exit;

  LName := FConfig.ConfigName;

  if LName = '' then
    FFilename := ChangeFileExt(ParamStr(0), '.ini')
  else
    FFilename := ExtractFilePath(Paramstr(0)) + LName;
  FIniFile := TIniFile.Create(FFilename);
end;

procedure TIniFileConfigLoader.DoLoadConfigBefore;
begin
  CreateIniFile;
end;

procedure TIniFileConfigLoader.DoSaveConfigAfter;
begin
  FIniFile.Free;
  FIniFIle := nil;
end;

function TIniFileConfigLoader.ReadValue(const ASection, AIdent: string;
  ADefault: TValue): TValue;
begin
  case ADefault.TypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      Result := TValue.From<string>(FIniFile.ReadString(ASection, AIdent, ADefault.AsString));

    tkInteger:
      Result := TValue.From<Integer>(FIniFile.ReadInteger(ASection, AIdent, ADefault.AsInteger));

    tkInt64:
      Result := TValue.From<Int64>(FIniFile.ReadInt64(ASection, AIdent, ADefault.AsInt64));

    tkFloat:
      if ADefault.TypeInfo = TypeInfo(TDateTime) then
        Result := TValue.From<TDateTime>(FIniFile.ReadDateTime(ASection, AIdent, ADefault.AsExtended))
      else
        Result := TValue.From<Double>(FIniFile.ReadFloat(ASection, AIdent, ADefault.AsExtended));

    tkEnumeration:
      if ADefault.TypeInfo = TypeInfo(Boolean) then
        Result := TValue.From<Boolean>(FIniFile.ReadBool(ASection, AIdent, ADefault.AsBoolean))
      else
      begin
        var IntVal := FIniFile.ReadInteger(ASection, AIdent, ADefault.AsOrdinal);
        Result := TValue.FromOrdinal(ADefault.TypeInfo, IntVal);
      end
  else
    Result := TValue.Empty;
  end;
end;

procedure TIniFileConfigLoader.WriteValue(const ASection, AIdent: string;
  AValue: TValue);
begin
  case AValue.TypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      FIniFile.WriteString(ASection, AIdent, AValue.AsString);

    tkInteger:
      FIniFile.WriteInteger(ASection, AIdent, AValue.AsInteger);

    tkInt64:
      FIniFile.WriteInt64(ASection, AIdent, AValue.AsInt64);

    tkFloat:
      if AValue.TypeInfo.Name = 'TDateTime' then
        FIniFile.WriteDateTime(ASection, AIdent, AValue.AsExtended)
      else
        FIniFile.WriteFloat(ASection, AIdent, AValue.AsExtended);

    tkEnumeration:
      if AValue.TypeInfo.Name = 'Boolean' then
        FIniFile.WriteBool(ASection, AIdent, AValue.AsBoolean)
      else
        FIniFile.WriteInteger(ASection, AIdent, AValue.AsOrdinal);
  else
    raise Exception.CreateFmt(STypeNotSupported, [AValue.TypeInfo.Name]);
  end;
end;

end.

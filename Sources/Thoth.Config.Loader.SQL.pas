unit Thoth.Config.Loader.SQL;

interface

uses
  Thoth.Config.Types,
  Thoth.Config.Loader,
  // FireDAC
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,

  System.Rtti, System.Generics.Collections;

type
//  TConfigItemInfo = record
//    KeyName: string;
//    DefaultValue: TValue;
//    Value: TValue;
//
//    constructor Create(AKeyName: string; ADefaultValue: TValue);
//  end;
//
  TConfigItem = class
  private
    FDefaultValue: TValue;
    FValue: TValue;
  public
    constructor Create(ADefaultValue: TValue);

    property DefaultValue: TValue read FDefaultValue;
    property Value: TValue read FValue write FValue;
  end;

  TConfigItems = class(TObjectDictionary<string, TConfigItem>)
  public
    procedure Add(AKeyName: string; ADefaultValue: TValue); overload;
  end;

  TSQLConfigLoader = class(TCustomConfigLoader)
  private
    FFetchAll: Boolean;
    FConnection: TFDConnection;
    FOwnQuery: Boolean;
    FQuery: TFDQuery;

//    FConfigItemInfos: TList<TConfigItemInfo>;
    FConfigItems: TConfigItems;

    FTableName: string;
    procedure SetConnection(const Value: TFDConnection);
    procedure SetQuery(const Value: TFDQuery);

    /// <Summary>Config 객체에서 필드 정보 추출</Summary>
    procedure ExtractFieldNames;
  protected
    procedure DoInitialize; override;

    function DoReadValue(const ASection, AKey: string; ADefault: TValue): TValue; override;
    procedure DoWriteValue(const ASection, AKey: string; AValue: TValue); override;

    procedure DoBeforeLoadConfig; override;
    procedure DoAfterLoadConfig; override;
    procedure DoBeforeSaveConfig; override;
    procedure DoAfterSaveConfig; override;

    procedure DoClearData; override;
  public
    constructor Create(AFetchAll: Boolean = True);
    destructor Destroy; override;

    property Connection: TFDConnection read FConnection write SetConnection;
    property Query: TFDQuery read FQuery write SetQuery;
  end;

implementation

uses
  System.SysUtils,

  Thoth.ResourceStrings;


//{ TConfigItemInfo }
//
//constructor TConfigItemInfo.Create(AKeyName: string; ADefaultValue: TValue);
//begin
//  KeyName := AKeyName;
//  DefaultValue := ADefaultValue;
//end;

{ TConfigItem }

constructor TConfigItem.Create(ADefaultValue: TValue);
begin
  FDefaultValue := ADefaultValue;
end;

{ TConfigItems }

procedure TConfigItems.Add(AKeyName: string; ADefaultValue: TValue);
begin
  Add(AKeyName, TConfigItem.Create(ADefaultValue));
end;

{ TSQLConfigLoader }

constructor TSQLConfigLoader.Create(AFetchAll: Boolean);
begin
  FFetchAll := AFetchAll;

  if FFetchAll then
  begin
//    FConfigItemInfos := TList<TConfigItemInfo>.Create;
    FConfigItems := TConfigItems.Create;
  end;
end;

destructor TSQLConfigLoader.Destroy;
begin
//  if Assigned(FConfigItemInfos) then
//    FConfigItemInfos.Free;

  if Assigned(FConfigItems) then
    FConfigItems.Free;

  if FOwnQuery then
    FQuery.Free;

  inherited;
end;

procedure TSQLConfigLoader.ExtractFieldNames;
begin
//  FConfigItemInfos.Clear;
  FConfigItems.Clear;

  ExtractConfigAttribute(procedure(ASectionName, AKeyName: string; ADefaultValue: TValue)
  begin
//    FConfigItemInfos.Add(TConfigItemInfo.Create(AKeyName, ADefaultValue));
    FConfigItems.Add(AKeyName, ADefaultValue);
  end);
end;

procedure TSQLConfigLoader.DoInitialize;
begin
  if not Assigned(FConnection) then
    raise Exception.CreateFmt(SNotAssigned, [ClassName, 'Connection']);

  if FTableName = '' then
    FTableName := FConfig.ConfigName;

  if FTableName = '' then
    raise Exception.CreateFmt(SNotAssigned, [ClassName, 'TableName']);


  if FFetchAll then
    ExtractFieldNames;

  FOwnQuery := False;
  if not Assigned(FQuery) then
  begin
    FOwnQuery := True;
    FQuery := TFDQuery.Create(nil);
    FQuery.Connection := FConnection;
  end;
end;

procedure TSQLConfigLoader.DoBeforeLoadConfig;
var
//  Info: TConfigItemInfo;
  I: Integer;
  SQL, Fields, Conds: string;
begin
  inherited;

  Fields := '''''';
//  for

  for I := 0 to FConfigItems.Count - 1 do
    Fields := Fields + ', ' + FConfigItems.Keys.ToArray[I];
  Conds := ' 1> 0';

  SQL := Format('SELECT %s FROM %s WHERE %s', [Fields, FTableName, Conds]);
  FQuery.Close;
  FQuery.SQL.Text := SQL;
  FQuery.Open;
end;

procedure TSQLConfigLoader.DoAfterLoadConfig;
begin
  inherited;

  FQuery.Close;
end;

procedure TSQLConfigLoader.DoBeforeSaveConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoAfterSaveConfig;
var
  I: Integer;
  Fields: string;
begin
  inherited;

  for I := 0 to FConfigItems.Count - 1 do
    Fields := Fields + ', ' + FConfigItems.Values.ToArray[I].Value.ToString;

  WriteLn(Fields);
end;

procedure TSQLConfigLoader.DoClearData;
begin
  inherited;

end;

function TSQLConfigLoader.DoReadValue(const ASection, AKey: string;
  ADefault: TValue): TValue;
var
  Field: TField;
begin
  if FFetchAll then
  begin
    if FQuery.RecordCount = 0 then
      Exit(ADefault);

    Field := FQuery.FindField(AKey);
    if not Assigned(Field) then
      raise Exception.CreateFmt(SNotFoundField, [AKey]);

    if Field.IsNull then
      Exit(ADefault);

    case ADefault.TypeInfo.Kind of
      tkString, tkLString, tkWString, tkUString:
        Result := TValue.From<string>(Field.AsString);

      tkInteger, tkInt64:
        Result := TValue.From<Integer>(Field.AsInteger);

      tkFloat:
        if ADefault.TypeInfo = TypeInfo(TDateTime) then
          Result := TValue.From<TDateTime>(Field.AsDateTime)
        else
          Result := TValue.From<Double>(Field.AsFloat);

      tkEnumeration:
        if ADefault.TypeInfo = TypeInfo(Boolean) then
          Result := TValue.From<Boolean>(Field.AsBoolean)
        else
        begin
          var IntVal := Field.AsInteger;
          Result := TValue.FromOrdinal(ADefault.TypeInfo, IntVal);
        end
    else
      Result := TValue.Empty;
    end;

  end;
end;

procedure TSQLConfigLoader.DoWriteValue(const ASection, AKey: string;
  AValue: TValue);
var
  Item: TConfigItem;
begin
  inherited;

  Item := FConfigItems.Items[AKey];
  if not Assigned(Item) then
    raise Exception.CreateFmt(SNotFoundField, [ClassName, AKey]);

//  case AValue.TypeInfo.Kind of
//    tkString, tkLString, tkWString, tkUString:
//      Item.Value := TValue
//      FIniFile.WriteString(ASection, AKey, AValue.AsString);
//
//    tkInteger:
//      FIniFile.WriteInteger(ASection, AKey, AValue.AsInteger);
//
//    tkInt64:
//      FIniFile.WriteInt64(ASection, AKey, AValue.AsInt64);
//
//    tkFloat:
//      if AValue.TypeInfo = TypeInfo(TDateTime) then
//        FIniFile.WriteDateTime(ASection, AKey, AValue.AsExtended)
//      else
//        FIniFile.WriteFloat(ASection, AKey, AValue.AsExtended);
//
//    tkEnumeration:
//      if AValue.TypeInfo = TypeInfo(Boolean) then
//        FIniFile.WriteBool(ASection, AKey, AValue.AsBoolean)
//      else
//        FIniFile.WriteInteger(ASection, AKey, AValue.AsOrdinal);
//  else
//    raise Exception.CreateFmt(STypeNotSupported, [ClassName, AValue.TypeInfo.Name]);
//  end;

  Item.Value := AValue;
end;

procedure TSQLConfigLoader.SetConnection(const Value: TFDConnection);
begin
  FConnection := Value;
end;

procedure TSQLConfigLoader.SetQuery(const Value: TFDQuery);
begin
  FQuery := Value;
  FQuery.Connection
end;

end.

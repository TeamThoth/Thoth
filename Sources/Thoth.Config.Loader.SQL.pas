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
    FSQLExecutor: ISQLConfigExecutor;
    FTableName: string;

    /// <Summary>Config 객체에서 필드 정보 추출</Summary>
//    procedure ExtractFieldNames;
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
    constructor Create(ASQLExecutor: ISQLConfigExecutor);
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  Thoth.ResourceStrings;


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

constructor TSQLConfigLoader.Create(ASQLExecutor: ISQLConfigExecutor);
begin
  FSQLExecutor := ASQLExecutor;
end;

destructor TSQLConfigLoader.Destroy;
begin

  inherited;
end;

procedure TSQLConfigLoader.DoInitialize;
begin
  if FTableName = '' then
    FTableName := FConfig.ConfigName;

  if FTableName = '' then
    raise Exception.CreateFmt(SNotAssigned, [ClassName, 'TableName']);
end;

procedure TSQLConfigLoader.DoBeforeLoadConfig;
begin
end;

procedure TSQLConfigLoader.DoAfterLoadConfig;
begin
  FSQLExecutor.Close;
end;

procedure TSQLConfigLoader.DoBeforeSaveConfig;
begin
end;

procedure TSQLConfigLoader.DoAfterSaveConfig;
begin
  FSQLExecutor.Close;
end;

procedure TSQLConfigLoader.DoClearData;
begin
  FSQLExecutor.DeleteAll;
end;

function TSQLConfigLoader.DoReadValue(const ASection, AKey: string;
  ADefault: TValue): TValue;
var
  Field: TField;
  V: Variant;
begin
  Field := FSQLExecutor.FetchField(ASection, AKey);

  if not Assigned(Field) then
    Exit(ADefault);

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

procedure TSQLConfigLoader.DoWriteValue(const ASection, AKey: string;
  AValue: TValue);
var
  LValue: TValue;
  Item: TConfigItem;
begin
  inherited;

  case AValue.TypeInfo.Kind of
    tkEnumeration:
      if AValue.TypeInfo = TypeInfo(Boolean) then
        LValue := TValue.From<Boolean>(AValue.AsBoolean)
      else
        LValue := TValue.From<Integer>(AValue.AsOrdinal);
  else
    LValue := AValue;
  end;

  FSQLExecutor.UpdateField(ASection, AKey, AValue);
end;

end.

unit Thoth.Config.Loader.SQL;

interface

uses
  Thoth.Config.Types,
  Thoth.Config.Loader,
  Thoth.Config.SQLExecutor,
  // FireDAC
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,

  System.Rtti, System.Generics.Collections;

type
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
  System.Variants,
  Thoth.ResourceStrings;


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
  FSQLExecutor.FetchesBegin;
end;

procedure TSQLConfigLoader.DoAfterLoadConfig;
begin
  FSQLExecutor.FetchesEnd;
end;

procedure TSQLConfigLoader.DoBeforeSaveConfig;
begin
  FSQLExecutor.FetchesBegin;
end;

procedure TSQLConfigLoader.DoAfterSaveConfig;
begin
  FSQLExecutor.FetchesEnd;
end;

procedure TSQLConfigLoader.DoClearData;
begin
  FSQLExecutor.DeleteAll;
end;

function TSQLConfigLoader.DoReadValue(const ASection, AKey: string;
  ADefault: TValue): TValue;
var
  Value: Variant;
begin
  Value := FSQLExecutor.FetchField(ASection, AKey);

  if VarIsNull(Value) then
    Exit(ADefault);

  case ADefault.TypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      Result := TValue.From<string>(Value);

    tkInteger, tkInt64:
      Result := TValue.From<Integer>(Value);

    tkFloat:
      if ADefault.TypeInfo = TypeInfo(TDateTime) then
        Result := TValue.From<TDateTime>(VarToDateTime(Value))
      else
        Result := TValue.From<Double>(Value);

    tkEnumeration:
      if ADefault.TypeInfo = TypeInfo(Boolean) then
        Result := TValue.From<Boolean>(Value)
      else
      begin
        var IntVal: Integer := Value;
        Result := TValue.FromOrdinal(ADefault.TypeInfo, IntVal);
      end
  else
    Result := TValue.Empty;
  end;
end;

procedure TSQLConfigLoader.DoWriteValue(const ASection, AKey: string;
  AValue: TValue);
begin
  inherited;

  FSQLExecutor.UpdateFieldData(ASection, AKey, AValue.AsVariant);
end;

end.

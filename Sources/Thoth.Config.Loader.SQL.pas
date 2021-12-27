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
  TConfigItemInfo = record
    KeyName: string;
    DefaultValue: TValue;

    constructor Create(AKeyName: string; ADefaultValue: TValue);
  end;

  TSQLConfigLoader = class(TCustomConfigLoader)
  private
    FFetchAll: Boolean;
    FConnection: TFDConnection;
    FOwnQuery: Boolean;
    FQuery: TFDQuery;

    FConfigItemInfos: TList<TConfigItemInfo>;

    FTableName: string;
    procedure SetConnection(const Value: TFDConnection);
    procedure SetQuery(const Value: TFDQuery);

    /// <Summary>Config 객체에서 필드 정보 추출</Summary>
    procedure ExtractFieldNames(AConfig: IConfig);
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


{ TConfigItemInfo }

constructor TConfigItemInfo.Create(AKeyName: string; ADefaultValue: TValue);
begin
  KeyName := AKeyName;
  DefaultValue := ADefaultValue;
end;

{ TSQLConfigLoader }

constructor TSQLConfigLoader.Create(AFetchAll: Boolean);
begin
  FFetchAll := AFetchAll;

  if FFetchAll then
  begin
//    FDictionary := TDictionary<string, TValue>.Create;
    FConfigItemInfos := TList<TConfigItemInfo>.Create;
  end;
end;

destructor TSQLConfigLoader.Destroy;
begin
//  if Assigned(FDictionary) then
//    FDictionary.Free;
  if Assigned(FConfigItemInfos) then
    FConfigItemInfos.Free;

  if FOwnQuery then
    FQuery.Free;

  inherited;
end;

procedure TSQLConfigLoader.ExtractFieldNames(AConfig: IConfig);
begin
  FConfigItemInfos.Clear;

  ExtractConfigAttribute(procedure(ASectionName, AKeyName: string; ADefaultValue: TValue)
  begin
    FConfigItemInfos.Add(TConfigItemInfo.Create(AKeyName, ADefaultValue));
  end);
end;

procedure TSQLConfigLoader.DoInitialize;
begin
  if not Assigned(FConnection) then
    raise Exception.CreateFmt(SNotAssigned, ['Connection']);

  if FFetchAll then
    ExtractFieldNames(FConfig);

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
  Info: TConfigItemInfo;
  SQL, Fields, Conds: string;
begin
  inherited;

  Fields := '''''';
  for Info in FConfigItemInfos do
    Fields := Fields + ', ' + Info.KeyName;
  Conds := ' 1> 0';

  SQL := Format('SELECT %s FROM %s WHERE %s', [Fields, FTableName, Conds]);
  FQuery.Close;
  FQuery.SQL.Text := SQL;
  FQuery.Open;
end;

procedure TSQLConfigLoader.DoAfterLoadConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoAfterSaveConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoBeforeSaveConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoClearData;
begin
  inherited;

end;

function TSQLConfigLoader.DoReadValue(const ASection, AKey: string;
  ADefault: TValue): TValue;
begin
end;

procedure TSQLConfigLoader.DoWriteValue(const ASection, AKey: string;
  AValue: TValue);
begin
  inherited;

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

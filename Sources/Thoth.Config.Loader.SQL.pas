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
  TSQLConfigLoader = class(TCustomConfigLoader)
  private
    FFetchAll: Boolean;
    FConnection: TFDConnection;
    FQuery: TFDQuery;

    FDictionary: TDictionary<string, TValue>;
    FDbFieldNames: TList<string>;

    FTableName: string;
    procedure SetConnection(const Value: TFDConnection);
    procedure SetQuery(const Value: TFDQuery);

    procedure CollectFields;
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


{ TSQLConfigLoader }

procedure TSQLConfigLoader.CollectFields;
begin

end;

constructor TSQLConfigLoader.Create(AFetchAll: Boolean);
begin
  FFetchAll := AFetchAll;

  if FFetchAll then
  begin
    FDictionary := TDictionary<string, TValue>.Create;
    FDbFieldNames := TList<string>.Create;
  end;
end;

destructor TSQLConfigLoader.Destroy;
begin
  if Assigned(FDictionary) then
    FDictionary.Free;
  if Assigned(FDbFieldNames) then
    FDbFieldNames.Free;

  inherited;
end;

procedure TSQLConfigLoader.DoInitialize;
begin
  if not Assigned(FConnection) then
    raise Exception.CreateFmt(SNotAssigned, ['Connection']);
end;

procedure TSQLConfigLoader.DoAfterLoadConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoAfterSaveConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoBeforeLoadConfig;
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

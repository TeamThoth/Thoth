unit TestsDatas;

interface

uses
  Thoth.Config,
  Thoth.Config.Types,
  Thoth.Config.SQLExecutor,

  System.Classes, System.Types, System.Rtti,
  Vcl.Forms,
  Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Def, FireDAC.Stan.Param, FireDAC.Stan.Async, FireDAC.DApt
;

const
  CONFIG_NAME = 'ThConfig';

type
  TRec1 = record
    WS: TWindowState;
    Int: Integer;
  end;

{$REGION 'Config class'}
  [ConfigName(CONFIG_NAME)]
  TTestConfig = class(TThothConfig)
  private
    FInt: Integer;
    FIntDef: Integer;
    FStr: string;
    FDtm: TDatetime;
    FRec1: TRec1;
    FBool: Boolean;
    FWindowState: TWindowState;
    FDbl: Double;
    FWindowBounds: TRect;
    FDtmStr: TDatetime;
  public
    [ConfigItem('TestSect', 10)]
    property Int: Integer read FInt write FInt;

    [ConfigItem('TestSect')]
    property IntDef: Integer read FIntDef write FIntDef;

    [ConfigItem('TestSect', 'abcd')]
    property Str: string read FStr write FStr;

    [ConfigItem('TestSect', False)]
    property Bool: Boolean read FBool write FBool;

    [ConfigItem('TestSect', 'wsMaximized')]
    [ConfigKeyName('WS')]
    property WindowState: TWindowState read FWindowState write FWindowState;

    [ConfigItem('TestSect')]
    [ConfigTargetFields('WS, Int', 'wsMinimized, 20')]
    property Rec1: TRec1 read FRec1 write FRec1;

    [ConfigItem('TestSect')]
    [ConfigTargetFields('Left, Top', '30,40')]
    property WindowBounds: TRect read FWindowBounds write FWindowBounds;

    [ConfigItem('TestSect')]
    property Dtm: TDatetime read FDtm write FDtm;

    [ConfigItem('TestSect', '2021-12-23')]
    [ConfigKeyName('DateTimeStr')]
    property DtmStr: TDatetime read FDtmStr write FDtmStr;

    [ConfigItem('TestSect', 10.23)]
    property Dbl: Double read FDbl write FDbl;
  end;
{$ENDREGION}

{$REGION 'SQLConfig data'}
const
  CONFIG_CREATE_SQL = 'CREATE TABLE IF NOT EXISTS ' + CONFIG_NAME + '(' +
    '   idx integer PRIMARY KEY AUTOINCREMENT' +
    ',  type varchar(8)' +
    ',  key VARCHAR(32)' +
    ',  value VARCHAR(256)' +
  ')';

type
  { TODO : 상속 시 구현이 어려워짐 }
  TSQLConfigFireDACExecutor = class(TSQLConfigExecutor)
  private
    FQuery: TFDQuery;
    FIsOwnQuery: Boolean;
  public
//    procedure FetchesBegin; override;
    function FetchFieldValue(const ASection, AKey: string): Variant; override;
    procedure UpdateFieldValue(const ASection, AKey: string; AValue: Variant); override;
    procedure FetchesEnd; override;
    procedure DeleteAll; override;

    constructor Create(AConnection: TFDConnection; AQuery: TFDQuery = nil);
    destructor Destroy; override;
  end;
{$ENDREGION}


implementation

uses
  System.SysUtils, System.Variants;

{ TSQLConfigFireDACExecutor }

constructor TSQLConfigFireDACExecutor.Create(AConnection: TFDConnection;
  AQuery: TFDQuery);
begin
  FQuery := AQuery;
  FIsOwnQuery := False;
  if not Assigned(FQuery) then
  begin
    FQuery := TFDQuery.Create(nil);
    FQuery.Connection := AConnection;

    FIsOwnQuery := True;
  end;
end;

destructor TSQLConfigFireDACExecutor.Destroy;
begin
  if FIsOwnQuery then
    FQuery.Free;

  inherited;
end;

function TSQLConfigFireDACExecutor.FetchFieldValue(const ASection, AKey: string): Variant;
begin
  FQuery.Close;
  FQuery.SQL.Text := Format('SELECT value FROM %s WHERE type = :TYPE AND key = :KEY', [TableName]);
  FQuery.Params[0].AsString := ASection;
  FQuery.Params[1].AsString := AKey;
  FQuery.Open;

  if FQuery.RecordCount = 0 then
    Exit(Null);

  Result := FQuery.Fields[0].AsVariant;
end;

procedure TSQLConfigFireDACExecutor.UpdateFieldValue(const ASection,
  AKey: string; AValue: Variant);
begin
  FQuery.ExecSQL(Format('DELETE FROM %s WHERE type = :TYPE AND key = :KEY', [TableName]), [ASection, AKey]);

  FQUery.Prepare;
  FQuery.SQL.Text := Format('INSERT INTO %s(type, key, value) ', [TableName]) +
                      'VALUES(:TYPE, :KEY, :VALUE)';
  FQuery.Params[0].AsString := ASection;
  FQuery.Params[1].AsString := AKey;
  FQuery.Params[2].Value := AValue;
  FQuery.ExecSQL;
end;

procedure TSQLConfigFireDACExecutor.FetchesEnd;
begin
  FQuery.Close;
end;

procedure TSQLConfigFireDACExecutor.DeleteAll;
begin
  FQuery.ExecSQL('DELETE FROM ' + TableName);
end;

end.

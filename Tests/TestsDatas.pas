unit TestsDatas;

interface

uses
  Thoth.Config,
  Thoth.Config.Types,
  Thoth.Config.SQLExecutor,

  Vcl.Forms,
  System.Types, System.Rtti,
  Data.DB,
  FireDAC.Comp.Client;

type
  TRec1 = record
    WS: TWindowState;
    Int: Integer;
  end;

{$REGION 'IniConfig'}
  [ConfigName('ThConfig.ini')]
  TIniConfig = class(TThothConfig)
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

{$REGION 'SQLConfig'}
  [ConfigName('ThConfig')] // Database
  TSQLConfig = class(TThothConfig)
  private
    FInt: Integer;
    FStr: string;
    FRec1: TRec1;
    FDtmStr: TDatetime;
    FBool: Boolean;
  public
    [ConfigItem('TestSect', 10)] // TableName
    property Int: Integer read FInt write FInt;

    [ConfigItem('TestSect', 'abcd')]
    property Str: string read FStr write FStr;

    [ConfigItem('TestSect', False)]
    property Bool: Boolean read FBool write FBool;

    [ConfigItem('TestSect')]
    [ConfigKeyName('')]
    [ConfigTargetFields('WS, Int', 'wsMinimized, 20', 'WS, TestInt')]
    property TestWS: TRec1 read FRec1 write FRec1;

    [ConfigItem('TestSect', '2021-12-23')]
    [ConfigKeyName('DateTimeStr')]
    property DtmStr: TDatetime read FDtmStr write FDtmStr;

    destructor Destroy; override;
  end;

const
  CONFIG_CREATE_SQL = 'CREATE TABLE IF NOT EXISTS ThConfig(' +
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
    function FetchField(const ASection, AKey: string): Variant; override;
    procedure UpdateFieldData(const ASection, AKey: string; AValue: Variant); override;
    procedure FetchesEnd; override;
    procedure DeleteAll; override;

    constructor Create(AConnection: TFDConnection; AQuery: TFDQuery = nil);
    destructor Destroy; override;
  end;
{$ENDREGION}


implementation

uses
  System.Variants;

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

function TSQLConfigFireDACExecutor.FetchField(const ASection, AKey: string): Variant;
begin
  FQuery.Close;
  FQuery.SQL.Text := 'SELECT value FROM ThConfig WHERE type = :TYPE AND key = :KEY';
  FQuery.Params[0].AsString := ASection;
  FQuery.Params[1].AsString := AKey;
  FQuery.Open;

  if FQuery.RecordCount = 0 then
    Exit(Null);

  Result := FQuery.Fields[0].AsVariant;
end;

procedure TSQLConfigFireDACExecutor.UpdateFieldData(const ASection,
  AKey: string; AValue: Variant);
begin
  FQuery.ExecSQL('DELETE FROM ThConfig WHERE type = :TYPE AND key = :KEY', [ASection, AKey]);

  FQUery.Prepare;
  FQuery.SQL.Text := 'INSERT INTO ThConfig(type, key, value) ' +
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
  FQuery.ExecSQL('DELETE FROM ThConfig');
end;

{ TSQLConfig }

destructor TSQLConfig.Destroy;
begin
  inherited;
end;

end.

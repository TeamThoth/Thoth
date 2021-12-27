unit TestsDatas;

interface

uses
  Thoth.Config,
  Thoth.Config.Types,
  Vcl.Forms, System.Types;

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
  public
    [ConfigItem('TestSect', 10)] // TableName
    property Int: Integer read FInt write FInt;

    [ConfigItem('TestSect', 'abcd')]
    property Str: string read FStr write FStr;

    [ConfigItem('TestSect')]
    [ConfigKeyName('')]
    [ConfigTargetFields('WS, Int', 'wsMinimized, 20', 'WS, TestInt')]
    property TestWS: TRec1 read FRec1 write FRec1;
  end;

const
  CONFIG_CREATE_SQL = 'CREATE TABLE IF NOT EXISTS ThConfig(' +
    '   user_id VARCHAR(16) NOT NULL' +
    ',  int INTEGER' +
    ',  Str VARCHAR(256)' +
    ',  WS VARCHAR(256)' +
    ',  TestInt INTEGER' +
  ')';
{$ENDREGION}


implementation

end.

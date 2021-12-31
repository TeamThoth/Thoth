unit Thoth.Config.SQLExecutor;

interface

uses
  System.Rtti;

type
  ISQLConfigExecutor = interface
    ['{1AE931AD-05FD-4FA9-837F-E4E88FDD674F}']
    procedure FetchesBegin;
    function FetchFieldValue(const ASection, AKey: string): Variant;
    procedure UpdateFieldValue(const ASection, AKey: string; AValue: Variant);
    procedure FetchesEnd;
    procedure DeleteAll;

    procedure SetTableName(const Value: string);
  end;

  // Role: SQLConfig 데이터를 읽고/저장 하는 작업을 수행
  TSQLConfigExecutor = class abstract(TInterfacedObject, ISQLConfigExecutor)
  private
    procedure SetTableName(const Value: string);
  protected
    FTableName: string;
  public
    /// <summary>데이터 읽기/쓰기 전 호출</summary>
    procedure FetchesBegin; virtual;
    /// <summary>Section과 Key에 해당하는 필드를 조회(또는 이동)해 필드 객체 반환</summary>
    function FetchFieldValue(const ASection, AKey: string): Variant; virtual; abstract;
    /// <summary>Section과 Key에 해당하는 필드에 AValue 저장</summary>
    procedure UpdateFieldValue(const ASection, AKey: string; AValue: Variant); virtual; abstract;
    /// <summary>데이터 읽기/쓰기 후 호출</summary>
    procedure FetchesEnd; virtual;
    /// <summary>설정 데이터 전체 삭제</summary>
    procedure DeleteAll; virtual; abstract;

    property TableName: string read FTableName write SetTableName;
  end;


implementation

{ TSQLConfigExecutor }

procedure TSQLConfigExecutor.FetchesBegin;
begin
end;

procedure TSQLConfigExecutor.FetchesEnd;
begin
end;

procedure TSQLConfigExecutor.SetTableName(const Value: string);
begin
  FTableName := Value;
end;

end.

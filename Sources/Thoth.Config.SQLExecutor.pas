unit Thoth.Config.SQLExecutor;

interface

uses
  System.Rtti;

type
  ISQLConfigExecutor = interface
    ['{1AE931AD-05FD-4FA9-837F-E4E88FDD674F}']
    procedure FetchesBegin;
    function FetchField(const ASection, AKey: string): Variant;
    procedure UpdateFieldData(const ASection, AKey: string; AValue: Variant);
    procedure FetchesEnd;
    procedure DeleteAll;
  end;

  // Role: SQLConfig �����͸� �а�/���� �ϴ� �۾��� ����
  TSQLConfigExecutor = class abstract(TInterfacedObject, ISQLConfigExecutor)
  private
    procedure SetTableName(AValue: string);
  protected
    FTableName: string;
  public
    /// <summary>������ �б�/���� �� ȣ��</summary>
    procedure FetchesBegin; virtual;
    /// <summary>Section�� Key�� �ش��ϴ� �ʵ带 ��ȸ(�Ǵ� �̵�)�� �ʵ� ��ü ��ȯ</summary>
    function FetchField(const ASection, AKey: string): Variant; virtual; abstract;
    /// <summary>Section�� Key�� �ش��ϴ� �ʵ忡 AValue ����</summary>
    procedure UpdateFieldData(const ASection, AKey: string; AValue: Variant); virtual; abstract;
    /// <summary>������ �б�/���� �� ȣ��</summary>
    procedure FetchesEnd; virtual;
    /// <summary>���� ������ ��ü ����</summary>
    procedure DeleteAll; virtual; abstract;
  end;


implementation

{ TSQLConfigExecutor }

procedure TSQLConfigExecutor.FetchesBegin;
begin
end;

procedure TSQLConfigExecutor.FetchesEnd;
begin
end;

procedure TSQLConfigExecutor.SetTableName(AValue: string);
begin
  FTableName := AValue;
end;

end.

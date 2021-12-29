unit Thoth.Config.SQLExecutor.FireDAC;

interface

uses
  Thoth.Config.Types,
  Data.DB,
  System.Rtti,
  FireDAC.Comp.Client;

type
  // SQL를 실행하고 필드를 (찾아)제공
  TSQLConfigFireDACExecutor = class abstract(TInterfacedObject, ISQLConfigExecutor)
  protected
    FQuery: TFDQuery;
  public
    procedure FetchAll; virtual;
    function FetchField(const ASection, AKey: string): TField; virtual;
    procedure UpdateField(const ASection, AKey: string; AValue: TValue); virtual;
    procedure DeleteAll; virtual;
    procedure Close; virtual;

    constructor Create(AConnection: TFDConnection; AQuery: TFDQuery = nil);
  end;


implementation

{ TSQLConfigExecutor }

constructor TSQLConfigFireDACExecutor.Create(AConnection: TFDConnection; AQuery: TFDQuery);
begin
  FQuery := AQuery;
  if not Assigned(FQuery) then
  begin
    FQuery := TFDQuery.Create(nil);
    FQuery.Connection := AConnection;
  end;
end;

procedure TSQLConfigFireDACExecutor.FetchAll;
begin
end;

function TSQLConfigFireDACExecutor.FetchField(const ASection, AKey: string): TField;
begin
  FQuery.Close;
  FQuery.SQL.Text := 'SELECT value FROM ThConfig WHERE type = :TYPE AND key = :KEY';
  FQuery.Params[0].AsString := ASection;
  FQuery.Params[1].AsString := AKey;
  FQuery.Open;

  if FQuery.RecordCount = 0 then
    Exit(nil);

  Result := FQuery.Fields[0];
end;

procedure TSQLConfigFireDACExecutor.UpdateField(const ASection, AKey: string; AValue: TValue);
begin
  FQuery.Close;
  FQuery.Params.Clear;
  FQuery.SQL.Text := 'INSERT OR REPLACE INTO ThConfig(type, key, value) ' +
    'VALUES(:TYPE, :KEY, :VALUE)';
  FQuery.Params[0].AsString := ASection;
  FQuery.Params[1].AsString := AKey;
  FQuery.Params[2].Value := AValue.AsVariant;
  FQuery.ExecSQL;
end;

procedure TSQLConfigFireDACExecutor.Close;
begin
  FQuery.Close;
end;

procedure TSQLConfigFireDACExecutor.DeleteAll;
begin
  FQuery.Close;
  FQuery.SQL.Text := 'DELETE FROM ThConfig';
  FQuery.ExecSQL;
end;

end.

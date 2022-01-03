unit ObservableFieldModule;

interface

uses
  Thoth.Bind.ObservableField,
  System.SysUtils, System.Classes;

type
  TdmViewModel = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FLimit: TObservableField<Integer>;
  public
    property Limit: TObservableField<Integer> read FLimit write FLimit;

    procedure ChangeLimit(Value: Integer);
  end;

var
  dmViewModel: TdmViewModel;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmViewModel.ChangeLimit(Value: Integer);
begin
  Limit.Value := Value;
end;

procedure TdmViewModel.DataModuleCreate(Sender: TObject);
begin
  FLimit := TObservableField<Integer>.Create;
end;

procedure TdmViewModel.DataModuleDestroy(Sender: TObject);
begin
  FLimit.Free;
end;

end.

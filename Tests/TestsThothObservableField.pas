unit TestsThothObservableField;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TThothObservableFieldTest = class
  public
    [Test]
    procedure TestSetValue;

    [Test]
    procedure TestChangeControl;
  end;

implementation

{ TThothObservableFieldTest }

uses
  Vcl.StdCtrls, Vcl.Controls,
  Thoth.Bind.ObservableField;

procedure TThothObservableFieldTest.TestSetValue;
var
  Edit: TEdit;
  Field: TObservableField<Integer>;
begin
  Edit := TEdit.Create(nil);

  Field := TObservableField<Integer>.Create;
  Field.BindComponent(Edit, 'Text');

  Field.Value := 100;

  Assert.AreEqual(Edit.Text, '100');

  Edit.Free;
end;

procedure TThothObservableFieldTest.TestChangeControl;
var
  Edit: TEdit;
  Field: TObservableField<Integer>;
begin
  Edit := TEdit.Create(nil);

  Field := TObservableField<Integer>.Create;
  Field.BindComponent(Edit, 'Text');

  Edit.SetFocus;

  Edit.Text := '300';
  Edit.Perform(CM_EXIT, 0, 0);

  Assert.AreEqual(Field.Value, 300);

  Edit.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TThothObservableFieldTest);

end.

unit TestsThothObservableField;

interface

uses
  DUnitX.TestFramework,
  TestObservableFieldForm;

type
  [TestFixture]
  TThothObservableFieldTest = class
  private
    FForm: TfrmObsFld;
  public
    [Setup]     procedure Setup;
    [TearDown]  procedure TearDown;

    [Test]
    procedure TestSetValue;

    [Test]
    procedure TestChangeControl;

    [Test]
    procedure TestObserve;
    [Test]
    procedure TestMultiObserve;
  end;

implementation

uses
  Vcl.StdCtrls, Vcl.Controls,
  Thoth.Bind.ObservableField;

{ TThothObservableFieldTest }

procedure TThothObservableFieldTest.Setup;
begin
  FForm := TfrmObsFld.Create(nil);
end;

procedure TThothObservableFieldTest.TearDown;
begin
  FForm.Free;
end;

procedure TThothObservableFieldTest.TestSetValue;
var
  Field: TObservableField<Integer>;
begin
  Field := TObservableField<Integer>.Create;
  Field.BindComponent(FForm.Edit1, 'Text');

  Field.Value := 100;

  Assert.AreEqual(FForm.Edit1.Text, '100');
  Field.Free;
end;

procedure TThothObservableFieldTest.TestChangeControl;
var
  Field: TObservableField<Integer>;
begin
  Field := TObservableField<Integer>.Create;
  Field.BindComponent(FForm.Edit1, 'Text');

  FForm.Edit1.Text := '300';

//  FForm.Show;
//  FForm.Edit2.SetFocus;
  FForm.Edit1.Perform(CM_EXIT, 0, 0);

  Assert.AreEqual(Field.Value, 300);
  Field.Free;
end;

procedure TThothObservableFieldTest.TestObserve;
var
  Field: TObservableField<Integer>;
  WasCalled: Boolean;
begin
  Field := TObservableField<Integer>.Create;

  WasCalled := False;

  Field.Value := 100;
  Field.Observe(Self,
    procedure
    begin
      Assert.AreEqual(Field.Value, 200);
      WasCalled := True;
    end);

  Field.Value := 200;

  Assert.IsTrue(WasCalled);

  Field.RemoveObserve(Self);

  Field.Free;
end;

procedure TThothObservableFieldTest.TestMultiObserve;
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TThothObservableFieldTest);

end.

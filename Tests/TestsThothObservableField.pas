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
    procedure TestIntAndStrSetValue;

    [Test]
    procedure TestChangeControl;

    [Test]
    procedure TestEnumChangeControl;

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
  IntField: TObservableField<Integer>;
  StrField: TObservableField<string>;
begin
  IntField := TObservableField<Integer>.Create;
  StrField := TObservableField<string>.Create;

  IntField.BindComponent(FForm.Edit1, 'Width');
  IntField.Value := 100;
  Assert.AreEqual(FForm.Edit1.Width, 100);

  StrField.BindComponent(FForm.Edit1, 'Text');
  StrField.Value := 'abcde';
  Assert.AreEqual(FForm.Edit1.Text, 'abcde');

  IntField.Free;
  StrField.Free;
end;

procedure TThothObservableFieldTest.TestIntAndStrSetValue;
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

procedure TThothObservableFieldTest.TestEnumChangeControl;
var
  Field: TObservableField<TAlign>;
begin
  Field := TObservableField<TAlign>.Create;
  Field.BindComponent(FForm.pnlChild, 'Align');

//  FForm.pnlChild.Align := alClient;
//  Assert.AreEqual(Field.Value, alClient); // 변경을 감지하지 못함

  Field.Value := alRight;
  Assert.AreEqual(FForm.pnlChild.Align, alRight);
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
    procedure(Value: Integer)
    begin
      Assert.AreEqual(Value, 200);
      WasCalled := True;
    end);

  Field.Value := 200;

  Assert.IsTrue(WasCalled);

  Field.RemoveObserve(Self);

  Field.Free;
end;

procedure TThothObservableFieldTest.TestMultiObserve;
var
  Field: TObservableField<Integer>;
  CallCount: Integer;
begin
  Field := TObservableField<Integer>.Create;

  CallCount := 0;

  Field.Value := 100;
  Field.Observe(Self,
    procedure(Value: Integer)
    begin
      Inc(CallCount);
    end);
  Field.Observe(Self,
    procedure(Value: Integer)
    begin
      Inc(CallCount);
    end);

  Field.Value := 200;

  Assert.AreEqual(CallCount, 2);

  Field.RemoveObserve(Self);

  Field.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TThothObservableFieldTest);

end.

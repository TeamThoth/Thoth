unit Thoth.Bind.ObservableField;

interface

uses
  Thoth.Bind.BindList,
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TUpdateControlEvent<T> = procedure(const Value: T) of object;

  IObservableField = interface
  ['{81695AA3-9A63-4CC2-A406-619AACD4368A}']
    procedure BindComponent(AComponent: TComponent; AProperty: string);
    procedure RemoveBindComponent(AComponent: TComponent; AProperty: string = '');

    procedure Observe(AObject: TObject; ACallback: TProc);
    procedure RemoveObserve(AObject: TObject);
  end;

  TObservableField<T> = class(TInterfacedObject, IObservableField)
  private
    FBindList: TBindList<T>;

    FValue: T;
    function GetValue: T;
    procedure SetValue(const Value: T);

    procedure ValueChanged(const Value: T);
    procedure ControlValueChanged(const Value: T);
  public
    constructor Create;
    destructor Destroy; override;

    property Value: T read GetValue write SetValue;

    procedure BindComponent(AComponent: TComponent; AProperty: string);
    procedure RemoveBindComponent(AComponent: TComponent; AProperty: string = '');

    procedure Observe(AObject: TObject; ACallback: TProc);
    procedure RemoveObserve(AObject: TObject);

    procedure Notify;

    { TODO : 컴포넌트 제거 시 BindComp 정보 정리 }
  end;

implementation

uses
  Thoth.Utils, Thoth.ResourceStrings,
  System.Generics.Defaults,
  System.Rtti;

{ TObservableField<T> }

constructor TObservableField<T>.Create;
begin
  FBindList := TBindList<T>.Create;
  FBindList.OnControlValueChanged := ControlValueChanged;
end;

destructor TObservableField<T>.Destroy;
begin
  FBindList.Free;

  inherited;
end;

function TObservableField<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TObservableField<T>.Notify;
begin
  ValueChanged(FValue);
end;

procedure TObservableField<T>.Observe(AObject: TObject; ACallback: TProc);
begin

end;

procedure TObservableField<T>.RemoveObserve(AObject: TObject);
begin

end;

procedure TObservableField<T>.SetValue(const Value: T);
var
  Comparer: IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;
  if Comparer.Equals(FValue, Value) then
    Exit;

  FValue := Value;

  ValueChanged(Value);
end;

procedure TObservableField<T>.ControlValueChanged(const Value: T);
begin
  FValue := Value;
end;

procedure TObservableField<T>.ValueChanged(const Value: T);
begin
  FBindList.NotifyControls(Value);
end;

procedure TObservableField<T>.BindComponent(AComponent: TComponent;
  AProperty: string);
begin
  if not TRttiUtil.HasProperty(AComponent, AProperty) then
    raise Exception.CreateFmt(SNotFoundProperty, [AComponent.Name, AProperty]);

  FBindList.Add(AComponent, AProperty);
end;

procedure TObservableField<T>.RemoveBindComponent(AComponent: TComponent;
  AProperty: string);
begin

end;

end.

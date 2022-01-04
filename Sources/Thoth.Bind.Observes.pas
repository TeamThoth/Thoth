unit Thoth.Bind.Observes;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

type
  TObserveItem<T> = class
  private
    FCallback: TProc<T>;
    FInstance: TObject;
  public
    constructor Create(AObject: TObject; ACallback: TProc<T>);

    property Instance: TObject read FInstance;
    property Callback: TProc<T> read FCallback;

    procedure Notify(const Value: T);
  end;
  TObservingList<T> = class
  type
    TObserveItemCompare = class(TComparer<TObserveItem<T>>)
    public
      function Compare(const Left, Right: TObserveItem<T>): Integer; override;
    end;
  private
    FList: TObjectList<TObserveItem<T>>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AObject: TObject; ACallback: TProc<T>);

    procedure NotifyAll(const Value: T);
  end;

implementation

{ TObserveItem }

constructor TObserveItem<T>.Create(AObject: TObject; ACallback: TProc<T>);
begin
  FInstance := AObject;
  FCallback := ACallback;
end;

procedure TObserveItem<T>.Notify(const Value: T);
begin
  FCallback(Value);
end;

{ TObserveList<T>.TObserveItemCompare }

function TObservingList<T>.TObserveItemCompare.Compare(const Left,
  Right: TObserveItem<T>): Integer;
begin
  Result := -1;
  if (Left.Instance = Right.Instance) and (Left.Callback = Right.Callback) then
    Result := 0
//  else
//    Result := CompareStr(Left.Instance.ClassName, Right.Instance.ClassName);
end;

{ TObserveList<T> }

constructor TObservingList<T>.Create;
begin
  FList := TObjectList<TObserveItem<T>>.Create(TObserveItemCompare.Create, True);
end;

destructor TObservingList<T>.Destroy;
begin
  FList.Free;

  inherited;
end;

procedure TObservingList<T>.Add(AObject: TObject; ACallback: TProc<T>);
var
  Item: TObserveItem<T>;
begin
  Item := TObserveItem<T>.Create(AObject, ACallback);
  if FList.Contains(Item) then
  begin
    Item.Free;
    Exit;
  end;

  FList.Add(Item);
end;

procedure TObservingList<T>.NotifyAll(const Value: T);
var
  Item: TObserveItem<T>;
begin
  for Item in FList do
    Item.Notify(Value);
end;

end.

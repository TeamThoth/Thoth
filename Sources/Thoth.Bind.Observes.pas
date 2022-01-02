unit Thoth.Bind.Observes;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

type
  TObserveItem = class
  private
    FCallback: TProc;
    FInstance: TObject;
  public
    constructor Create(AObject: TObject; ACallback: TProc);

    property Instance: TObject read FInstance;
    property Callback: TProc read FCallback;

    procedure Notify;
  end;
  TObserveList<T> = class
  type
    TObserveItemCompare = class(TComparer<TObserveItem>)
    public
      function Compare(const Left, Right: TObserveItem): Integer; override;
    end;
  private
    FObserves: TObjectList<TObserveItem>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AObject: TObject; ACallback: TProc);

    procedure Notify(const Value: T);
  end;

implementation

{ TObserveItem }

constructor TObserveItem.Create(AObject: TObject; ACallback: TProc);
begin
  FInstance := AObject;
  FCallback := ACallback;
end;

procedure TObserveItem.Notify;
begin
  FCallback();
end;

{ TObserveList<T>.TObserveItemCompare }

function TObserveList<T>.TObserveItemCompare.Compare(const Left,
  Right: TObserveItem): Integer;
begin
  Result := -1;
  if (Left.Instance = Right.Instance) and (Left.Callback = Right.Callback) then
    Result := 0
//  else
//    Result := CompareStr(Left.Instance.ClassName, Right.Instance.ClassName);
end;

{ TObserveList<T> }

constructor TObserveList<T>.Create;
begin
  FObserves := TObjectList<TObserveItem>.Create(TObserveItemCompare.Create, True);
end;

destructor TObserveList<T>.Destroy;
begin
  FObserves.Free;

  inherited;
end;

procedure TObserveList<T>.Add(AObject: TObject; ACallback: TProc);
var
  Item: TObserveItem;
begin
  Item := TObserveItem.Create(AObject, ACallback);
  if FObserves.Contains(Item) then
  begin
    Item.Free;
    Exit;
  end;

  FObserves.Add(Item);
end;

procedure TObserveList<T>.Notify(const Value: T);
var
  Item: TObserveItem;
begin
  for Item in FObserves do
    Item.Notify;
end;

end.

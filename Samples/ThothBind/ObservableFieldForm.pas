unit ObservableFieldForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  ObservableFieldModule;

type
  TForm2 = class(TForm)
    TrackBar1: TTrackBar;
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  dmViewModel.Limit.Value := 30;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  if not TrackBar1.Observers.CanObserve(TObserverMapping.ControlValueID) then
    Memo1.Lines.Add('TrackBar1 is not support controlvalue observe');
  if not Edit1.Observers.CanObserve(TObserverMapping.ControlValueID) then
    Memo1.Lines.Add('Edit1 is not support controlvalue observe');

  dmViewModel.Limit.BindComponent(TrackBar1, 'Position'); // readonly(control <- data)
  dmViewModel.Limit.BindComponent(Edit1, 'Text'); // read-write(control <-> data)

  dmViewModel.Limit.Observe(Self, procedure
    begin
      Memo1.Lines.Add(dmViewModel.Limit.Value.ToString);
    end);
end;

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
  dmViewModel.Limit.Value := TTrackBar(Sender).Position;
end;

end.

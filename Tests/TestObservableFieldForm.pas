unit TestObservableFieldForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmObsFld = class(TForm)
    Edit1: TEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Edit2: TEdit;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmObsFld: TfrmObsFld;

implementation

{$R *.dfm}

end.

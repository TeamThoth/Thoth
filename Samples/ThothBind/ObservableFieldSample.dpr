program ObservableFieldSample;

uses
  Vcl.Forms,
  ObservableFieldForm in 'ObservableFieldForm.pas' {Form2},
  ObservableFieldModule in 'ObservableFieldModule.pas' {dmViewModel: TDataModule},
  Thoth.Bind.Bindings in '..\..\Sources\Thoth.Bind.Bindings.pas',
  Thoth.Bind.ObservableField in '..\..\Sources\Thoth.Bind.ObservableField.pas',
  Thoth.Bind.Observes in '..\..\Sources\Thoth.Bind.Observes.pas',
  Thoth.Classes in '..\..\Sources\Thoth.Classes.pas',
  Thoth.ResourceStrings in '..\..\Sources\Thoth.ResourceStrings.pas',
  Thoth.Utils in '..\..\Sources\Thoth.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmViewModel, dmViewModel);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

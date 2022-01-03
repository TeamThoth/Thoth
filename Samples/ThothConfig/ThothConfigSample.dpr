program ThothConfigSample;

uses
  Vcl.Forms,
  ConfigForm in 'ConfigForm.pas' {Form1},
  Thoth.Classes in '..\..\Sources\Thoth.Classes.pas',
  Thoth.Config.Attr in '..\..\Sources\Thoth.Config.Attr.pas',
  Thoth.Config.Loader.IniFile in '..\..\Sources\Thoth.Config.Loader.IniFile.pas',
  Thoth.Config.Loader in '..\..\Sources\Thoth.Config.Loader.pas',
  Thoth.Config.Loader.SQL in '..\..\Sources\Thoth.Config.Loader.SQL.pas',
  Thoth.Config in '..\..\Sources\Thoth.Config.pas',
  Thoth.Config.SQLExecutor in '..\..\Sources\Thoth.Config.SQLExecutor.pas',
  Thoth.Config.Types in '..\..\Sources\Thoth.Config.Types.pas',
  Thoth.Utils in '..\..\Sources\Thoth.Utils.pas',
  Thoth.ResourceStrings in '..\..\Sources\Thoth.ResourceStrings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

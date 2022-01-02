program ThothTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUNitX.MemoryLeakMonitor.FastMM4,
  {$ENDIF }
  DUnitX.TestFramework,
  TestsThothConfig in 'TestsThothConfig.pas',
  Thoth.Config in '..\Sources\Thoth.Config.pas',
  Thoth.Config.Loader in '..\Sources\Thoth.Config.Loader.pas',
  Thoth.Config.Types in '..\Sources\Thoth.Config.Types.pas',
  Thoth.LiveData in '..\Sources\Thoth.LiveData.pas',
  TestsThothLIveData in 'TestsThothLIveData.pas',
  Thoth.Config.Loader.IniFile in '..\Sources\Thoth.Config.Loader.IniFile.pas',
  Thoth.Utils in '..\Sources\Thoth.Utils.pas',
  Thoth.Classes in '..\Sources\Thoth.Classes.pas',
  Thoth.ResourceStrings in '..\Sources\Thoth.ResourceStrings.pas',
  Thoth.Config.Loader.SQL in '..\Sources\Thoth.Config.Loader.SQL.pas',
  TestsDatas in 'TestsDatas.pas',
  Thoth.Bind.ObservableField in '..\Sources\Thoth.Bind.ObservableField.pas',
  TestsThothObservableField in 'TestsThothObservableField.pas',
  Thoth.Config.SQLExecutor in '..\Sources\Thoth.Config.SQLExecutor.pas',
  TestObservableFieldForm in 'TestObservableFieldForm.pas' {frmObsFld},
  Thoth.Bind.Bindings in '..\Sources\Thoth.Bind.Bindings.pas',
  Thoth.Bind.Observes in '..\Sources\Thoth.Bind.Observes.pas';

{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
//  ReportMemoryLeaksOnShutdown := True;

{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.

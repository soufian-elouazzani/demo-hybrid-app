program Project1;

uses
  Vcl.Forms, Unit1, VersionInfo;

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'DemoApp v' + APP_VERSION;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.


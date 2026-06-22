program AutoLogon;



uses
  Vcl.Forms,
  libReg in 'Lib\libReg.pas',
  dllAdvAPI32 in 'API\dllAdvAPI32.pas',
  dllUser32 in 'API\dllUser32.pas',
  wndAutoLogon in 'Forms\wndAutoLogon.pas' {frmAutoLogon},
  wndAbout in 'Forms\wndAbout.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmAutoLogon, frmAutoLogon);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.

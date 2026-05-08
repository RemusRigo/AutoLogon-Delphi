program AutoLogon;

uses
  Vcl.Forms,
  wndAutoLogon in 'Forms\wndAutoLogon.pas' {frmAutoLogon},
  libReg in 'Lib\libReg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmAutoLogon, frmAutoLogon);
  Application.Run;
end.

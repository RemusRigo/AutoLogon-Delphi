unit wndAutoLogon;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmAutoLogon = class(TForm)
    CheckBox1: TCheckBox;
    grpBoxOptions: TGroupBox;
    rGroupType: TRadioGroup;
    edUserName: TEdit;
    lblUserName: TLabel;
    edPassword: TEdit;
    lblPassword: TLabel;
    edDomain: TEdit;
    lblDomain: TLabel;
    btnRead: TButton;
    btnDelete: TButton;
    btnSet: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAutoLogon: TfrmAutoLogon;

implementation

{$R *.dfm}

end.

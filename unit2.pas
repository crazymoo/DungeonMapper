unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, Buttons;

type

  { TfrmMapOptions }

  TfrmMapOptions = class(TForm)
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    spnWidth: TSpinEdit;
    spnHeight: TSpinEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMapOptions: TfrmMapOptions;

implementation

uses
  Unit1;

{$R *.lfm}

{ TfrmMapOptions }

procedure TfrmMapOptions.btnOkClick(Sender: TObject);
begin
  Form1.gridWidth := spnWidth.Value;
  Form1.gridHeight := spnHeight.Value;
  Form1.ModalResult:=mrOk;
  Close;
end;

procedure TfrmMapOptions.btnCancelClick(Sender: TObject);
begin
  Form1.ModalResult := mrCancel;
  Close;
end;

procedure TfrmMapOptions.FormShow(Sender: TObject);
begin
  spnWidth.Value := Form1.gridWidth;
  spnHeight.Value := Form1.gridHeight;
end;

end.


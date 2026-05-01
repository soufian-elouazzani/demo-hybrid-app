unit Unit1;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB, Datasnap.DBClient;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure LoadProducts;
  end;

var
  Form1: TForm1;

implementation
uses
  System.JSON, System.Net.HttpClient, VersionInfo;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Label1.Caption := Format('Demo App - Version %s (Build %s)', 
    [APP_VERSION, APP_BUILD]);
  LoadProducts;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  LoadProducts;
end;

procedure TForm1.LoadProducts;
var
  HTTP: THTTPClient;
  Response: IHTTPResponse;
  JSON: TJSONArray;
  i: Integer;
begin
  Memo1.Lines.Clear;
  HTTP := THTTPClient.Create;
  try
    Response := HTTP.Get('http://localhost:5000/products');
    if Response.StatusCode = 200 then
    begin
      JSON := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONArray;
      try
        for i := 0 to JSON.Count - 1 do
          Memo1.Lines.Add(Format('ID: %d, Name: %s, Price: $%s',
            [(JSON.Items[i] as TJSONObject).GetValue('Id').Value.ToInteger,
             (JSON.Items[i] as TJSONObject).GetValue('Name').Value,
             (JSON.Items[i] as TJSONObject).GetValue('Price').Value]));
      finally
        JSON.Free;
      end;
    end
    else
      Memo1.Lines.Add('Error: ' + Response.StatusCode.ToString);
  finally
    HTTP.Free;
  end;
end;
end.

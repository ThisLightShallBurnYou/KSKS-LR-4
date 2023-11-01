unit Maim;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPClient, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.DateUtils, idGlobal,
  FMX.Edit, FMX.ComboEdit, FMX.Objects;

type TPacket = packed record
  msLen:Byte;
  colorarray:array [1..40,1..40] of cardinal;
  w:integer;
  h:integer;
  msg:string[255];
end;

const commands: array [1..6] of string = (
    'drawline', 'drawellipse', 'drawtext', 'clear', 'drawimage','fillroundedrectangle'
);

// ������������ ��� ����� ������
type TCommand=(DRAW_LINE, DRAW_ELLIPSE, DRAW_TEXT, CLEAR, DRAW_IMAGE, FILL_ROUNDED_RECTANGLE);

type
  TForm1 = class(TForm)
    IdUDPClient1: TIdUDPClient;
    Button1: TButton;
    Memo1: TMemo;
    ComboEdit1: TComboEdit;
    Label1: TLabel;
    Image1: TImage;
    Timer1: TTimer;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    bmp:TBitmap;
    packet:TPacket;
    send_data:TIdBytes;
    sendcommand:TCommand;
  public
    { Public declarations }
    function DrawLineEncode(const sendcommand, parx1,pary1,parx2,pary2,parcolor:string):string;
    function DrawEllipseEncode(const sendcommand, elx1,ely1,elx2,ely2,parcolor:string):string;
    function DrawTextEncode(const sendcommand, tx1,ty1,tx2,ty2,text,parcolor:string):string;
    function ClearEncode(const sendcommand:string; const parcolor:string):string;
    function DrawImageEncode(const sendcommand:string; width,heigth:string):string;
    function FillRoundedRectangleEncode(const sendcommand:string; px1,py1,px2,py2,radius,parcolor:string):string;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var spl:TArray<string>; s:string; i:integer; iw,jw:integer; b:TBitmapData;
begin

  packet.msLen:=Length(Memo1.Text);
  SetLength(packet.msg,packet.msLen);

  s:=Memo1.Text;
  spl:=s.Split([' ']);

  for i:=1 to 6 do
  begin
    if commands[i]=spl[0] then
    begin
      sendcommand:=TCommand(i-1);
      case sendcommand of
      TCommand.DRAW_LINE:
        packet.msg:=DrawLineEncode((i-1).ToString,spl[1],spl[2],spl[3],spl[4],spl[5]);
      TCommand.DRAW_ELLIPSE:
        packet.msg:=DrawEllipseEncode((i-1).ToString,spl[1],spl[2],spl[3],spl[4],spl[5]);
      TCommand.DRAW_TEXT:
        packet.msg:=DrawTextEncode((i-1).ToString,spl[1],spl[2],spl[3],spl[4],spl[5],spl[6]);
      TCommand.CLEAR:
        packet.msg:=ClearEncode((i-1).ToString,spl[1]);
      TCommand.DRAW_IMAGE:
      begin
        packet.msg:=DrawImageEncode((i-1).ToString,spl[1],spl[2]);
        bmp:=TBitmap.CreateFromFile(spl[3]);

        packet.w:=bmp.Width;
        packet.h:=bmp.Height;


        bmp.Map(TMapAccess.Read,b);

        for iw:=1 to Round(bmp.Width) do
        for jw:=1 to Round(bmp.Height) do
          packet.colorarray[iw,jw]:=b.GetPixel(iw,jw);

        bmp.Unmap(b);
        Image1.Bitmap.Assign(bmp);

      end;
      TCommand.FILL_ROUNDED_RECTANGLE:
        packet.msg:=FillRoundedRectangleEncode((i-1).ToString,spl[1],spl[2],spl[3],spl[4],spl[5],spl[6]);
      end;
    end;
  end;

  IdUDPClient1.Active:=true;
  IdUDPClient1.Port:=5000;
  IdUDPClient1.Host:=ComboEdit1.Text;
  IdUDPClient1.Connect;

  if IdUDPClient1.Connected then
  begin
    SetLength(send_data,sizeof(packet));
    Move(packet,send_data[0],sizeof(packet));
    IdUDPClient1.SendBuffer(send_data);
  end;

  IdUDPClient1.Active:=false;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Timer1.Enabled:=not Timer1.Enabled;
end;

function TForm1.ClearEncode(const sendcommand:string; const parcolor: string): string;
var command:integer;
begin
try
    command:=Integer.Parse(sendcommand);
    Result:=command.ToString+' '+parcolor;
  except on EConvertError do
  begin
    ShowMessage('���� ��������!!!');
    Result:='3 '+'000000';
  end;
  end;
end;

function TForm1.DrawEllipseEncode(const sendcommand, elx1, ely1, elx2, ely2,
  parcolor: string): string;
var x1,y1,x2,y2,command:integer;
begin
  try
    x1:=Integer.Parse(elx1);
    y1:=Integer.Parse(ely1);
    x2:=Integer.Parse(elx2);
    y2:=Integer.Parse(ely2);
    command:=Integer.Parse(sendcommand);
    Result:=command.ToString+' '+x1.ToString+' '+y1.ToString+' '+x2.ToString+' '+y2.ToString+' '+parcolor;
  except on EConvertError do
  begin
    ShowMessage('���������� ������� �������!!!');
    Result:='1 0 0 0 0 '+parcolor;
  end;
  end;
end;

function TForm1.DrawImageEncode(const sendcommand: string; width,
  heigth: string): string;
var w,h,command:integer;
begin
  try
    w:=Integer.Parse(width);
    h:=Integer.Parse(heigth);
    command:=Integer.Parse(sendcommand);
    Result:=command.ToString+' '+w.ToString+' '+h.ToString;
  except on EConvertError do
  begin
    ShowMessage('������� �������!!!');
    Result:='4 0 0';
  end;
  end;
end;

function TForm1.DrawLineEncode(const sendcommand, parx1, pary1, parx2, pary2,
  parcolor: string): string;
var x1,y1,x2,y2,command:integer;
begin
  try
    x1:=Integer.Parse(parx1);
    y1:=Integer.Parse(pary1);
    x2:=Integer.Parse(parx2);
    y2:=Integer.Parse(pary2);
    command:=Integer.Parse(sendcommand);
    Result:=command.ToString+' '+x1.ToString+' '+y1.ToString+' '+x2.ToString+' '
    +y2.ToString+' '+parcolor;
  except on EConvertError do
  begin
    ShowMessage('���������� ����� �������!!!');
    Result:='0 0 0 0 0 '+parcolor;
  end;
  end;
end;

function TForm1.DrawTextEncode(const sendcommand, tx1, ty1, tx2, ty2, text,
  parcolor: string): string;
var x1,y1,x2,y2,command:integer;
begin
  try
    x1:=Integer.Parse(tx1);
    y1:=Integer.Parse(ty1);
    x2:=Integer.Parse(tx2);
    y2:=Integer.Parse(ty2);
    command:=Integer.Parse(sendcommand);
    Result:=command.ToString+' '+x1.ToString+' '+y1.ToString+' '+x2.ToString+' '
    +y2.ToString+' '+text+' '+parcolor;
  except on EConvertError do
  begin
    ShowMessage('���������� ����� �������!!!');
    Result:='2 0 0 0 0 '+text+' '+parcolor;
  end;
  end;
end;

function TForm1.FillRoundedRectangleEncode(const sendcommand: string; px1, py1,
  px2, py2, radius, parcolor: string): string;
var x1,y1,x2,y2,rad,command,color:integer;
begin
  try
    x1:=Integer.Parse(px1);
    y1:=Integer.Parse(py1);
    x2:=Integer.Parse(px2);
    y2:=Integer.Parse(py2);
    rad:=Integer.Parse(radius);
    command:=Integer.Parse(sendcommand);
    Result:=command.ToString+' '+x1.ToString+' '+y1.ToString+' '+
    x2.ToString+' '+y2.ToString+' '+rad.ToString+' '+parcolor;
  except on EConvertError do
  begin
    ShowMessage('������!!!');
    Result:='5 0 0 0 0 0 0';
  end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var spl:TArray<string>; s:string;
 i:integer; iw,jw:integer; b:TBitmapData; t:TDateTime;
 scommand:string; p1,p2:integer;
begin

  scommand:=ClearEncode('3','0000FF');

  packet.msLen:=Length(scommand);
  SetLength(packet.msg,packet.msLen);

  packet.msg:=scommand;

  IdUDPClient1.Active:=true;
  IdUDPClient1.Port:=5000;
  IdUDPClient1.Host:=ComboEdit1.Text;
  IdUDPClient1.Connect;

  if IdUDPClient1.Connected then
  begin
    SetLength(send_data,sizeof(packet));
    Move(packet,send_data[0],sizeof(packet));
    IdUDPClient1.SendBuffer(send_data);
  end;

  IdUDPClient1.Active:=false;

  p1:=random(100);
  p2:=random(100);

  t:=Time;

  scommand:=DrawTextEncode('2',p1.ToString,p1.ToString,(p2+250).ToString,(p2+250).ToString,TimeToStr(t),'fff000');

  packet.msLen:=Length(scommand);
  SetLength(packet.msg,packet.msLen);

  packet.msg:=scommand;

  IdUDPClient1.Active:=true;
  IdUDPClient1.Port:=5000;
  IdUDPClient1.Host:=ComboEdit1.Text;
  IdUDPClient1.Connect;

  if IdUDPClient1.Connected then
  begin
    SetLength(send_data,sizeof(packet));
    Move(packet,send_data[0],sizeof(packet));
    IdUDPClient1.SendBuffer(send_data);
  end;

  IdUDPClient1.Active:=false;

end;


end.

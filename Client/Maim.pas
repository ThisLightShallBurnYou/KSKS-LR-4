unit Maim;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPClient, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.DateUtils, idGlobal,
  FMX.Edit, FMX.ComboEdit, FMX.Objects;

type TPacket = packed record
  msLen: Byte;
  colorarray: array[1..40, 1..40] of Cardinal;
  w: Integer;
  h: Integer;
  msg: string[255];
end;

const
  commands: array[1..6] of string = (
    'drawline', 'drawellipse', 'drawtext', 'clear', 'drawimage', 'fillroundedrectangle'
  );

// Перечисление для типов команд
type
  TCommand = (DRAW_LINE, DRAW_ELLIPSE, DRAW_TEXT, CLEAR, DRAW_IMAGE, FILL_ROUNDED_RECTANGLE);

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
    bmp: TBitmap;
    packet: TPacket;
    send_data: TIdBytes;
    send_command: TCommand;
  public
    { Public declarations }
    function DrawLineEncode(const send_command, par_x1, par_y1, par_x2, par_y2, par_color: string): string;
    function DrawEllipseEncode(const send_command, el_x1, el_y1, el_x2, el_y2, par_color: string): string;
    function DrawTextEncode(const send_command, t_x1, t_y1, t_x2, t_y2, text, par_color: string): string;
    function ClearEncode(const send_command: string; const par_color: string): string;
    function DrawImageEncode(const send_command: string; width, height: string): string;
    function FillRoundedRectangleEncode(const send_command: string; r_x1, r_y1, r_x2, r_y2, radius, par_color: string): string;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  spl: TArray<string>;
  s: string;
  i: Integer;
  iw, jw: Integer;
  b: TBitmapData;
begin
  packet.msLen := Length(Memo1.Text);
  SetLength(packet.msg, packet.msLen);

  s := Memo1.Text;
  spl := s.Split([' ']);

  for i := 1 to 6 do
  begin
    if commands[i] = spl[0] then
    begin
      send_command := TCommand(i - 1);
      case send_command of
        TCommand.DRAW_LINE:
          packet.msg := DrawLineEncode((i - 1).ToString, spl[1], spl[2], spl[3], spl[4], spl[5]);
        TCommand.DRAW_ELLIPSE:
          packet.msg := DrawEllipseEncode((i - 1).ToString, spl[1], spl[2], spl[3], spl[4], spl[5]);
        TCommand.DRAW_TEXT:
          packet.msg := DrawTextEncode((i - 1).ToString, spl[1], spl[2], spl[3], spl[4], spl[5], spl[6]);
        TCommand.CLEAR:
          packet.msg := ClearEncode((i - 1).ToString, spl[1]);
        TCommand.DRAW_IMAGE:
        begin
          packet.msg := DrawImageEncode((i - 1).ToString, spl[1], spl[2]);
          bmp := TBitmap.Create();

          bmp.SetSize(packet.w, packet.h);

          bmp.Map(TMapAccess.Read, b);

          for iw := 1 to Round(bmp.Width) do
            for jw := 1 to Round(bmp.Height) do
              packet.colorarray[iw, jw] := b.GetPixel(iw, jw);

          bmp.Unmap(b);
          Image1.Bitmap.Assign(bmp);
        end;
        TCommand.FILL_ROUNDED_RECTANGLE:
          packet.msg := FillRoundedRectangleEncode((i - 1).ToString, spl[1], spl[2], spl[3], spl[4], spl[5], spl[6]);
      end;
    end;
  end;

  IdUDPClient1.Active := True;
  IdUDPClient1.Port := 5000;
  IdUDPClient1.Host := ComboEdit1.Text;
  IdUDPClient1.Connect;

  if IdUDPClient1.Connected then
  begin
    SetLength(send_data, SizeOf(packet));
    Move(packet, send_data[0], SizeOf(packet));
    IdUDPClient1.SendBuffer(send_data);
  end;

  IdUDPClient1.Active := False;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Timer1.Enabled := not Timer1.Enabled;
end;

function TForm1.ClearEncode(const send_command: string; const par_color: string): string;
var
  command: Integer;
begin
  try
    command := Integer.Parse(send_command);
    Result := command.ToString + ' ' + par_color;
  except
    on EConvertError do
    begin
      ShowMessage('Ошибка преобразования!!!');
      Result := '3 ' + '000000';
    end;
  end;
end;

function TForm1.DrawEllipseEncode(const send_command, el_x1, el_y1, el_x2, el_y2, par_color: string): string;
var
  x1, y1, x2, y2, command: Integer;
begin
  try
    x1 := Integer.Parse(el_x1);
    y1 := Integer.Parse(el_y1);
    x2 := Integer.Parse(el_x2);
    y2 := Integer.Parse(el_y2);
    command := Integer.Parse(send_command);
    Result := command.ToString + ' ' + x1.ToString + ' ' + y1.ToString + ' ' + x2.ToString + ' ' + y2.ToString + ' ' + par_color;
  except
    on EConvertError do
    begin
      ShowMessage('Ошибка ввода координат!!!');
      Result := '1 0 0 0 0 ' + par_color;
    end;
  end;
end;

function TForm1.DrawImageEncode(const send_command: string; width, height: string): string;
var
  w, h, command: Integer;
begin
  try
    w := Integer.Parse(width);
    h := Integer.Parse(height);
    command := Integer.Parse(send_command);
    Result := command.ToString + ' ' + w.ToString + ' ' + h.ToString;
  except
    on EConvertError do
    begin
      ShowMessage('Ошибка ввода размеров изображения!!!');
      Result := '4 0 0';
    end;
  end;
end;

function TForm1.DrawLineEncode(const send_command, par_x1, par_y1, par_x2, par_y2, par_color: string): string;
var
  x1, y1, x2, y2, command: Integer;
begin
  try
    x1 := Integer.Parse(par_x1);
    y1 := Integer.Parse(par_y1);
    x2 := Integer.Parse(par_x2);
    y2 := Integer.Parse(par_y2);
    command := Integer.Parse(send_command);
    Result := command.ToString + ' ' + x1.ToString + ' ' + y1.ToString + ' ' + x2.ToString + ' ' + y2.ToString + ' ' + par_color;
  except
    on EConvertError do
    begin
      ShowMessage('Ошибка ввода координат!!!');
      Result := '0 0 0 0 0 ' + par_color;
    end;
  end;
end;

function TForm1.DrawTextEncode(const send_command, t_x1, t_y1, t_x2, t_y2, text, par_color: string): string;
var
  x1, y1, x2, y2, command: Integer;
begin
  try
    x1 := Integer.Parse(t_x1);
    y1 := Integer.Parse(t_y1);
    x2 := Integer.Parse(t_x2);
    y2 := Integer.Parse(t_y2);
    command := Integer.Parse(send_command);
    Result := command.ToString + ' ' + x1.ToString + ' ' + y1.ToString + ' ' + x2.ToString + ' ' + y2.ToString + ' ' + text + ' ' + par_color;
  except
    on EConvertError do
    begin
      ShowMessage('Ошибка ввода координат!!!');
      Result := '2 0 0 0 0 ' + text + ' ' + par_color;
    end;
  end;
end;

function TForm1.FillRoundedRectangleEncode(const send_command: string; r_x1, r_y1, r_x2, r_y2, radius, par_color: string): string;
var
  x1, y1, x2, y2, rad, command, col: Integer;
begin
  try
    x1 := Integer.Parse(r_x1);
    y1 := Integer.Parse(r_y1);
    x2 := Integer.Parse(r_x2);
    y2 := Integer.Parse(r_y2);
    rad := Integer.Parse(radius);
    col := Integer.Parse(par_color);
    command := Integer.Parse(send_command);
    Result := command.ToString + ' ' + x1.ToString + ' ' + y1.ToString + ' ' + x2.ToString + ' ' + y2.ToString + ' ' + rad.ToString + ' ' + col.ToString;
  except
    on EConvertError do
    begin
      ShowMessage('Ошибка ввода!!!');
      Result := '5 0 0 0 0 0 0';
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  s_command: string;
  p1, p2: Integer;
begin
  s_command := ClearEncode('3', 'FF0000'); // Красный цвет

  packet.msLen := Length(s_command);
  SetLength(packet.msg, packet.msLen);

  packet.msg := s_command;

  IdUDPClient1.Active := True;
  IdUDPClient1.Port := 5000;
  IdUDPClient1.Host := ComboEdit1.Text;
  IdUDPClient1.Connect;

  if IdUDPClient1.Connected then
  begin
    SetLength(send_data, SizeOf(packet));
    Move(packet, send_data[0], SizeOf(packet));
    IdUDPClient1.SendBuffer(send_data);
  end;

  IdUDPClient1.Active := False;

  p1 := Random(100);
  p2 := Random(100);

  s_command := DrawTextEncode('2', p1.ToString, p1.ToString, (p2 + 250).ToString, (p2 + 250).ToString, TimeToStr(Now), 'FFF000');

  packet.msLen := Length(s_command);
  SetLength(packet.msg, packet.msLen);

  packet.msg := s_command;

  IdUDPClient1.Active := True;
  IdUDPClient1.Port := 5000;
  IdUDPClient1.Host := ComboEdit1.Text;
  IdUDPClient1.Connect;

  if IdUDPClient1.Connected then
  begin
    SetLength(send_data, SizeOf(packet));
    Move(packet, send_data[0], SizeOf(packet));
    IdUDPClient1.SendBuffer(send_data);
  end;

  IdUDPClient1.Active := False;
end;

end.


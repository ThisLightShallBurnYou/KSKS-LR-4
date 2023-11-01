unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer, IdGlobal, IdSocketHandle, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, System.DateUtils, FMX.Objects, MyCommands, System.Generics.Collections;

// Запись для приема данных от клиента
type TPacket = packed record
  msLen:Byte;
  colorarray:array [1..40,1..40] of cardinal;
  w:integer;
  h:integer;
  msg:string[255];
end;

// Параметры картинки

type TPicData = class
  pic:TBitmap;
  x:Double;
  y:Double;
  constructor Create(var x,y:Double;var pic:TBitmap); overload;
end;

// Параметры надписи

type TTextData = class
  text:string;
  x1:Double;
  y1:Double;
  x2:Double;
  y2:Double;
  color:string;
  constructor Create(var text:string; var x1,y1,x2,y2:Double; color:string); overload;
end;


type TEllipseData = class
  x1:Double;
  y1:Double;
  x2:Double;
  y2:Double;
  color:string;
  constructor Create(var x1,y1,x2,y2:Double; color:string); overload;
end;


type TFillRoundedRectangleData = class
  x1:Integer;
  y1:Integer;
  x2:Integer;
  y2:Integer;
  radius:Integer;
  color:string;
  constructor Create(var x1,y1,x2,y2,radius:Integer;color:string); overload;
end;


// Параметры линии

type TLineData = class
  p1:TPointF;
  p2:TPointF;
  color:string;
  constructor Create(var p1,p2:TPointF; color:string); overload;
end;

// Перечисление для типов команд
type TCommand=(DRAW_LINE, DRAW_ELLIPSE, DRAW_TEXT, CLEAR, DRAW_IMAGE, FILL_ROUNDED_RECTANGLE);

type
  TForm1 = class(TForm)
    IdUDPServer1: TIdUDPServer;
    ToolBar1: TToolBar;
    Label2: TLabel;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
  private
    { Private declarations }
    bmp:TBitmap;
    packet:TPacket;
    command:TCommand;
    drawcommand:integer;
    piclist:TList<TPicData>;
    textlist:TList<TTextData>;
    linelist:TList<TLineData>;
    ellipselist:TList<TEllipseData>;
    fillroundedrectanglelist:TList<TFillRoundedRectangleData>;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  IdUDPServer1.Active:=true;
  TMyCommands.linepath:=TPathData.Create;
  TMyCommands.ellipsepath:=TPathData.Create;
  TMyCommands.clearcolor:='000000';
  piclist:=TList<TPicData>.Create;
  textlist:=TList<TTextData>.Create;
  linelist:=TList<TLineData>.Create;
  ellipselist:=TList<TEllipseData>.Create;
  fillroundedrectanglelist:=TList<TFillRoundedRectangleData>.Create;
end;

procedure TForm1.IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var s:string; i:integer;     spl:TArray<string>; iw,jw:integer;
    b1:TBitmapData; picdata:TPicData; textdata:TTextData;
    linedata:TLineData; ellipsedata:TEllipseData;
    fillroundedrectangledata:TFillRoundedRectangleData;
begin

          Move(AData[0],packet,sizeof(packet));
          s:=packet.msg;
          spl:=s.Split([' ']);

          // Парсим полученную команду от клиента

          command:=TCommand(Integer.Parse(spl[0]));

        case command of
          TCommand.DRAW_LINE:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareLine(spl[1],spl[2],spl[3],spl[4],spl[5]);
            linedata:=TLineData.Create(TMyCommands.p1,TMyCommands.p2,TMyCommands.linecolor);
            linelist.Add(linedata);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_ELLIPSE:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareEllipse(spl[1],spl[2],spl[3],spl[4],spl[5]);
            ellipsedata:=TEllipseData.Create(TMyCommands.x1_ellipse,TMyCommands.y1_ellipse,
            TMyCommands.x2_ellipse,TMyCommands.y2_ellipse,TMyCommands.ellipsecolor);
            ellipselist.Add(ellipsedata);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_TEXT:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareText(spl[1],spl[2],spl[3],spl[4],spl[5],spl[6]);
            textdata:=TTextData.Create(TMyCommands.textout,TMyCommands.x1_text,TMyCommands.y1_text,
            TMyCommands.x2_text,TMyCommands.y2_text,TMyCommands.textcolor);
            textlist.Add(textdata);
            PaintBox1.Repaint;
          end;
          TCommand.CLEAR:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareClear(spl[1]);
            piclist.Clear;
            textlist.Clear;
            linelist.Clear;
            ellipselist.Clear;
            fillroundedrectanglelist.Clear;
            Form1.Fill.Color:=StrToInt('$ff'+TMyCommands.clearcolor);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_IMAGE:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareDrawImage(spl[1],spl[2]);
            bmp:=TBitmap.Create();

            bmp.SetSize(packet.w,packet.h);

            bmp.Map(TMapAccess.Write,b1);

            for iw:=1 to Round(bmp.Width) do
            for jw:=1 to Round(bmp.Height) do
            begin
              b1.SetPixel(iw,jw,packet.colorarray[iw,jw]);
            end;
            bmp.Unmap(b1);

            picdata:=TPicData.Create(TMyCommands.ximage,TMyCommands.yimage,bmp);
            piclist.Add(picdata);

            PaintBox1.Repaint;
          end;
          TCommand.FILL_ROUNDED_RECTANGLE:
          begin
            TMyCommands.PrepareFillRoundedRectangle(spl[1],spl[2],spl[3],spl[4],spl[5],spl[6]);
            fillroundedrectangledata:=TFillRoundedRectangleData.Create(TMyCommands.x1,TMyCommands.y1,
              TMyCommands.x2,TMyCommands.y2,TMyCommands.radius,TMyCommands.fillroundedrectanglecolor);
            fillroundedrectanglelist.Add(fillroundedrectangledata);
            PaintBox1.Repaint;
          end;


        end;

end;


procedure TForm1.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
var i:integer; p:TPicData; t:TTextData; l:TLineData;  e:TEllipseData;
    frr:TFillRoundedRectangleData;
begin
  PaintBox1.Canvas.BeginScene();

        for l in linelist do
          TMyCommands.DrawMyLine(l.p1,l.p2,Canvas,StrToInt('$ff'+l.color));

        for e in ellipselist do
          TMyCommands.DrawMyEllipse(e.x1,e.y1,e.x2,e.y2,Canvas,StrToInt('$ff'+e.color));

        for t in textlist do
          TMyCommands.DrawMyText(t.x1,t.y1,t.x2,t.y2,
             t.text, 30, Canvas, StrToInt('$ff'+t.color));

        for p in piclist do
          TMyCommands.DrawImage(p.x,p.y,p.pic,Canvas);

        for frr in fillroundedrectanglelist do
          TMyCommands.FillRoundedRectangle(frr.x1,frr.y1,frr.x2,frr.y2,frr.radius,
            Canvas,StrToInt('$ff'+frr.color));

  PaintBox1.Canvas.EndScene;

end;




{ TPicData }

constructor TPicData.Create(var x, y: Double; var pic: TBitmap);
begin
  Self.x:=x;
  Self.y:=y;
  Self.pic:=pic;
end;

{ TTextData }

constructor TTextData.Create(var text:string; var x1,y1,x2,y2:Double; color:string);
begin
  Self.text:=text;
  Self.x1:=x1;
  Self.y1:=y1;
  Self.x2:=x2;
  Self.y2:=y2;
  Self.color:=color;
end;

{ TLineData }

constructor TLineData.Create(var p1,p2:TPointF; color:string);
begin
  Self.p1:=p1;
  Self.p2:=p2;
  Self.color:=color;
end;

{ TEllipseData }

constructor TEllipseData.Create(var x1, y1, x2, y2: Double; color: string);
begin
  Self.x1:=x1;
  Self.y1:=y1;
  Self.x2:=x2;
  Self.y2:=y2;
  Self.color:=color;
end;

{ TFillRoundedRectangleData }

constructor TFillRoundedRectangleData.Create(var x1, y1, x2, y2,
  radius: Integer; color: string);
begin
  Self.x1:=x1;
  Self.y1:=y1;
  Self.x2:=x2;
  Self.y2:=y2;
  Self.radius:=radius;
  Self.color:=color;
end;

end.

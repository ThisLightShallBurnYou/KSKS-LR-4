unit MyCommands;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer, IdGlobal, IdSocketHandle, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, System.DateUtils, FMX.Objects, System.Generics.Collections;



type
  TMyCommands=class
  public
  class var linepath:TPathData;
  class var ellipsepath:TPathData;
  class var p1:TPointF;
  class var p2:TPointF;
  class var linecolor:string;
  class var ellipsecolor:string;
  class var textcolor:string;
  class var fillroundedrectanglecolor:string;
  class var clearcolor:string;
  class var ximage,yimage:Double;
  class var x1_text,y1_text,x2_text,y2_text:Double;
  class var x1,y1,x2,y2,radius:Integer;
  class var x1_ellipse,y1_ellipse,x2_ellipse,y2_ellipse:Double;
  class var textout:string;
  class procedure DrawImage(const x, y: double; const bmp: TBitmap; const Canvas:TCanvas);
  class procedure DrawMyLine(const p1,p2:TPointF;const Canvas:TCanvas; const color:Cardinal);
  class procedure DrawMyEllipse(const x1_ellipse,y1_ellipse,x2_ellipse,y2_ellipse:Double; const Canvas:TCanvas; const color:Cardinal);
  class procedure FillRoundedRectangle(const x1,y1,x2,y2,radius:Integer; const Canvas:TCanvas; const color:Cardinal);
  class procedure DrawMyText(const x1_text,y1_text,x2_text,y2_text:Double; const textout:string; const fontsize:integer; const Canvas:TCanvas; const color:Cardinal);
  class procedure ClearCanvas(const Form:TForm; const Canvas:TCanvas; const color:Cardinal);
  class function PrepareLine(const parx1,pary1,parx2,pary2,parcolor:string):integer;
  class function PrepareEllipse(const elx1,ely1,elx2,ely2,parcolor:string):integer;
  class function PrepareText(const tx1,ty1,tx2,ty2,text,parcolor:string):integer;
  class function PrepareFillRoundedRectangle(const x1,y1,x2,y2,rad,parcolor:string):integer;
  class function PrepareClear(parcolor:string):integer;
  class function PrepareDrawImage(x,y:string):integer;

end;


implementation


{ TMyCommands }

class procedure TMyCommands.ClearCanvas(const Form:TForm; const Canvas:TCanvas; const color: Cardinal);
begin
  Canvas.Clear(color);
  Form.Fill.Color:=color;
end;

class procedure TMyCommands.DrawImage(const x, y: double; const bmp: TBitmap; const Canvas:TCanvas);
begin
    Canvas.DrawBitmap(bmp, TRectF.Create(0, 0, bmp.Width, bmp.Height),
    TRectF.Create(0 + x, 0 + y, bmp.Width + x, bmp.Height + y), 1.0, true);
end;

class procedure TMyCommands.DrawMyEllipse(const x1_ellipse, y1_ellipse,
  x2_ellipse, y2_ellipse: Double; const Canvas: TCanvas; const color: Cardinal);
var rect:TRectF;
begin
  rect:=TRectF.Create(x1_ellipse,y1_ellipse,x2_ellipse,y2_ellipse);
  Canvas.Stroke.Color:=color;
  Canvas.Stroke.Thickness:=3;
  Canvas.Stroke.Dash:=TStrokeDash.Solid;
  Canvas.DrawEllipse(rect,1.0);
end;

class procedure TMyCommands.DrawMyLine(const p1, p2: TPointF;
  const Canvas: TCanvas; const color: Cardinal);
begin
  Canvas.Stroke.Color:=color;
  Canvas.Stroke.Thickness:=5;
  Canvas.Stroke.Dash:=TStrokeDash.Solid;
  Canvas.DrawLine(p1,p2,1.0);
end;

class procedure TMyCommands.DrawMyText(const x1_text, y1_text, x2_text,
  y2_text: Double; const textout: string; const fontsize: integer;
  const Canvas: TCanvas; const color: Cardinal);
begin
  Canvas.Font.Size:=fontsize;
  Canvas.Font.Style:=[TFontStyle.fsBold];
  Canvas.Fill.Color:=color;
  Canvas.FillText(TRectF.Create(x1_text,y1_text,x2_text,y2_text),textout,true,1.0,[],TTextAlign.Leading,TTextAlign.Leading);
end;

class procedure TMyCommands.FillRoundedRectangle(const x1,y1,x2,y2,
  radius: Integer; const Canvas: TCanvas; const color: Cardinal);
begin
  Canvas.Fill.Color:=color;
  Canvas.FillRect(TRectF.Create(x1,y1,x2,y2),radius,radius,[TCorner.TopRight,TCorner.BottomRight,TCorner.TopLeft,TCorner.BottomLeft],1);
end;

class function TMyCommands.PrepareClear(parcolor: string): integer;
begin
  try
    clearcolor:=parcolor;
    Result:=1;
  except on EConvertError do
  begin
    Result:=0;
  end;
  end;
end;

class function TMyCommands.PrepareDrawImage(x,y:string): integer;
begin
  try
    ximage:=Double.Parse(x);
    yimage:=Double.Parse(y);
    Result:=1;
  except on EConvertError do
  begin
    Result:=0;
  end;
  end;
end;

class function TMyCommands.PrepareEllipse(const elx1, ely1, elx2, ely2,
  parcolor: string): integer;
begin
  try
    x1_ellipse:=Double.Parse(elx1);
    y1_ellipse:=Double.Parse(ely1);
    x2_ellipse:=Double.Parse(elx2);
    y2_ellipse:=Double.Parse(ely2);
    ellipsecolor:=parcolor;
    Result:=1;
  except on EConvertError do
  begin
    Result:=0;
  end;
  end;
end;

class function TMyCommands.PrepareFillRoundedRectangle(const x1, y1, x2, y2,
  rad, parcolor: string): integer;
begin
  try
    Self.x1:=Integer.Parse(x1);
    Self.y1:=Integer.Parse(y1);
    Self.x2:=Integer.Parse(x2);
    Self.y2:=Integer.Parse(y2);
    fillroundedrectanglecolor:=parcolor;
    radius:=Integer.Parse(rad);
    Result:=1;
  except on EConvertError do
  begin
    Result:=0;
  end;
  end;
end;

class function TMyCommands.PrepareLine(const parx1, pary1, parx2,
  pary2, parcolor : string): integer;
begin
  try
    p1.X:=Double.Parse(parx1);
    p1.Y:=Double.Parse(pary1);
    p2.X:=Double.Parse(parx2);
    p2.Y:=Double.Parse(pary2);
    linecolor:=parcolor;
    Result:=1;
  except on EConvertError do
  begin
    ShowMessage('Неверно введены координаты линии!!!');
    Result:=0;
  end;
  end;
end;


class function TMyCommands.PrepareText(const tx1, ty1, tx2, ty2, text,
  parcolor: string): integer;
begin
  try
    x1_text:=Double.Parse(tx1);
    y1_text:=Double.Parse(ty1);
    x2_text:=Double.Parse(tx2);
    y2_text:=Double.Parse(ty2);
    textcolor:=parcolor;
    textout:=text;
    Result:=1;
  except on EConvertError do
  begin
    Result:=0;
  end;
  end;
end;

end.

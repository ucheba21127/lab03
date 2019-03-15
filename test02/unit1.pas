{
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    dgPole: TDrawGrid;
    lblDif: TLabel;
    sbDif: TScrollBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure dgPoleClick(Sender: TObject);
    procedure lblDifClick(Sender: TObject);
    procedure sbDifChange(Sender: TObject);
  private
}
    unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    dgPole: TDrawGrid;
    Button1: TButton;
    Button2: TButton;
    sbDif: TScrollBar;
    lblDif: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure dgPoleClick(Sender: TObject);
    procedure dgPoleDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure sbDifChange(Sender: TObject);
    {



    procedure dgPoleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button2Click(Sender: TObject);
    procedure sbDifChange(Sender: TObject);
    }
  private
        procedure CreateLab;
        function FindPath: boolean;
        procedure ShowPath;

    { Private declarations }
    {

    function FindPath: boolean;
    procedure ShowPath;
   }
  public
    { public declarations }
  end;

const
  GO= -1;
  STOP= -2;
  BEG_CELL= 0;
  END_CELL= -3;
var
  Form1: TForm1;


  masPole: array[0..11, 0..11] of integer;
  BeginCell, EndCell: TPoint;
  Dif: integer=35;

implementation

{$R *.lfm}

{ TForm1 }
//СОЗДАТЬ ЛАБИРИНТ
procedure TForm1.CreateLab;
var
  i, j: integer;
begin

  for j:= 0 to 11 do
    for i:= 0 to 11 do
      if Random(101) >= Dif then
        masPole[i,j]:= GO
      else
        masPole[i,j]:= STOP;
  dgPole.Invalidate;
end;
 //СТАРТ ПРОГРАММЫ
procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  //CreateLab;
end;

procedure TForm1.sbDifChange(Sender: TObject);
begin

end;

//НОВЫЙ ЛАБИРИНТ
procedure TForm1.Button1Click(Sender: TObject);
begin
  CreateLab;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if FindPath then
    ShowPath
  else
    showmessage('Пути нет')
end;
//НАЙТИ ПУТЬ МЕЖДУ ДВУМЯ ТОЧКАМИ
function TForm1.FindPath: boolean;
var
  //список координат:
  CoordList: array[1..143] of TPoint;
  //указатели в списке:
  ptrWrite, ptrRead: integer;
  p, q: integer;
  i, j: integer;

  //проверить координаты
  function TestCoord(x,y: integer): boolean;
  begin
    Result:= true;
    if (x<0) or (x>11) or (y<0) or (y> 11)or
     ((masPole[x,y]<> GO) and (masPole[x,y]<> END_CELL)) then
      Result:= false;
  end;

begin
  //если BeginCell = EndCell, то начальная клетка совпадает с конечной,
  //и путь искать не нужно!
  //заносим в список координаты начальной клетки:
  CoordList[1]:= BeginCell;
  //устанавливаем указатель для считывания координат на начало списка:
  ptrRead:= 1;
  //устанавливаем указатель для записи новых координат на следующий индекс:
  ptrWrite:= 2;
  //в начальной клетке в массиве masPole находится BEG_CELL= 0

  //двигаемся от начала списка к его концу, пока он не кончится:
  while ptrRead < ptrWrite do begin
    //координаты текущей клетки:
    p:= CoordList[ptrRead].x; q:= CoordList[ptrRead].y;
    //проверяем соседние с ней клетки:
    for i:= p - 1 to p + 1 do
      for j:= q - 1 to q + 1 do
        //если нашли соседнюю проходимую клетку,
        if ((i=p) or (j=q)) and TestCoord(i,j) then
        begin
          //то записываем в неё число, на единицу большее,
          //чем в текущей клетке:
          masPole[i,j]:= masPole[p,q] + 1;
          //если дошли до конечной клетки,
          if (i= EndCell.x) and (j= EndCell.y) then begin
            //то путь найден:
            Result:= True;
            exit;
          end
          else begin
            //записываем координаты соседней клетки в конец списка:
            CoordList[ptrWrite]:= Point(i,j);
            //перемещаем указатель:
            inc(ptrWrite);
            dgPole.Invalidate;
            //showmessage(inttostr(masPole[i,j]) + ' x='+inttostr(i)+ ' y='+inttostr(j));
          end;
        end;
      //переходим к следующей клетке в списке:
      inc(ptrRead);
  end;
  //путь не найден:
  Result:= False;
end;


procedure TForm1.dgPoleClick(Sender: TObject);
begin

end;

procedure TForm1.dgPoleDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  s: string;
begin
  //закрасить клетку своим цветом:
  case masPole[ACol, ARow] of
    GO: dgPole.Canvas.Brush.Color:= clWhite;
    STOP: dgPole.Canvas.Brush.Color:= clBlack;
    BEG_CELL: dgPole.Canvas.Brush.Color:= clYellow;
    END_CELL: dgPole.Canvas.Brush.Color:= clBlue;
    //номер хода:
    else begin
       with aRect, dgPole.Canvas do begin
        Brush.Style:= bsClear;
        s:= inttostr(masPole[ACol, ARow]);
        textrect(aRect, left+(right-left-textwidth(s)) div 2,
             top+(bottom-top-textheight(s)) div 2, s);
      end;
    end;
  end;
  dgPole.Canvas.FillRect(aRect);
end;
//ПОКАЗАТЬ  ПУТЬ
procedure TForm1.ShowPath;
var
  n, LenPath: integer;
  i, j, p, q: integer;
  path: array[0..144] of TPoint;
  Rect: TRECT;
  s: string;

  //проверить координаты:
  function TestCoord(x,y: integer): boolean;
  begin
    Result:= true;
    if (x<0) or (x>11) or (y<0) or (y> 11)or (masPole[x,y]<> n-1) then
      Result:= false;
  end;

begin
  //длина пути равна числу в конечной клетке:
  LenPath:= masPole[EndCell.x, EndCell.y];
  n:= LenPath;
  //конечная клетка пути:
  path[n]:= EndCell;
  //двигаемся от неё к начальной клетке:
  repeat
    //найти соседнюю клетку с числом n-1:
    p:= path[n].x;  q:= path[n].y;
    //проверяем соседние клетки:
    for i:= p - 1 to p + 1 do
      for j:= q - 1 to q + 1 do
        //нашли подходящую клетку:
        if ((i=p) or (j=q)) and TestCoord(i,j) then
        begin
          //записываем её координаты:
          path[n-1]:= Point(i,j);
          break;
        end;
    //ищем клетку с предыдущим номером:
    dec (n);
  until n<0;
  //показаьб путь в сетке:
  for i:= 1 to LenPath-1 do begin
    {ListBox1.Items.Add(inttostr(i)+ ' ' + inttostr(path[i].x)+ ' '+
                                inttostr(path[i].y));}
    Rect:= dgPole.CellRect(path[i].x,path[i].y);
    //выделить красным цветом:
    dgPole.Canvas.Brush.Color:= clRed;
    dgPole.Canvas.FillRect(Rect);
     with Rect, dgPole.Canvas do begin
        s:= inttostr(i);
        textrect(Rect, left+(right-left-textwidth(s)) div 2,
             top+(bottom-top-textheight(s)) div 2, s);
     end;
  end;
end;
end.


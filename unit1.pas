unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, ComCtrls, LCLIntf;

type
  TWallType =  (wtOpen, wtWall, wtDoor, wtSecretDoor, wtOneWayDoor, wtOWDNorth,
                wtOWDSouth, wtOWDEast, wtOWDWest);
  TFloorType = (ftClear, ftDown, ftUp, ftDarkness);

type
  TCell = Record
    visible: boolean;
    nWall,
    sWall,
    eWall,
    wWall: TWallType;
    floor: TFloorType;
    description: string;
  end;

type
  { TForm1 }

  TForm1 = class(TForm)
    btnExitUp: TButton;
    btnExitDown: TButton;
    btnDarkness: TButton;
    btnDoor: TBitBtn;
    btnEast: TSpeedButton;
    btnEmpty: TBitBtn;
    btnSpecial: TBitBtn;
    btnNorth: TSpeedButton;
    btnOneWayDoor: TBitBtn;
    btnSecretDoor: TBitBtn;
    btnSouth: TSpeedButton;
    btnUp: TSpeedButton;
    btnWall: TBitBtn;
    btnWest: TSpeedButton;
    btnClear: TButton;
    chkClear: TCheckBox;
    chkClear1: TCheckBox;
    chkClear3: TCheckBox;
    chkClear4: TCheckBox;
    edtMapTitle: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    MainMenu1: TMainMenu;
    map: TImage;
    memCellDescription: TMemo;
    miGridHeight: TMenuItem;
    miGridWidth: TMenuItem;
    miMapOptions: TMenuItem;
    miNewMap: TMenuItem;
    miSaveMap: TMenuItem;
    miLoadMap: TMenuItem;
    miFile: TMenuItem;
    OpenDialog1: TOpenDialog;
    pnlDirectionBtns: TPanel;
    SaveDialog1: TSaveDialog;
    procedure btnClearClick(Sender: TObject);
    procedure btnDarknessClick(Sender: TObject);
    procedure btnDoorClick(Sender: TObject);
    procedure btnEmptyClick(Sender: TObject);
    procedure btnExitDownClick(Sender: TObject);
    procedure btnExitUpClick(Sender: TObject);
    procedure btnOneWayDoorClick(Sender: TObject);
    procedure btnSecretDoorClick(Sender: TObject);
    procedure btnSpecialClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnWallClick(Sender: TObject);
    procedure edtMapTitleEnter(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure mapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure memCellDescriptionChange(Sender: TObject);
    procedure mapOptionsClick(Sender: TObject);
    procedure miLoadMapClick(Sender: TObject);
    procedure miMapOptionsClick(Sender: TObject);
    procedure miNewMapClick(Sender: TObject);
    procedure miSaveMapClick(Sender: TObject);
  private
    procedure CreateMap(gridX, gridY: integer);
    procedure UpdateMap;
    procedure WallTypeClick(aType: TWallType);
    procedure FloorTypeClick(aType: TFloorType);
  public
    pd,
    specialCnt,
    mapOffsetX,
    mapOffsetY,
    cellSize,
    gridHeight,
    gridWidth: integer;
    lastCell,
    currentCell: TPoint;
    mapGrid: array of array of TCell;
  end;

var
  Form1: TForm1;

implementation

uses
  Unit2;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormClose(Sender: TObject);
begin
  FreeAndNil(map);
end;

procedure TForm1.btnDoorClick(Sender: TObject);
begin
  WallTypeClick(wtDoor);
end;

procedure TForm1.btnDarknessClick(Sender: TObject);
begin
  FloorTypeClick(ftDarkness);
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  FloorTypeClick(ftClear);
end;

procedure TForm1.btnEmptyClick(Sender: TObject);
begin
  WallTypeClick(wtOpen);
end;

procedure TForm1.btnExitDownClick(Sender: TObject);
begin
  FloorTypeClick(ftDown);
end;

procedure TForm1.btnExitUpClick(Sender: TObject);
begin
  FloorTypeClick(ftUp);
end;

procedure TForm1.btnOneWayDoorClick(Sender: TObject);
begin
  WallTypeClick(wtOneWayDoor);
end;

procedure TForm1.btnSecretDoorClick(Sender: TObject);
begin
  WallTypeClick(wtSecretDoor);
end;

procedure TForm1.btnSpecialClick(Sender: TObject);
begin
  Inc(specialCnt);
  memCellDescription.Enabled := True;
  memCellDescription.Text := Format('%2.2d',[specialCnt]) + '. ';
  map.Canvas.Pen.Color := clBlack;
  map.Canvas.Font.Name:='Arial';
  if cellSize > 24 then
    map.Canvas.Font.Size:=8
  else if cellSize > 16 then
    map.Canvas.Font.Size:=7
  else if cellSize < 11 then
    map.Canvas.Font.Size:=6;
  map.Canvas.Pen.Color := clBlack;
  map.Canvas.Brush.Color := clWhite;
  map.Canvas.TextOut((currentCell.x*cellSize+(cellSize DIV 2)-pd)+mapOffsetX,
                     (currentCell.y*cellSize+(cellSize DIV 2)-pd)+mapOffsetY,
                     Format('%2.2d',[specialCnt]) + '. ');
  memCellDescription.SetFocus;
  memCellDescription.SelStart := 4;
end;

procedure TForm1.btnUpClick(Sender: TObject);
begin
  btnNorth.Down := False;
  btnSouth.Down := False;
  btnEast.Down  := False;
  btnWest.Down  := False;
end;

procedure TForm1.btnWallClick(Sender: TObject);
begin
  WallTypeClick(wtWall);
end;

procedure TForm1.edtMapTitleEnter(Sender: TObject);
begin
  HideCaret(edtMapTitle.Handle);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  gridHeight := 20;
  gridWidth  := 20;
  specialCnt := 0;
  CreateMap(gridWidth, gridHeight);
  currentCell := Point(-1,-1);
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
begin
  Key := UpCase(Key);
  if not ((Key = 'W') or (Key = 'A')or (Key = 'S') or (Key = 'D')) then
    Exit;
  //-toDO: movement based of keyboard input.
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Form1.Width:=Form1.Height+44;
  UpdateMap;
end;

procedure TForm1.mapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  px, py, i,
  dx, dy, cx, cy,
  north, south, east, west: integer;
  direction: char;
begin
  //get cell clicked on
  for i:=0 to gridWidth do
    if X < i*cellSize+mapOffsetX then
    begin
      px := i-1;
      break;
    end;
  for i:=0 to gridHeight do
    if Y < i*cellSize+mapOffsetY then
    begin
      py := i-1;
      break;
    end;
  lastCell := currentCell;
  currentCell := Point(px, py);
  memCellDescription.Text := mapGrid[px,py].Description;
  memCellDescription.Enabled := memCellDescription.Text <> '';
  if Button = mbRight then
  begin
    //paint cell
    map.Canvas.Brush.Color := clGray;
    map.Canvas.Rectangle(px*cellSize + mapOffsetX,
                         py*cellSize + mapOffsetY,
                         px*cellSize + cellSize + mapOffSetX,
                         py*cellSize + cellSize + mapOffSetY);
    map.Canvas.Pen.Color := clSilver;
    map.Canvas.Rectangle(px*cellSize + mapOffsetX,
                         py*cellSize + mapOffsetY,
                         px*cellSize + cellSize + mapOffsetX+1,
                         py*cellSize + cellSize + mapOffsetY+1);
    //set cell properties back to unused
    cx:=currentCell.x; cy:=currentCell.y;
    mapGrid[cx, cy].Visible := False;
    mapGrid[cx, cy].nWall := wtWall;
    mapGrid[cx, cy].sWall := wtWall;
    mapGrid[cx, cy].eWall := wtWall;
    mapGrid[cx, cy].wWall := wtWall;
    mapGrid[cx, cy].floor := ftClear;
    mapGrid[cx, cy].description := '';
    //set walls around current cell
    //-northern cell
    cy:=cy-1; if cy<0 then cy:=gridHeight-1;
    mapGrid[cx, cy].sWall := wtWall;
    cy:=currentCell.y;
    //-southern cell
    cy:=cy+1; if cy>gridHeight-1 then cy:=0;
    mapGrid[cx, cy].nWall := wtWall;
    cy:=currentCell.y;
    //-eastern cell
    cx:=cx+1; if cx>gridWidth-1 then cx:=0;
    mapGrid[cx, cy].wWall := wtWall;
    cx:=currentCell.x;
    //-western cell
    cx:=cx-1; if cx<0 then cx:=gridWidth-1;
    mapGrid[cx, cy].eWall := wtWall;
    cx:=currentCell.x;
  end
  else
  begin
    // find direction and if not adjacent
    dx := currentCell.x - lastCell.x;
    dy := currentCell.y - lastCell.y;
    if (dx = 0) and (dy = 0) then exit;
    if (dx > 1) or (dx < -1) or
       (dy > 1) or (dy < -1) or (lastCell.x = -1) then
      direction := 'O'
    else
    begin
      if dx = 0 then
      // north or south
      begin
        if dy > 0 then
          direction := 'S'
        else
          direction := 'N';
      end
      else
      // east or west
      begin
        if dx > 0 then
          direction := 'E'
        else
          direction := 'W';
      end;
    end;
    if not mapGrid[px,py].visible then
    begin
      mapGrid[px,py].visible := True;
      // find adjacent tile coords
      north := py-1; if north < 0 then north := gridHeight-1;
      south := py+1; if south > gridHeight-1 then south := 0;
      east  := px+1; if east  > gridWidth-1 then east := 0;
      west  := px-1; if west  < 0 then west := gridWidth-1;
      case direction of
        'O':
          begin
            mapGrid[px,py].nWall := mapGrid[px,north].sWall;
            mapGrid[px,py].sWall := mapGrid[px,south].nWall;
            mapGrid[px,py].eWall := mapGrid[east,py].wWall;
            mapGrid[px,py].wWall := mapGrid[west,py].eWall;
          end;
        'N':
          begin
            mapGrid[px,py].nWall := mapGrid[px,north].sWall;
            mapGrid[px,py].eWall := mapGrid[east,py].wWall;
            mapGrid[px,py].wWall := mapGrid[west,py].eWall;
            if mapGrid[px,south].nWall = wtWall then
            begin
              mapGrid[px,south].nWall := wtOpen;
              mapGrid[px,py].sWall := wtOpen;
            end
            else
              mapGrid[px,py].sWall := mapGrid[px,south].nWall;
          end;
        'S':
          begin
            mapGrid[px,py].sWall := mapGrid[px,south].nWall;
            mapGrid[px,py].eWall := mapGrid[east,py].wWall;
            mapGrid[px,py].wWall := mapGrid[west,py].eWall;
            if mapGrid[px,north].sWall = wtWall then
            begin
              mapGrid[px,north].sWall := wtOpen;
              mapGrid[px,py].nWall := wtOpen;
            end
            else
              mapGrid[px,py].nWall := mapGrid[px,north].sWall;
          end;
        'E':
          begin
            mapGrid[px,py].nWall := mapGrid[px,north].sWall;
            mapGrid[px,py].sWall := mapGrid[px,south].nWall;
            mapGrid[px,py].eWall := mapGrid[east,py].wWall;
            if mapGrid[west,py].eWall = wtWall then
            begin
              mapGrid[west,py].eWall := wtOpen;
              mapGrid[px,py].wWall := wtOpen;
            end
            else
              mapGrid[px,py].wWall := mapGrid[west,py].eWall;
          end;
        'W':
          begin
            mapGrid[px,py].nWall := mapGrid[px,north].sWall;
            mapGrid[px,py].sWall := mapGrid[px,south].nWall;
            mapGrid[px,py].wWall := mapGrid[west,py].eWall;
            if mapGrid[east,py].wWall = wtWall then
            begin
              mapGrid[east,py].wWall := wtOpen;
              mapGrid[px,py].eWall := wtOpen;
            end
            else
              mapGrid[px,py].eWall := mapGrid[east,py].wWall;
          end;
      end;
    end;
  end;
  UpdateMap;
end;

procedure TForm1.memCellDescriptionChange(Sender: TObject);
begin
  mapGrid[currentCell.x, currentCell.y].description := memCellDescription.Text;
end;

procedure TForm1.mapOptionsClick(Sender: TObject);
begin
  frmMapOptions := TFrmMapOptions.Create(Application);
  try
    frmMapOptions.ShowModal;
    if ModalResult = mrOk then
      CreateMap(gridWidth, gridHeight);
  finally
    FreeAndNil(frmMapOptions);
  end;
end;

procedure TForm1.miLoadMapClick(Sender: TObject);
var
  filename, tempStr: string;
  F: TextFile;
  x,y: integer;

  function ReturnWallType(aType: integer): TWallType;
  begin
    case aType of
      0: result := wtOpen;
      1: result := wtWall;
      2: result := wtDoor;
      3: result := wtSecretDoor;
      4: result := wtOneWayDoor;
    end;
  end;

  function ReturnFloorType(aType: integer): TFloorType;
  begin
    case aType of
      0: result := ftClear;
      1: result := ftDown;
      2: result := ftUp;
      3: result := ftDarkness;
    end;
  end;

begin
  OpenDialog1.Title := 'Load a map';
  OpenDialog1.Filter := 'Text file|*.txt';
  OpenDialog1.DefaultExt := 'txt';
  OpenDialog1.FilterIndex := 1;
  if OpenDialog1.Execute then
  begin
    specialCnt := 0;
    filename := OpenDialog1.FileName;
    AssignFile(F, filename);
    Reset(F);
    Readln(F, gridWidth);
    Readln(F, gridHeight);
    Readln(F, tempStr);
    edtMapTitle.Text := tempStr;
    CreateMap(gridWidth, gridHeight);
    for x:=0 to gridWidth-1 do
      for y:=0 to gridHeight-1 do
      begin
        Readln(F, tempStr);
        if tempStr[1]='1' then
          mapGrid[x,y].visible := True
        else
          mapGrid[x,y].visible := False;
        mapGrid[x,y].nWall := ReturnWallType(StrToInt(tempStr[2]));
        mapGrid[x,y].sWall := ReturnWallType(StrToInt(tempStr[3]));
        mapGrid[x,y].eWall := ReturnWallType(StrToInt(tempStr[4]));
        mapGrid[x,y].wWall := ReturnWallType(StrToInt(tempStr[5]));
        mapGrid[x,y].floor := ReturnFloorType(StrToInt(tempStr[6]));
        tempStr := Copy(tempStr, 7, Length(tempStr));
        if tempStr > ' ' then Inc(specialCnt);
        mapGrid[x,y].description := tempStr;
      end;
    CloseFile(F);
  end;
  UpdateMap;
end;

procedure TForm1.miMapOptionsClick(Sender: TObject);
begin
  miGridWidth.Caption := 'Grid Width = ' + IntToStr(gridWidth);
  miGridHeight.Caption := 'Grid Height = ' + IntToStr(gridHeight);
end;

procedure TForm1.miNewMapClick(Sender: TObject);
begin
  CreateMap(gridWidth, gridHeight);
  specialCnt := 0;
end;

procedure TForm1.miSaveMapClick(Sender: TObject);
var
  filename: string;
  F: TextFile;
  x,y: integer;
begin
  SaveDialog1.Title := 'Save your map to a text file';
  SaveDialog1.Filter := 'Text file|*.txt';
  SaveDialog1.DefaultExt := 'txt';
  SaveDialog1.FilterIndex := 1;
  if SaveDialog1.Execute then
  begin
    filename := SaveDialog1.FileName;
    AssignFile(F, filename);
    Rewrite(F);
    Writeln(F, gridWidth);
    Writeln(F, gridHeight);
    Writeln(F, edtMapTitle.Text);
    for x:=0 to gridWidth-1 do
      for y:=0 to gridHeight-1 do
      begin
        if mapGrid[x,y].visible then
          Write(F, '1') else Write(F, '0');
        Write(F, Ord(mapGrid[x,y].nWall));
        Write(F, Ord(mapGrid[x,y].sWall));
        Write(F, Ord(mapGrid[x,y].eWall));
        Write(F, Ord(mapGrid[x,y].wWall));
        Write(F, Ord(mapGrid[x,y].floor));
        Write(F, mapGrid[x,y].description);
        Writeln(F);
      end;
    CloseFile(F);
  end;
end;

procedure TForm1.CreateMap(gridX, gridY: integer);
var
  i, j, w, h: integer;
begin
  w:=map.Width;
  h:=map.Height;
  map.Visible := False;
  lastCell := Point(-1, -1);

  if gridX >= gridY then
    cellSize := w DIV gridX
  else
    cellSize := h DIV gridY;

  if gridY = gridX then
  begin
    mapOffsetX := ((w MOD gridX) DIV 2)-1;
    mapOffsetY := mapOffsetX;
  end
  else
  if gridY > gridX then
    mapOffsetX := ((w MOD gridX) DIV 2)+(((gridY-gridX) DIV 2)*cellSize)-1
  else
  if gridX > gridY then
    mapOffsetY := ((h MOD gridY) DIV 2)+(((gridX-gridY) DIV 2)*cellSize)-1;

  // clear canvas
  map.Canvas.Clear;
  map.Canvas.Brush.Color := $004A66A6;
  map.Canvas.FillRect(0,0,map.width,map.height);
  // paint new map
  map.Canvas.Brush.Color := clGray;
  map.Canvas.Pen.Color := clSilver;
  map.Canvas.FillRect(mapOffsetX,mapOffsetY,
                      cellSize*gridX+mapOffsetX,cellSize*gridY+mapOffsetY);
  for i:=0 to gridX do
    map.Canvas.Line(i*cellSize + mapOffsetX,
                    mapOffsetY,
                    i*cellSize + mapOffsetX,
                    cellSize*gridY + mapOffsetY);
  for i:=0 to gridY do
    map.Canvas.Line(mapOffsetX,
                    i*cellSize + mapOffsetY,
                    cellSize*gridX  + mapOffsetX,
                    i*cellSize + mapOffsetY);
  map.Visible := True;
  SetLength(mapGrid, gridX);
  for i:=0 to gridX-1 do
    SetLength(mapGrid[i], gridY);
  for i:=0 to gridX-1 do
    for j:=0 to gridY-1 do
    begin
      mapGrid[i,j].visible := false;
      mapGrid[i,j].nWall := wtWall;
      mapGrid[i,j].sWall := wtWall;
      mapGrid[i,j].eWall := wtWall;
      mapGrid[i,j].wWall := wtWall;
      mapGrid[i,j].floor := ftClear;
      mapGrid[i,j].description := '';
    end;
end;

procedure TForm1.UpdateMap;
var
  x, y, pixel: integer;
begin
  pd := cellSize DIV 5;
  for x:=0 to High(mapGrid) do
    for y:=0 to High(mapGrid[x]) do
    begin
      if mapGrid[x,y].visible then
      begin
        //paint cell floor
        case mapGrid[x,y].floor of
          ftClear, ftDown, ftUp:
            map.Canvas.Brush.Color := clWhite;
          ftDarkness:
            map.Canvas.Brush.Color := clSilver;
        end;
        map.Canvas.Rectangle(x*cellSize+mapOffsetX,
                             y*cellSize+mapOffsetY,
                             x*cellSize+cellSize+mapOffSetX+1,
                             y*cellSize+cellSize+mapOffSetY+1);
        if (x = currentCell.x) and (y = currentCell.y) then
        begin
          // draw red rectangle in cell
          map.Canvas.Pen.Color := clRed;
          map.Canvas.Rectangle(x*cellSize+mapOffsetX+1,
                               y*cellSize+mapOffsetY+1,
                               x*cellSize+cellSize+mapOffsetX,
                               y*cellSize+cellSize+mapOffsetY);
        end;
        // mark any specials and/or floor types in the cell
        if mapGrid[x,y].Description > '' then
        begin
          map.Canvas.Pen.Color := clBlack;
          map.Canvas.Brush.Color := clWhite;
          map.Canvas.TextOut((x*cellSize + (cellSize DIV 2) - pd) + mapOffsetX,
                             (y*cellSize + (cellSize DIV 2) - pd) + mapOffsetY,
                             mapGrid[x,y].Description[1] +
                             mapGrid[x,y].Description[2] +
                             mapGrid[x,y].Description[3]);
        end;
        if mapGrid[x,y].floor = ftUp then
        begin
          map.Canvas.Pen.Color := clBlack;
          map.Canvas.Line((x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)-pd)+mapOffsetY,
                          (x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)+pd)+mapOffsetY);
          map.Canvas.Line((x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)-pd)+mapOffsetY,
                          (x*cellSize+(cellSize DIV 2)-pd)+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)+(pd DIV 2))+mapOffsetY);
          map.Canvas.Line((x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)-pd)+mapOffsetY,
                          (x*cellSize+(cellSize DIV 2)+pd)+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)+(pd DIV 2))+mapOffsetY);
        end;
        if mapGrid[x,y].floor = ftDown then
        begin
          map.Canvas.Pen.Color := clBlack;
          map.Canvas.Line((x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)-pd)+mapOffsetY,
                          (x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)+pd)+mapOffsetY);
          map.Canvas.Line((x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)+pd)+mapOffsetY,
                          (x*cellSize+(cellSize DIV 2)-pd)+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)-(pd DIV 2))+mapOffsetY);
          map.Canvas.Line((x*cellSize+(cellSize DIV 2))+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)+pd)+mapOffsetY,
                          (x*cellSize+(cellSize DIV 2)+pd)+mapOffsetX,
                          (y*cellSize+(cellSize DIV 2)-(pd DIV 2))+mapOffsetY);
        end;
        //paint north wall
        case mapGrid[x,y].nWall of
          wtOpen, wtWall:
            begin
            if mapGrid[x,y].nWall = wtOpen then
            begin
              map.Canvas.Pen.Color := clMoneyGreen;
              pixel := 1;
            end
            else
            begin
              map.Canvas.Pen.Color := clBlack;
              pixel := 0;
            end;
            map.Canvas.Line(x*cellSize+mapOffsetX+pixel,
                            y*cellSize+mapOffsetY,
                            x*cellSize+mapOffsetX+cellSize,
                            y*cellSize+mapOffsetY);
            end;
          wtDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
             (y*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
             (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
             (y*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            end;
          wtSecretDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
             (y*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
             (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
             (y*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            map.Canvas.Line(
             (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
             (y*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
             (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
             (y*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            end;
          wtOWDNorth:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 (y*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 y*cellSize + mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 y*cellSize + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 (y*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            end;
          wtOWDSouth:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 y*cellSize + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 (y*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 (y*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 y*cellSize + mapOffsetY);
            end;
        end;
        // paint south wall
        case mapGrid[x,y].sWall of
          wtOpen, wtWall:
            begin
            if mapGrid[x,y].sWall = wtOpen then
            begin
              map.Canvas.Pen.Color := clMoneyGreen;
              pixel := 1;
            end
            else
            begin
              map.Canvas.Pen.Color := clBlack;
              pixel := 0;
            end;
            map.Canvas.Line(x*cellSize+mapOffsetX+pixel,
                            y*cellSize+mapOffsetY+cellSize,
                            x*cellSize+mapOffsetX+cellSize,
                            y*cellSize+mapOffsetY+cellSize);
            end;
          wtDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
             (y*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
             (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
             (y*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            end;
          wtSecretDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
             (y*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
             (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
             (y*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            map.Canvas.Line(
             (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
             (y*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
             (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
             (y*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            end;
          wtOWDNorth:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 (y*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 y*cellSize+cellSize + mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 y*cellSize+cellSize + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 (y*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            end;
          wtOWDSouth:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            (x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Line((x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 y*cellSize+cellSize + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 (y*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle((x*cellSize+(cellSize DIV 2 - pd)) + mapOffsetX,
                                 (y*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetY,
                                 (x*cellSize+(cellSize DIV 2 + pd)) + mapOffsetX,
                                 y*cellSize+cellSize + mapOffsetY);
            end;
        end;
        // paint east wall
        case mapGrid[x,y].eWall of
          wtOpen, wtWall:
            begin
            if mapGrid[x,y].eWall = wtOpen then
            begin
              map.Canvas.Pen.Color := clMoneyGreen;
              pixel := 1;
            end
            else
            begin
              map.Canvas.Pen.Color := clBlack;
              pixel := 0;
            end;
            map.Canvas.Line(x*cellSize+mapOffsetX+cellSize,
                            y*cellSize+mapOffsetY+pixel,
                            x*cellSize+mapOffsetX+cellSize,
                            y*cellSize+mapOffsetY+cellSize);
            end;
          wtDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
             (x*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
          wtSecretDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
             (x*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            map.Canvas.Line(
             (x*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
             (x*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
          wtOWDEast:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle((x*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 x*cellSize+cellSize + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle( x*cellSize+cellSize + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 (x*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
          wtOWDWest:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle((x*cellSize+cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 x*cellSize+cellSize + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle( x*cellSize+cellSize + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 (x*cellSize+cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
        end;
        // paint west wall
        case mapGrid[x,y].wWall of
          wtOpen, wtWall:
            begin
            if mapGrid[x,y].wWall = wtOpen then
            begin
              map.Canvas.Pen.Color := clMoneyGreen;
              pixel := 1;
            end
            else
            begin
              map.Canvas.Pen.Color := clBlack;
              pixel := 0;
            end;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY+pixel,
                            x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY+cellSize);
            end;
          wtDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
             (x*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
          wtSecretDoor:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Rectangle(
             (x*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
             (x*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            map.Canvas.Line(
             (x*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
             (x*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
             (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
          wtOWDEast:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle((x*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 x*cellSize+mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle( x*cellSize+ mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 (x*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
          wtOWDWest:
            begin
            map.Canvas.Pen.Color := clBlack;
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            y*cellSize+mapOffsetY,
                            x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY);
            map.Canvas.Line(x*cellSize+mapOffsetX,
                            (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY,
                            x*cellSize+mapOffsetX,
                            y*cellSize+cellSize+mapOffsetY);
            map.Canvas.Brush.Color := clBlack;
            map.Canvas.Rectangle((x*cellSize-((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 x*cellSize+mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            map.Canvas.Brush.Color := clWhite;
            map.Canvas.Rectangle( x*cellSize+ mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 - pd)) + mapOffsetY,
                                 (x*cellSize+((cellSize DIV 4) DIV 2)) + mapOffsetX,
                                 (y*cellSize+(cellSize DIV 2 + pd)) + mapOffsetY);
            end;
        end;
      end
      else {cell is "invisible"}
      begin
        //paint the inside of the cell grey
        map.Canvas.Brush.Color := clGray;
        map.Canvas.Pen.Color := clSilver;
        map.Canvas.Rectangle(x*cellSize+mapOffsetX,
                             y*cellSize+mapOffsetY,
                             x*cellSize+mapOffsetX+cellSize+1,
                             y*cellSize+mapOffsetY+cellSize+1);
        //check walls
        map.Canvas.Pen.Color := clBlack;
        //north
        if (y > 0) and (mapGrid[x, y-1].sWall = wtWall) and
         (mapGrid[x, y-1].visible) then
          map.Canvas.Line(x*cellSize + mapOffsetX, y*cellSize + mapOffsetY,
           x*cellSize+cellSize+mapOffSetX, y*cellSize + mapOffsetY);
        //south
        if (y < gridHeight-1) and (mapGrid[x, y+1].nWall = wtWall) and
         (mapGrid[x, y+1].visible) then
          map.Canvas.Line(x*cellSize + mapOffsetX,
                          y*cellSize+cellSize+mapOffsetY,
                          x*cellSize+cellSize+mapOffsetX,
                          y*cellSize+cellSize+mapOffsetY);
        //east
        if (x < gridWidth-1) and (mapGrid[x+1, y].wWall = wtWall) and
         (mapGrid[x+1, y].visible) then
          map.Canvas.Line(x*cellSize+cellSize+mapOffsetX,
                          y*cellSize + mapOffsetY,
                          x*cellSize+cellSize+mapOffsetX,
                          y*cellSize+cellSize+mapOffsetY);
        //west
        if (x > 0) and (mapGrid[x-1, y].eWall = wtWall) and
         (mapGrid[x-1, y].visible) then
          map.Canvas.Line(x*cellSize + mapOffsetX, y*cellSize + mapOffsetY,
                          x*cellSize + mapOffsetX,
                          y*cellSize+cellSize+mapOffsetY);
      end;
    end;
end;

procedure TForm1.WallTypeClick(aType: TWallType);
var
  north, south, east, west: integer;
begin
  north := currentCell.y-1; if north < 0 then north := gridHeight-1;
  south := currentCell.y+1; if south > gridHeight-1 then south := 0;
  east := currentCell.x+1; if east > gridWidth-1 then east := 0;
  west := currentCell.x-1; if west < 0 then west := gridWidth-1;
  if btnNorth.Down then
  begin
    if aType = wtOneWayDoor then
    begin
      mapGrid[currentCell.x, currentCell.y].nWall := wtOWDNorth;
      mapGrid[currentCell.x, north].sWall := wtOWDNorth;
    end
    else
    begin
      mapGrid[currentCell.x, currentCell.y].nWall := aType;
      mapGrid[currentCell.x, north].sWall := aType;
    end;
  end;
  if btnSouth.Down then
  begin
    if aType = wtOneWayDoor then
    begin
      mapGrid[currentCell.x, currentCell.y].sWall := wtOWDSouth;
      mapGrid[currentCell.x, south].nWall := wtOWDSouth;
    end
    else
    begin
      mapGrid[currentCell.x, currentCell.y].sWall := aType;
      mapGrid[currentCell.x, south].nWall := aType;
    end;
  end;
  if btnEast.Down then
  begin
    if aType = wtOneWayDoor then
    begin
      mapGrid[currentCell.x, currentCell.y].eWall := wtOWDEast;
      mapGrid[east, currentCell.y].wWall := wtOWDEast;
    end
    else
    begin
      mapGrid[currentCell.x, currentCell.y].eWall := aType;
      mapGrid[east, currentCell.y].wWall := aType;
    end;
  end;
  if btnWest.Down then
  begin
    if aType = wtOneWayDoor then
    begin
      mapGrid[currentCell.x, currentCell.y].wWall := wtOWDWest;
      mapGrid[west, currentCell.y].eWall := wtOWDWest;
    end
    else
    begin
      mapGrid[currentCell.x, currentCell.y].wWall := aType;
      mapGrid[west, currentCell.y].eWall := aType;
    end;
  end;
  UpdateMap;
end;

procedure TForm1.FloorTypeClick(aType: TFloorType);
begin
  mapGrid[currentCell.x, currentCell.y].floor := aType;
  UpdateMap;
end;

end.


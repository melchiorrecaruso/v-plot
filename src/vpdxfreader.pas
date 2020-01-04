{
  Description: vPlot DXF file reader class.

  This unit derives from LAZARUS/FREEPASCAL dxfvectorialreader unit.

  Copyright (C) 2018-2019 Melchiorre Caruso <melchiorrecaruso@gmail.com>
  Copyright (C) 1993-2017 Felipe Monteiro de Carvalho

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit vpdxfreader;

{$mode objfpc}

interface

uses
  classes, fpimage, sysutils, vpmath, vppaths;

type
  tpolylineelement = record
    x: vpfloat;
    y: vpfloat;
    color: tfpcolor;
  end;

  tsplineelement = record
    x: vpfloat;
    y: vpfloat;
    knotvalue: integer;
  end;

  tlwpolylineelement = record
    x: vpfloat;
    y: vpfloat;
  end;

  { tdxftokens }

  tdxftokens = class(tfplist)
  public
    destructor destroy; override;
    procedure clear;
  end;

  { tdxftoken }

  tdxftoken = class(tobject)
  public
    groupcode:  integer;
    strvalue:   string;
    floatvalue: vpfloat;
    intvalue:   integer;
    childs:     tdxftokens;
  public
    constructor create;
    destructor destroy; override;
  end;

  { tdxftokenizer }

  tdxftokenizer = class(tobject)
  public
    tokens: tdxftokens;
    constructor create;
    destructor destroy; override;
    procedure readfromstrings(astrings: tstrings);
    function  istables_subsection(astr: string): boolean;
    function  isblocks_subsection(astr: string): boolean;
    function  isentities_subsection(astr: string): boolean;
  end;

  { tvdxfreader }

  tvdxfreader = class
  private
    fpointseparator: tformatsettings;
    // header data
    angbase: vpfloat;
    angdir:  vpfloat;
    insbase, extmin, extmax, limmin, limmax: pvppoint;
    // for building the polyline objects which is composed of multiple records
    isreadingpolyline: boolean;
    isreadingattrib: boolean;
    polyline: array of tpolylineelement;
    //
    procedure readheader(atokens: tdxftokens; elements: tvpelementlist);
    procedure readtables(atokens: tdxftokens; elements: tvpelementlist);
    procedure readtables_table(atokens: tdxftokens; elements: tvpelementlist);
    procedure readtables_layer(atokens: tdxftokens; elements: tvpelementlist);
    procedure readblocks(atokens: tdxftokens; elements: tvpelementlist);
    procedure readblocks_block(atokens: tdxftokens; elements: tvpelementlist);
    procedure readblocks_endblk(atokens: tdxftokens; elements: tvpelementlist);
    procedure readentities(atokens: tdxftokens; elements: tvpelementlist);
    procedure readentities_line(atokens: tdxftokens; elements: tvpelementlist);
    procedure readentities_circlearc(atokens: tdxftokens; elements: tvpelementlist);
    procedure readentities_circle(atokens: tdxftokens; elements: tvpelementlist);
    procedure readentities_ellipse(atokens: tdxftokens; elements: tvpelementlist);
    procedure internalreadentities(atokenstr: string; atokens: tdxftokens; elements: tvpelementlist);
   public
    { general reading methods }
    tokenizer: tdxftokenizer;
    constructor create;
    destructor destroy; override;
    procedure readfromstrings(astrings: tstrings; elements: tvpelementlist);
    procedure readfromfile(const afilename: string; elements: tvpelementlist);
  end;

  procedure dxf2paths(const afilename: string; elements: tvpelementlist);

implementation

const
  // Items in the HEADER section

  // $ACADVER
  DXF_AUTOCAD_2010        = 'AC1024'; // AutoCAD 2011 and 2012 too
  DXF_AUTOCAD_2007        = 'AC1021'; // AutoCAD 2008 and 2009 too
  DXF_AUTOCAD_2004        = 'AC1018'; // AutoCAD 2005 and 2006 too
  DXF_AUTOCAD_2000        = 'AC1015'; // 1999  In some docs it is proposed as AC1500, but in practice I found AC1015
                                      // http://www.autodesk.com/techpubs/autocad/acad2000/dxf/
                                      // AutoCAD 2000i and 2002 too
  DXF_AUTOCAD_R14         = 'AC1014'; // 1997  http://www.autodesk.com/techpubs/autocad/acadr14/dxf/index.htm
  DXF_AUTOCAD_R13         = 'AC1012'; // 1994
  DXF_AUTOCAD_R11_and_R12 = 'AC1009'; // 1990
  DXF_AUTOCAD_R10         = 'AC1006'; // 1988
  DXF_AUTOCAD_R9          = 'AC1004';

  // Group Codes for ENTITIES
  DXF_ENTITIES_TYPE                 = 0;
  DXF_ENTITIES_HANDLE               = 5;
  DXF_ENTITIES_LINETYPE_NAME        = 6;
  DXF_ENTITIES_APPLICATION_GROUP    = 102;
  DXF_ENTITIES_AcDbEntity           = 100;
  DXF_ENTITIES_MODEL_OR_PAPER_SPACE = 67; // default=0=model, 1=paper
  DXF_ENTITIES_VISIBILITY           = 60; // default=0 = Visible, 1 = Invisible

  AUTOCAD_COLOR_PALETTE: array[0..15] of tfpcolor =
  ((red: $0000; green: $0000; blue: $0000; alpha: alphaopaque),  //  0 - black
   (red: $ffff; green: $0000; blue: $0000; alpha: alphaopaque),  //  1 - light red
   (red: $ffff; green: $ffff; blue: $0000; alpha: alphaopaque),  //  2 - light yellow
   (red: $0000; green: $ffff; blue: $0000; alpha: alphaopaque),  //  3 - light green
   (red: $0000; green: $ffff; blue: $ffff; alpha: alphaopaque),  //  4 - light cyan
   (red: $0000; green: $0000; blue: $ffff; alpha: alphaopaque),  //  5 - light blue
   (red: $ffff; green: $0000; blue: $ffff; alpha: alphaopaque),  //  6 - light magenta
   (red: $ffff; green: $ffff; blue: $ffff; alpha: alphaopaque),  //  7 - white
   (red: $4141; green: $4141; blue: $4141; alpha: alphaopaque),  //  8 - dark gray
   (red: $8080; green: $8080; blue: $8080; alpha: alphaopaque),  //  9 - gray
   (red: $ffff; green: $0000; blue: $0000; alpha: alphaopaque),  // 10 - light red
   (red: $ffff; green: $aaaa; blue: $aaaa; alpha: alphaopaque),  // 11
   (red: $bdbd; green: $0000; blue: $0000; alpha: alphaopaque),  // 12
   (red: $bdbd; green: $7e7e; blue: $7e7e; alpha: alphaopaque),  // 13
   (red: $8181; green: $0000; blue: $0000; alpha: alphaopaque),  // 14
   (red: $8181; green: $5656; blue: $5656; alpha: alphaopaque)); // 15

{ tdxftokens }

destructor tdxftokens.destroy;
begin
  clear;
  inherited destroy;
end;

procedure tdxftokens.clear;
var
  i: longint;
begin
  for i := 0 to count - 1 do
  begin
    tobject(items[i]).destroy;
  end;
  inherited clear;
end;

{ tdxftoken }

constructor tdxftoken.create;
begin
  inherited create;
  childs := tdxftokens.create;
end;

destructor tdxftoken.destroy;
begin
  childs.free;
  inherited destroy;
end;

{ tdxftokenizer }

constructor tdxftokenizer.create;
begin
  inherited create;
  tokens := tdxftokens.create;
end;

destructor tdxftokenizer.destroy;
begin
  tokens.free;
  inherited destroy;
end;

procedure tdxftokenizer.readfromstrings(astrings: tstrings);
var
  i: integer;
  strsectiongroupcode,
  strsectionname: string;
  intsectiongroupcode: integer;
  curtokenbase,
  nexttokenbase,
  sectiontokenbase,
  lastblocktoken: tdxftokens;
  newtoken: tdxftoken;
  parserstate: integer;
begin
  tokens.clear;

  curtokenbase  := tokens;
  nexttokenbase := tokens;

  parserstate   := 0;
  i             := 0;
  while i < astrings.count - 1 do
  begin
    curtokenbase := nexttokenbase;
                                                
    // now read and process the section name
    strsectiongroupcode := astrings.strings[i];
    intsectiongroupcode := strtoint(trim(strsectiongroupcode));
    strsectionname      := astrings.strings[i+1];

    newtoken            := tdxftoken.create;
    newtoken.groupcode  := intsectiongroupcode;
    newtoken.strvalue   := strsectionname;

    // waiting for a section
    if parserstate = 0 then
    begin
      if (strsectionname = 'SECTION') then
      begin
        parserstate   := 1;
        nexttokenbase := newtoken.childs;
      end else
      if (strsectionname = 'EOF') then
      begin
        freeandnil(newtoken);
        exit;
      end else
      // comments can be in the beginning of the file and start with 999
      if (intsectiongroupcode = 999) then
      begin
      // nothing to be done, let it add the token
      end else
        raise exception.create(format(
          'tdxftokenizer.readfromstrings: expected section, but got: %s', [strsectionname]));
    end else
    // processing the section name
    if parserstate = 1 then
    begin
      if (strsectionname = 'HEADER')  or
         (strsectionname = 'CLASSES') or
         (strsectionname = 'OBJECTS') or
         (strsectionname = 'THUMBNAILIMAGE') then
      begin
        parserstate      := 2;
        sectiontokenbase := curtokenbase;
      end else
      if (strsectionname = 'BLOCKS') or
         (strsectionname = 'TABLES') then
      begin
        parserstate      := 4;
        sectiontokenbase := curtokenbase;
      end else
      if (strsectionname = 'ENTITIES') then
      begin
        parserstate      := 3;
        sectiontokenbase := curtokenbase;
      end else
        raise exception.create(format(
          'tdxftokenizer.readfromstrings: invalid section name: %s', [strsectionname]));
    end else
    // reading a generic section
    if parserstate = 2 then
    begin
      if strsectionname = 'ENDSEC' then
      begin
        parserstate   := 0;
        curtokenbase  := sectiontokenbase;
        nexttokenbase := tokens;
      end;
    end else
    // reading the entities section
    if parserstate = 3 then
    begin
      if isentities_subsection(strsectionname) then
      begin
        curtokenbase  := sectiontokenbase;
        nexttokenbase := newtoken.childs;
      end else
      if strsectionname = 'ENDSEC' then
      begin
        parserstate   := 0;
        curtokenbase  := sectiontokenbase;
        nexttokenbase := tokens;
      end;
    end else
    // reading the tables or blocks sections
    if parserstate = 4 then
    begin
      // this orders the blocks themselves
      if istables_subsection(strsectionname) or
         isblocks_subsection(strsectionname) then
      begin
        curtokenbase   := sectiontokenbase;
        nexttokenbase  := newtoken.childs;
        lastblocktoken := newtoken.childs;
      end else
      // this orders the entities inside blocks
      if isentities_subsection(strsectionname) and (lastblocktoken <> nil) then
      begin
        curtokenbase  := lastblocktoken;
        nexttokenbase := newtoken.childs;
      end else
      if strsectionname = 'ENDSEC' then
      begin
        parserstate   := 0;
        curtokenbase  := sectiontokenbase;
        nexttokenbase := tokens;
      end;
    end;

    curtokenbase.add(newtoken);
    inc(i, 2);
  end;
end;

function tdxftokenizer.istables_subsection(astr: string): boolean;
begin
  result :=
    (astr = 'TABLE') or
    (astr = 'LAYER');
end;

function tdxftokenizer.isblocks_subsection(astr: string): boolean;
begin
  result :=
    (astr = 'BLOCK') or
    (astr = 'ENDBLK');
end;

function tdxftokenizer.isentities_subsection(astr: string): boolean;
begin
  result :=
    (astr = '3DFACE'           ) or
    (astr = '3DSOLID'          ) or
    (astr = 'ACAD_PROXY_ENTITY') or
    (astr = 'ARC'              ) or
    (astr = 'ATTDEF'           ) or
    (astr = 'ATTRIB'           ) or
    (astr = 'BODY'             ) or
    (astr = 'CIRCLE'           ) or
    (astr = 'DIMENSION'        ) or
    (astr = 'ELLIPSE'          ) or
    (astr = 'HATCH'            ) or
    (astr = 'IMAGE'            ) or
    (astr = 'INSERT'           ) or
    (astr = 'LEADER'           ) or
    (astr = 'LINE'             ) or
    (astr = 'LWPOLYLINE'       ) or
    (astr = 'MLINE'            ) or
    (astr = 'MTEXT'            ) or
    (astr = 'OLEFRAME'         ) or
    (astr = 'OLE2FRAME'        ) or
    (astr = 'POINT'            ) or
    (astr = 'POLYLINE'         ) or
    (astr = 'RAY'              ) or
    (astr = 'REGION'           ) or
    (astr = 'SEQEND'           ) or
    (astr = 'SHAPE'            ) or
    (astr = 'SOLID'            ) or
    (astr = 'SPLINE'           ) or
    (astr = 'TEXT'             ) or
    (astr = 'TOLERANCE'        ) or
    (astr = 'TRACE'            ) or
    (astr = 'VERTEX'           ) or
    (astr = 'VIEWPORT'         ) or
    (astr = 'XLINE');
end;

{ tvdxfvectorialreader }

procedure tvdxfreader.readheader(atokens: tdxftokens; elements: tvpelementlist);
var
      i, j: integer;
  curtoken: tdxftoken;
  curfield: pvppoint;
  S: string;
begin
  i := 0;
  while i < atokens.count do
  begin
    curtoken := tdxftoken(atokens.items[i]);

    s:= curtoken.strvalue;

    if curtoken.strvalue = '$ANGBASE' then
    begin
      curtoken := tdxftoken(atokens.items[i+1]);
      angbase  := strtofloat(curtoken.strvalue, fpointseparator);
      inc(i);
    end else
    if curtoken.strvalue = '$ANGDIR' then
    begin
      curtoken := tdxftoken(atokens.items[i+1]);
      angdir   := strtoint(curtoken.strvalue);
      inc(i);
    end else
    // this indicates the size of the document
    if (curtoken.strvalue = '$INSBASE') or
       (curtoken.strvalue = '$EXTMIN' ) or (curtoken.strvalue = '$EXTMAX') or
       (curtoken.strvalue = '$LIMMIN' ) or (curtoken.strvalue = '$LIMMAX') then
    begin
      if (curtoken.strvalue = '$INSBASE') then curfield := @INSBASE else
      if (curtoken.strvalue = '$EXTMIN' ) then curfield := @EXTMIN  else
      if (curtoken.strvalue = '$EXTMAX' ) then curfield := @EXTMAX  else
      if (curtoken.strvalue = '$LIMMIN' ) then curfield := @LIMMIN  else
      if (curtoken.strvalue = '$LIMMAX' ) then curfield := @LIMMAX;

      // check the next 2 items and verify if they
      // are the values of the size of the document
      for j := 0 to 1 do
      begin
        curtoken := tdxftoken(atokens.items[i+1]);
        case curtoken.groupcode of
        10:
        begin;
          curfield^.x := strtofloat(curtoken.strvalue, fpointseparator);
          inc(i);
        end;
        20:
        begin
          curfield^.y := strtofloat(curtoken.strvalue, fpointseparator);
          inc(i);
        end;
        end;
      end;
    end else

    if curtoken.strvalue = '$DWGCODEPAGE' then
    begin
      //if we are forcing an encoding, don't use the value from the header
      //if adoc.forcedencodingonread = '' then
      //begin
      curtoken := tdxftoken(atokens.items[i+1]);
        //if curtoken.strvalue = 'ANSI_1252' then
        //  encoding := 'CP1252';
      //end;
      inc(i);
    end;
    inc(i);
  end;
end;

procedure tvdxfreader.readtables(atokens: tdxftokens; elements: tvpelementlist);
var
  i: integer;
  curtoken: tdxftoken;
begin
  for i := 0 to atokens.count - 1 do
  begin
    curtoken := tdxftoken(atokens.items[i]);
    if curtoken.strvalue = 'TABLE' then readtables_table(curtoken.childs, elements) else
    if curtoken.strvalue = 'LAYER' then readtables_layer(curtoken.childs, elements) else
    begin
      // ...
    end;
  end;
end;

procedure tvdxfreader.readtables_table(atokens: tdxftokens; elements: tvpelementlist);
var
  curtoken: tdxftoken;
  i: integer;
  //block data
  lname: string;
  posx, posy, posz: vpfloat;
begin
  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
       2: lname := curtoken.strvalue;
      10:  posx := curtoken.floatvalue;
      20:  posy := curtoken.floatvalue;
      30:  posz := curtoken.floatvalue;
       0:
      begin
        //...
      end;
    end;
  end;
end;

procedure tvdxfreader.readtables_layer(atokens: tdxftokens; elements: tvpelementlist);
var
  curtoken: tdxftoken;
  i: integer;
  //layer data
  lname: string;
  posx, posy, posz: vpfloat;
begin
  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
       2: lname := curtoken.strvalue;
      10:  posx := curtoken.floatvalue;
      20:  posy := curtoken.floatvalue;
      30:  posz := curtoken.floatvalue;
       0:
      begin
        // ...
      end;
    end;
  end;
end;

procedure tvdxfreader.readblocks(atokens: tdxftokens; elements: tvpelementlist);
var
  i: integer;
  curtoken: tdxftoken;
begin
  for i := 0 to atokens.count - 1 do
  begin
    curtoken := tdxftoken(atokens.items[i]);
    if curtoken.strvalue = 'BLOCK'  then readblocks_block (curtoken.childs, elements) else
    if curtoken.strvalue = 'ENDBLK' then readblocks_endblk(curtoken.childs, elements) else
    begin
      // ...
    end;
  end;
end;

procedure tvdxfreader.readblocks_block(atokens: tdxftokens; elements: tvpelementlist);
var
  curtoken: tdxftoken;
  i: integer;
  //block data
  lname: string;
  posx, posy, posz: vpfloat;
begin
  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
       2: lname := curtoken.strvalue;
      10:  posx := curtoken.floatvalue;
      20:  posy := curtoken.floatvalue;
      30:  posz := curtoken.floatvalue;
       0:
      begin
        //...
      end;
    end;
  end;
end;

procedure tvdxfreader.readblocks_endblk(atokens: tdxftokens; elements: tvpelementlist);
begin
  // ...
end;

procedure tvdxfreader.readentities(atokens: tdxftokens; elements: tvpelementlist);
var
  i: integer;
  curtoken: tdxftoken;
begin
  isreadingpolyline := false;

  for i := 0 to atokens.count - 1 do
  begin
    curtoken := tdxftoken(atokens.items[i]);
    internalreadentities(curtoken.strvalue, curtoken.childs, elements);
  end;
end;

procedure tvdxfreader.readentities_line(atokens: tdxftokens; elements: tvpelementlist);
var
  curtoken: tdxftoken;
  i: integer;
  // lline
  llayer: string;
  lline:  tvpline;
begin
  // initial values
  lline.p0.x := 0.0;
  lline.p0.y := 0.0;
  //lline.p0.z := true;
  lline.p1.x := 0.0;
  lline.p1.y := 0.0;
  //lline.p1.z := true;
  llayer     :=  '';

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 11, 21, 31, 62] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
       8: llayer     := curtoken.strvalue;
      10: lline.p0.x := curtoken.floatvalue;
      20: lline.p0.y := curtoken.floatvalue;
    //30: lline.p0.z := curtoken.floatvalue;
      11: lline.p1.x := curtoken.floatvalue;
      21: lline.p1.y := curtoken.floatvalue;
    //31: lline.p1.z := curtoken.floatvalue;
    //62: lcolor     := curtoken.floatvalue;
    end;
  end;

  elements.add(lline);
end;

procedure tvdxfreader.readentities_circlearc(atokens: tdxftokens; elements: tvpelementlist);
var
  curtoken: tdxftoken;
  i: integer;
  // circlearc
  llayer: string;
  larc: tvpcirclearc;
begin
  larc.center.x   := 0.0;
  larc.center.y   := 0.0;
//larc.center.z   := 0.0;
  larc.radius     := 0.0;
  larc.startangle := 0.0;
  larc.endangle   := 0.0;
  llayer          :=  '';

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 40, 50, 51, 62] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
       8: llayer          := curtoken.strvalue;
      10: larc.center.x   := curtoken.floatvalue;
      20: larc.center.y   := curtoken.floatvalue;
    //30: larc.center.z   := curtoken.floatvalue;
      40: larc.radius     := curtoken.floatvalue;
      50: larc.startangle := curtoken.floatvalue;
      51: larc.endangle   := curtoken.floatvalue;
    //62: lcolor          := curtoken.floatvalue;
    end;
  end;

  // in dxf the endangle is always greater then the startangle.
  // if it isn't then sum 360 to it to make sure we don't get wrong results
  if larc.endangle < larc.startangle then
    larc.endangle := larc.endangle + 360;

  elements.add(larc);
end;

procedure tvdxfreader.readentities_circle(atokens: tdxftokens; elements: tvpelementlist);
var
  curtoken: tdxftoken;
  i: integer;
  // circle
  llayer: string;
  lcircle: tvpcircle;
begin
  lcircle.center.x := 0.0;
  lcircle.center.y := 0.0;
//lcircle.center.z := 0.0;
  lcircle.radius   := 0.0;
  llayer           :=  '';

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 40] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
       8: llayer           := curtoken.strvalue;
      10: lcircle.center.x := curtoken.floatvalue;
      20: lcircle.center.y := curtoken.floatvalue;
    //30: lcircle.center.z := curtoken.floatvalue;
      40: lcircle.radius   := curtoken.floatvalue;
    end;
  end;

  elements.add(lcircle);
end;

procedure tvdxfreader.readentities_ellipse(atokens: tdxftokens; elements: tvpelementlist);
var
  curtoken: tdxftoken;
  i: integer;
  // ellipse
  llayer: string;
  lellipse: tvpellipse;
begin
  lellipse.center.x       := 0.0;
  lellipse.center.y       := 0.0;
//lellipse.center.z       := 0.0;
//lellipse.majoraxisendx  := 0.0;
//lellipse.majoraxisendy  := 0.0;
//lellipse.majoraxisendz  := 0.0;
//lellipse.minoraxisratio := 0.0;
//lellipse.startparam     := 0.0;
//lellipse.endparam       := 0.0;
  llayer                  :=  '';

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 11, 21, 31, 40, 41, 42] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
       8: llayer                  := curtoken.strvalue;
      10: lellipse.center.x       := curtoken.floatvalue;
      20: lellipse.center.y       := curtoken.floatvalue;
    //30: lellipse.center.z       := curtoken.floatvalue;
    //11: lellipse.majoraxisendx  := curtoken.floatvalue;
    //21: lellipse.majoraxisendy  := curtoken.floatvalue;
    //31: lellipse.majoraxisendz  := curtoken.floatvalue;
    //40: lellipse.minoraxisratio := curtoken.floatvalue;
    //41: lellipse.startparam     := curtoken.floatvalue;
    //42: lellipse.endparam       := curtoken.floatvalue;
    end;
  end;

  //elements.add(lellipse);
end;

{.$define FPVECTORIALDEBUG_LWPOLYLINE}
{
100 Subclass marker (AcDbPolyline)
90  Number of vertices
70  Polyline flag (bit-coded); default is 0:
    1 = Closed; 128 = Plinegen
43  Constant width (optional; default = 0). Not used if variable width (codes 40 and/or 41) is set
38  Elevation (optional; default = 0)
39  Thickness (optional; default = 0)
10  Vertex coordinates (in OCS), multiple entries; one entry for each vertex
    DXF: X value; APP: 2D point
20  DXF: Y value of vertex coordinates (in OCS), multiple entries; one entry for each vertex
40  Starting width (multiple entries; one entry for each vertex) (optional; default = 0; multiple entries). Not used if constant width (code 43) is set
41  End width (multiple entries; one entry for each vertex) (optional; default = 0; multiple entries). Not used if constant width (code 43) is set
42  Bulge (multiple entries; one entry for each vertex) (optional; default = 0)
210 Extrusion direction (optional; default = 0, 0, 1)
    DXF: X value; APP: 3D vector
220, 230 DXF: Y and Z values of extrusion direction (optional)
}

(*
function tvdxfreader.readentities_lwpolyline(atokens: tdxftokens;
  apaths: tvppaths; aonlycreate: boolean = false): tpath;
var
  curtoken: tdxftoken;
  i, curpoint: integer;
  // line
  lwpolyline: array of tlwpolylineelement;
  lwflags: integer = 0;
begin
  curpoint := -1;
  result   := nil;

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 11, 21, 31, 70] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    // loads the coordinates
    // with position fixing for documents with negative coordinates
    case curtoken.groupcode of
      10:
      begin
        // starting a new point
        inc(curpoint);
        setlength(lwpolyline, curpoint+1);

        lwpolyline[curpoint].x := curtoken.floatvalue - doc_offset.x;
      end;
      20: lwpolyline[curpoint].y := curtoken.floatvalue - doc_offset.y;
      70: lwflags := round(curtoken.floatvalue);
    end;
  end;

  // in case of a flag="closed" then we need to close the line
  if lwflags = 1 then
  begin
    inc(curpoint);
    setlength(lwpolyline, curpoint+1);
    lwpolyline[curpoint].x := lwpolyline[0].x;
    lwpolyline[curpoint].y := lwpolyline[0].y;
  end;

  // And now write it
  if curPoint >= 0 then // otherwise the polyline is empty of points
  begin
    //AData.StartPath(LWPolyline[0].X, LWPolyline[0].Y);
    {$ifdef FPVECTORIALDEBUG_LWPOLYLINE}
    Write(Format('LWPOLYLINE ID=%d %f,%f', [AData.PathCount-1, LWPolyline[0].X, LWPolyline[0].Y]));
    {$endif}
    for i := 1 to curPoint do
    begin
      //AData.AddLineToPath(LWPolyline[i].X, LWPolyline[i].Y);
      {$ifdef FPVECTORIALDEBUG_LWPOLYLINE}
       Write(Format(' %f,%f', [LWPolyline[i].X, LWPolyline[i].Y]));
      {$endif}
    end;
    {$ifdef FPVECTORIALDEBUG_LWPOLYLINE}
     WriteLn('');
    {$endif}
    //Result := AData.EndPath(AOnlyCreate);
  end;
end;

{.$define FPVECTORIALDEBUG_SPLINE}
function tvdxfreader.readentities_spline(atokens: tdxftokens;
  apaths: tvppaths; aonlycreate: boolean = false): tpath;
var
  curtoken: tdxftoken;
  i, curpoint: integer;
  // line
  spline: array of tsplineelement;
begin
  curpoint := -1;
  result := nil;

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 11, 21, 31] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    // loads the coordinates
    // with position fixing for documents with negative coordinates
    case curtoken.groupcode of
      10:
      begin
        // starting a new point
        inc(curpoint);
        setlength(spline, curpoint+1);

        spline[curpoint].x := curtoken.floatvalue - doc_offset.x;
      end;
      20: spline[curpoint].y := curtoken.floatvalue - doc_offset.y;
    end;
  end;

  // And now write it
  if curPoint >= 0 then // otherwise the polyline is empty of points
  begin
    //AData.StartPath(SPLine[0].X, SPLine[0].Y);
    {$ifdef FPVECTORIALDEBUG_SPLINE}
    Write(Format('SPLINE ID=%d %f,%f', [AData.PathCount-1, SPLine[0].X, SPLine[0].Y]));
    {$endif}
    for i := 1 to curPoint do
    begin
      //AData.AddLineToPath(SPLine[i].X, SPLine[i].Y);
      {$ifdef FPVECTORIALDEBUG_SPLINE}
       Write(Format(' %f,%f', [SPLine[i].X, SPLine[i].Y]));
      {$endif}
    end;
    {$ifdef FPVECTORIALDEBUG_SPLINE}
     WriteLn('');
    {$endif}
    //Result := AData.EndPath(AOnlyCreate);
  end;
end;

*)

(*
procedure tvdxfreader.readentities_polyline(atokens: tdxftokens; apaths: tvppaths);
begin
  setlength(polyline, 0);
end;

*)


(*
procedure tvdxfreader.readentities_vertex(atokens: tdxftokens; apaths: tvppaths);
var
  curtoken: tdxftoken;
  i, curpoint: integer;
begin
  if not isreadingpolyline then raise exception.create('[tvdxfvectorialreader.readentities_vertex] unexpected record: vertex before a polyline');

  curpoint := length(polyline);
  setlength(polyline, curpoint+1);
  polyline[curpoint].x := 0;
  polyline[curpoint].y := 0;
  polyline[curpoint].color := colblack;

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 62] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    // loads the coordinates
    // with position fixing for documents with negative coordinates
    case curtoken.groupcode of
      10: polyline[curpoint].x     := curtoken.floatvalue - doc_offset.x;
      20: polyline[curpoint].y     := curtoken.floatvalue - doc_offset.y;
      62: polyline[curpoint].color := dxfcolorindextofpcolor(trunc(curtoken.floatvalue));
    end;
  end;
end;

*)


(*
function tvdxfreader.readentities_seqend(atokens: tdxftokens;
  apaths: tvppaths; aonlycreate: boolean = false): tpath;
var
  i: Integer;
begin
  Result := nil;
  if (not IsReadingPolyline) and (not IsReadingAttrib) then
    raise Exception.Create('[TvDXFVectorialReader.ReadENTITIES_SEQEND] Unexpected record: SEQEND before a POLYLINE or ATTRIB');

  if IsReadingPolyline then
  begin
    // Write the Polyline to the document
    if Length(Polyline) >= 0 then // otherwise the polyline is empty of points
    begin
      //AData.StartPath(Polyline[0].X, Polyline[0].Y);
      {$ifdef FPVECTORIALDEBUG_POLYLINE}
       Write(Format('POLYLINE %f,%f', [Polyline[0].X, Polyline[0].Y]));
      {$endif}
      for i := 1 to Length(Polyline)-1 do
      begin
        //AData.AddLineToPath(Polyline[i].X, Polyline[i].Y, Polyline[i].Color);
        {$ifdef FPVECTORIALDEBUG_POLYLINE}
         Write(Format(' %f,%f', [Polyline[i].X, Polyline[i].Y]));
        {$endif}
      end;
      {$ifdef FPVECTORIALDEBUG_POLYLINE}
       WriteLn('');
      {$endif}
      //Result := AData.EndPath(AOnlyCreate);
    end;
  end;
end;

function tvdxfreader.readentities_mtext(atokens: tdxftokens;
  apaths: tvppaths; aonlycreate: boolean = false): tvtext;
var
  curtoken: tdxftoken;
  i: integer;
  posx: vpfloat = 0.0;
  posy: vpfloat = 0.0;
  posz: vpfloat = 0.0;
  fontsize: vpfloat = 10.0;
  str: string = '';
begin
  for i := 0 to ATokens.Count - 1 do
  begin
    // Now read and process the item name
    CurToken := TDXFToken(ATokens.Items[i]);

    // Avoid an exception by previously checking if the conversion can be made
    if CurToken.GroupCode in [10, 20, 30, 40] then
    begin
      CurToken.FloatValue :=  StrToFloat(Trim(CurToken.StrValue), FPointSeparator);
    end;

    case CurToken.GroupCode of
      1:  Str := CurToken.StrValue;
      10: PosX := CurToken.FloatValue;
      20: PosY := CurToken.FloatValue;
      30: PosZ := CurToken.FloatValue;
      40: FontSize := CurToken.FloatValue;
    end;
  end;

  // Position fixing for documents with negative coordinates
  PosX := PosX - DOC_OFFSET.X;
  PosY := PosY + FontSize - DOC_OFFSET.Y;

  //
  // Result := AData.AddText(PosX, PosY, 0, '', Round(FontSize), Str, AOnlyCreate);
  Result.Font.Color := colWhite;
end;

function tvdxfreader.readentities_leader(atokens: tdxftokens;
  apaths: tvppaths; aonlycreate: boolean = false): tvarrow;
var
  curtoken: tdxftoken;
  i, curpoint: integer;
  lvaluex, lvaluey: vpfloat;
  larrow: tvarrow;
  lelementcolor: tfpcolor;
begin
  // larrow        := tvarrow.create(adata);
  curpoint      := 0;
  lelementcolor := colblack;
  result        := nil;

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 11, 21, 31, 62] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    // loads the coordinates
    // with position fixing for documents with negative coordinates
    case curtoken.groupcode of
      10:
      begin
        // starting a new point
        inc(curpoint);

        lvaluex := curtoken.floatvalue - doc_offset.x;

        case curpoint of
        1: larrow.x := lvaluex;
        2: larrow.base.x := lvaluex;
        3: larrow.extralinebase.x := lvaluex;
        end;
      end;
      20:
      begin
        lvaluey := curtoken.floatvalue - doc_offset.y;

        case curpoint of
        1: larrow.y := lvaluey;
        2: larrow.base.y := lvaluey;
        3: larrow.extralinebase.y := lvaluey;
        end;
      end;
      62: lelementcolor := dxfcolorindextofpcolor(trunc(curtoken.floatvalue));
    end;
  end;

  // give a % of the line length to the arrow head
  larrow.arrowlength := 0.2 * sqrt(sqr(larrow.base.y - larrow.y) + sqr(larrow.base.x - larrow.x));
  larrow.arrowbaselength := larrow.arrowlength / 2;

  // and now write it
  larrow.hasextraline := true;
  larrow.pen.color    := lelementcolor;
  larrow.brush.style  := bssolid;
  larrow.brush.color  := lelementcolor;
  result := larrow;
  //if not aonlycreate then adata.addentity(larrow);
end;

function tvdxfreader.readentities_point(atokens: tdxftokens;
  apaths: tvppaths; aonlycreate: boolean = false): tventity;
var
  curtoken: tdxftoken;
  i: integer;
  circlecenterx, circlecentery, circlecenterz, circleradius: vpfloat;
begin
  circlecenterx := 0.0;
  circlecentery := 0.0;
  circlecenterz := 0.0;
  circleradius  := 1.0;

  for i := 0 to atokens.count - 1 do
  begin
    // now read and process the item name
    curtoken := tdxftoken(atokens.items[i]);

    // avoid an exception by previously checking if the conversion can be made
    if curtoken.groupcode in [10, 20, 30, 40] then
      curtoken.floatvalue :=  strtofloat(trim(curtoken.strvalue), fpointseparator);

    case curtoken.groupcode of
      10: circlecenterx := curtoken.floatvalue;
      20: circlecentery := curtoken.floatvalue;
      30: circlecenterz := curtoken.floatvalue;
//      40: circleradius := curtoken.floatvalue;
    end;
  end;

  // position fixing for documents with negative coordinates
  circlecenterx := circlecenterx - doc_offset.x;
  circlecentery := circlecentery - doc_offset.y;

  //result := adata.addcircle(circlecenterx, circlecentery, circleradius, aonlycreate);
end;

*)

procedure tvdxfreader.internalreadentities(atokenstr: string; atokens: tdxftokens; elements: tvpelementlist);
begin
  case atokenstr of
    'ARC':     readentities_circlearc (atokens, elements);
    'CIRCLE':  readentities_circle    (atokens, elements);
    'ELLIPSE': readentities_ellipse   (atokens, elements);
    'LINE':    readentities_line      (atokens, elements);
  end;
end;

constructor tvdxfreader.create;
begin
  inherited create;
  tokenizer       := tdxftokenizer.create;
  fpointseparator := defaultformatsettings;
  fpointseparator.decimalseparator  := '.';
  // disable the thousand separator
  fpointseparator.thousandseparator := '#';
end;

destructor tvdxfreader.destroy;
begin
  tokenizer.free;
  inherited destroy;
end;

procedure tvdxfreader.readfromstrings(astrings: tstrings; elements: tvpelementlist);
var
  i: integer;
  curtoken,
  curtokenfirstchild: tdxftoken;
begin
  // default header data
  //angbase := 0.0; // starts pointing to the right / east
  //angdir  := 0;   // counter-clock wise

  tokenizer.readfromstrings(astrings);
  for i := 0 to tokenizer.tokens.count - 1 do
  begin
    curtoken := tdxftoken(tokenizer.tokens.items[i]);
    if (curtoken.childs       = nil) or
       (curtoken.childs.count = 0  ) then continue;
    curtokenfirstchild := tdxftoken(curtoken.childs.items[0]);

  //if curtokenfirstchild.strvalue = 'HEADER'   then readheader  (curtoken.childs, apaths) else
  //if curtokenfirstchild.strvalue = 'TABLES'   then readtables  (curtoken.childs, apaths) else
  //if curtokenfirstchild.strvalue = 'BLOCKS'   then readblocks  (curtoken.childs, apaths) else
    if curtokenfirstchild.strvalue = 'ENTITIES' then readentities(curtoken.childs, elements);
  end;
end;

procedure tvdxfreader.readfromfile(const afilename: string; elements: tvpelementlist);
var
  s: tstringlist;
begin
  s := tstringlist.create;
  s.loadfromfile(afilename);
  readfromstrings(s, elements);
  s.destroy;
end;

// dxf2paths

procedure dxf2paths(const afilename: string; elements: tvpelementlist);
var
  reader: tvdxfreader;
begin
  reader := tvdxfreader.create;
  reader.readfromfile(afilename, elements);
  reader.destroy;

  elements.movetoorigin;
end;

end.


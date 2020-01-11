{
  Description: vPlot paths class.

  Copyright (C) 2017-2019 Melchiorre Caruso <melchiorrecaruso@gmail.com>

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

unit vppaths;

{$mode objfpc}

interface

uses
  classes, graphics, sysutils, vpmath, vpwave, bgrapath, bgrabitmaptypes;

type
  tvpelement = class(tobject)
  private
    fhidden:   boolean;
    fselected: boolean;
  public
    constructor create;
    destructor destroy; override;
    procedure invert; virtual; abstract;
    procedure move(deltax, deltay: vpfloat); virtual; abstract;
    procedure rotate(angle: vpfloat); virtual; abstract;
    procedure scale(value: vpfloat); virtual; abstract;
    procedure mirrorx; virtual; abstract;
    procedure mirrory; virtual; abstract;
    procedure interpolate(var path: tvppolygonal; value: vpfloat); virtual abstract;
    function interpolate: tbgrapath; virtual abstract;
    procedure read(stream: tstream); virtual;
    procedure write(stream: tstream); virtual;
    function getfirstpoint: tvppoint; virtual abstract;
    function getlastpoint: tvppoint; virtual abstract;
  public
    property hidden:   boolean  read fhidden   write fhidden;
    property selected: boolean  read fselected write fselected;
  end;

  tvpelementline = class(tvpelement)
  private
    fline: tvpline;
  public
    constructor create;
    constructor create(const aline: tvpline);
    procedure invert; override;
    procedure move(deltax, deltay: vpfloat); override;
    procedure rotate(angle: vpfloat); override;
    procedure scale(value: vpfloat); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: vpfloat); override;
    function interpolate: tbgrapath; override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function getfirstpoint: tvppoint; override;
    function getlastpoint: tvppoint; override;
  end;

  tvpelementcircle = class(tvpelement)
  private
    fcircle: tvpcircle;
  public
    constructor create;
    constructor create(const acircle: tvpcircle);
    procedure invert; override;
    procedure move(deltax, deltay: vpfloat); override;
    procedure rotate(angle: vpfloat); override;
    procedure scale(value: vpfloat); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: vpfloat); override;
    function interpolate: tbgrapath; override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function getfirstpoint: tvppoint; override;
    function getlastpoint: tvppoint; override;
  end;

  tvpelementcirclearc = class(tvpelement)
  private
    fcirclearc: tvpcirclearc;
  public
    constructor create;
    constructor create(const acirclearc: tvpcirclearc);
    procedure invert; override;
    procedure move(deltax, deltay: vpfloat); override;
    procedure rotate(angle: vpfloat); override;
    procedure scale(value: vpfloat); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: vpfloat); override;
    function interpolate: tbgrapath; override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function getfirstpoint: tvppoint; override;
    function getlastpoint: tvppoint; override;
  end;

  tvpelementpolygonal = class(tvpelement)
  private
    fpolygonal: tvppolygonal;
  public
    constructor create;
    constructor create(const apolygonal: tvppolygonal);
    procedure invert; override;
    procedure move(deltax, deltay: vpfloat); override;
    procedure rotate(angle: vpfloat); override;
    procedure scale(value: vpfloat); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: vpfloat); override;
    function interpolate: tbgrapath; override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function getfirstpoint: tvppoint; override;
    function getlastpoint: tvppoint; override;
  end;

  tvpelementlist = class(tobject)
  private
    flist: tfplist;
    fheight: single;
    fwidth: single;
    procedure createtoolpath4layer(list: tfplist);
    function getitem(index: longint): tvpelement;
    function getcount: longint;
    function getmid: tvppoint;
  public
    constructor create;
    destructor destroy; override;
    procedure add(const line: tvpline);
    procedure add(const circle: tvpcircle);
    procedure add(const circlearc: tvpcirclearc);
    procedure add(const polygonal: tvppolygonal);
    procedure add(element: tvpelement);
    procedure merge(elements: tvpelementlist);
    procedure insert(index: longint; element: tvpelement);
    function  extract(index: longint): tvpelement;
    procedure delete(index: longint);
    procedure clear;
    //
    procedure move(deltax, deltay: vpfloat);
    procedure rotate(angle: vpfloat);
    procedure scale(value: vpfloat);
    procedure mirrorx;
    procedure mirrory;
    procedure invert;
    procedure invert(index: longint);
    procedure createtoolpath;
    procedure movetoorigin;
    //
    procedure hide(value: boolean);
    procedure hideselected;
    procedure inverthidden;
    //
    procedure select(value: boolean);
    procedure selectattached;
    procedure invertselected;

    procedure load(const filename: string);
    procedure save(const filename: string);
  public
    property count: longint read getcount;
    property items[index: longint]: tvpelement read getitem;
    property height: single read fheight;
    property width: single read fwidth;
  end;


implementation

uses
  math;

// tvpelement routines

function getfirst(const p: tvppoint; list: tfplist): longint;
var
  i: longint;
begin
  result := -1;
  for i := 0 to list.count -1 do
  begin
    if distance_between_two_points(p, tvpelement(list[i]).getfirstpoint) < 0.02 then
    begin
      result := i;
      exit;
    end
  end;
end;

function getlast(const p: tvppoint; list: tfplist): longint;
var
  i: longint;
begin
  result := -1;
  for i := 0 to list.count -1 do
  begin
    if distance_between_two_points(p, tvpelement(list[i]).getlastpoint) < 0.02 then
    begin
      result := i;
      exit;
    end
  end;
end;

function getnear(const p: tvppoint; list: tfplist): longint;
var
     i: longint;
  len1: vpfloat = $FFFFFFF;
  len2: vpfloat = $FFFFFFF;
  elem: tvpelement;
begin
  result := -1;
  for i := 0 to list.count -1 do
  begin
    elem := tvpelement(list[i]);

    len2 := distance_between_two_points(p, elem.getfirstpoint);
    if len1 > len2 then
    begin
      len1   := len2;
      result := i;
    end;

    len2 := distance_between_two_points(p, elem.getlastpoint);
    if len1 > len2 then
    begin
      elem.invert;
      len1   := len2;
      result := i;
    end;

  end;
end;

function isaloop(const element: tvpelement): boolean;
begin
  result := distance_between_two_points(
    element.getfirstpoint,
    element.getlastpoint) < 0.02;
end;

// tvpelement

constructor tvpelement.create;
begin
  inherited create;
  fhidden   := false;
  fselected := false;
end;

destructor tvpelement.destroy;
begin
  inherited destroy;
end;

procedure tvpelement.read(stream: tstream);
begin
  stream.read(fhidden,   sizeof(boolean));
  stream.read(fselected, sizeof(boolean));
end;

procedure tvpelement.write(stream: tstream);
begin
  stream.write(fhidden,   sizeof(boolean));
  stream.write(fselected, sizeof(boolean));
end;

// tvpelementline

constructor tvpelementline.create;
begin
  inherited create;
end;

constructor tvpelementline.create(const aline: tvpline);
begin
  inherited create;
  fline := aline;
end;

procedure tvpelementline.invert;
begin
  vpmath.invert(fline);
end;

procedure tvpelementline.move(deltax, deltay: vpfloat);
begin
  vpmath.move(fline, deltax, deltay);
end;

procedure tvpelementline.rotate(angle: vpfloat);
begin
  vpmath.rotate(fline, angle);
end;

procedure tvpelementline.scale(value: vpfloat);
begin
  vpmath.scale(fline, value);
end;

procedure tvpelementline.mirrorx;
begin
  vpmath.mirrorx(fline);
end;

procedure tvpelementline.mirrory;
begin
  vpmath.mirrory(fline);
end;

procedure tvpelementline.interpolate(var path:  tvppolygonal; value: vpfloat);
begin
  vpmath.interpolate(fline, path, value);
end;

function tvpelementline.interpolate: tbgrapath;
begin
  result := tbgrapath.create;
  result.beginpath;
  result.moveto(fline.p0.x, fline.p0.y);
  result.lineto(fline.p1.x, fline.p1.y);
end;

procedure tvpelementline.read(stream: tstream);
begin
  inherited read(stream);
  stream.read(fline, sizeof(tvpline));
end;

procedure tvpelementline.write(stream: tstream);
begin
  inherited write(stream);
  stream.write(fline, sizeof(tvpline));
end;

function tvpelementline.getfirstpoint: tvppoint;
begin
  result := fline.p0;
end;

function tvpelementline.getlastpoint: tvppoint;
begin
  result := fline.p1;
end;

// tvpelementcircle

constructor tvpelementcircle.create;
begin
  inherited create;
end;

constructor tvpelementcircle.create(const acircle: tvpcircle);
begin
  inherited create;
  fcircle := acircle;
end;

procedure tvpelementcircle.invert;
begin
  vpmath.invert(fcircle);
end;

procedure tvpelementcircle.move(deltax, deltay: vpfloat);
begin
  vpmath.move(fcircle, deltax, deltay);
end;

procedure tvpelementcircle.rotate(angle: vpfloat);
begin
  vpmath.rotate(fcircle, angle);
end;

procedure tvpelementcircle.scale(value: vpfloat);
begin
  vpmath.scale(fcircle, value);
end;

procedure tvpelementcircle.mirrorx;
begin
  vpmath.mirrorx(fcircle);
end;

procedure tvpelementcircle.mirrory;
begin
  vpmath.mirrory(fcircle);
end;

procedure tvpelementcircle.interpolate(var path:  tvppolygonal; value: vpfloat);
begin
  vpmath.interpolate(fcircle, path, value);
end;

function tvpelementcircle.interpolate: tbgrapath;
begin
  result := tbgrapath.create;
  result.beginpath;
  result.arc(fcircle.center.x,
             fcircle.center.y,
             fcircle.radius,0, 2*pi);
end;

procedure tvpelementcircle.read(stream: tstream);
begin
  inherited read(stream);
  stream.read(fcircle, sizeof(tvpcircle));
end;

procedure tvpelementcircle.write(stream: tstream);
begin
  inherited write(stream);
  stream.write(fcircle, sizeof(tvpcircle));
end;

function tvpelementcircle.getfirstpoint: tvppoint;
begin
  result.x := fcircle.center.x + fcircle.radius;
  result.y := fcircle.center.y;
end;

function tvpelementcircle.getlastpoint: tvppoint;
begin
  result := getfirstpoint;
end;

// tvpelementcirclearc

constructor tvpelementcirclearc.create;
begin
  inherited create;
end;

constructor tvpelementcirclearc.create(const acirclearc: tvpcirclearc);
begin
  inherited create;
  fcirclearc := acirclearc;
end;

procedure tvpelementcirclearc.invert;
begin
  vpmath.invert(fcirclearc);
end;

procedure tvpelementcirclearc.move(deltax, deltay: vpfloat);
begin
  vpmath.move(fcirclearc, deltax, deltay);
end;

procedure tvpelementcirclearc.rotate(angle: vpfloat);
begin
  vpmath.rotate(fcirclearc, angle);
end;

procedure tvpelementcirclearc.scale(value: vpfloat);
begin
  vpmath.scale(fcirclearc, value);
end;

procedure tvpelementcirclearc.mirrorx;
begin
  vpmath.mirrorx(fcirclearc);
end;

procedure tvpelementcirclearc.mirrory;
begin
  vpmath.mirrory(fcirclearc);
end;

procedure tvpelementcirclearc.interpolate(var path:  tvppolygonal; value: vpfloat);
begin
  vpmath.interpolate(fcirclearc, path, value);
end;

function tvpelementcirclearc.interpolate: tbgrapath;
begin
  result := tbgrapath.create;
  result.beginpath;
  result.arc(fcirclearc.center.x,
             fcirclearc.center.y,
             fcirclearc.radius,
    degtorad(fcirclearc.startangle),
    degtorad(fcirclearc.endangle),
             fcirclearc.startangle >
             fcirclearc.endangle);
end;

procedure tvpelementcirclearc.read(stream: tstream);
begin
  inherited read(stream);
  stream.read(fcirclearc, sizeof(tvpcirclearc));
end;

procedure tvpelementcirclearc.write(stream: tstream);
begin
  inherited write(stream);
  stream.write(fcirclearc, sizeof(tvpcirclearc));
end;

function tvpelementcirclearc.getfirstpoint: tvppoint;
begin
  result.x := fcirclearc.radius;
  result.y := 0;
  vpmath.rotate(result, degtorad(fcirclearc.startangle));
  vpmath.move  (result, fcirclearc.center.x,
                        fcirclearc.center.y);
end;

function tvpelementcirclearc.getlastpoint: tvppoint;
begin
  result.x := fcirclearc.radius;
  result.y := 0;
  vpmath.rotate(result, degtorad(fcirclearc.endangle));
  vpmath.move  (result, fcirclearc.center.x,
                        fcirclearc.center.y);
end;

// tvpelementpolygonal

constructor tvpelementpolygonal.create;
begin
  inherited create;
end;

constructor tvpelementpolygonal.create(const apolygonal: tvppolygonal);
var
  i: longint;
begin
  inherited create;
  setlength(fpolygonal, system.length(apolygonal));
  for i := 0 to high(apolygonal) do
  begin
    fpolygonal[i] := apolygonal[i];
  end;
end;

procedure tvpelementpolygonal.invert;
begin
  vpmath.invert(fpolygonal);
end;

procedure tvpelementpolygonal.move(deltax, deltay: vpfloat);
begin
  vpmath.move(fpolygonal, deltax, deltay);
end;

procedure tvpelementpolygonal.rotate(angle: vpfloat);
begin
  vpmath.rotate(fpolygonal, angle);
end;

procedure tvpelementpolygonal.scale(value: vpfloat);
begin
  vpmath.scale(fpolygonal, value);
end;

procedure tvpelementpolygonal.mirrorx;
begin
  vpmath.mirrorx(fpolygonal);
end;

procedure tvpelementpolygonal.mirrory;
begin
  vpmath.mirrory(fpolygonal);
end;

procedure tvpelementpolygonal.interpolate(var path:  tvppolygonal; value: vpfloat);
begin
  vpmath.interpolate(fpolygonal, path, value);
end;

function tvpelementpolygonal.interpolate: tbgrapath;
begin
  result := tbgrapath.create;
  result.beginpath;
end;

procedure tvpelementpolygonal.read(stream: tstream);
var
  i, j: longint;
begin
  inherited read(stream);
  setlength(fpolygonal, 0);
  if stream.read(j, sizeof(longint)) = sizeof(longint) then
  begin
    setlength(fpolygonal, j);
    for i := 0 to high(fpolygonal) do
    begin
      stream.read(fpolygonal[i], sizeof(tvppoint));
    end;
  end;
end;

procedure tvpelementpolygonal.write(stream: tstream);
var
  i, j: longint;
begin
  inherited write(stream);
  j := system.length(fpolygonal);
  stream.write(j, sizeof(longint));
  for i := 0 to high(fpolygonal) do
  begin
    stream.write(fpolygonal[i], sizeof(tvppoint));
  end;
end;

function tvpelementpolygonal.getfirstpoint: tvppoint;
begin
  result := fpolygonal[low(fpolygonal)];
end;

function tvpelementpolygonal.getlastpoint: tvppoint;
begin
  result := fpolygonal[high(fpolygonal)];
end;

// tvpelementslist

constructor tvpelementlist.create;
begin
  inherited create;
  flist   := tfplist.create;
  fwidth  := 0;
  fheight := 0;
end;

destructor tvpelementlist.destroy;
begin
  clear;
  flist.destroy;
  inherited destroy;
end;

procedure tvpelementlist.clear;
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).destroy;
  end;
  flist.clear;
  fwidth  := 0;
  fheight := 0;
end;

function tvpelementlist.getcount: longint;
begin
  result := flist.count;
end;

function tvpelementlist.getitem(index: longint): tvpelement;
begin
  result := tvpelement(flist[index]);
end;

function tvpelementlist.getmid: tvppoint;
var
     i, j: longint;
     xmin: vpfloat;
     xmax: vpfloat;
     ymin: vpfloat;
     ymax: vpfloat;
     path: tvppolygonal;
    point: tvppoint;
begin
  xmin  := + maxint;
  xmax  := - maxint;
  ymin  := + maxint;
  ymax  := - maxint;
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).interpolate(path, 0.5);

    for j := 0 to high(path) do
    begin
      point := path[j];
       xmin := min(xmin, point.x);
       xmax := max(xmax, point.x);
       ymin := min(ymin, point.y);
       ymax := max(ymax, point.y);
    end;
  end;
  fwidth   := (xmax - xmin);
  fheight  := (ymax - ymin);
  result.x := (xmin + xmax)/2;
  result.y := (ymin + ymax)/2;
end;

procedure tvpelementlist.add(const line: tvpline);
begin
   flist.add(tvpelementline.create(line));
end;

procedure tvpelementlist.add(const circle: tvpcircle);
begin
  flist.add(tvpelementcircle.create(circle));
end;

procedure tvpelementlist.add(const circlearc: tvpcirclearc);
begin
  flist.add(tvpelementcirclearc.create(circlearc));
end;

procedure tvpelementlist.add(const polygonal: tvppolygonal);
begin
  flist.add(tvpelementpolygonal.create(polygonal));
end;

procedure tvpelementlist.add(element: tvpelement);
begin
  flist.add(element);
end;

procedure tvpelementlist.merge(elements: tvpelementlist);
var
  i: longint;
begin
  for i := 0 to elements.count -1 do
  begin
    flist.add(elements.items[i]);
  end;
  elements.flist.clear;
end;

procedure tvpelementlist.insert(index: longint; element: tvpelement);
begin
  flist.insert(index, element);
end;

function tvpelementlist.extract(index: longint): tvpelement;
begin
  result := tvpelement(flist[index]);
  flist.delete(index);
end;

procedure tvpelementlist.delete(index: longint);
begin
  tvpelement(flist[index]).destroy;
  flist.delete(index);
end;

procedure tvpelementlist.move(deltax, deltay: vpfloat);
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).move(deltax, deltay);
  end;
end;

procedure tvpelementlist.rotate(angle: vpfloat);
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).rotate(angle);
  end;
end;

procedure tvpelementlist.scale(value: vpfloat);
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).scale(value);
  end;
end;

procedure tvpelementlist.mirrorx;
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).mirrorx;
  end;
end;

procedure tvpelementlist.mirrory;
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).mirrory;
  end;
end;

procedure tvpelementlist.invert;
var
  i, cnt: longint;
begin
  cnt := flist.count -1;
  for i := 0 to cnt do
  begin
    tvpelement(flist[0]).invert;
    flist.move(0, cnt-i);
  end;
end;

procedure tvpelementlist.invert(index: longint);
begin
  tvpelement(flist[index]).invert;
end;

procedure tvpelementlist.hide(value: boolean);
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).fhidden := value;;
  end;
end;

procedure tvpelementlist.hideselected;
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
    if tvpelement(flist[i]).fselected then
    begin
      tvpelement(flist[i]).fhidden := true;
    end;
end;

procedure tvpelementlist.inverthidden;
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).fhidden := not tvpelement(flist[i]).fhidden;
  end;
end;

procedure tvpelementlist.select(value: boolean);
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).fselected := value;
  end;
end;

procedure tvpelementlist.selectattached;
var
     i, j: longint;
  element: tvpelement;
begin
  for i := 0 to flist.count -1 do
  begin
    element := tvpelement(flist[i]);

    if element.fselected then
    begin
      repeat
        j := getfirst(element.getlastpoint, flist);
        if j <> -1 then
        begin
          element := tvpelement(flist[j]);
          if element.fselected then
            break;
          element.fselected := true;
        end;
      until (j = -1) or (j = i);

      element := tvpelement(flist[i]);
      repeat
        j := getlast(element.getfirstpoint, flist);
        if j <> -1 then
        begin
          element := tvpelement(flist[j]);
          if element.fselected then
            break;
          element.fselected := true;
        end;
      until (j = -1) or (j = i);

    end;
  end;
end;

procedure tvpelementlist.invertselected;
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).fselected := not tvpelement(flist[i]).fselected;
  end;
end;

procedure tvpelementlist.save(const filename: string);
var
        i: longint;
  element: tvpelement;
        s: tmemorystream;
begin
  s := tmemorystream.create;
  s.writeansistring('vpl5.0');
  s.write(flist.count, sizeof(longint));
  for i := 0 to flist.count -1 do
  begin
    element := tvpelement(flist[i]);

    if element is tvpelementline      then s.writeansistring('line')      else
    if element is tvpelementcircle    then s.writeansistring('circle')    else
    if element is tvpelementcirclearc then s.writeansistring('circlearc') else
    if element is tvpelementpolygonal then s.writeansistring('polygonal') else
      raise exception.create('tvpelementlist.save');

    element.write(s);
  end;
  s.savetofile(filename);
  s.destroy;
end;

procedure tvpelementlist.load(const filename: string);
var
     i, j: longint;
  element: tvpelement;
     sign: string;
        s: tmemorystream;
begin
  clear;
  s := tmemorystream.create;
  s.loadfromfile(filename);
  if s.readansistring = 'vpl5.0' then
  begin
    if s.read(j, sizeof(longint))= sizeof(longint) then
      for i := 0 to j -1 do
      begin
        sign := s.readansistring;

        if sign = 'line'      then element := tvpelementline.create      else
        if sign = 'circle'    then element := tvpelementcircle.create    else
        if sign = 'circlearc' then element := tvpelementcirclearc.create else
        if sign = 'polygonal' then element := tvpelementpolygonal.create else
          raise exception.create('tvpelementlist.load');

        element.read(s);
        add(element);
      end;
  end;
  s.destroy;
end;

procedure tvpelementlist.createtoolpath;
begin
  createtoolpath4layer(flist);
end;

procedure tvpelementlist.createtoolpath4layer(list: tfplist);
var
      i: longint;
   elem: tvpelement;
  list1: tfplist;
  list2: tfplist;
begin
  list1 := tfplist.create;
  list2 := tfplist.create;
  // create toolpath
  while list.count > 0 do
  begin
    list1.add(list[0]);
    list.delete(0);

    if isaloop(tvpelement(list1[0])) = false then
    begin

      elem := tvpelement(list1[0]);
      repeat
        i := getfirst(elem.getlastpoint, list);
        if i = -1 then
        begin
          i := getlast(elem.getlastpoint, list);
          if i <> -1 then tvpelement(list[i]).invert;
        end;

        if i <> -1 then
        begin
          elem := tvpelement(list[i]);
          list1.add(elem);
          list.delete(i);
        end;
      until i = -1;

      elem := tvpelement(list1[0]);
      repeat
        i := getlast(elem.getfirstpoint, list);
        if i = -1 then
        begin
          i := getfirst(elem.getfirstpoint, list);
          if i <> -1 then tvpelement(list[i]).invert;
        end;

        if i <> -1 then
        begin
          elem := tvpelement(list[i]);
          list1.insert(0, elem);
          list.delete(i);
        end;
      until i = -1;
    end;

    // move toolpath
    while list1.count > 0 do
    begin
      list2.add(tvpelement(list1[0]));
      list1.delete(0);
    end;
  end;

  while list2.count > 0 do
  begin
    list.add(tvpelement(list2[0]));
    list2.delete(0);
  end;
  list2.destroy;
  list1.destroy;
end;

procedure tvpelementlist.movetoorigin;
var
  p: tvppoint;
begin
  p := getmid;
  move(-p.x, -p.y);
end;

end.




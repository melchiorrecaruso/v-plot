{
  Description: vPlot element classes.

  Copyright (C) 2017-2020 Melchiorre Caruso <melchiorrecaruso@gmail.com>

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
  bgrapath, classes, graphics, sysutils, vpmath;

type
  tvpelement = class(tobject)
  public
    constructor create;
    destructor destroy; override;
    procedure invert; virtual; abstract;
    procedure move(dx, dy: double); virtual; abstract;
    procedure rotate(angle: double); virtual; abstract;
    procedure scale(value: double); virtual; abstract;
    procedure mirrorx; virtual; abstract;
    procedure mirrory; virtual; abstract;
    procedure interpolate(var path: tvppolygonal; value: double); virtual abstract;
    procedure interpolate(var path: tbgrapath); virtual abstract;
    procedure read(stream: tstream); virtual; abstract;
    procedure write(stream: tstream); virtual; abstract;
    function firstpoint: tvppoint; virtual abstract;
    function lastpoint: tvppoint; virtual abstract;
  end;

  tvpelementline = class(tvpelement)
  private
    fline: tvpline;
  public
    constructor create;
    constructor create(const aline: tvpline);
    procedure invert; override;
    procedure move(dx, dy: double); override;
    procedure rotate(angle: double); override;
    procedure scale(value: double); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: double); override;
    procedure interpolate(var path: tbgrapath); override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function firstpoint: tvppoint; override;
    function lastpoint: tvppoint; override;
  end;

  tvpelementcircle = class(tvpelement)
  private
    fcircle: tvpcircle;
  public
    constructor create;
    constructor create(const acircle: tvpcircle);
    procedure invert; override;
    procedure move(dx, dy: double); override;
    procedure rotate(angle: double); override;
    procedure scale(value: double); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: double); override;
    procedure interpolate(var path: tbgrapath); override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function firstpoint: tvppoint; override;
    function lastpoint: tvppoint; override;
  end;

  tvpelementcirclearc = class(tvpelement)
  private
    fcirclearc: tvpcirclearc;
  public
    constructor create;
    constructor create(const acirclearc: tvpcirclearc);
    procedure invert; override;
    procedure move(dx, dy: double); override;
    procedure rotate(angle: double); override;
    procedure scale(value: double); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: double); override;
    procedure interpolate(var path: tbgrapath); override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function firstpoint: tvppoint; override;
    function lastpoint: tvppoint; override;
  end;

  tvpelementpolygonal = class(tvpelement)
  private
    fpolygonal: tvppolygonal;
  public
    constructor create;
    constructor create(const apolygonal: tvppolygonal);
    procedure invert; override;
    procedure move(dx, dy: double); override;
    procedure rotate(angle: double); override;
    procedure scale(value: double); override;
    procedure mirrorx; override;
    procedure mirrory; override;
    procedure interpolate(var path: tvppolygonal; value: double); override;
    procedure interpolate(var path: tbgrapath); override;
    procedure read(stream: tstream); override;
    procedure write(stream: tstream); override;
    function firstpoint: tvppoint; override;
    function lastpoint: tvppoint; override;
  end;

  tvpelementlist = class(tobject)
  private
    flist: tfplist;
    function getitem(index: longint): tvpelement;
    function getcount: longint;
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
    procedure move(dx, dy: double);
    procedure rotate(angle: double);
    procedure scale(value: double);
    procedure mirrorx;
    procedure mirrory;
    procedure invert;
    procedure invert(index: longint);
    //
    procedure load(const filename: string);
    procedure save(const filename: string);
    //
    procedure centertoorigin;
  public
    property count: longint read getcount;
    property items[index: longint]: tvpelement read getitem;
  end;

// toolpath utils

procedure optimizetoolpath(elements: tvpelementlist; startpoint: tvppoint);

implementation

uses
  math;

/// tvpelement

constructor tvpelement.create;
begin
  inherited create;
end;

destructor tvpelement.destroy;
begin
  inherited destroy;
end;

/// tvpelementline

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

procedure tvpelementline.move(dx, dy: double);
begin
  vpmath.move(fline, dx, dy);
end;

procedure tvpelementline.rotate(angle: double);
begin
  vpmath.rotate(fline, angle);
end;

procedure tvpelementline.scale(value: double);
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

procedure tvpelementline.interpolate(var path: tvppolygonal; value: double);
begin
  vpmath.interpolate(fline, path, value);
end;

procedure tvpelementline.interpolate(var path: tbgrapath);
begin
  path.beginpath;
  path.moveto(fline.p0.x, fline.p0.y);
  path.lineto(fline.p1.x, fline.p1.y);
end;

procedure tvpelementline.read(stream: tstream);
begin
  stream.read(fline, sizeof(tvpline));
end;

procedure tvpelementline.write(stream: tstream);
begin
  stream.write(fline, sizeof(tvpline));
end;

function tvpelementline.firstpoint: tvppoint;
begin
  result := fline.p0;
end;

function tvpelementline.lastpoint: tvppoint;
begin
  result := fline.p1;
end;

/// tvpelementcircle

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

procedure tvpelementcircle.move(dx, dy: double);
begin
  vpmath.move(fcircle, dx, dy);
end;

procedure tvpelementcircle.rotate(angle: double);
begin
  vpmath.rotate(fcircle, angle);
end;

procedure tvpelementcircle.scale(value: double);
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

procedure tvpelementcircle.interpolate(var path: tvppolygonal; value: double);
begin
  vpmath.interpolate(fcircle, path, value);
end;

procedure tvpelementcircle.interpolate(var path: tbgrapath);
begin
  path.beginpath;
  path.arc(fcircle.center.x,
           fcircle.center.y,
           fcircle.radius,0, 2*pi);
end;

procedure tvpelementcircle.read(stream: tstream);
begin
  stream.read(fcircle, sizeof(tvpcircle));
end;

procedure tvpelementcircle.write(stream: tstream);
begin
  stream.write(fcircle, sizeof(tvpcircle));
end;

function tvpelementcircle.firstpoint: tvppoint;
begin
  result.x := fcircle.center.x + fcircle.radius;
  result.y := fcircle.center.y;
end;

function tvpelementcircle.lastpoint: tvppoint;
begin
  result := firstpoint;
end;

/// tvpelementcirclearc

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

procedure tvpelementcirclearc.move(dx, dy: double);
begin
  vpmath.move(fcirclearc, dx, dy);
end;

procedure tvpelementcirclearc.rotate(angle: double);
begin
  vpmath.rotate(fcirclearc, angle);
end;

procedure tvpelementcirclearc.scale(value: double);
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

procedure tvpelementcirclearc.interpolate(var path: tvppolygonal; value: double);
begin
  vpmath.interpolate(fcirclearc, path, value);
end;

procedure tvpelementcirclearc.interpolate(var path: tbgrapath);
begin
  path.beginpath;
  path.arc(fcirclearc.center.x,
           fcirclearc.center.y,
           fcirclearc.radius,
  degtorad(fcirclearc.startangle),
  degtorad(fcirclearc.endangle),
           fcirclearc.startangle >
           fcirclearc.endangle);
end;

procedure tvpelementcirclearc.read(stream: tstream);
begin
  stream.read(fcirclearc, sizeof(tvpcirclearc));
end;

procedure tvpelementcirclearc.write(stream: tstream);
begin
  stream.write(fcirclearc, sizeof(tvpcirclearc));
end;

function tvpelementcirclearc.firstpoint: tvppoint;
begin
  result.x := fcirclearc.radius;
  result.y := 0;
  vpmath.rotate(result, degtorad(fcirclearc.startangle));
  vpmath.move  (result, fcirclearc.center.x,
                        fcirclearc.center.y);
end;

function tvpelementcirclearc.lastpoint: tvppoint;
begin
  result.x := fcirclearc.radius;
  result.y := 0;
  vpmath.rotate(result, degtorad(fcirclearc.endangle));
  vpmath.move  (result, fcirclearc.center.x,
                        fcirclearc.center.y);
end;

/// tvpelementpolygonal

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

procedure tvpelementpolygonal.move(dx, dy: double);
begin
  vpmath.move(fpolygonal, dx, dy);
end;

procedure tvpelementpolygonal.rotate(angle: double);
begin
  vpmath.rotate(fpolygonal, angle);
end;

procedure tvpelementpolygonal.scale(value: double);
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

procedure tvpelementpolygonal.interpolate(var path:  tvppolygonal; value: double);
begin
  vpmath.interpolate(fpolygonal, path, value);
end;

procedure tvpelementpolygonal.interpolate(var path: tbgrapath);
begin
  path.beginpath;
  // todo
end;

procedure tvpelementpolygonal.read(stream: tstream);
var
  i, j: longint;
begin
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
  j := system.length(fpolygonal);
  stream.write(j, sizeof(longint));
  for i := 0 to high(fpolygonal) do
  begin
    stream.write(fpolygonal[i], sizeof(tvppoint));
  end;
end;

function tvpelementpolygonal.firstpoint: tvppoint;
begin
  result := fpolygonal[low(fpolygonal)];
end;

function tvpelementpolygonal.lastpoint: tvppoint;
begin
  result := fpolygonal[high(fpolygonal)];
end;

/// tvpelementslist

constructor tvpelementlist.create;
begin
  inherited create;
  flist := tfplist.create;
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
end;

function tvpelementlist.getcount: longint;
begin
  result := flist.count;
end;

function tvpelementlist.getitem(index: longint): tvpelement;
begin
  result := tvpelement(flist[index]);
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

procedure tvpelementlist.move(dx, dy: double);
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).move(dx, dy);
  end;
end;

procedure tvpelementlist.rotate(angle: double);
var
  i: longint;
begin
  for i := 0 to flist.count -1 do
  begin
    tvpelement(flist[i]).rotate(angle);
  end;
end;

procedure tvpelementlist.scale(value: double);
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

procedure tvpelementlist.save(const filename: string);
var
        i: longint;
  element: tvpelement;
        s: tmemorystream;
begin
  s := tmemorystream.create;
  s.writeansistring('vpl6.0');
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
  if s.readansistring = 'vpl6.0' then
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

procedure tvpelementlist.centertoorigin;
var
  i, j: longint;
  xmin, xmax: double;
  ymin, ymax: double;
  path: tvppolygonal = nil;
  point: tvppoint;
begin
  xmin  := + maxint;
  xmax  := - maxint;
  ymin  := + maxint;
  ymax  := - maxint;
  for i := 0 to flist.count -1 do
  begin
    getitem(i).interpolate(path, 0.5);
    for j := 0 to high(path) do
    begin
      point := path[j];
       xmin := min(xmin, point.x);
       xmax := max(xmax, point.x);
       ymin := min(ymin, point.y);
       ymax := max(ymax, point.y);
    end;
    path := nil;
  end;
  move(-(xmin + xmax)/2, -(ymin + ymax)/2);
end;

// toolpath utils

function getcount(const p: tvppoint; list: tvpelementlist): longint;
var
     i: longint;
  elem: tvpelement;
begin
  result := 0;
  for i := 0 to list.count -1 do
  begin
    elem := list.items[i];
    if distance_between_two_points(p, elem.firstpoint) < 0.02 then inc(result);
    if distance_between_two_points(p, elem.lastpoint ) < 0.02 then inc(result);
  end;
end;

function getfirst(const p: tvppoint; list: tvpelementlist): longint;
var
     i: longint;
  elem: tvpelement;
begin
  result := -1;
  for i := 0 to list.count -1 do
  begin
    elem := list.items[i];
    if distance_between_two_points(p, elem.firstpoint) < 0.02 then
    begin
      result := i;
      exit;
    end
  end;
end;

function getlast(const p: tvppoint; list: tvpelementlist): longint;
var
     i: longint;
  elem: tvpelement;
begin
  result := -1;
  for i := 0 to list.count -1 do
  begin
    elem := list.items[i];
    if distance_between_two_points(p, elem.lastpoint) < 0.02 then
    begin
      result := i;
      exit;
    end
  end;
end;

function getnear(const p: tvppoint; list: tvpelementlist): longint;
var
     i: longint;
  len1: double = $FFFFFFF;
  len2: double = $FFFFFFF;
  elem: tvpelement;
begin
  result := -1;
  for i := 0 to list.count -1 do
  begin
    elem := list.items[i];

    len2 := distance_between_two_points(p, elem.firstpoint);
    if len1 > len2 then
    begin
      len1   := len2;
      result := i;
    end;

    len2 := distance_between_two_points(p, elem.lastpoint);
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
    element.firstpoint,
    element.lastpoint) < 0.02;
end;

procedure optimizetoolpath(elements: tvpelementlist; startpoint: tvppoint);
var
      i: longint;
   elem: tvpelement;
   last: tvppoint;
  list1: tfplist;
  list2: tfplist;
begin
  list1 := tfplist.create;
  list2 := tfplist.create;
  last  := startpoint;
  // create toolpath
  while elements.count > 0 do
  begin
    i := getnear(last, elements);
    list1.add(elements.extract(i));

    if isaloop(tvpelement(list1[0])) = false then
    begin

      elem := tvpelement(list1[0]);
      repeat
        i := getfirst(elem.lastpoint, elements);
        if i = -1 then
        begin
          i := getlast(elem.lastpoint, elements);
          if i <> -1 then elements.items[i].invert;
        end;

        if i <> -1 then
        begin
          elem := elements.extract(i);
          list1.add(elem);
        end;
      until i = -1;

      elem := tvpelement(list1[0]);
      repeat
        i := getlast(elem.firstpoint, elements);
        if i = -1 then
        begin
          i := getfirst(elem.firstpoint, elements);
          if i <> -1 then elements.items[i].invert;
        end;

        if i <> -1 then
        begin
          elem := elements.extract(i);
          list1.insert(0, elem);
        end;
      until i = -1;
    end;

    // move toolpath
    while list1.count > 0 do
    begin
      last :=   tvpelement(list1[0]).lastpoint;
      list2.add(tvpelement(list1[0]));
      list1.delete(0);
    end;
  end;

  while list2.count > 0 do
  begin
    elements.add(tvpelement(list2[0]));
    list2.delete(0);
  end;
  list2.destroy;
  list1.destroy;
end;

end.

{
  Description: Sketcher class.

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

unit vpsketcher;

{$mode objfpc}

interface

uses
  bgrabitmap, classes, math, fpimage, sysutils, vpmath, vppaths;

type
  tvpsketcher = class
  private
    fbit: tbgrabitmap;
    fdotsize: vpfloat;
    fpatternh: vpfloat;
    fpatternw: vpfloat;
    fpatternbh: longint;
    fpatternbw: longint;
    function getdarkness(x, y, heigth, width: longint): vpfloat;
  public
    constructor create(bit: tbgrabitmap);
    destructor destroy; override;
    procedure update(elements: tvpelementlist); virtual abstract;
  public
    property dotsize:   vpfloat read fdotsize   write fdotsize;
    property patternh:  vpfloat read fpatternh  write fpatternh;
    property patternw:  vpfloat read fpatternw  write fpatternw;
    property patternbh: longint read fpatternbh write fpatternbh;
    property patternbw: longint read fpatternbw write fpatternbw;
  end;

  tvpsketchersquare = class(tvpsketcher)
  private
    function step1(n, heigth, width: vpfloat): tvpelementlist; virtual;
  public
    procedure update(elements: tvpelementlist); override;
  end;

  tvpsketcherroundedsquare = class(tvpsketchersquare)
  private
    function step1(n, heigth, width: vpfloat): tvpelementlist; override;
    function step2(elements: tvpelementlist; radius: vpfloat): tvpelementlist;
  end;

  tvpsketchertriangular = class(tvpsketcher)
  private
    function step1(n, heigth, width: vpfloat): tvpelementlist; virtual;
  public
    procedure update(elements: tvpelementlist); override;
  end;


implementation

// tvpsketcher

constructor tvpsketcher.create(bit: tbgrabitmap);
begin
  inherited create;
  fbit       := bit;
  fdotsize   := 0.5;
  fpatternh  := 10;
  fpatternw  := 10;
  fpatternbh := 10;
  fpatternbw := 10;
end;

destructor tvpsketcher.destroy;
begin
  inherited destroy;
end;

function tvpsketcher.getdarkness(x, y, heigth, width: longint): vpfloat;
var
  i: longint;
  j: longint;
  c: tfpcolor;
begin
  result := 0;
  for j := 0 to heigth -1 do
    for i := 0 to width -1 do
    begin
      c := fbit.colors[x+i, y+j];
      result := result + c.blue;
      result := result + c.green;
      result := result + c.red;
    end;

  result := 1 - result/(3*$FFFF*(heigth*width));
end;

// tvpsketchersquare

function tvpsketchersquare.step1(n, heigth, width: vpfloat): tvpelementlist;
var
  line: tvpline;
begin
  result := tvpelementlist.create;
  if n > 0 then
  begin
    line.p0.x := 0;
    line.p0.y := 0;
    line.p1.x := width/(n*2);
    line.p1.y := 0;
    result.add(line);

    while line.p1.x < width do
    begin
      if line.p1.x - line.p0.x > 0  then
      begin
        line.p0 := line.p1;
        if line.p1.y = 0 then
          line.p1.y := line.p1.y + heigth
        else
          line.p1.y := 0
      end else
      begin
        line.p0   := line.p1;
        line.p1.x := line.p1.x + width/n;
        if line.p1.x > width then
          line.p1.x := width;
      end;
      result.add(line);
    end;
  end else
  begin
    line.p0.x := 0;
    line.p0.y := 0;
    line.p1.x := width;
    line.p1.y := 0;
    result.add(line);
  end;
end;

procedure tvpsketchersquare.update(elements: tvpelementlist);
var
   i, j, k: longint;
    aw, ah: longint;
      dark: vpfloat;
     list1: tvpelementlist;
     list2: tvpelementlist;
        mx: boolean;
begin
  list1 := tvpelementlist.create;
     aw := (fbit.width  div fpatternbw);
     ah := (fbit.height div fpatternbh);
     mx := false;

  j := 0;
  while j < ah do
  begin
    i := 0;
    while i < aw do
    begin
      dark  := getdarkness(fpatternbw*i, fpatternbh*j, fpatternbw, fpatternbh);
      list2 := step1(round((fpatternw/dotsize)*dark), fpatternh, fpatternw);

      if mx then
      begin
        list2.mirrorx;
        list2.move(0, patternw);
      end;
      mx := list2.items[list2.count -1].getlastpoint.y > 0;

      for k := 0 to list2.count -1 do
      begin
        list2.items[k].move(patternw*i, patternw*j);
      end;
      list1.merge(list2);
      list2.destroy;
      inc(i, 1);
    end;

    if j mod 2 = 1 then
      list1.invert;
    elements.merge(list1);
    inc(j, 1);
  end;
  list1.destroy;
  elements.mirrorx;
  elements.movetoorigin;
end;

// tvpsketcherroundedsquare

function tvpsketcherroundedsquare.step1(n, heigth, width: vpfloat): tvpelementlist;
begin
  if n > 0 then
    result := step2(inherited step1(n, heigth, width), width/(2*n))
  else
    result :=       inherited step1(n, heigth, width)
end;

function tvpsketcherroundedsquare.step2(elements: tvpelementlist; radius: vpfloat): tvpelementlist;
var
   i: longint;
  l0: tvpline;
  l1: tvpline;
  a0: tvpcirclearc;
begin
  result := tvpelementlist.create;

  if elements.count = 1 then
  begin
    result.add(elements.extract(0));
  end else
  begin
    l0.p0 := tvpelementline(elements.items[0]).getfirstpoint;
    l0.p1 := tvpelementline(elements.items[0]).getlastpoint;

    for i := 1 to elements.count -1 do
    begin
      l1.p0 := tvpelementline(elements.items[i]).getfirstpoint;
      l1.p1 := tvpelementline(elements.items[i]).getlastpoint;

      if (l0.p1.y = 0) and
         (l1.p1.y > 0) then // left-bottom corner
      begin
        a0.radius     := radius;
        a0.center.x   := l0.p1.x - radius;
        a0.center.y   := l0.p1.y + radius;
        a0.startangle := 270;
        a0.endangle   := 360;
        l0.p1.x       := a0.center.x;
        l1.p0.y       := a0.center.y;
        result.add(a0);
      end else
      if (l0.p1.y > 0) and
         (l1.p1.y > 0) then // left-top corner
      begin
        a0.radius     := radius;
        a0.center.x   := l0.p1.x + radius;
        a0.center.y   := l0.p1.y - radius;
        a0.startangle := 180;
        a0.endangle   :=  90;
        l1.p0.x       := a0.center.x;
        l0.p1.y       := a0.center.y;
        result.add(l0);
        result.add(a0);
      end else
      if (l0.p1.y > 0) and
         (l1.p1.y = 0) then // right-top corner
      begin
        a0.radius     := radius;
        a0.center.x   := l0.p1.x - radius;
        a0.center.y   := l0.p1.y - radius;
        a0.startangle := 90;
        a0.endangle   :=  0;
        l0.p1.x       := a0.center.x;
        l1.p0.y       := a0.center.y;
        result.add(a0);
      end else
      if (l0.p1.y = 0) and
         (l1.p1.y = 0) then // right-bottom corner
      begin
        a0.radius     := radius;
        a0.center.x   := l0.p1.x + radius;
        a0.center.y   := l0.p1.y + radius;
        a0.startangle := 180;
        a0.endangle   := 270;
        l1.p0.x       := a0.center.x;
        l0.p1.y       := a0.center.y;
        result.add(l0);
        result.add(a0);
      end;

      l0 := l1;
    end;
  end;
  elements.destroy;
end;

// tvpsketchertriangular

function tvpsketchertriangular.step1(n, heigth, width: vpfloat): tvpelementlist;
var
  line: tvpline;
begin
  result := tvpelementlist.create;
  if n > 0 then
  begin
    line.p0.x := 0;
    line.p0.y := 0;
    line.p1.x := width/(n*2);
    line.p1.y := heigth;
    result.add(line);

    while line.p1.x < width do
    begin
      if line.p1.y > line.p0.y then
      begin
        line.p0   := line.p1;
        line.p1.x := min(line.p1.x + width/(n), width);
        line.p1.y := 0;
      end else
      begin
        line.p0   := line.p1;
        line.p1.x := min(line.p1.x + width/(n), width);
        line.p1.y := heigth;
      end;
      result.add(line);
    end;
  end else
  begin
    line.p0.x := 0;
    line.p0.y := 0;
    line.p1.x := width;
    line.p1.y := 0;
    result.add(line);
  end;
end;

procedure tvpsketchertriangular.update(elements: tvpelementlist);
var
  i, j, k: longint;
   aw, ah: longint;
     dark: vpfloat;
    list1: tvpelementlist;
    list2: tvpelementlist;
       mx: boolean;
begin
  list1 := tvpelementlist.create;
     aw := (fbit.width  div fpatternbw);
     ah := (fbit.height div fpatternbw);
     mx := false;

  j := 0;
  while j < ah do
  begin
    i := 0;
    while i < aw do
    begin
      dark  := getdarkness(fpatternbw*i, fpatternbh*j, fpatternbw, fpatternbh);
      list2 := step1(round((fpatternw/dotsize)*dark), fpatternh, fpatternw);

      if mx then
      begin
        list2.mirrorx;
        list2.move(0, patternw);
      end;
      mx := list2.items[list2.count -1].getlastpoint.y > 0;

      for k := 0 to list2.count -1 do
      begin
        list2.items[k].move(patternw*i, patternw*j);
      end;
      list1.merge(list2);
      list2.destroy;
      inc(i, 1);
    end;

    if j mod 2 = 1 then
      list1.invert;
    elements.merge(list1);
    inc(j, 1);
  end;
  list1.destroy;
  elements.mirrorx;
  elements.movetoorigin;
end;


end.


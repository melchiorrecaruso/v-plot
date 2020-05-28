{
  Description: vPlot driver class.

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

unit vpdriver;

{$mode objfpc}

interface

uses
  classes, math, sysutils, vpmath, vpserial, vpsetting, vputils;

const
  vpserver_getxcount = 240;
  vpserver_getycount = 241;
  vpserver_getzcount = 242;
  vpserver_getrampkb = 243;
  vpserver_getrampkm = 244;

  vpserver_setxcount = 230;
  vpserver_setycount = 231;
  vpserver_setzcount = 232;
  vpserver_setrampkb = 233;
  vpserver_setrampkm = 234;

type
  tvpdriver = class(tthread)
  private
    fenabled: boolean;
    fmessage: string;
    frampkb: longint;
    frampkl: longint;
    frampkm: longint;
    fserial: tvpserialstream;
    fsetting: tvpsetting;
    fstream: tmemorystream;
    fxcount: longint;
    fycount: longint;
    fzcount: longint;
    fonerror: tthreadmethod;
    foninit: tthreadmethod;
    fonstart: tthreadmethod;
    fonstop: tthreadmethod;
    fontick: tthreadmethod;
    procedure createramps;
  public
    constructor create(asetting: tvpsetting; aserial: tvpserialstream);
    destructor destroy; override;
    procedure init;
    procedure move(cx, cy: longint);
    procedure movez(cz: longint);
    procedure execute; override;
  published
    property enabled: boolean read fenabled write fenabled;
    property message: string  read fmessage;
    property onerror: tthreadmethod read fonerror write fonerror;
    property oninit:  tthreadmethod read foninit  write foninit;
    property onstart: tthreadmethod read fonstart write fonstart;
    property onstop:  tthreadmethod read fonstop  write fonstop;
    property ontick:  tthreadmethod read fontick  write fontick;
    property xcount:  longint read fxcount;
    property ycount:  longint read fycount;
    property zcount:  longint read fzcount;
  end;

const
  driverloop = 7;

type
  tvpdriverengine = class
  private
    fiteration:      longint;
    fiterationlimit: longint;
    fpoints: array[0..1, 0..driverloop] of tvppoint;
    fsetting: tvpsetting;
    function getangle(const a0, a1: double; index: longint): double;
    procedure calcpointinternal(const lx, ly: double;
      out p: tvppoint; const a0, a1, b0, b1: double);
  public
    constructor create(asetting: tvpsetting);
    destructor destroy; override;
    function  calclength0(const p, t0: tvppoint; r0: double): double;
    function  calclength1(const p, t1: tvppoint; r1: double): double;
    procedure calclengths(const p: tvppoint; out lx, ly: double);
    procedure calcsteps(const p: tvppoint; out cx, cy: longint);
    procedure calcpoint(const lx, ly: double; out p: tvppoint);
  end;


  function serverget(serial: tvpserialstream; id: byte; var value: longint): boolean;
  function serverset(serial: tvpserialstream; id: byte;     value: longint): boolean;

  procedure driverenginedebug(adriverengine: tvpdriverengine);


implementation

// server get/set routines

function serverget(serial: tvpserialstream; id: byte; var value: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    result := (serial.write(id,    sizeof(id   )) = sizeof(id   )) and
              (serial.read (cc,    sizeof(cc   )) = sizeof(cc   )) and
              (serial.read (cc,    sizeof(cc   )) = sizeof(cc   )) and
              (serial.read (value, sizeof(value)) = sizeof(value));

    result := result and (cc = id);
  end;
end;

function serverset(serial: tvpserialstream; id: byte; value: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    result := (serial.write(id,    sizeof(id   )) = sizeof(id   )) and
              (serial.read (cc,    sizeof(cc   )) = sizeof(cc   )) and
              (serial.write(value, sizeof(value)) = sizeof(value)) and
              (serial.read (cc,    sizeof(cc   )) = sizeof(cc   ));

    result := result and (cc = id);
  end;
end;

// tvpdriverengine

constructor tvpdriverengine.create(asetting: tvpsetting);
begin
  inherited create;
  fiterationlimit := 50;
  fsetting := asetting;
end;

destructor tvpdriverengine.destroy;
begin
  inherited destroy;
end;

function tvpdriverengine.calclength0(const p, t0: tvppoint; r0: double): double;
var
      a0: double;
  c0, cx: tvpcircleimp;
  s0, sx: tvppoint;
begin
  //find tangent point t0
  result := sqrt(sqr(distance_between_two_points(t0, p))-sqr(r0));
  c0 := circle_by_center_and_radius(t0, r0);
  cx := circle_by_center_and_radius(p, result);
  if intersection_of_two_circles(c0, cx, s0, sx) = 0 then
    raise exception.create('intersection_of_two_circles [c0c2]');
  a0 := angle(line_by_two_points(s0, t0));
  result := result + a0*r0;
end;

function tvpdriverengine.calclength1(const p, t1: tvppoint; r1: double): double;
var
      a1: double;
  c1, cx: tvpcircleimp;
  s1, sx: tvppoint;
begin
  //find tangent point t1
  result := sqrt(sqr(distance_between_two_points(t1, p))-sqr(r1));
  c1 := circle_by_center_and_radius(t1, r1);
  cx := circle_by_center_and_radius(p, result);
  if intersection_of_two_circles(c1, cx, s1, sx) = 0 then
    raise exception.create('intersection_of_two_circles [c1c2]');
  a1 := pi-angle(line_by_two_points(s1, t1));
  result := result + a1*r1;
end;

procedure tvpdriverengine.calclengths(const p: tvppoint; out lx, ly: double);
var
      a0, a1: double;
  c0, c1, cx: tvpcircleimp;
  s0, s1, sx: tvppoint;
      t0, t1: tvppoint;
begin
  //find tangent point t0
  t0 := fsetting.point0;
  lx := sqrt(sqr(distance_between_two_points(t0, p))-sqr(fsetting.pulley0radius));
  c0 := circle_by_center_and_radius(t0, fsetting.pulley0radius);
  cx := circle_by_center_and_radius(p, lx);
  if intersection_of_two_circles(c0, cx, s0, sx) = 0 then
    raise exception.create('intersection_of_two_circles [c0c2]');
  a0 := angle(line_by_two_points(s0, t0));
  lx := lx + a0*fsetting.pulley0radius;
  //find tangent point t1
  t1 := fsetting.point1;
  ly := sqrt(sqr(distance_between_two_points(t1, p))-sqr(fsetting.pulley1radius));
  c1 := circle_by_center_and_radius(t1, fsetting.pulley1radius);
  cx := circle_by_center_and_radius(p, ly);
  if intersection_of_two_circles(c1, cx, s1, sx) = 0 then
    raise exception.create('intersection_of_two_circles [c1c2]');
  a1 := pi-angle(line_by_two_points(s1, t1));
  ly := ly + a1*fsetting.pulley1radius;
end;

procedure tvpdriverengine.calcsteps(const p: tvppoint; out cx, cy: longint);
var
  lx: double;
  ly: double;
begin
  calclengths(p, lx, ly);
  // calculate steps
  cx := round(lx/fsetting.pulley0ratio);
  cy := round(ly/fsetting.pulley1ratio);
end;

function tvpdriverengine.getangle(const a0, a1: double; index: longint): double;
begin
  result := a0+((a1-a0)/driverloop)*index;
end;

procedure tvpdriverengine.calcpointinternal(const lx, ly: double;
  out p: tvppoint; const a0, a1, b0, b1: double);
var
  e1, e2: double;
     ang: double;
  i1, j1: longint;
  i2, j2: longint;
       t: tvppoint;
       a: array[0..1] of double;
       b: array[0..1] of double;
begin
  inc(fiteration);
  for i1 := 0 to driverloop do
  begin
    ang := getangle(a0, a1, i1);
    t.x := -fsetting.pulley0radius;
    t.y := -lx + (ang * fsetting.pulley0radius);
    rotate(t, ang);
    move(t, fsetting.point0.x,
            fsetting.point0.y);
    fpoints[0, i1] := t;

    ang := getangle(b0, b1, i1);
    t.x := +fsetting.pulley1radius;
    t.y := -ly + (ang * fsetting.pulley1radius);
    rotate(t, -ang);
    move(t, fsetting.point1.x,
            fsetting.point1.y);
    fpoints[1, i1] := t;
  end;

  i2 := 0;
  j2 := 0;
  e1 := $FFFFFFF;
  for i1 := 0 to driverloop do
  begin
    for j1 := 0 to driverloop do
    begin
      e2 := distance_between_two_points(fpoints[0, i1], fpoints[1, j1]);
      if e1 > e2 then
      begin
        e1 := e2;
        i2 := i1;
        j2 := j1;
      end;
    end;
  end;

  p.x := (fpoints[0, i2].x + fpoints[1, j2].x) / 2;
  p.y := (fpoints[0, i2].y + fpoints[1, j2].y) / 2;

  if e1 > 0.01 then
    if fiteration < fiterationlimit then
    begin
      a[0] := getangle(a0, a1, max(0, i2-1));
      b[0] := getangle(b0, b1, max(0, j2-1));
      a[1] := getangle(a0, a1, min(i2+1, driverloop));
      b[1] := getangle(b0, b1, min(j2+1, driverloop));
      calcpointinternal(lx, ly, p, a[0], a[1], b[0], b[1]);
    end;
end;

procedure tvpdriverengine.calcpoint(const lx, ly: double; out p: tvppoint);
var
  a0, a1: double;
  b0, b1: double;
begin
  fiteration   := 0;
  a0 := 0;  a1 := pi/2;
  b0 := 0;  b1 := pi/2;
  calcpointinternal(lx, ly, p, a0, a1, b0, b1);
end;

procedure driverenginedebug(adriverengine: tvpdriverengine);
var
    i,  j: longint;
   lx, ly: double;
  offsetx: double;
  offsety: double;
     page: array[0..2, 0..2] of tvppoint;
       pp: tvppoint;
begin
  page[0, 0].x := -adriverengine.fsetting.pagewidth  / 2;
  page[0, 0].y := +adriverengine.fsetting.pageheight / 2;
  page[0, 1].x := +0;
  page[0, 1].y := +adriverengine.fsetting.pageheight / 2;
  page[0, 2].x := +adriverengine.fsetting.pagewidth  / 2;
  page[0, 2].y := +adriverengine.fsetting.pageheight / 2;

  page[1, 0].x := -adriverengine.fsetting.pagewidth  / 2;
  page[1, 0].y := +0;
  page[1, 1].y := +0;
  page[1, 1].y := +0;
  page[1, 2].x := +0;
  page[1, 2].x := +adriverengine.fsetting.pagewidth  / 2;

  page[2, 0].x := -adriverengine.fsetting.pagewidth  / 2;
  page[2, 0].y := -adriverengine.fsetting.pageheight / 2;
  page[2, 1].x := +0;
  page[2, 1].y := -adriverengine.fsetting.pageheight / 2;
  page[2, 2].x := +adriverengine.fsetting.pagewidth  / 2;
  page[2, 2].y := -adriverengine.fsetting.pageheight / 2;

  with adriverengine.fsetting do
  begin
    offsetx := point8.x;
    offsety := point8.y + (pageheight)*point9factor + point9offset;
  end;

  for i := 0 to 2 do
    for j := 0 to 2 do
    begin
      pp   := page[i, j];
      pp.x := pp.x + offsetx;
      pp.y := pp.y + offsety;
      adriverengine.calclengths(pp, lx, ly);

      writeln(format('  CALC::PNT.X       = %12.5f  PNT.Y  = %12.5f  |  ' +
                     'LX = %12.5f  LY = %12.5f', [pp.x, pp.y, lx, ly]));
    end;
end;

// tvpdriver

constructor tvpdriver.create(asetting: tvpsetting; aserial: tvpserialstream);
begin
  fenabled := true;
  fmessage := '';
  fsetting := asetting;
  frampkb  := fsetting.rampkb;
  frampkl  := fsetting.rampkl;
  frampkm  := fsetting.rampkm;
  fserial  := aserial;
  fsetting := asetting;
  fstream  := tmemorystream.create;
  fxcount  := 0;
  fycount  := 0;
  fzcount  := 0;

  fonerror := nil;
  foninit  := nil;
  fonstart := nil;
  fonstop  := nil;
  fontick  := nil;
  freeonterminate := true;
  inherited create(true);
end;

destructor tvpdriver.destroy;
begin
  fserial  := nil;
  fsetting := nil;
  fstream.clear;
  fstream.destroy;
  inherited destroy;
end;

procedure tvpdriver.init;
begin
  fstream.clear;
  fserial.clear;
  if (not serverget(fserial, vpserver_getxcount, fxcount)) or
     (not serverget(fserial, vpserver_getycount, fycount)) or
     (not serverget(fserial, vpserver_getzcount, fzcount)) or
     (not serverset(fserial, vpserver_setrampkb, frampkb)) or
     (not serverset(fserial, vpserver_setrampkm, frampkm))then
  begin
    fmessage := 'Unable connecting to server !';
    if assigned(fonerror) then
      synchronize(fonerror);
  end;
end;

procedure tvpdriver.move(cx, cy: longint);
var
  b0: byte;
  b1: byte;
  dx: longint;
  dy: longint;
begin
  b0 := %00000000;
  dx := (cx - fxcount);
  dy := (cy - fycount);
  if (dx < 0) then setbit1(b0, 1);
  if (dy < 0) then setbit1(b0, 3);

  dx := abs(dx);
  dy := abs(dy);
  while (dx > 0) or (dy > 0) do
  begin
    b1 := b0;
    if dx > 0 then
    begin
      setbit1(b1, 0);
      dec(dx);
    end;

    if dy > 0 then
    begin
      setbit1(b1, 2);
      dec(dy);
    end;
    fstream.write(b1, sizeof(b1));
  end;
  fxcount := cx;
  fycount := cy;
end;

procedure tvpdriver.movez(cz : longint);
var
   b0: byte;
   b1: byte;
   dz: longint;
begin
  b0 := %00000000;
  dz := (cz - fzcount);
  if (dz < 0) then setbit1(b0, 5);

  dz := abs(dz);
  while (dz > 0) do
  begin
    b1 := b0;
    if dz > 0 then
    begin
      setbit1(b1, 4);
      dec(dz);
    end;
    fstream.write(b1, sizeof(b1));
  end;
  fzcount := cz;
end;

procedure tvpdriver.createramps;
const
  ds    = 2;
  maxdx = 4;
  maxdy = 4;
var
  bufsize: longint;
  buf: array of byte;
  dx:  array of longint;
  dy:  array of longint;
  i, j, k, r: longint;
begin
  bufsize := fstream.size;
  if bufsize > 0 then
  begin
    setlength(dx,  bufsize);
    setlength(dy,  bufsize);
    setlength(buf, bufsize);
    fstream.seek(0, sofrombeginning);
    fstream.read(buf[0], bufsize);

    // store data in dx and dy arrays
    for i := 0 to bufsize -1 do
    begin
      dx[i] := 0;
      dy[i] := 0;
      for j := max(i-ds, 0) to min(i+ds, bufsize-1) do
      begin
        if getbit1(buf[j], 0) then
        begin
          if getbit1(buf[j], 1) then
            dec(dx[i])
          else
            inc(dx[i]);
        end;

        if getbit1(buf[j], 2) then
        begin
          if getbit1(buf[j], 3) then
            dec(dy[i])
          else
            inc(dy[i]);
        end;
      end;
    end;

    i := 0;
    j := i + 1;
    while (j < bufsize) do
    begin
      k := i;
      while (abs(dx[j] - dx[k]) <= maxdx) and
            (abs(dy[j] - dy[k]) <= maxdy) do
      begin
        if j = bufsize -1 then break;
        inc(j);

        if (j - k) > (2*frampkl) then
        begin
          k := j - frampkl;
        end;
      end;

      if j - i > 10 then
      begin
        r := min((j-i) div 2, frampkl);
        for k := (i) to (i+r-1) do
          setbit1(buf[k], 6);

        for k := (j-r+1) to (j) do
          setbit1(buf[k], 7);
      end;
      i := j + 1;
      j := i + 1;
    end;
    fstream.seek(0, sofrombeginning);
    fstream.write(buf[0], bufsize);
    setlength(dx,  0);
    setlength(dy,  0);
    setlength(buf, 0);
  end;
end;

procedure tvpdriver.execute;
var
  buf: array[0..59]of byte;
  bufsize: byte;
  i: longint;
begin
  fserial.clear;
  if assigned(onstart) then
    synchronize(fonstart);
  createramps;

  fstream.seek(0, sofrombeginning);
  bufsize := fstream.read(buf, system.length(buf));
  while (bufsize > 0) and (not terminated) do
  begin
    fserial.write(buf, bufsize);
    if assigned(fontick) then
      synchronize(ontick);
    while (not terminated) do
    begin
      bufsize := 0;
      fserial.read(bufsize, sizeof(bufsize));
      if bufsize > 0 then
      begin
        break;
      end;
    end;
    bufsize := fstream.read(buf, bufsize);
    while (not fenabled) do sleep(200);
  end;

  bufsize := 255;
  fserial.write(bufsize, sizeof(bufsize));
  while true do
  begin
    bufsize := 0;
    fserial.read(bufsize, sizeof(bufsize));
    if bufsize = 255 then
    begin
      break;
    end;
  end;

  if ((not serverget(fserial, vpserver_getxcount ,i)) or (fxcount <> i)) or
     ((not serverget(fserial, vpserver_getycount ,i)) or (fycount <> i)) or
     ((not serverget(fserial, vpserver_getzcount ,i)) or (fzcount <> i)) or
     ((not serverget(fserial, vpserver_getrampkb ,i)) or (frampkb <> i)) or
     ((not serverget(fserial, vpserver_getrampkm ,i)) or (frampkm <> i)) then
  begin
    fmessage := 'Server syncing error !';
    if assigned(fonerror) then
      synchronize(fonerror);
  end;
  if assigned(foninit) then
    synchronize(foninit);
  if assigned(fonstop) then
    synchronize(fonstop);
end;

end.


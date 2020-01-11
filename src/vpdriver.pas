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
  classes, dialogs, math, sysutils, vpmath, vpserial, vpsetting, vputils;

type
  tvpdriver = class(tthread)
  private
    fenabled: boolean;
    ferror:  longint;
    fserial: tvpserialstream;
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
    constructor create(aserial: tvpserialstream);
    destructor destroy; override;
    procedure init;
    procedure move(cx, cy: longint);
    procedure movez(cz: longint);
    procedure execute; override;
  published
    property enabled: boolean       read fenabled write fenabled;
    property onerror: tthreadmethod read fonerror write fonerror;
    property oninit:  tthreadmethod read foninit  write foninit;
    property onstart: tthreadmethod read fonstart write fonstart;
    property onstop:  tthreadmethod read fonstop  write fonstop;
    property ontick:  tthreadmethod read fontick  write fontick;
    property error:   longint       read ferror;
    property xcount:  longint       read fxcount;
    property ycount:  longint       read fycount;
    property zcount:  longint       read fzcount;
  end;

  function servergetxcount(serial: tvpserialstream; var cx: longint): boolean;
  function servergetycount(serial: tvpserialstream; var cy: longint): boolean;
  function servergetzcount(serial: tvpserialstream; var cz: longint): boolean;
  function serversetxcount(serial: tvpserialstream;     cx: longint): boolean;
  function serversetycount(serial: tvpserialstream;     cy: longint): boolean;
  function serversetzcount(serial: tvpserialstream;     cz: longint): boolean;

  procedure calculatexy(const p: tvppoint; out lx, ly: vpfloat); overload;
  procedure calculatexy(const p: tvppoint; out cx, cy: longint); overload;
  function  calculatex (const p, t0: tvppoint; r0: vpfloat): vpfloat;
  function  calculatey (const p, t1: tvppoint; r1: vpfloat): vpfloat;

var
  driver: tvpdriver = nil;

implementation

const
  vpserver_getxcount = 240;
  vpserver_getycount = 241;
  vpserver_getzcount = 242;
  vpserver_setxcount = 230;
  vpserver_setycount = 231;
  vpserver_setzcount = 232;

// server direct routines

function servergetxcount(serial: tvpserialstream; var cx: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    cc := vpserver_getxcount;
    result := (serial.write(cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cx, sizeof(cx)) = sizeof(cx));

    result := result and (cc = vpserver_getxcount);
  end;
end;

function servergetycount(serial: tvpserialstream; var cy: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    cc := vpserver_getycount;
    result := (serial.write(cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cy, sizeof(cy)) = sizeof(cy));

    result := result and (cc = vpserver_getycount);
  end;
end;

function servergetzcount(serial: tvpserialstream; var cz: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    cc := vpserver_getzcount;
    result := (serial.write(cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cz, sizeof(cz)) = sizeof(cz));

    result := result and (cc = vpserver_getzcount);
  end;
end;

function serversetxcount(serial: tvpserialstream; cx: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    cc := vpserver_setxcount;
    result := (serial.write(cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.write(cx, sizeof(cx)) = sizeof(cx)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc));

    result := result and (cc = vpserver_setxcount);
  end;
end;

function serversetycount(serial: tvpserialstream; cy: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    cc := vpserver_setycount;
    result := (serial.write(cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.write(cy, sizeof(cy)) = sizeof(cy)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc));

    result := result and (cc = vpserver_setycount);
  end;
end;

function serversetzcount(serial: tvpserialstream; cz: longint): boolean;
var
  cc: byte;
begin
  result := serial.connected;
  if result then
  begin
    serial.clear;
    cc := vpserver_setzcount;
    result := (serial.write(cc, sizeof(cc)) = sizeof(cc)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc)) and
              (serial.write(cz, sizeof(cz)) = sizeof(cz)) and
              (serial.read (cc, sizeof(cc)) = sizeof(cc));

    result := result and (cc = vpserver_setzcount);
  end;
end;

//

function calculatex(const p, t0: tvppoint; r0: vpfloat): vpfloat;
var
      a0: vpfloat;
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

function calculatey(const p, t1: tvppoint; r1: vpfloat): vpfloat;
var
      a1: vpfloat;
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

procedure calculatexy(const p: tvppoint; out lx, ly: vpfloat);
var
      a0, a1: vpfloat;
  c0, c1, cx: tvpcircleimp;
  s0, s1, sx: tvppoint;
      t0, t1: tvppoint;
begin
  //find tangent point t0
  t0 := setting.layout0;
  lx := sqrt(sqr(distance_between_two_points(t0, p))-sqr(setting.mxradius));
  c0 := circle_by_center_and_radius(t0, setting.mxradius);
  cx := circle_by_center_and_radius(p, lx);
  if intersection_of_two_circles(c0, cx, s0, sx) = 0 then
    raise exception.create('intersection_of_two_circles [c0c2]');
  a0 := angle(line_by_two_points(s0, t0));
  lx := lx + a0*setting.mxradius;
  //find tangent point t1
  t1 := setting.layout1;
  ly := sqrt(sqr(distance_between_two_points(t1, p))-sqr(setting.myradius));
  c1 := circle_by_center_and_radius(t1, setting.myradius);
  cx := circle_by_center_and_radius(p, ly);
  if intersection_of_two_circles(c1, cx, s1, sx) = 0 then
    raise exception.create('intersection_of_two_circles [c1c2]');
  a1 := pi-angle(line_by_two_points(s1, t1));
  ly := ly + a1*setting.myradius;
end;

procedure calculatexy(const p: tvppoint; out cx, cy: longint);
var
  lx, ly: vpfloat;
begin
  calculatexy(p, lx, ly);
  // calculate steps
  cx := round(lx/setting.mxratio);
  cy := round(ly/setting.myratio);
end;

// tvpdriver

constructor tvpdriver.create(aserial: tvpserialstream);
begin
  fenabled := true;
  ferror  := 0;
  fserial := aserial;
  fstream := tmemorystream.create;
  fxcount := 0;
  fycount := 0;
  fzcount := 0;

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
  fserial := nil;
  fstream.clear;
  fstream.destroy;
  inherited destroy;
end;

procedure tvpdriver.init;
begin
  fstream.clear;
  fserial.clear;
  if (not servergetxcount(fserial, fxcount)) or
     (not servergetycount(fserial, fycount)) or
     (not servergetzcount(fserial, fzcount)) then
  begin
    ferror := 1;
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
  ramp_ds  = 2;
  ramp_dx  = 2;
  ramp_dy  = 2;
  ramp_len = 200;
var
  b: array of byte;
  x: array of longint;
  y: array of longint;

  bs: longint;
  i: longint;
  j: longint;
  k: longint;
  r: longint;
begin
  bs := fstream.size;
  if bs > 0 then
  begin
    setlength(b, bs);
    setlength(x, bs);
    setlength(y, bs);
    fstream.seek(0, sofrombeginning);
    fstream.read(b[0], bs);

    for i := 0 to bs -1 do
    begin
      x[i] := 0;
      y[i] := 0;
      for j := max(i-ramp_ds,    0) to
               min(i+ramp_ds, bs-1) do
      begin
        if getbit1(b[j], 0) then
        begin
          if getbit1(b[j], 1) then
            dec(x[i])
          else
            inc(x[i]);
        end;

        if getbit1(b[j], 2) then
        begin
          if getbit1(b[j], 3) then
            dec(y[i])
          else
            inc(y[i]);
        end;
      end;
    end;

    i := 0;
    j := i + 1;
    while (j < bs) do
    begin
      while (abs(x[j]-x[i])<=ramp_dx) and
            (abs(y[j]-y[i])<=ramp_dy) do
      begin
        if j = bs -1 then break;
        inc(j);
      end;

      if j - i > 10 then
      begin
        r := min((j-i) div 2, ramp_len);
        for k := (i  ) to (i+r-1) do setbit1(b[k], 6);
        for k := (j-r+1) to (  j) do setbit1(b[k], 7);
      end;
      i := j + 1;
      j := i + 1;
    end;
    fstream.seek(0, sofrombeginning);
    fstream.write(b[0], bs);
  end;
  b := nil;
  x := nil;
  y := nil;
end;

procedure tvpdriver.execute;
var
  b:  array [0..59]of byte;
  bs: byte;
  i:  longint;
begin
  fserial.clear;
  if assigned(onstart) then
    synchronize(fonstart);
  createramps;

  fstream.seek(0, sofrombeginning);
  bs := fstream.read(b, system.length(b));
  while (bs > 0) and (not terminated) do
  begin
    fserial.write(b, bs);
    while (not terminated) do
    begin
      bs := 0;
      fserial.read(bs, sizeof(bs));
      if bs > 0 then
      begin
        break;
      end;
    end;
    bs := fstream.read(b, bs);
    while (not fenabled) do sleep(200);
  end;

  bs := 255;
  fserial.write(bs, sizeof(bs));
  while true do
  begin
    bs := 0;
    fserial.read(bs, sizeof(bs));
    if bs = 255 then
    begin
      break;
    end;
  end;

  if (not servergetxcount(fserial, i)) or (fxcount <> i) then
  begin
    ferror := 2;
    if assigned(fonerror) then
      synchronize(fonerror);
  end;

  if (not servergetycount(fserial, i)) or (fycount <> i) then
  begin
    ferror := 3;
    if assigned(fonerror) then
      synchronize(fonerror);
  end;

  if (not servergetzcount(fserial, i)) or (fzcount <> i) then
  begin
    ferror := 4;
    if assigned(fonerror) then
      synchronize(fonerror);
  end;

  if assigned(foninit) then
    synchronize(foninit);
  if assigned(fonstop) then
    synchronize(fonstop);
end;
end.


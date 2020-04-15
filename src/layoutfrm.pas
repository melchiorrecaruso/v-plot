{
  Description: vPlot layout design form.

  Copyright (C) 2019-2020 Melchiorre Caruso <melchiorrecaruso@gmail.com>

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

unit layoutfrm;

{$mode objfpc}

interface

uses                     
  buttons, classes, sysutils, forms, controls, graphics, dialogs, extctrls,
  bcradialprogressbar, intfgraphics, math, spin, stdctrls, extdlgs, vpmath;

type
  { tlayoutform }

  tlayoutform = class(tform)
    savebtn: tbitbtn;
    savedialog: tsavepicturedialog;
    sheetmodelb: tlabel;
    sheetsizecb: tcombobox;
    sheetsize: tlabel;
    resetbtn: tbitbtn;
    image: timage;
    notebook: tnotebook;
    progressbar: tbcradialprogressbar;
    progresspage: tpage;
    previewpage: tpage;
    bevel: tbevel;
    drawbtn:    tbitbtn;
    distancelb: tlabel;
    distancese: tspinedit;
    sheetoffsetlb: tlabel;
    minloadse: tfloatspinedit;
    maxloadse: tfloatspinedit;
    minloadlb: tlabel;
    macloadlb: tlabel;
    minresolutionse: tfloatspinedit;
    minresolutiolb: tlabel;
    sheetoffsetse: tspinedit;
    sheetmodecb: tcombobox;
    procedure formcreate(sender: tobject);
    procedure maxloadsechange(sender: tobject);
    procedure minloadsechange(sender: tobject);
    procedure resetbtnclick(sender: tobject);
    procedure drawbtnclick(sender: tobject);
    procedure savebtnclick(sender: tobject);
  private
     m0: tvppoint;
     m1: tvppoint;
  public
    procedure lock(value: boolean);
  end;

var
  layoutform: tlayoutform;

implementation

{$R *.lfm}

const
  gap0  = 0;
  gap1  = 1;
  gap2  = 2;
  gap3  = 3;
  gap6  = 6;
  gap8  = 8;
  gap15 = 15;

var
  bit: tbitmap;

{ tlayoutform }

function calc_pp(const a, b, c: vpfloat): tvppoint;
var
  alpha: vpfloat;
begin
     alpha := arccos((sqr(a)+sqr(c)-sqr(b))/(2*a*c));
  result.x := +a*cos(alpha);
  result.y := -a*sin(alpha);
end;

procedure calc_load(const m0, m1, p: tvppoint; out l0, l1: vpfloat);
var
  a0, a1: vpfloat;
       d: vpfloat;
begin
  a0 :=    angle(line_by_two_points(p, m0));
  a1 := pi-angle(line_by_two_points(p, m1));
  // calculate loads
   d := (cos(a0)*sin(a1)+sin(a0)*cos(a1));
  l0 := cos(a1)/d;
  l1 := cos(a0)/d;
end;

procedure draw_sheet(top, w, h: longint; const s: string; b: tbitmap);
var
  rect: trect;
begin
  rect.left   := (b.width - w) div 2;
  rect.right  := (b.width + w) div 2;
  rect.top    := top;
  rect.bottom := rect.top + h;

  b.canvas.pen.color   := clblack;
  b.canvas.brush.color := clblack;
  b.canvas.rectangle(rect);

  rect.left   := rect.left   + 1;
  rect.right  := rect.right  - 1;
  rect.top    := rect.top    + 1;
  rect.bottom := rect.bottom - 1;

  b.canvas.pen.color   := clblack;
  b.canvas.brush.color := rgbtocolor(207, 216, 220);
  b.canvas.rectangle(rect);

  b.canvas.brush.color := rgbtocolor(207, 216, 220);;
  b.canvas.textout(rect.left +gap15, rect.bottom -b.canvas.textheight(s)-2, s);
end;

procedure tlayoutform.formcreate(sender: tobject);
begin
  resetbtnclick(sender);
  lock(true);
end;

procedure tlayoutform.maxloadsechange(sender: tobject);
begin
  if maxloadse.value <= minloadse.value then
    maxloadse.value := minloadse.value + 0.05;
end;

procedure tlayoutform.minloadsechange(sender: tobject);
begin
  if minloadse.value >= maxloadse.value then
    minloadse.value := maxloadse.value - 0.05;
end;

procedure tlayoutform.savebtnclick(sender: tobject);
var
  limage: tlazintfimage;
begin
  if savedialog.execute then
  begin
    limage := tlazintfimage.create(image.width, image.height);
    limage.loadfrombitmap(image.picture.bitmap.handle, 0);
    limage.savetofile(savedialog.filename);
    limage.destroy;
  end;
end;

procedure tlayoutform.resetbtnclick(sender: tobject);
begin
  distancese     .value := 3000;
  minloadse      .value :=  0.5;
  maxloadse      .value :=  1.5;
  minresolutionse.value :=  1.4;
  sheetoffsetse  .value := 0;
  sheetsizecb.itemindex := 0;
  sheetmodecb.itemindex := 1;
end;

procedure tlayoutform.lock(value: boolean);
begin
  distancese     .enabled := value;
  minloadse      .enabled := value;
  maxloadse      .enabled := value;
  minresolutionse.enabled := value;
  sheetoffsetse  .enabled := value;
  sheetsizecb    .enabled := value;
  sheetmodecb    .enabled := value;

  drawbtn .enabled := value;
  resetbtn.enabled := value;
  savebtn .enabled := value;

  if value then
    notebook.pageindex := 1
  else
    notebook.pageindex := 0;
  application.processmessages;
end;

procedure tlayoutform.drawbtnclick(sender: tobject);
var
  clr : tcolor;
  clrs: array[0..9] of tcolor;
  a,b,c, d0, d1, ld0, ld1: vpfloat;
  x,  y, dx, dy, sx, sy, sz: longint;
  p, pp: tvppoint;
  s: string;
begin
  image.picture.clear;
  lock(false);
  // init colors array, blu scale
  clrs[0] := rgbtocolor( 66, 165, 245);
  clrs[1] := rgbtocolor( 66, 165, 245);
  clrs[2] := rgbtocolor( 66, 165, 245);
  clrs[3] := rgbtocolor( 66, 165, 245);
  clrs[4] := rgbtocolor( 66, 165, 245);
  clrs[5] := rgbtocolor(239,  83,  80);
  clrs[6] := rgbtocolor(239,  83,  80);
  clrs[7] := rgbtocolor(239,  83,  80);
  clrs[8] := rgbtocolor(239,  83,  80);
  clrs[9] := rgbtocolor(239,  83,  80);
  // init motors position
  dx   :=       distancese.value;
  dy   := round(distancese.value*0.75);
  m0.x := 0;
  m0.y := dy;
  m1.x := dx+m0.x;
  m1.y := dy;
  // update bitmap
  bit := image.picture.bitmap;
  bit.beginupdate(true);
  bit.setsize(dx, dy);
  bit.canvas.font.bold   := true;
  bit.canvas.font.size   := 40;
  bit.canvas.pen.color   := clwhite;
  bit.canvas.brush.color := clwhite;
  bit.canvas.rectangle(0, 0, dx, dy);

  for x := round(m0.x+1) to (dx -1) do
  begin
    progressbar.value := round(100*x/(dx-1));
    application.processmessages;

    for y := (bit.canvas.textheight('X=')+gap6) to dy -(bit.canvas.textheight('X=')+gap6) do
    begin
      p.x := x;
      p.y := y;
      calc_load(m0, m1, p, ld0, ld1);
      if p.x < (dx div 2) then
      begin
        ld0 := ld1;
      end;
      clr := clwhite;

      if                                  (ld0 <  minloadse.value-0.4) then clr := clrs[0] else
      if (ld0 >= minloadse.value-0.4) and (ld0 <  minloadse.value-0.3) then clr := clrs[1] else
      if (ld0 >= minloadse.value-0.3) and (ld0 <  minloadse.value-0.2) then clr := clrs[2] else
      if (ld0 >= minloadse.value-0.2) and (ld0 <  minloadse.value-0.1) then clr := clrs[3] else
      if (ld0 >= minloadse.value-0.1) and (ld0 <  minloadse.value    ) then clr := clrs[4] else
      if (ld0 >  maxloadse.value    ) and (ld0 <= maxloadse.value+0.1) then clr := clrs[5] else
      if (ld0 >  maxloadse.value+0.1) and (ld0 <= maxloadse.value+0.2) then clr := clrs[6] else
      if (ld0 >  maxloadse.value+0.2) and (ld0 <= maxloadse.value+0.3) then clr := clrs[7] else
      if (ld0 >  maxloadse.value+0.3) and (ld0 <= maxloadse.value+0.4) then clr := clrs[8] else
      if (ld0 >  maxloadse.value+0.4)                                  then clr := clrs[9];

      if clr = clwhite then
      begin
        a := distance_between_two_points(m0,  p);
        b := distance_between_two_points(m1,  p);
        c := distance_between_two_points(m0, m1);

        pp   := calc_pp(a+1,b,c);
        pp.x := pp.x + m0.x;
        pp.y := pp.y + m0.y;
        d0   := distance_between_two_points(p, pp);

        pp   := calc_pp(a,b+1,c);
        pp.x := pp.x + m0.x;
        pp.y := pp.y + m0.y;
        d1   := distance_between_two_points(p, pp);

        if d0 > minresolutionse.value then clr := rgbtocolor(255, 238,  88) else
        if d1 > minresolutionse.value then clr := rgbtocolor(255, 238,  88);
      end;
      bit.canvas.pixels[x, dy -y] := clr;
    end;
  end;

  x := bit.width div 2;
  y := bit.canvas.textheight('X=')*2;
  while y < bit.height -1 do
  begin
    if bit.canvas.pixels[x, y] = clwhite then
    begin
      break;
    end;
    inc(y);
  end;
  inc(y, sheetoffsetse.value);
  // draw sheet
  bit.canvas.font.size := 42;
  bit.canvas.font.bold := true;
  case sheetsizecb.itemindex of
    4: begin sx :=  297; sy := 210; s := 'A4'; end;
    3: begin sx :=  420; sy := 297; s := 'A3'; end;
    2: begin sx :=  594; sy := 420; s := 'A2'; end;
    1: begin sx :=  841; sy := 594; s := 'A1'; end;
  else begin sx := 1189; sy := 841; s := 'A0'; end;
  end;

  if sheetmodecb.itemindex = 0 then
  begin
    sz := sx;
    sx := sy;
    sy := sz;
  end;
  draw_sheet(y, sx, sy, s, bit);

  // draw texts
  s  := format('Y=%d', [y]);
  bit.canvas.brush.color := clrs[0];
  bit.canvas.textout  (gap6, y, s);
  bit.canvas.rectangle(gap0, y, dx, y+gap2);

  s  := format('Y=%d', [y+sy]);
  bit.canvas.textout  (gap6, y+sy, s);
  bit.canvas.rectangle(gap0, y+sy, dx, y+sy-gap2);

  s  := ('X=0, Y=0');
  bit.canvas.brush.color := clwhite;
  bit.canvas.textout(gap6, 0, s);

  s  := format('X=%d', [dx]);
  bit.canvas.textout(dx-bit.canvas.textwidth(s)-gap6, 0, s);

  s  := format('X=%d', [(dx-sx)div 2]);
  bit.canvas.textout  (((dx-sx)div 2)+gap8, 0, s);
  bit.canvas.rectangle(((dx-sx)div 2)+gap2, bit.canvas.textheight('X=')+gap3, ((dx-sx)div 2), dy-(bit.canvas.textheight('X=')+gap2));

  s  := format('X=%d', [(dx+sx)div 2]);
  bit.canvas.textout  (((dx+sx)div 2)+gap8, 0, s);
  bit.canvas.rectangle(((dx+sx)div 2)-gap2, bit.canvas.textheight('X=')+gap3, ((dx+sx)div 2), dy-(bit.canvas.textheight('X=')+gap2));

  s  := format('min-load=%f  max-load=%f  avg-load=%f  min-resolution=%f  offset=%d',
    [minloadse.value,  maxloadse.value,
    (minloadse.value + maxloadse.value)/2,
     minresolutionse.value, sheetoffsetse.value]);
  bit.canvas.textout((dx-bit.canvas.textwidth(s)) div 2, dy-bit.canvas.textheight(s), s);
  bit.endupdate(false);
  //---
  lock(true);
end;

end.


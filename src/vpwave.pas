{
  Description: vPlot wave class.

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

unit vpwave;

{$mode objfpc}

interface

uses
  classes, sysutils, vpmath, vpsetting;

type
  tvpdegres = 0..10;

  tvppolynome = packed record
    coefs: array[tvpdegres] of double;
    deg:   tvpdegres;
  end;

  tvpwavemesh = array[0..8] of tvppoint;

  tvpwave = class
  private
    fenabled: boolean;
    fsetting: tvpsetting;
    lax, lay: tvppolynome;
    lbx, lby: tvppolynome;
    lcx, lcy: tvppolynome;
  public
    constructor create(asetting: tvpsetting; const mesh: tvpwavemesh);
    destructor destroy; override;
    function update(const p: tvppoint): tvppoint;
  published
    property enabled: boolean read fenabled write fenabled;
  end;

  procedure wavedebug(awave: tvpwave);


implementation

uses
  matrix;

// polynomial evaluation

function polyeval(const apoly: tvppolynome; x: double): double;
var
  i: tvpdegres;
begin
  with apoly do
  begin
    result := 0;
    for i := deg downto low(coefs) do
      result := result * x + coefs[i];
  end;
end;

// tspacewave

constructor tvpwave.create(asetting: tvpsetting; const mesh: tvpwavemesh);
var
  a, aa: tvector3_double;
  b, bb: tvector3_double;
  c, cc: tvector3_double;
     dy: tvector3_double;
     dx: tvector3_double;
   y, x: tmatrix3_double;
  dxmax: double;
  dymax: double;
begin
  inherited create;
  fenabled := false;
  fsetting := asetting;
  dxmax    := fsetting.pagewidth  / 2;
  dymax    := fsetting.pageheight / 2;

  x.init(1, -dxmax, sqr(-dxmax), 1, 0, 0, 1, +dxmax, sqr(+dxmax));
  y.init(1, +dymax, sqr(+dymax), 1, 0, 0, 1, -dymax, sqr(-dymax));
  x := x.inverse(x.determinant);
  y := y.inverse(y.determinant);

  // calculate y-mirror
  dy.init(mesh[0].y, mesh[1].y, mesh[2].y);   a := x * dy;
  dy.init(mesh[3].y, mesh[4].y, mesh[5].y);   b := x * dy;
  dy.init(mesh[6].y, mesh[7].y, mesh[8].y);   c := x * dy;

  dx.init(a.data[0], b.data[0], c.data[0]);  cc := y * dx;
  dx.init(a.data[1], b.data[1], c.data[1]);  bb := y * dx;
  dx.init(a.data[2], b.data[2], c.data[2]);  aa := y * dx;

  lay.deg :=2;
  lay.coefs[2] := aa.data[2];
  lay.coefs[1] := aa.data[1];
  lay.coefs[0] := aa.data[0];

  lby.deg :=2;
  lby.coefs[2] := bb.data[2];
  lby.coefs[1] := bb.data[1];
  lby.coefs[0] := bb.data[0];

  lcy.deg :=2;
  lcy.coefs[2] := cc.data[2];
  lcy.coefs[1] := cc.data[1];
  lcy.coefs[0] := cc.data[0];

  // calculate x-mirror
  dx.init(mesh[0].x, mesh[3].x, mesh[6].x);   a := y * dx;
  dx.init(mesh[1].x, mesh[4].x, mesh[7].x);   b := y * dx;
  dx.init(mesh[2].x, mesh[5].x, mesh[8].x);   c := y * dx;

  dy.init(a.data[0], b.data[0], c.data[0]);  cc := x * dy;
  dy.init(a.data[1], b.data[1], c.data[1]);  bb := x * dy;
  dy.init(a.data[2], b.data[2], c.data[2]);  aa := x * dy;

  lax.deg :=2;
  lax.coefs[2] := aa.data[2];
  lax.coefs[1] := aa.data[1];
  lax.coefs[0] := aa.data[0];

  lbx.deg :=2;
  lbx.coefs[2] := bb.data[2];
  lbx.coefs[1] := bb.data[1];
  lbx.coefs[0] := bb.data[0];

  lcx.deg :=2;
  lcx.coefs[2] := cc.data[2];
  lcx.coefs[1] := cc.data[1];
  lcx.coefs[0] := cc.data[0];
end;

destructor tvpwave.destroy;
begin
  inherited destroy;
end;

function tvpwave.update(const p: tvppoint): tvppoint;
var
  lx: tvppolynome;
  ly: tvppolynome;
  pp: tvppoint;
begin
  if enabled then
  begin
    pp.x := p.x * fsetting.wavescale;
    pp.y := p.y * fsetting.wavescale;

    ly.deg :=2;
    ly.coefs[2] := polyeval(lay, pp.y);
    ly.coefs[1] := polyeval(lby, pp.y);
    ly.coefs[0] := polyeval(lcy, pp.y);

    lx.deg :=2;
    lx.coefs[2] := polyeval(lax, pp.x);
    lx.coefs[1] := polyeval(lbx, pp.x);
    lx.coefs[0] := polyeval(lcx, pp.x);

    result.x := pp.x + polyeval(lx, pp.y);
    result.y := pp.y + polyeval(ly, pp.x);
  end else
  begin
    result.x := p.x;
    result.y := p.y;
  end;
end;

procedure wavedebug(awave: tvpwave);
var
  i, j: longint;
  page: array[0..2, 0..2] of tvppoint;
    pp: tvppoint;
begin
  page[0, 0].x := -awave.fsetting.pagewidth  / 2;
  page[0, 0].y := +awave.fsetting.pageheight / 2;
  page[0, 1].x := +0;
  page[0, 1].y := +awave.fsetting.pageheight / 2;
  page[0, 2].x := +awave.fsetting.pagewidth  / 2;
  page[0, 2].y := +awave.fsetting.pageheight / 2;

  page[1, 0].x := -awave.fsetting.pagewidth  / 2;
  page[1, 0].y := +0;
  page[1, 1].y := +0;
  page[1, 1].y := +0;
  page[1, 2].x := +0;
  page[1, 2].x := +awave.fsetting.pagewidth  / 2;

  page[2, 0].x := -awave.fsetting.pagewidth  / 2;
  page[2, 0].y := -awave.fsetting.pageheight / 2;
  page[2, 1].x := +0;
  page[2, 1].y := -awave.fsetting.pageheight / 2;
  page[2, 2].x := +awave.fsetting.pagewidth  / 2;
  page[2, 2].y := -awave.fsetting.pageheight / 2;

  for i := 0 to 2 do
    for j := 0 to 2 do
    begin
      pp := awave.update(page[i, j]);
      writeln(format('WAVING::PNT.X       = %12.5f  PNT''.X = %12.5f', [page[i, j].x, pp.x]));
      writeln(format('WAVING::PNT.Y       = %12.5f  PNT''.Y = %12.5f', [page[i, j].y, pp.y]));
    end;
end;

end.

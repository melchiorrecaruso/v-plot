{
  Description: vPlot wave class.

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

unit vpwave;

{$mode objfpc}

interface

uses
  classes, sysutils, vpmath;

type
  tdegres = 0..10;

  tpolynome = packed record
    coefs: array[tdegres] of vpfloat;
    deg:   tdegres;
  end;

  twavemesh = array[0..8] of tvppoint;

  tspacewave = class
  private
    lax, lay: tpolynome;
    lbx, lby: tpolynome;
    lcx, lcy: tpolynome;
    fenabled: boolean;
    fscale:   vpfloat;
  public
    constructor create(xmax, ymax, scale: vpfloat; const mesh: twavemesh);
    destructor destroy; override;
    function update(const p: tvppoint): tvppoint;
    procedure debug;
  published
    property enabled: boolean read fenabled write fenabled;
  end;

  function polyeval(const apoly: tpolynome; x: vpfloat): vpfloat;

var
  spacewave: tspacewave = nil;

implementation

uses
  matrix;

// polynomial evaluation

function polyeval(const apoly: tpolynome; x: vpfloat): vpfloat;
var
  i: tdegres;
begin
  with apoly do
  begin
    result := 0;
    for i := deg downto low(coefs) do
      result := result * x + coefs[i];
  end;
end;

// tspacewave

constructor tspacewave.create(xmax, ymax, scale: vpfloat; const mesh: twavemesh);
var
  a, aa: tvector3_double;
  b, bb: tvector3_double;
  c, cc: tvector3_double;
     dy: tvector3_double;
     dx: tvector3_double;
      y: tmatrix3_double;
      x: tmatrix3_double;
begin
  inherited create;
  xmax := abs(xmax);
  ymax := abs(ymax);

  x.init(1, -xmax, sqr(-xmax), 1, 0, 0, 1, +xmax, sqr(+xmax));
  y.init(1, +ymax, sqr(+ymax), 1, 0, 0, 1, -ymax, sqr(-ymax));
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

  fscale       := scale;
  fenabled     := false;
end;

destructor tspacewave.destroy;
begin
  inherited destroy;
end;

function tspacewave.update(const p: tvppoint): tvppoint;
var
  ly,
  lx: tpolynome;
  pp: tvppoint;
begin
  if enabled then
  begin
    pp.x := p.x * fscale;
    pp.y := p.y * fscale;

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

procedure tspacewave.debug;
var
  p0,p1: tvppoint;

procedure test_print;
begin
  writeln(format('  WAVING::P.X    = %12.5f  P''.X = %12.5f', [p0.x, p1.x]));
  writeln(format('  WAVING::P.Y    = %12.5f  P''.Y = %12.5f', [p0.y, p1.y]));
end;

begin
  if enabledebug then
  begin
    p0.x := -594.5;  p0.y := +420.5;  p1 := update(p0);  test_print;
    p0.x := +0.000;  p0.y := +420.5;  p1 := update(p0);  test_print;
    p0.x := +594.5;  p0.y := +420.5;  p1 := update(p0);  test_print;
    p0.x := -594.5;  p0.y := +0.000;  p1 := update(p0);  test_print;
    p0.x := +0.000;  p0.y := +0.000;  p1 := update(p0);  test_print;
    p0.x := +594.5;  p0.y := +0.000;  p1 := update(p0);  test_print;
    p0.x := -594.5;  p0.y := -420.5;  p1 := update(p0);  test_print;
    p0.x := +0.000;  p0.y := -420.5;  p1 := update(p0);  test_print;
    p0.x := +594.5;  p0.y := -420.5;  p1 := update(p0);  test_print;
  end;
end;

end.


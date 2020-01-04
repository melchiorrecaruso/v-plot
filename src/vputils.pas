{
  Description: vPlot tools.

  Copyright (C) 2019 Melchiorre Caruso <melchiorrecaruso@gmail.com>

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

unit vputils;

{$mode objfpc}

interface

function  getbit1(const bits: byte; index: longint): boolean;
procedure setbit1(var   bits: byte; index: longint);

implementation

function getbit1(const bits: byte; index: longint): boolean;
var
  bt: byte;
begin
  bt :=  $01;
  bt :=  bt shl index;
  result := (bt and bits) > 0;
end;

procedure setbit1(var bits: byte; index: longint);
var
  bt: byte;
begin
  bt := $01;
  bt := bt shl index;
  bits := bits or bt;
end;

end.


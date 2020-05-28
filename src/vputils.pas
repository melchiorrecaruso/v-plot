{
  Description: vPlot utils unit.

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

unit vputils;

{$mode objfpc}

interface

uses
  fgl;

type
  tintegerlist = specialize tfpglist<integer>;
  tdoublelist  = specialize tfpglist<double>;
  tsinglelist  = specialize tfpglist<single>;

function  getbit1(const bits: byte; index: longint): boolean;
procedure setbit1(var   bits: byte; index: longint);

{$IFDEF UNIX}

procedure sleepmicroseconds(microseconds: longword);

{$ENDIF}

implementation

uses
 {$IFDEF UNIX} baseunix, unix, {$ENDIF} sysutils;

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

{$IFDEF UNIX}

procedure sleepmicroseconds(microseconds: longword);
var
  res: longint;
  timeout: ttimespec;
  timeoutresult: ttimespec;
begin
  timeout.tv_sec := (microseconds div 1000000);
  timeout.tv_nsec := 1000*(microseconds mod 1000000);
  repeat
    res := fpnanosleep(@timeout, @timeoutresult);
    timeout := timeoutresult;
  until (res <> -1) or (fpgeterrno <> esyseintr);
end;

{$ENDIF}

end.


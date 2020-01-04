{
  Description: Serial class.

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

unit vpserial;

{$mode objfpc}

interface

uses
  classes, dateutils, serial, sysutils;

type
  tvpserialstream = class
  private
    fbaudrate: longint;
    fbits:     longint;
    fflags:    tserialflags;
    fhandle:   longint;
    fparity:   tparitytype;
    fstopbits: longint;
    ftimeout:  longint;
  public
    constructor create;
    destructor destroy; override;
    function open(const device: string): boolean;
    function read (var buffer; count: longint): longint;
    function write(var buffer; count: longint): longint;
    function connected: boolean;
    procedure clear;
    procedure close;
  public
    property baudrate: longint      read fbaudrate write fbaudrate;
    property bits:     longint      read fbits     write fbits;
    property flags:    tserialflags read fflags    write fflags;
    property parity:   tparitytype  read fparity   write fparity;
    property stopbits: longint      read fstopbits write fstopbits;
  end;

var
  serialstream: tvpserialstream = nil;

implementation

constructor tvpserialstream.create;
begin
  inherited create;
  fbits     := 8;
  fbaudrate := 115200;
  fflags    := [];
  fhandle   := 0;
  fparity   := noneparity;
  fstopbits := 1;
  ftimeout  := 1000;
end;

destructor tvpserialstream.destroy;
begin
  close;
  inherited destroy;
end;

function tvpserialstream.open(const device: string): boolean;
begin
  close;

  fhandle := seropen(device);
  result  := fhandle <> 0;
  if result then
  begin
    sersetparams(fhandle, fbaudrate, fbits, noneparity, fstopbits, fflags);
    clear;
  end;
end;

procedure tvpserialstream.clear;
var
  cc: byte;
begin
  if connected then
  begin
    serflushinput (fhandle);
    serflushoutput(fhandle);
    while serreadtimeout(fhandle, cc, 100) > 0 do;
  end;
end;

procedure tvpserialstream.close;
begin
  if connected then
  begin
    sersync       (fhandle);
    serflushoutput(fhandle);
    serclose      (fhandle);
    fhandle := 0
  end;
end;

function tvpserialstream.read(var buffer; count: longint): longint;
var
  data: array[0..maxint-1] of byte absolute buffer;
     x: tdatetime;
begin
  x := now;
  result := 0;
  while (result < count) do
  begin
    inc(result, serread(fhandle, data[result], 1));
    if millisecondsbetween(now, x) > ftimeout then exit;
  end;
end;

function tvpserialstream.write(var buffer; count: longint): longint;
begin
  result := serwrite(fhandle, buffer, count);
end;


function tvpserialstream.connected: boolean;
begin
  {$IFDEF WINDOWS}
    result := fhandle <> 0;
  {$ELSE}
    result := fhandle <> thandle(-1);
  {$ENDIF}
end;

end.


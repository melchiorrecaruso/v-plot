{
  Description: vPlot setting class.

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

unit vpsetting;

{$mode objfpc}

interface

uses
  inifiles, sysutils, vpmath;

type
  tvpsetting = class
  private
    // points
    flayout0:  tvppoint;
    flayout1:  tvppoint;
    flayout8:  tvppoint;
    foffset:   vpfloat;
    fscale:    vpfloat;
    // x-motor
    fmxradius: vpfloat;
    fmxratio:  vpfloat;
    // 1-motor
    fmyradius: vpfloat;
    fmyratio:  vpfloat;
    // z-motor
    fmzmin:    longint;
    fmzmax:    longint;
    // ramps
    frampkb:   longint;
    frampkc:   longint;
    frampkd:   longint;
    frampmin:  longint;
    frampmax:  longint;
    // space wave
    fspacewave0: tvppoint;
    fspacewave1: tvppoint;
    fspacewave2: tvppoint;
    fspacewave3: tvppoint;
    fspacewave4: tvppoint;
    fspacewave5: tvppoint;
    fspacewave6: tvppoint;
    fspacewave7: tvppoint;
    fspacewave8: tvppoint;
    fspacewavedxmax: vpfloat;
    fspacewavedymax: vpfloat;
    fspacewavescale: vpfloat;
    fspacewaveoff: longint;
 public
    constructor create;
    destructor destroy; override;
    procedure load(const filename: rawbytestring);
 public
    property layout0:        tvppoint read flayout0  write flayout0;
    property layout1:        tvppoint read flayout1  write flayout1;
    property layout8:        tvppoint read flayout8  write flayout8;
    property offset:         vpfloat  read foffset   write foffset;
    property scale:          vpfloat  read fscale    write fscale;

    property mxradius:       vpfloat  read fmxradius write fmxradius;
    property mxratio:        vpfloat  read fmxratio  write fmxratio;
    property myradius:       vpfloat  read fmyradius write fmyradius;
    property myratio:        vpfloat  read fmyratio  write fmyratio;
    property mzmin:          longint  read fmzmin;
    property mzmax:          longint  read fmzmax;

    property spacewave0:     tvppoint read fspacewave0;
    property spacewave1:     tvppoint read fspacewave1;
    property spacewave2:     tvppoint read fspacewave2;
    property spacewave3:     tvppoint read fspacewave3;
    property spacewave4:     tvppoint read fspacewave4;
    property spacewave5:     tvppoint read fspacewave5;
    property spacewave6:     tvppoint read fspacewave6;
    property spacewave7:     tvppoint read fspacewave7;
    property spacewave8:     tvppoint read fspacewave8;
    property spacewavedxmax: vpfloat  read fspacewavedxmax;
    property spacewavedymax: vpfloat  read fspacewavedymax;
    property spacewavescale: vpfloat  read fspacewavescale;
    property spacewaveoff:   longint  read fspacewaveoff;
 end;

var
  setting:  tvpsetting = nil;

implementation

constructor tvpsetting.create;
begin
  inherited create;
end;

destructor tvpsetting.destroy;
begin
  inherited destroy;
end;

procedure tvpsetting.load(const filename: rawbytestring);
var
  ini: tinifile;
begin
  ini := tinifile.create(filename);
  ini.formatsettings.decimalseparator := '.';

  flayout0.x := ini.readfloat('LAYOUT', 'L0.X',   0);
  flayout0.y := ini.readfloat('LAYOUT', 'L0.Y',   0);
  flayout1.x := ini.readfloat('LAYOUT', 'L1.X',   0);
  flayout1.y := ini.readfloat('LAYOUT', 'L1.Y',   0);
  flayout8.x := ini.readfloat('LAYOUT', 'L8.X',   0);
  flayout8.y := ini.readfloat('LAYOUT', 'L8.Y',   0);
  foffset    := ini.readfloat('LAYOUT', 'OFFSET', 0);
  fscale     := ini.readfloat('LAYOUT', 'SCALE',  0);

  fmxradius := ini.readfloat  ('X-AXIS', 'RADIUS', 0);
  fmxratio  := ini.readfloat  ('X-AXIS', 'RATIO',  0);
  fmyradius := ini.readfloat  ('Y-AXIS', 'RADIUS', 0);
  fmyratio  := ini.readfloat  ('Y-AXIS', 'RATIO',  0);
  fmzmin    := ini.readinteger('Z-AXIS', 'MIN',    0);
  fmzmax    := ini.readinteger('Z-AXIS', 'MAX',    0);

  fspacewave0.x   := ini.readfloat  ('SPACE-WAVE', 'W0.X',  0);
  fspacewave0.y   := ini.readfloat  ('SPACE-WAVE', 'W0.Y',  0);
  fspacewave1.x   := ini.readfloat  ('SPACE-WAVE', 'W1.X',  0);
  fspacewave1.y   := ini.readfloat  ('SPACE-WAVE', 'W1.Y',  0);
  fspacewave2.x   := ini.readfloat  ('SPACE-WAVE', 'W2.X',  0);
  fspacewave2.y   := ini.readfloat  ('SPACE-WAVE', 'W2.Y',  0);
  fspacewave3.x   := ini.readfloat  ('SPACE-WAVE', 'W3.X',  0);
  fspacewave3.y   := ini.readfloat  ('SPACE-WAVE', 'W3.Y',  0);
  fspacewave4.x   := ini.readfloat  ('SPACE-WAVE', 'W4.X',  0);
  fspacewave4.y   := ini.readfloat  ('SPACE-WAVE', 'W4.Y',  0);
  fspacewave5.x   := ini.readfloat  ('SPACE-WAVE', 'W5.X',  0);
  fspacewave5.y   := ini.readfloat  ('SPACE-WAVE', 'W5.Y',  0);
  fspacewave6.x   := ini.readfloat  ('SPACE-WAVE', 'W6.X',  0);
  fspacewave6.y   := ini.readfloat  ('SPACE-WAVE', 'W6.Y',  0);
  fspacewave7.x   := ini.readfloat  ('SPACE-WAVE', 'W7.X',  0);
  fspacewave7.y   := ini.readfloat  ('SPACE-WAVE', 'W7.Y',  0);
  fspacewave8.x   := ini.readfloat  ('SPACE-WAVE', 'W8.X',  0);
  fspacewave8.y   := ini.readfloat  ('SPACE-WAVE', 'W8.Y',  0);
  fspacewavedxmax := ini.readfloat  ('SPACE-WAVE', 'DXMAX', 0);
  fspacewavedymax := ini.readfloat  ('SPACE-WAVE', 'DYMAX', 0);
  fspacewavescale := ini.readfloat  ('SPACE-WAVE', 'SCALE', 0);
  fspacewaveoff   := ini.readinteger('SPACE-WAVE', 'OFF',   0);

  if enabledebug then
  begin
    writeln(format('  LAYOUT::L0.X   = %12.5f  L0.Y = %12.5f', [flayout0.x, flayout0.y]));
    writeln(format('  LAYOUT::L1.X   = %12.5f  L1.Y = %12.5f', [flayout1.x, flayout1.y]));
    writeln(format('  LAYOUT::L8.X   = %12.5f  L8.Y = %12.5f', [flayout8.x, flayout8.y]));
    writeln(format('  LAYOUT::OFFSET = %12.5f', [foffset   ]));
    writeln(format('  LAYOUT::SCALE  = %12.5f', [fscale    ]));

    writeln(format('  X-AXIS::RADIUS = %12.5f', [fmxradius ]));
    writeln(format('  X-AXIS::RATIO  = %12.5f', [fmxratio  ]));
    writeln(format('  Y-AXIS::RADIUS = %12.5f', [fmyradius ]));
    writeln(format('  Y-AXIS::RATIO  = %12.5f', [fmyratio  ]));
    writeln(format('  Z-AXIS::MIN    = %12.5u', [fmzmin    ]));
    writeln(format('  Z-AXIS::MAX    = %12.5u', [fmzmax    ]));

    writeln(format(' SPACE-W::W0.X   = %12.5f  W0.Y = %12.5f', [fspacewave0.x, fspacewave0.y]));
    writeln(format(' SPACE-W::W1.X   = %12.5f  W1.Y = %12.5f', [fspacewave1.x, fspacewave1.y]));
    writeln(format(' SPACE-W::W2.X   = %12.5f  W2.Y = %12.5f', [fspacewave2.x, fspacewave2.y]));
    writeln(format(' SPACE-W::W3.X   = %12.5f  W3.Y = %12.5f', [fspacewave3.x, fspacewave3.y]));
    writeln(format(' SPACE-W::W4.X   = %12.5f  W4.Y = %12.5f', [fspacewave4.x, fspacewave4.y]));
    writeln(format(' SPACE-W::W5.X   = %12.5f  W5.Y = %12.5f', [fspacewave5.x, fspacewave5.y]));
    writeln(format(' SPACE-W::W6.X   = %12.5f  W6.Y = %12.5f', [fspacewave6.x, fspacewave6.y]));
    writeln(format(' SPACE-W::W7.X   = %12.5f  W7.Y = %12.5f', [fspacewave7.x, fspacewave7.y]));
    writeln(format(' SPACE-W::W8.X   = %12.5f  W8.Y = %12.5f', [fspacewave8.x, fspacewave8.y]));
    writeln(format(' SPACE-W::DXMAX  = %12.5f',                [fspacewavedxmax]));
    writeln(format(' SPACE-W::DYMAX  = %12.5f',                [fspacewavedymax]));
    writeln(format(' SPACE-W::SCALE  = %12.5f',                [fspacewavescale]));
    writeln(format(' SPACE-W::OFF    = %12.5u',                [fspacewaveoff  ]));
  end;
  ini.destroy;
end;

end.


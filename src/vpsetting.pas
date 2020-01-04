{
  Description: vPlot setting class.

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

unit vpsetting;

{$mode objfpc}

interface

uses
  inifiles, sysutils, vpmath;

type
  tvpsetting = class
  private
    // points
    fpoint0:   tvppoint;
    fpoint1:   tvppoint;
    fpoint8:   tvppoint;
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
    fspacewaveon: longint;
 public
    constructor create;
    destructor destroy; override;
    procedure load(const filename: rawbytestring);
 public
    property point0:         tvppoint read fpoint0   write fpoint0;
    property point1:         tvppoint read fpoint1   write fpoint1;
    property point8:         tvppoint read fpoint8   write fpoint8;
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
    property spacewaveon:    longint  read fspacewaveon;
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

  fpoint0.x := ini.readfloat('LAYOUT', 'P0.X',   0);
  fpoint0.y := ini.readfloat('LAYOUT', 'P0.Y',   0);
  fpoint1.x := ini.readfloat('LAYOUT', 'P1.X',   0);
  fpoint1.y := ini.readfloat('LAYOUT', 'P1.Y',   0);
  fpoint8.x := ini.readfloat('LAYOUT', 'P8.X',   0);
  fpoint8.y := ini.readfloat('LAYOUT', 'P8.Y',   0);
  foffset   := ini.readfloat('LAYOUT', 'OFFSET', 0);
  fscale    := ini.readfloat('LAYOUT', 'SCALE',  0);

  fmxradius := ini.readfloat  ('X-AXIS', 'RADIUS', 0);
  fmxratio  := ini.readfloat  ('X-AXIS', 'RATIO',  0);
  fmyradius := ini.readfloat  ('Y-AXIS', 'RADIUS', 0);
  fmyratio  := ini.readfloat  ('Y-AXIS', 'RATIO',  0);
  fmzmin    := ini.readinteger('Z-AXIS', 'MIN',    0);
  fmzmax    := ini.readinteger('Z-AXIS', 'MAX',    0);

  fspacewave0.x := ini.readfloat('SPACE-WAVE', '00.X', 0);
  fspacewave0.y := ini.readfloat('SPACE-WAVE', '00.Y', 0);
  fspacewave1.x := ini.readfloat('SPACE-WAVE', '01.X', 0);
  fspacewave1.y := ini.readfloat('SPACE-WAVE', '01.Y', 0);
  fspacewave2.x := ini.readfloat('SPACE-WAVE', '02.X', 0);
  fspacewave2.y := ini.readfloat('SPACE-WAVE', '02.Y', 0);
  fspacewave3.x := ini.readfloat('SPACE-WAVE', '03.X', 0);
  fspacewave3.y := ini.readfloat('SPACE-WAVE', '03.Y', 0);
  fspacewave4.x := ini.readfloat('SPACE-WAVE', '04.X', 0);
  fspacewave4.y := ini.readfloat('SPACE-WAVE', '04.Y', 0);
  fspacewave5.x := ini.readfloat('SPACE-WAVE', '05.X', 0);
  fspacewave5.y := ini.readfloat('SPACE-WAVE', '05.Y', 0);
  fspacewave6.x := ini.readfloat('SPACE-WAVE', '06.X', 0);
  fspacewave6.y := ini.readfloat('SPACE-WAVE', '06.Y', 0);
  fspacewave7.x := ini.readfloat('SPACE-WAVE', '07.X', 0);
  fspacewave7.y := ini.readfloat('SPACE-WAVE', '07.Y', 0);
  fspacewave8.x := ini.readfloat('SPACE-WAVE', '08.X', 0);
  fspacewave8.y := ini.readfloat('SPACE-WAVE', '08.Y', 0);
  fspacewavedxmax := ini.readfloat('SPACE-WAVE', 'DXMAX', 0);
  fspacewavedymax := ini.readfloat('SPACE-WAVE', 'DYMAX', 0);
  fspacewavescale := ini.readfloat('SPACE-WAVE', 'SCALE', 0);
  fspacewaveon    := ini.readinteger('SPACE-WAVE', 'ON', 0);

  if enabledebug then
  begin
    writeln(format('  LAYOUT::L0.X   = %12.5f  L0.Y = %12.5f', [fpoint0.x, fpoint0.y]));
    writeln(format('  LAYOUT::L1.X   = %12.5f  L1.Y = %12.5f', [fpoint1.x, fpoint1.y]));
    writeln(format('  LAYOUT::L8.X   = %12.5f  L8.Y = %12.5f', [fpoint8.x, fpoint8.y]));
    writeln(format('  LAYOUT::OFFSET = %12.5f', [foffset   ]));
    writeln(format('  LAYOUT::SCALE  = %12.5f', [fscale    ]));

    writeln(format('  X-AXIS::RADIUS = %12.5f', [fmxradius ]));
    writeln(format('  X-AXIS::RATIO  = %12.5f', [fmxratio  ]));
    writeln(format('  Y-AXIS::RADIUS = %12.5f', [fmyradius ]));
    writeln(format('  Y-AXIS::RATIO  = %12.5f', [fmyratio  ]));
    writeln(format('  Z-AXIS::MIN    = %12.5u', [fmzmin    ]));
    writeln(format('  Z-AXIS::MAX    = %12.5u', [fmzmax    ]));

    writeln(format(' SPACE-W::00.X   = %12.5f  00.Y = %12.5f', [fspacewave0.x, fspacewave0.y]));
    writeln(format(' SPACE-W::01.X   = %12.5f  01.Y = %12.5f', [fspacewave1.x, fspacewave1.y]));
    writeln(format(' SPACE-W::02.X   = %12.5f  02.Y = %12.5f', [fspacewave2.x, fspacewave2.y]));
    writeln(format(' SPACE-W::03.X   = %12.5f  03.Y = %12.5f', [fspacewave3.x, fspacewave3.y]));
    writeln(format(' SPACE-W::04.X   = %12.5f  04.Y = %12.5f', [fspacewave4.x, fspacewave4.y]));
    writeln(format(' SPACE-W::05.X   = %12.5f  05.Y = %12.5f', [fspacewave5.x, fspacewave5.y]));
    writeln(format(' SPACE-W::06.X   = %12.5f  06.Y = %12.5f', [fspacewave6.x, fspacewave6.y]));
    writeln(format(' SPACE-W::07.X   = %12.5f  07.Y = %12.5f', [fspacewave7.x, fspacewave7.y]));
    writeln(format(' SPACE-W::08.X   = %12.5f  08.Y = %12.5f', [fspacewave8.x, fspacewave8.y]));
    writeln(format(' SPACE-W::DXMAX  = %12.5f',                [fspacewavedxmax]));
    writeln(format(' SPACE-W::DYMAX  = %12.5f',                [fspacewavedymax]));
    writeln(format(' SPACE-W::SCALE  = %12.5f',                [fspacewavescale]));
    writeln(format(' SPACE-W::ON     = %12.5u',                [fspacewaveon   ]));
  end;
  ini.destroy;
end;

end.


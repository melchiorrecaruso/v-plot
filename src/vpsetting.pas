{
  Description: Setting class.

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
    // layout
    fpoint0: tvppoint;
    fpoint1: tvppoint;
    fpoint8: tvppoint;
    fpoint9offset: vpfloat;
    fpoint9factor: vpfloat;
    fpageheight:   vpfloat;
    fpagewidth:    vpfloat;
    // x-motor
    fmxradius: vpfloat;
    fmxratio:  vpfloat;
    // y-motor
    fmyradius: vpfloat;
    fmyratio:  vpfloat;
    // z-motor
    fmzmin: longint;
    fmzmax: longint;
    // ramps
    frampkb: longint;
    frampkl: longint;
    frampkm: longint;
    // wave
    fwavepoint0: tvppoint;
    fwavepoint1: tvppoint;
    fwavepoint2: tvppoint;
    fwavepoint3: tvppoint;
    fwavepoint4: tvppoint;
    fwavepoint5: tvppoint;
    fwavepoint6: tvppoint;
    fwavepoint7: tvppoint;
    fwavepoint8: tvppoint;
    fwavescale:  vpfloat;
    fwaveoff:    longint;
 public
    constructor create;
    destructor destroy; override;
    procedure load(const filename: rawbytestring);
 public
    property point0:       tvppoint read fpoint0       write fpoint0;
    property point1:       tvppoint read fpoint1       write fpoint1;
    property point8:       tvppoint read fpoint8       write fpoint8;
    property point9offset: vpfloat  read fpoint9offset write fpoint9offset;
    property point9factor: vpfloat  read fpoint9factor write fpoint9factor;
    property pageheight:   vpfloat  read fpageheight;
    property pagewidth:    vpfloat  read fpagewidth;

    property mxradius:     vpfloat read fmxradius write fmxradius;
    property mxratio:      vpfloat read fmxratio  write fmxratio;
    property myradius:     vpfloat read fmyradius write fmyradius;
    property myratio:      vpfloat read fmyratio  write fmyratio;
    property mzmin:        longint read fmzmin;
    property mzmax:        longint read fmzmax;

    property rampkb:       longint read frampkb;
    property rampkl:       longint read frampkl;
    property rampkm:       longint read frampkm;

    property wavepoint0: tvppoint read fwavepoint0;
    property wavepoint1: tvppoint read fwavepoint1;
    property wavepoint2: tvppoint read fwavepoint2;
    property wavepoint3: tvppoint read fwavepoint3;
    property wavepoint4: tvppoint read fwavepoint4;
    property wavepoint5: tvppoint read fwavepoint5;
    property wavepoint6: tvppoint read fwavepoint6;
    property wavepoint7: tvppoint read fwavepoint7;
    property wavepoint8: tvppoint read fwavepoint8;
    property wavescale:  vpfloat  read fwavescale;
    property waveoff:    longint  read fwaveoff;
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
  ini.options := [ifoformatsettingsactive];

  fpoint0.x     := ini.readfloat('LAYOUT', 'POINT0.X',       0);
  fpoint0.y     := ini.readfloat('LAYOUT', 'POINT0.Y',       0);
  fpoint1.x     := ini.readfloat('LAYOUT', 'POINT1.X',       0);
  fpoint1.y     := ini.readfloat('LAYOUT', 'POINT1.Y',       0);
  fpoint8.x     := ini.readfloat('LAYOUT', 'POINT8.X',       0);
  fpoint8.y     := ini.readfloat('LAYOUT', 'POINT8.Y',       0);
  fpoint9offset := ini.readfloat('LAYOUT', 'POINT9.OFFSET',  0);
  fpoint9factor := ini.readfloat('LAYOUT', 'POINT9.FACTOR',  0);
  fpageheight   := ini.readfloat('LAYOUT', 'PAGE.HEIGHT',    0);
  fpagewidth    := ini.readfloat('LAYOUT', 'PAGE.WIDTH',     0);

  fmxradius     := ini.readfloat  ('X-AXIS', 'RADIUS', 0);
  fmxratio      := ini.readfloat  ('X-AXIS', 'RATIO',  0);
  fmyradius     := ini.readfloat  ('Y-AXIS', 'RADIUS', 0);
  fmyratio      := ini.readfloat  ('Y-AXIS', 'RATIO',  0);
  fmzmin        := ini.readinteger('Z-AXIS', 'MIN',    0);
  fmzmax        := ini.readinteger('Z-AXIS', 'MAX',    0);

  frampkb       := ini.readinteger('RAMP','KB', 0);
  frampkl       := ini.readinteger('RAMP','KL', 0);
  frampkm       := ini.readinteger('RAMP','KM', 0);

  fwavepoint0.x := ini.readfloat  ('WAVE', 'POINT0.X', 0);
  fwavepoint0.y := ini.readfloat  ('WAVE', 'POINT0.Y', 0);
  fwavepoint1.x := ini.readfloat  ('WAVE', 'POINT1.X', 0);
  fwavepoint1.y := ini.readfloat  ('WAVE', 'POINT1.Y', 0);
  fwavepoint2.x := ini.readfloat  ('WAVE', 'POINT2.X', 0);
  fwavepoint2.y := ini.readfloat  ('WAVE', 'POINT2.Y', 0);
  fwavepoint3.x := ini.readfloat  ('WAVE', 'POINT3.X', 0);
  fwavepoint3.y := ini.readfloat  ('WAVE', 'POINT3.Y', 0);
  fwavepoint4.x := ini.readfloat  ('WAVE', 'POINT4.X', 0);
  fwavepoint4.y := ini.readfloat  ('WAVE', 'POINT4.Y', 0);
  fwavepoint5.x := ini.readfloat  ('WAVE', 'POINT5.X', 0);
  fwavepoint5.y := ini.readfloat  ('WAVE', 'POINT5.Y', 0);
  fwavepoint6.x := ini.readfloat  ('WAVE', 'POINT6.X', 0);
  fwavepoint6.y := ini.readfloat  ('WAVE', 'POINT6.Y', 0);
  fwavepoint7.x := ini.readfloat  ('WAVE', 'POINT7.X', 0);
  fwavepoint7.y := ini.readfloat  ('WAVE', 'POINT7.Y', 0);
  fwavepoint8.x := ini.readfloat  ('WAVE', 'POINT8.X', 0);
  fwavepoint8.y := ini.readfloat  ('WAVE', 'POINT8.Y', 0);
  fwavescale    := ini.readfloat  ('WAVE', 'SCALE',    0);
  fwaveoff      := ini.readinteger('WAVE', 'OFF',      0);

  if enabledebug then
  begin
    writeln(format('LAYOUT::PNT0.X      = %12.5f  PNT0.Y = %12.5f', [fpoint0.x, fpoint0.y]));
    writeln(format('LAYOUT::PNT1.X      = %12.5f  PNT1.Y = %12.5f', [fpoint1.x, fpoint1.y]));
    writeln(format('LAYOUT::PNT8.X      = %12.5f  PNT8.Y = %12.5f', [fpoint8.x, fpoint8.y]));
    writeln(format('LAYOUT::PNT9.OFFSET = %12.5f', [fpoint9offset]));
    writeln(format('LAYOUT::PNT9.FACTOR = %12.5f', [fpoint9factor]));
    writeln(format('LAYOUT::PAGE.HEIGHT = %12.5f', [fpageheight]));
    writeln(format('LAYOUT::PAGE.WIDTH  = %12.5f', [fpagewidth ]));

    writeln(format('X-AXIS::RADIUS      = %12.5f', [fmxradius ]));
    writeln(format('X-AXIS::RATIO       = %12.5f', [fmxratio  ]));
    writeln(format('Y-AXIS::RADIUS      = %12.5f', [fmyradius ]));
    writeln(format('Y-AXIS::RATIO       = %12.5f', [fmyratio  ]));
    writeln(format('Z-AXIS::MIN         = %12.5u', [fmzmin    ]));
    writeln(format('Z-AXIS::MAX         = %12.5u', [fmzmax    ]));

    writeln(format('  RAMP::KB          = %12.5u', [frampkb]));
    writeln(format('  RAMP::KL          = %12.5u', [frampkl]));
    writeln(format('  RAMP::KM          = %12.5u', [frampkm]));

    writeln(format('  WAVE::PNT0.X      = %12.5f  PNT0.Y = %12.5f', [fwavepoint0.x, fwavepoint0.y]));
    writeln(format('  WAVE::PNT1.X      = %12.5f  PNT1.Y = %12.5f', [fwavepoint1.x, fwavepoint1.y]));
    writeln(format('  WAVE::PNT2.X      = %12.5f  PNT2.Y = %12.5f', [fwavepoint2.x, fwavepoint2.y]));
    writeln(format('  WAVE::PNT3.X      = %12.5f  PNT3.Y = %12.5f', [fwavepoint3.x, fwavepoint3.y]));
    writeln(format('  WAVE::PNT4.X      = %12.5f  PNT4.Y = %12.5f', [fwavepoint4.x, fwavepoint4.y]));
    writeln(format('  WAVE::PNT5.X      = %12.5f  PNT5.Y = %12.5f', [fwavepoint5.x, fwavepoint5.y]));
    writeln(format('  WAVE::PNT6.X      = %12.5f  PNT6.Y = %12.5f', [fwavepoint6.x, fwavepoint6.y]));
    writeln(format('  WAVE::PNT7.X      = %12.5f  PNT7.Y = %12.5f', [fwavepoint7.x, fwavepoint7.y]));
    writeln(format('  WAVE::PNT8.X      = %12.5f  PNT8.Y = %12.5f', [fwavepoint8.x, fwavepoint8.y]));
    writeln(format('  WAVE::SCALE       = %12.5f', [fwavescale]));
    writeln(format('  WAVE::OFF         = %12.5u', [fwaveoff  ]));
  end;
  ini.destroy;
end;

end.


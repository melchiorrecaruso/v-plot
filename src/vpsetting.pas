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
  dialogs, inifiles, sysutils, vpmath;

type
  tvpsetting = class
  private
    // layout
    fpoint0: tvppoint;
    fpoint1: tvppoint;
    fpoint8: tvppoint;
    fpoint9offset: double;
    fpoint9factor: double;
    fpageheight: double;
    fpagewidth:  double;
    // pulley-0
    fpulley0radius: double;
    fpulley0ratio:  double;
    // pulley-1
    fpulley1radius: double;
    fpulley1ratio:  double;
    // servo-z
    fservozvalue0: longint;
    fservozvalue1: longint;
    fservozvalue2: longint;
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
    fwavescale:  double;
    fwaveoff:    longint;
 public
    constructor create;
    destructor destroy; override;
    procedure load(const filename: string);
    procedure save(const filename: string);
 public
    property point0: tvppoint read fpoint0 write fpoint0;
    property point1: tvppoint read fpoint1 write fpoint1;
    property point8: tvppoint read fpoint8 write fpoint8;
    property point9offset: double read fpoint9offset write fpoint9offset;
    property point9factor: double read fpoint9factor write fpoint9factor;
    property pageheight: double read fpageheight write fpageheight;
    property pagewidth:  double read fpagewidth  write fpagewidth;

    property pulley0radius: double read fpulley0radius write fpulley0radius;
    property pulley0ratio:  double read fpulley0ratio  write fpulley0ratio;
    property pulley1radius: double read fpulley1radius write fpulley1radius;
    property pulley1ratio:  double read fpulley1ratio  write fpulley1ratio;
    property servozvalue0: longint read fservozvalue0 write fservozvalue0;
    property servozvalue1: longint read fservozvalue1 write fservozvalue1;
    property servozvalue2: longint read fservozvalue2 write fservozvalue2;

    property rampkb: longint read frampkb write frampkb;
    property rampkl: longint read frampkl write frampkl;
    property rampkm: longint read frampkm write frampkm;

    property wavepoint0: tvppoint read fwavepoint0 write fwavepoint0;
    property wavepoint1: tvppoint read fwavepoint1 write fwavepoint1;
    property wavepoint2: tvppoint read fwavepoint2 write fwavepoint2;
    property wavepoint3: tvppoint read fwavepoint3 write fwavepoint3;
    property wavepoint4: tvppoint read fwavepoint4 write fwavepoint4;
    property wavepoint5: tvppoint read fwavepoint5 write fwavepoint5;
    property wavepoint6: tvppoint read fwavepoint6 write fwavepoint6;
    property wavepoint7: tvppoint read fwavepoint7 write fwavepoint7;
    property wavepoint8: tvppoint read fwavepoint8 write fwavepoint8;
    property wavescale:  double  read fwavescale  write fwavescale;
    property waveoff:    longint  read fwaveoff    write fwaveoff;
 end;


function getclientsettingfilename(global: boolean): string;
function getsettingfilename(global: boolean): string;


implementation

function getclientsettingfilename(global: boolean): string;
begin
  result := includetrailingbackslash(getappconfigdir(global)) + 'vplot.client';
end;

function getsettingfilename(global: boolean): string;
begin
  result := includetrailingbackslash(getappconfigdir(false)) + 'vplot.ini';

  if global and (not fileexists(result)) then
  begin
    {$IFDEF MSWINDOWS}
    result := extractfilepath(paramstr(0)) + 'vplot.ini';
    {$ELSE}
    {$IFDEF UNIX}
    result := '/opt/vplot/vplot.ini';
    {$ELSE}
    result := '';
    {$ENDIF}
    {$ENDIF}
  end;
end;

// tvpsetting

constructor tvpsetting.create;
begin
  inherited create;
end;

destructor tvpsetting.destroy;
begin
  inherited destroy;
end;

procedure tvpsetting.load(const filename: string);
var
  ini: tinifile;
begin
  if fileexists(filename) = false then
  begin
    messagedlg('vPlot Client', 'Setting file not found !', mterror, [mbok], 0);
  end else
  begin
    ini := tinifile.create(filename);
    ini.formatsettings.decimalseparator := '.';
    ini.options := [ifoformatsettingsactive];

    fpoint0.x     := ini.readfloat('LAYOUT', 'POINT0.X',      0);
    fpoint0.y     := ini.readfloat('LAYOUT', 'POINT0.Y',      0);
    fpoint1.x     := ini.readfloat('LAYOUT', 'POINT1.X',      0);
    fpoint1.y     := ini.readfloat('LAYOUT', 'POINT1.Y',      0);
    fpoint8.x     := ini.readfloat('LAYOUT', 'POINT8.X',      0);
    fpoint8.y     := ini.readfloat('LAYOUT', 'POINT8.Y',      0);
    fpoint9offset := ini.readfloat('LAYOUT', 'POINT9.OFFSET', 0);
    fpoint9factor := ini.readfloat('LAYOUT', 'POINT9.FACTOR', 0);

    fpulley0radius := ini.readfloat  ('PULLEY-0', 'RADIUS',  0);
    fpulley0ratio  := ini.readfloat  ('PULLEY-0', 'RATIO',   0);
    fpulley1radius := ini.readfloat  ('PULLEY-1', 'RADIUS',  0);
    fpulley1ratio  := ini.readfloat  ('PULLEY-1', 'RATIO',   0);
    fservozvalue0  := ini.readinteger('SERVO-Z',  'VALUE-0', 0);
    fservozvalue1  := ini.readinteger('SERVO-Z',  'VALUE-1', 0);
    fservozvalue2  := ini.readinteger('SERVO-Z',  'VALUE-2', 0);

    fpageheight := ini.readfloat('PAGE', 'HEIGHT', 0);
    fpagewidth  := ini.readfloat('PAGE', 'WIDTH',  0);

    frampkb := ini.readinteger('RAMP','KB', 0);
    frampkl := ini.readinteger('RAMP','KL', 0);
    frampkm := ini.readinteger('RAMP','KM', 0);

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
    {$IFOPT D+}
    writeln(format('LAYOUT::PNT0.X      = %12.5f  PNT0.Y = %12.5f', [fpoint0.x, fpoint0.y]));
    writeln(format('LAYOUT::PNT1.X      = %12.5f  PNT1.Y = %12.5f', [fpoint1.x, fpoint1.y]));
    writeln(format('LAYOUT::PNT8.X      = %12.5f  PNT8.Y = %12.5f', [fpoint8.x, fpoint8.y]));
    writeln(format('LAYOUT::PNT9.OFFSET = %12.5f', [fpoint9offset]));
    writeln(format('LAYOUT::PNT9.FACTOR = %12.5f', [fpoint9factor]));

    writeln(format('PLLY-0::RADIUS      = %12.5f', [fpulley0radius]));
    writeln(format('PLLY-0::RATIO       = %12.5f', [fpulley0ratio ]));
    writeln(format('PLLY-1::RADIUS      = %12.5f', [fpulley1radius]));
    writeln(format('PLLY-1::RATIO       = %12.5f', [fpulley1ratio ]));
    writeln(format(' SRV-Z::VALUE-0     = %12.5u', [fservozvalue0 ]));
    writeln(format(' SRV-Z::VALUE-1     = %12.5u', [fservozvalue1 ]));
    writeln(format(' SRV-Z::VALUE-2     = %12.5u', [fservozvalue2 ]));

    writeln(format('  PAGE::HEIGHT      = %12.5f', [fpageheight]));
    writeln(format('  PAGE::WIDTH       = %12.5f', [fpagewidth ]));

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
    {$ENDIF}
    ini.destroy;
  end;
end;

procedure tvpsetting.save(const filename: string);
var
  ini: tinifile;
begin
  ini := tinifile.create(filename);
  ini.formatsettings.decimalseparator := '.';
  ini.options := [ifoformatsettingsactive];

  ini.writefloat('LAYOUT', 'POINT0.X',      fpoint0.x);
  ini.writefloat('LAYOUT', 'POINT0.Y',      fpoint0.y);
  ini.writefloat('LAYOUT', 'POINT1.X',      fpoint1.x);
  ini.writefloat('LAYOUT', 'POINT1.Y',      fpoint1.y);
  ini.writefloat('LAYOUT', 'POINT8.X',      fpoint8.x);
  ini.writefloat('LAYOUT', 'POINT8.Y',      fpoint8.y);
  ini.writefloat('LAYOUT', 'POINT9.OFFSET', fpoint9offset);
  ini.writefloat('LAYOUT', 'POINT9.FACTOR', fpoint9factor);

  ini.writefloat  ('PULLEY-0', 'RADIUS',  fpulley0radius);
  ini.writefloat  ('PULLEY-0', 'RATIO',   fpulley0ratio);
  ini.writefloat  ('PULLEY-1', 'RADIUS',  fpulley1radius);
  ini.writefloat  ('PULLEY-1', 'RATIO',   fpulley1ratio);
  ini.writeinteger('SERVO-Z',  'VALUE-0', fservozvalue0);
  ini.writeinteger('SERVO-Z',  'VALUE-1', fservozvalue1);
  ini.writeinteger('SERVO-Z',  'VALUE-2', fservozvalue2);

  ini.writefloat('PAGE', 'HEIGHT', fpageheight);
  ini.writefloat('PAGE', 'WIDTH',  fpagewidth);

  ini.writeinteger('RAMP','KB', frampkb);
  ini.writeinteger('RAMP','KL', frampkl);
  ini.writeinteger('RAMP','KM', frampkm);

  ini.writefloat  ('WAVE', 'POINT0.X', fwavepoint0.x);
  ini.writefloat  ('WAVE', 'POINT0.Y', fwavepoint0.y);
  ini.writefloat  ('WAVE', 'POINT1.X', fwavepoint1.x);
  ini.writefloat  ('WAVE', 'POINT1.Y', fwavepoint1.y);
  ini.writefloat  ('WAVE', 'POINT2.X', fwavepoint2.x);
  ini.writefloat  ('WAVE', 'POINT2.Y', fwavepoint2.y);
  ini.writefloat  ('WAVE', 'POINT3.X', fwavepoint3.x);
  ini.writefloat  ('WAVE', 'POINT3.Y', fwavepoint3.y);
  ini.writefloat  ('WAVE', 'POINT4.X', fwavepoint4.x);
  ini.writefloat  ('WAVE', 'POINT4.Y', fwavepoint4.y);
  ini.writefloat  ('WAVE', 'POINT5.X', fwavepoint5.x);
  ini.writefloat  ('WAVE', 'POINT5.Y', fwavepoint5.y);
  ini.writefloat  ('WAVE', 'POINT6.X', fwavepoint6.x);
  ini.writefloat  ('WAVE', 'POINT6.Y', fwavepoint6.y);
  ini.writefloat  ('WAVE', 'POINT7.X', fwavepoint7.x);
  ini.writefloat  ('WAVE', 'POINT7.Y', fwavepoint7.y);
  ini.writefloat  ('WAVE', 'POINT8.X', fwavepoint8.x);
  ini.writefloat  ('WAVE', 'POINT8.Y', fwavepoint8.y);
  ini.writefloat  ('WAVE', 'SCALE',    fwavescale);
  ini.writeinteger('WAVE', 'OFF',      fwaveoff);
  ini.destroy;
end;

end.


{
  Description: vPlot svg reader class.

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

unit vpsvgreader;

{$mode objfpc}

interface

uses
  bgrabitmap, bgrabitmaptypes, bgrasvg, bgrasvgshapes, bgrasvgtype,
  bgravectorize, classes, vpmath, vppaths, sysutils;

procedure svg2paths(const afilename: string; elements: tvpelementlist);

implementation

procedure element2paths(element: tsvgelement; elements: tvpelementlist);
var
     bmp: tbgrabitmap;
       i: longint;
    line: tvpline;
  points: arrayoftpointf;
begin
  bmp := tbgrabitmap.create;
  bmp.canvas2d.fontrenderer := tbgravectorizedfontrenderer.create;
  if (element is tsvgline      ) or
     (element is tsvgrectangle ) or
     (element is tsvgcircle    ) or
     (element is tsvgellipse   ) or
     (element is tsvgpath      ) or
     (element is tsvgtext      ) or
     (element is tsvgpolypoints) then
  begin
    element.draw(bmp.canvas2d, cucustom);
    points := bmp.canvas2d.currentpath;
    for i := 0 to system.length(points) -2 do
      if (not isemptypointf(points[i  ])) and
         (not isemptypointf(points[i+1])) then
      begin
        line.p0.x := points[i    ].x;
        line.p0.y := points[i    ].y;
        line.p1.x := points[i + 1].x;
        line.p1.y := points[i + 1].y;
        elements.add(line);
      end;
    setlength(points, 0);
  end else
  if (element is tsvggroup) then
  begin
    with tsvggroup(element).content do
      for i := 0 to elementcount -1 do
        element2paths(element[i], elements);
  end else
  if enabledebug then
    writeln(element.classname);
  bmp.destroy;
end;

procedure svg2paths(const afilename: string; elements: tvpelementlist);
var
    i: longint;
  svg: tbgrasvg;
begin
  svg := tbgrasvg.create(afilename);
  for i := 0 to svg.content.elementcount - 1 do
  begin
    element2paths(svg.content.element[i], elements);
  end;
  svg.destroy;

  elements.mirrorx;
  elements.movetoorigin;
end;

end.


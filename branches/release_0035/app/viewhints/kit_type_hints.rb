#    This file is part of Brewtools.
#
#    Brewtools is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Brewtools is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with Brewtools.  If not, see <http://www.gnu.org/licenses/>.
#
#    Copyright Chris Taylor, 2008, 2009, 2010

class KitTypeHints < Hobo::ViewHints

   field_names :ibus => "IBU"

   field_help :name => "Must be unique",
       :yeild => "% yeild of the fermentable in the designed volume",
       :ibus  => "IBU of the kit",
       :volume => "Volume of the kit (only relevant to liquid kits such as wort kits)",
       :designed_volume => "Volume that the kit is designed for to the fermenter",
       :weight => "Weight of the kit",
       :colour => "What is the colour contribution (EBC)",
       :description => "Provide a brief description"


end

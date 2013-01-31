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

class YeastTypeHints < Hobo::ViewHints

  field_help :name => "Must be unique",
  :description => "Provide a brief description",
  :min_temp => "Minimuim temperature for fermententation as recommended by the yeast manufacturer",
  :max_temp => "Maximum temperature for fermententation as recommended by the yeast manufacturer",
  :flocculation => "Describes how easily the yeast will drop out of suspension",
  :attenuation => "Typical apparent attenuation on a standard wort",
  :alcohol_tollerance => "Describes the yeasts ability to handle a high alcohol environment"

end

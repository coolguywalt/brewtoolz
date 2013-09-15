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

class HopTypeHints < Hobo::ViewHints
  field_names :aa => "AA", :hsi => "HSI"

  field_help :name => "Must be unique",
    :aa => "Hop alpha acid%, which is the main bittering component of hops",
    :beta => "Hop beta acid%, can contribute to bittering but only when oxidized.",
    :hsi => "Hop stability index, percentage of the alpha acids present after 6 months at 20C",
    :humulene => "Hop humulene level%",
    :caryophllene => "Hop caryophllene level%",
    :cohumulone => "Hop cohumulone level%",
    :myrcene => "Hop myrcene level%",
    :description => "Provide a brief description"

end

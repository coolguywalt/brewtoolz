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

module RecipeCalcs
  
  def calc_abv( og, fg )
    return 0.0 if nil == og || nil == fg
    
    return ( (og-fg)/7.46)
  end
  
  def calc_attenuation(og,fg)
    return 0.0 if nil == og || nil == fg
    
    return ((og-fg)/og)
  end
  
  def calc_rte( og, fg )
    return 0.0 if ( nil==og || nil==fg ) #precondition
    
    rte = 0.82*fg + 0.18*og
    return rte
  end
  
  
  def calc_balance( og, fg, ibu )
    return 0.0 if nil == og || nil == fg || nil == ibu
    
    balance_value = (0.8 * ibu)/calc_rte( og, fg ) 
    return balance_value
  end

  def adjust_for_temp( volume, t2, t1=21.0 )

    v2 = volume * density_h2o(t1)/density_h2o(t2)

    logger.debug "volume: #{volume}, v2: #{v2} "

    return v2
  end

  def density_h2o( temp )
    rho = 1000*(1.0-(temp+288.9414)/(508929.2*(temp+68.12963))*((temp-3.9863)**2))
    return rho
  end

  def pitching_rate( og, volume )
   yeast_cells = 0.75 * (volume * 1000) * (og/4.0) * 1000000
   return yeast_cells
  end

end

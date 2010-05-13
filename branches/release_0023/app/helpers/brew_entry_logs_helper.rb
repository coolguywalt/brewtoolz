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

module BrewEntryLogsHelper

	def brew_entry_summary( brew_entry_log )
		summary = ""
		summary += "<b>Rating:</b> " + brew_entry_log.rating.to_s + "<br/>Age at tasting:</b> " + age_str(brew_entry_log) if brew_entry_log.istasting
		if brew_entry_log.isobservation
			unless brew_entry_log.specific_gravity == nil
				summary += "<b>Gravity reading[" + gravity_unit() +"]:</b> " + gravity_value( brew_entry_log.specific_gravity )
				summary += ", <b>Temp[" + temp_units() +"]:</b> " + temp_values( brew_entry_log.temperature ) if brew_entry_log.temperature != nil
				summary += ", <b>Atten:</b> " + number_to_percentage(brew_entry_log.attenuation*100, :precision => 2)
				summary += ", <b>ABV:</b> " +  number_to_percentage( brew_entry_log.abv, :precision => 2)
			end
		end
    	return summary
	end
	
	def age_str( brew_entry_log)
		return "n/a" unless brew_entry_log.brew_entry.bottled_kegged
		distance_of_time_in_words(brew_entry_log.brew_entry.bottled_kegged, brew_entry_log.log_date.to_date )
	end

	def brewlogentry_for( brew_entry_log )
		url_for( brew_entry_log.brew_entry )
	end
end

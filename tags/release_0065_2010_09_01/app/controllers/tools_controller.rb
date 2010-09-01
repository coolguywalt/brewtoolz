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

class ToolsController < ApplicationController

	hobo_controller
  include RecipeCalcs

	def index


	end

	def refractometer_correction
		refract_reading_points = ""
		refract_reading_p = ""
		begin
      og = Float(BrewingUnits::input_gravity( params[:OG], current_user.units.gravity ))

			logger.debug "Og: #{og}"

			refract_reading_points = BrewingUnits::refractomer_to_points(params[:refract_reading],og)

			refract_reading_p = BrewingUnits::to_p(refract_reading_points)

			#refract_reading =  gravity_values(refract_reading_points, current_user)

			refract_reading_p =  "%01.2f" % refract_reading_p

			logger.debug "Refract corrected reading: #{refract_reading_points}"
		rescue
      flash_error_update("All input values must be numeric")
      return
		end
		# @refract_reading = "bob"

    auser = current_user
		respond_to do |format|
			format.html
			format.js {
				render :update do |page|
					page["refract_value_sg"].update( gravity_values(refract_reading_points, auser))
					page["refract_value_p"].update(refract_reading_p)
          page.hide 'tools_errors_div'
				end
			}
		end
	end

  def yeast_pitch
		yeast_pitching_rate = 0.0
		begin

      og = Float(BrewingUnits::input_gravity( params[:OG], current_user.units.gravity ))
			#og = (Float(params[:OG]) - 1.0)*1000.0
			logger.debug "Og: #{og}"

			yeast_type = params[:ferment_type]
			logger.debug "Yeast type: #{yeast_type}"

      volume = Float(BrewingUnits::input_recipe_vol( params[:volume], current_user.units.volume ))
			logger.debug "Volume: #{volume}"

      modifier = 1.0
      if( yeast_type ) then
        modifier = 2.0 if (yeast_type.downcase =~ /lager/)   # lager beers
        modifier = 1.5 if (yeast_type.downcase =~ /hybrid/)  # kolsch
      end

      # Calc for ale pitching rates
      yeast_pitching_rate = pitching_rate(og, volume) * modifier
    rescue
      flash_error_update("All input values must be numeric")
      return
    end

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html 'yeast_pitch_results_div', :partial => 'yeast_pitch_results', :object => yeast_pitching_rate
          page.hide 'tools_errors_div'
        end
      }
    end
  end


  def dilution_update

    logger.debug "Current user: #{current_user}"
    logger.debug "Flash #{flash}"

    #TODO: error/range checking on input values
    begin
      wort_sg = Float(BrewingUnits::input_gravity( params[:wort_sg], current_user.units.gravity ))
    
      wort_volume = Float(BrewingUnits::input_recipe_vol( params[:wort_volume], current_user.units.volume ))
    
      dil_sg =  params[:dil_sg]
      if (dil_sg.nil? or dil_sg.empty?)
        dil_sg = 0.0
      else
        dil_sg = Float(BrewingUnits::input_gravity( params[:dil_sg], current_user.units.gravity ))
      end

      dil_volume = Float(BrewingUnits::input_recipe_vol( params[:dil_volume], current_user.units.volume ))
    rescue
      flash_error_update("All input values must be numeric")
      return
    end

    new_vol = wort_volume + dil_volume
    new_sg = (wort_sg * wort_volume + dil_sg * dil_volume) / new_vol

    auser=current_user

    respond_to do |format|
			format.html
			format.js {
				render :update do |page|
					page["diluted_sg_value"].update(gravity_values(new_sg, auser))
					page["diluted_volume_value"].update(volume_values(new_vol, auser))
          page.hide 'tools_errors_div'
				end
			}
		end

  end

  def dilution_required_update
    begin
      wort_sg = Float(BrewingUnits::input_gravity( params[:wort_sg], current_user.units.gravity ))

      wort_volume = Float(BrewingUnits::input_recipe_vol( params[:wort_volume], current_user.units.volume ))

      dil_sg =  params[:dil_sg]
      if (dil_sg.nil? or dil_sg.empty?)
        dil_sg = 0.0
      else
        dil_sg = Float(BrewingUnits::input_gravity( params[:dil_sg], current_user.units.gravity ))
      end

      req_gravity =  Float(BrewingUnits::input_gravity( params[:req_gravity], current_user.units.gravity ))

    rescue
      flash_error_update("All input values must be numeric")
      return
    end


    if dil_sg == req_gravity then #Check for corner case.
      vol_req = 0.0
    else
      vol_req = (wort_volume*(wort_sg - req_gravity)) / (req_gravity-dil_sg)
    end

    #Another corner case where negative value, and dil_sg >0 ... should ignore the dil_sg in this case and recalculate.
    # ie cant evapourate off wort with a certian sg, only water
    if dil_sg > 0 and vol_req < 0
      vol_req = (wort_volume*(wort_sg - req_gravity)) / req_gravity
    end

    new_vol = wort_volume + vol_req

    auser=current_user

    respond_to do |format|
			format.html
			format.js {
				render :update do |page|
					page["diluted_volume_addition_value"].update(volume_values(vol_req, auser))
					page["diluted_volume_total_value"].update(volume_values(new_vol, auser))
          page.hide 'tools_errors_div'
				end
			}
		end
  end



  protected
  def flash_error_update( message )
    #Update flash and exit
    flash.now[:error] = message

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.show 'tools_errors_div'
          page.replace_html 'tools_errors_div', :inline => %{ <div class="flash error"><%=  flash[:error] %><div> }
        end
      }

    end
  end
end

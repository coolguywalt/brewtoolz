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
#    Copyright Chris Taylor, 2008, 2009, 2010, 2013

class InventoriesController < ApplicationController
    hobo_controller
    include RecipesHelper
    include ApplicationHelper

    def index

    end

    def remove_item
        invent_type_txt = params[:type]
        invent_prefix = invent_type_txt.gsub(/Inventory/, '')

        theItem = Object.const_get(invent_type_txt).find(params[:id])
        if !theItem.updatable_by?(current_user)  || !request.xhr?
            notifyattempt(request, "InventoriesController.remove_item not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @inventory_item = Object.const_get(invent_type_txt).delete(params[:id])

        unless @inventory_item.nil? then
            render(:update) { |page|
                page.replace_html invent_type_txt + '_div', :partial => 'inventory_sub_page', 
                    :locals => { :item_type => invent_prefix.downcase }
            }
        else
            render(:update) { |page|
                page.replace_html 'errors_div', :partial => 'errors'
            }
        end
    end

    def add_item
        item_type_txt = params[:item_type]
        invent_type_txt = params[:invent_type]

        #Get item list
        invent_prefix = invent_type_txt.gsub(/Inventory/, '')
        user_items = current_user.send("#{invent_prefix.downcase}_inventories")

        item = Object.const_get(item_type_txt).find(params[:item_id])

        if item_type_txt == "HopType" then
            @inventory_item = user_items.create( :source_date => Time.now, :amount => 50, :balance => 50, "#{invent_prefix.singularize.downcase}_type" => item,
                                                :aa => item.aa )
        elsif item_type_txt == "FermentableType" then
            @inventory_item = user_items.create( :source_date => Time.now, :amount => 500, :balance => 500, "#{invent_prefix.singularize.downcase}_type" => item )
        else
            @inventory_item = user_items.create( :source_date => Time.now, :amount => 1, :balance => 1, "#{invent_prefix.singularize.downcase}_type" => item )
        end
        
        @inventory_item.save

        unless @inventory_item.nil? then
            render(:update) { |page|
                page.replace_html invent_type_txt + '_div', :partial => 'inventory_sub_page', 
                    :locals => { :item_type => invent_prefix.downcase }
            }
        else
            render(:update) { |page|
                page.replace_html 'errors_div', :partial => 'errors'
            }
        end
    end

    def update
        # Check permissions
        if current_user.guest? || !request.xhr?
            #      flash[:error] = "Update fermentable - permission denied."
            #      update_details_and_fermentables( @recipe )
            notifyattempt(request, "InventoriesController.update not from authorized user: #{current_user}")

            render( :nothing => true )
            return
        end

        # Convert units
        if params[:fermentable_inventory] then
            type = "fermentable"
            params[:fermentable_inventory][:balance] = 
                BrewingUnits::value_for_storage( current_user.units.send(type), 
                                                params[:fermentable_inventory][:balance] ) if params[:fermentable_inventory][:balance] 
        end

        if params[:hops_inventory] then
            type = "hops"
            params[:hops_inventory][:balance] = 
                BrewingUnits::value_for_storage( current_user.units.send(type), 
                                                params[:hops_inventory][:balance] ) if params[:hops_inventory][:balance] 
        end
        type = "yeast" if params[:yeast_inventory] 
        type = "kit" if params[:kit_inventory] 

        inventory_txt = "#{type}_inventories"
        inventory_sym = "#{type}_inventory".to_sym

        #Update values and write to the database
        @inventory_item =  current_user.send(inventory_txt).find(params[:id])
        
        logger.debug "++inventories controller update:  @inventory_item: #{@inventory_item}"
        logger.debug "++inventories controller update:  @inventory_item.balance: #{@inventory_item.balance}"
        logger.debug "++inventories controller update:  @inventory_item: #{@inventory_item}"
        logger.debug "++inventories controller update: inventory_sym: #{inventory_sym}"
        logger.debug "++inventories controller update: params[inventory_sym]: #{params[inventory_sym]}"

        is_valid = false
        if @inventory_item.update_attributes(params[inventory_sym]) then
            logger.debug "++inventories controller update: update_attributes passed"
            logger.debug "++inventories controller update:  @inventory_item.balance: #{@inventory_item.balance}"
            is_valid = @inventory_item.save
            logger.debug "++inventories controller update: is_valid: #{is_valid}" 
        end    

        logger.debug "++inventories controller update:  @inventory_item.balance: #{@inventory_item.balance}"
        
        invent_type_txt = type.capitalize + "Inventory"
        if is_valid then
            render(:update) { |page|
                page.replace_html invent_type_txt + '_div', :partial => 'inventory_sub_page', 
                    :locals => { :item_type => type }
                page.replace_html 'errors_div', :partial => 'errors'
            }
        else
            render(:update) { |page|
                page.replace_html 'errors_div', :partial => 'errors'
            }

        end
    end

    def loadhopstab
        render :partial => 'hops_inventory'
    end

    def loadkitstab
        render :partial => 'kits_inventory'
    end

    def loadyeasttab
        render  :partial => 'yeast_inventory'
    end

    def loadplanningtab
        render  :partial => 'planning'
    end

    def changeplanningdaterange
        @monthrange = params[:monthrange]
        
        render(:update) { |page|
            page.replace_html "inventplanningdetails", :partial => "inventory_planning_details"
        }

    end
end

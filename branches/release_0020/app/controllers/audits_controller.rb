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


class AuditsController < ApplicationController

  hobo_model_controller

  include AuditsHelper

  

  def index

    unless current_user.administrator?
      render( :nothing => true )
      return
    end

    @this = audit_log_list_filter_out_test()

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "results" block...works for this example
          # 'page.replace_html' will replace "results" inner html...useful elsewhere
          page.replace 'audit_list_div', :partial => 'audit_list', :object => @this
        end


      }
    end

  end

  def user_history

    unless current_user.administrator?
      render( :nothing => true )
      return
    end
    @this = audit_log_list_user( params[:user_id] )

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "results" block...works for this example
          # 'page.replace_html' will replace "results" inner html...useful elsewhere
          page.replace 'audit_list_div', :partial => 'audit_list_user', :object => @this
        end

      }
    end

  end

  def ipaddress_history

    unless current_user.administrator?
      render( :nothing => true )
      return
    end
    
    @this = audit_log_list_ipaddress( params[:ipaddress] )

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "results" block...works for this example
          # 'page.replace_html' will replace "results" inner html...useful elsewhere
          page.replace 'audit_list_div', :partial => 'audit_list_ipaddress', :object => @this
        end

      }
    end

  end

  def top_users
    unless current_user.administrator?
      render( :nothing => true )
      return
    end

    @this = audit_log_list_top_users( )

    #render  :partial => 'audit_top_users', :object => @this
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "results" block...works for this example
          # 'page.replace_html' will replace "results" inner html...useful elsewhere
          page.replace 'audit_list_div', :partial => 'audit_top_users', :object => @this
        end
      }
    end

  

  end

  def top_ipaddress
    unless current_user.administrator?
      render( :nothing => true )
      return
    end

    @this = audit_log_list_top_ipaddress( )

    #render  :partial => 'audit_top_ip_address', :object => @this


    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "results" block...works for this example
          # 'page.replace_html' will replace "results" inner html...useful elsewhere
          page.replace 'audit_list_div', :partial => 'audit_top_ip_address', :object => @this
        end

      }
    end

  end

   def new_users
    unless current_user.administrator?
      render( :nothing => true )
      return
    end

    @this = audit_log_list_new_users( )

    #render  :partial => 'audit_top_ip_address', :object => @this


    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "results" block...works for this example
          # 'page.replace_html' will replace "results" inner html...useful elsewhere
          page.replace 'audit_list_div', :partial => 'audit_new_users', :object => @this
        end

      }
    end

  end


end

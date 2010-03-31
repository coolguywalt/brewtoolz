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


module AppSecurity
  def notifyattempt( request, message )
    message = "Security warning: #{message}"
    message = "#{message}: ip_addr: #{request.remote_ip} url: #{request.url} is ajax?: #{request.xhr?}" if request
    logger.warn message
  end

  def audit_log( request, user )

    return if request.remote_ip == "66.154.123.72" # Dont bother logging the monit html pings

    Audit.new do |al|

      if user
        unless user.guest?
          al.user = user
          al.username = user.name
        else
          al.username = "guest"
        end
      else
        al.user = "none"
      end
      
      al.ajax = request.xhr?
      al.url = request.url
       
      al.ipaddress = request.remote_ip

      al.params = request.params unless (request.url.include?("login") || request.url.include?("signup"))

      al.save
    end
  end
end

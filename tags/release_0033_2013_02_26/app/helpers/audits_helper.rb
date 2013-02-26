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

module AuditsHelper

  def audit_log_list
    Audit.paginate( :page => params[:page],
		  :per_page => 40, :order => "created_at DESC" )
  end

  def audit_log_list_filter_out_test
    Audit.paginate( :page => params[:page],
		  :per_page => 40,
      :order => "created_at DESC",
      :conditions => "ipaddress != '66.154.123.72'" )
  end

  def audit_log_list_user(user_id)

    condition = ""
    if user_id
      condition = "ipaddress != '66.154.123.72' AND user_id = #{user_id}"
    else
      condition = "ipaddress != '66.154.123.72' AND user_id IS NULL"
    end

    Audit.paginate( :page => params[:page],
		  :per_page => 40,
      :order => "created_at DESC",
      :conditions => condition )
  end

  def audit_log_list_ipaddress(ipaddress)

    Audit.paginate( :page => params[:page],
		  :per_page => 40,
      :order => "created_at DESC",
      :conditions => "ipaddress = '#{ipaddress}'" )
  end


  def audit_log_list_top_users()
    Audit.paginate_by_sql( ['SELECT username, user_id, count(*) as entries FROM `audits` group by username order by entries desc'],
      :page => params[:page],
      :per_page => 40)
  end

  def last_active( user_id )

    @record = Audit.find_by_user_id(user_id, :first, :order => "created_at DESC")

  end

  def audit_log_list_top_ipaddress()
    Audit.paginate_by_sql( ['SELECT ipaddress, count(*) as entries FROM `audits` group by ipaddress order by entries desc'],
      :page => params[:page],
      :per_page => 40)
  end

  def last_active_by_ip( ip )

    @record = Audit.find_by_ipaddress(ip, :first, :order => "created_at DESC")

  end


  def audit_log_list_new_users()

    Audit.paginate_by_sql( ['SELECT username, user_id, created_at  FROM `audits` GROUP BY username ORDER BY created_at DESC'],
      :page => params[:page],
      :per_page => 40)
  end

end

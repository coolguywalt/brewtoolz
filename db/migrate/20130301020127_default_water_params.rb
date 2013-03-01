class DefaultWaterParams < ActiveRecord::Migration
	DEFAULT_BREWERY = {
		:capacity => 23.0,
		:efficency => 75.0,
		
		:liquor_to_grist => 3.0,
		:boil_time => 60,
		:mash_tun_capacity => 44.0,
		:mash_tun_deadspace => 2.0,

		:evapouration_rate => 4.0,

                :bicarbonate => 292.0,
              	:calcium => 80.0,
               	:carbonate => 0.0,
               	:chloride => 118.0,
               	:fluoride => 0.0,
               	:iron => 0.0,
               	:magnesium => 31.0,
               	:nitrate => 16.4,
               	:nitrite => 0.0,
               	:pH => 7.0,
               	:potassium => 6.0,
               	:sodium => 86.0,
               	:sulfate => 96.0,
               	:total_alkalinity => 239.0
	}
  def self.up
	  Brewery.update_all( DEFAULT_BREWERY );
  end

  def self.down
  end
end

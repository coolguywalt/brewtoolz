# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

class MemoryProfiler
  DEFAULTS = {:delay => 10, :string_debug => false}

  def self.start(opt={})
    opt = DEFAULTS.dup.merge(opt)

    Thread.new do
      prev = Hash.new(0)
      curr = Hash.new(0)
      curr_strings = []
      delta = Hash.new(0)

      file = File.open('log/memory_profiler.log','w')

      loop do
        begin
          GC.start
          curr.clear

          curr_strings = [] if opt[:string_debug]

          ObjectSpace.each_object do |o|
            curr[o.class] += 1 #Marshal.dump(o).size rescue 1
            if opt[:string_debug] and o.class == String
              curr_strings.push o
            end
          end

          if opt[:string_debug]
            File.open("log/memory_profiler_strings.log.#{Time.now.to_i}",'w') do |f|
              curr_strings.sort.each do |s|
                f.puts s
              end
            end
            curr_strings.clear
          end

          delta.clear
          (curr.keys + delta.keys).uniq.each do |k,v|
            delta[k] = curr[k]-prev[k]
          end

          file.puts "Top 20"
          delta.sort_by { |k,v| -v.abs }[0..19].sort_by { |k,v| -v}.each do |k,v|
            file.printf "%+5d: %s (%d)\n", v, k.name, curr[k] unless v == 0
          end
          file.flush

          delta.clear
          prev.clear
          prev.update curr
          GC.start
        rescue Exception => err
          STDERR.puts "** memory_profiler error: #{err}"
        end
        sleep opt[:delay]
      end
    end
  end
end




Rails::Initializer.run do |config|
  config.gem 'hobo'
  config.gem 'hobosupport'
  config.gem 'hobofields'
  config.gem 'calendar_date_select'

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
#  config.plugins = [:hobo_support, :hobo, :all]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # MemoryProfiler.start
end



require 'apidoco_dsl'
require 'rails'

module ApidocoDsl
  class Railtie < Rails::Railtie
    railtie_name :apidoco_dsl

    rake_tasks do
      path = File.expand_path(__dir__ + '/../')
      Dir.glob("#{path}/tasks/**/*.rake").each{|t| load t }
    end
  end
end


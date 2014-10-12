require 'optparse'

module StartupsByCity
  module Options
    class << self
      def parse
        options = {}

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: generate.rb [options]"

          opts.on('-g', '--google-analytics CODE', 'Specify Google Analytics tracking code') do |code|
            options[:google_analytics] = code
          end

          opts.on('-e', '--use-existing', 'Use most recent CrunchBase CSV in data directory, if it exists') do
            options[:data_file_method] = :use_existing
          end

          opts.on('-d', '--download', 'Download the latest CrunchBase CSV') do
            options[:data_file_method] = :download
          end

          opts.on('-h', '--help', 'Display this screen') do
            puts opts
            exit
          end
        end
        opt_parser.parse!

        options
      end
    end
  end
end

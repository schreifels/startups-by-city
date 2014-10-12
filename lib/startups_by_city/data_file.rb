require 'tmpdir'

module StartupsByCity
  module DataFile
    class << self
      def get_path(method)
        `mkdir -p #{File.join(BASE_PATH, 'data')}`
        data_file = Dir[File.join(BASE_PATH, 'data', 'crunchbase_*.csv')].last

        if method == :download || !data_file
          fetch
        elsif method == :use_existing
          data_file
        else
          prompt_with_data_file(data_file)
        end
      end

      private

      def prompt_with_data_file(data_file)
        puts
        puts "Would you like to (enter 1 or 2):"
        puts "  1.) Use #{data_file.sub(BASE_PATH + File::SEPARATOR, '')}"
        puts "  2.) Download the latest data"

        response = gets.chomp

        if response == '1'
          data_file
        elsif response == '2'
          fetch
        else
          prompt_with_data_file(data_file)
        end
      end

      def fetch
        puts
        puts 'Fetching latest data...'
        puts

        Dir.mktmpdir('StartupsByCity') do |tmpdir|
          archive_path = File.join(tmpdir, 'crunchbase.tar.gz')
          `curl http://static.crunchbase.com/exports/crunchbase_odm_csv.tar.gz -o #{archive_path}`
          `tar -xf #{archive_path} -C #{tmpdir} organizations.csv`
          destination_path = File.join(BASE_PATH, 'data', "crunchbase_#{Time.now.strftime('%Y-%m-%d')}.csv")
          `mv #{File.join(tmpdir, 'organizations.csv')} #{destination_path}`
          destination_path
        end
      end
    end
  end
end

module StartupsByCity
  class SourceFile
    class << self
      def fetch
        puts
        puts 'Fetching latest data...'
        puts

        filename = "source/crunchbase_#{Time.now.strftime('%Y-%m-%d')}.csv.tar.gz"
        `curl http://static.crunchbase.com/exports/crunchbase_odm_csv.tar.gz -o #{filename}`
        `tar -xf #{filename} -C source organizations.csv`
        csv_filename = filename.chomp('.tar.gz')
        `mv source/organizations.csv #{csv_filename}`
        `rm #{filename}`

        csv_filename
      end
    end

    def initialize
      @source_file = Dir['source/crunchbase_*.csv'].last
      @source_file ? prompt_with_source_file : self.class.fetch
    end

    private

    def prompt_with_source_file
      puts
      puts 'Would you like to (enter 1 or 2):'
      puts "  1.) Use #{@source_file}"
      puts "  2.) Download the latest"

      response = gets.chomp

      if response == '1'
        @source_file
      elsif response == '2'
        self.class.fetch
      else
        prompt_with_source_file
      end
    end
  end
end

require 'csv'

module StartupsByCity
  module Collection
    class << self
      def build(data_file)
        puts
        puts 'Indexing data...'

        #
        # Initial format:
        #
        #   {
        #     'USA' => {
        #       'CA' => {
        #         'San Francisco' => [startup1, startup2, ...],
        #         'Palo Alto'     => [startup1, startup2, ...]
        #       }
        #     }
        #   }
        #
        # After all the data has been collected, it will be transformed into:
        #
        #   {
        #     'USA' => {
        #       'CA' => [
        #         { name: 'San Francisco', startups: [startup1, startup2, ...], startups_count: 50 },
        #         { name: 'Palo Alto',     startups: [startup1, startup2, ...], startups_count: 10 }
        #       ]
        #     }
        #   }
        #
        # where cities are ordered by startups_count.
        #
        collection = {}

        indexed = 0
        skipped = 0
        CSV.foreach(data_file, headers: true) do |row|
          indexed += 1
          puts "  Indexed #{indexed} startups" if indexed % 10000 == 0

          if row['location_country_code'].nil? || row['location_region'].nil? || row['location_city'].nil?
            skipped += 1
            next
          end

          collection[row['location_country_code']] ||= {}
          collection[row['location_country_code']][row['location_region']] ||= {}
          collection[row['location_country_code']][row['location_region']][row['location_city']] ||= []
          collection[row['location_country_code']][row['location_region']][row['location_city']] <<
            row.to_hash.select { |k, v| ['name', 'short_description', 'homepage_url', 'crunchbase_url'].include?(k) }
        end

        puts "Skipped #{skipped} records with incomplete location data"

        puts
        puts 'Cleansing data...'

        filtered = 0
        collection.each do |country, regions|
          regions.each do |region, cities|
            # Transform cities hash into an ordered array for easier rendering
            cities_array = []

            cities.each do |city, startups|
              startups_count = startups.count
              if startups_count < 10
                filtered += 1
              else
                cities_array << { name: city, startups: startups, startups_count: startups_count }
              end
            end

            if cities_array.empty?
              collection[country].delete(region)
            else
              # sort_by.reverse is faster than negating startups_count in sort_by
              collection[country][region] = cities_array.sort_by { |city| city[:startups_count] }.reverse
            end
          end

          collection.delete(country) if collection[country].empty?
        end

        puts "Filtered out #{filtered} cities with less than 10 startups"

        collection
      end
    end
  end
end

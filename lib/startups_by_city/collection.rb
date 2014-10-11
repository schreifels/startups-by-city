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

          collection[encode(row['location_country_code'])] ||= {}
          collection[encode(row['location_country_code'])][encode(row['location_region'])] ||= {}
          collection[encode(row['location_country_code'])][encode(row['location_region'])][encode(row['location_city'])] ||= []
          collection[encode(row['location_country_code'])][encode(row['location_region'])][encode(row['location_city'])] <<
            Hash[*row.to_hash.map do |k, v|
              if v && ['name', 'short_description', 'homepage_url', 'crunchbase_url'].include?(k)
                [encode(k), encode(v)]
              end
            end.compact.flatten]
        end

        puts "Skipped #{skipped} records with incomplete location data"

        puts
        puts 'Restructuring data...'

        #
        # Transform collection into:
        #
        #   [
        #     { name: 'USA', startups_count: 100, regions: [
        #       { name: 'CA', sartups_count: 60, cities: [
        #         { name: 'San Francisco', startups_count: 50, startups: [startup1, startup2, ...] },
        #         { name: 'Palo Alto',     startups_count: 10, startups: [startup1, startup2, ...] }
        #       ]}
        #     ]}
        #   ]
        #
        # where each tier is sorted by startups_count.
        #
        cities_filtered = 0
        collection = collection.map do |country, regions|
          country_startups_count = 0
          country = {
            name: country,
            regions: regions.map do |region, cities|
              region_startups_count = 0
              region = {
                name: region,
                cities: cities.map do |city, startups|
                  city_startups_count = startups.count
                  if city_startups_count < 10
                    cities_filtered += 1
                    nil
                  else
                    region_startups_count += city_startups_count
                    { name: city, startups: startups, startups_count: city_startups_count }
                  end
                end.compact.sort_by { |city| city[:startups_count] }.reverse,
                startups_count: region_startups_count
              }
              if region[:cities].empty?
                nil
              else
                country_startups_count += region_startups_count
                region
              end
            end.compact.sort_by { |region| region[:startups_count] }.reverse,
            startups_count: country_startups_count
          }
          country[:regions].empty? ? nil : country
        end.compact.sort_by { |country| country[:startups_count] }.reverse

        puts "Filtered out #{cities_filtered} cities with less than 10 startups"

        collection
      end

      private

      # The CSV claims to be UTF-8, but it wasn't encoded properly
      def encode(str)
        encode_options = { invalid: :replace, undef: :replace, replace: '' }
        str.encode('Windows-1252', encode_options).force_encoding('UTF-8').
            encode('UTF-8', encode_options) # remove any remaining unsupported characters
      end
    end
  end
end

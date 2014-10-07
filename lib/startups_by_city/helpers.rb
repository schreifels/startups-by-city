module StartupsByCity
  module Helpers
    def to_path(country, state, city)
      "#{city} #{state} #{country}".downcase.gsub(/\W+/, '-') + '.html'
    end
  end
end

module Cigarillo
  module Utils
    module Words
      def distance_of_time_in_words(from_time, to_time = nil)
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time   ||= Time.at(0)
        to_time   = to_time.to_time if to_time.respond_to?(:to_time)

        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        case distance_in_minutes
        when 0..1
          distance_in_minutes == 0 ? "less than a minute" : "#{distance_in_minutes} minutes"

        when 2..44           then "#{distance_in_minutes} minutes"
        when 45..89          then "about an hour"
        when 90..1439        then "about about #{(distance_in_minutes.to_f / 60.0).round} hours"
        when 1440..2529      then "about a day"
        when 2530..43199     then "about #{(distance_in_minutes.to_f / 1440.0).round} days"
        when 43200..86399    then "about a month"
        when 86400..525599   then "about #{(distance_in_minutes.to_f / 43200.0).round} months"
        else
          #distance_in_years           = distance_in_minutes / 525600
          #minute_offset_for_leap_year = (distance_in_years / 4) * 1440
          #remainder                   = ((distance_in_minutes - minute_offset_for_leap_year) % 525600)
          #if remainder < 131400
            #locale.t(:about_x_years,  :count => distance_in_years)
          #elsif remainder < 394200
            #locale.t(:over_x_years,   :count => distance_in_years)
          #else
            #locale.t(:almost_x_years, :count => distance_in_years + 1)
          #end
          "a long time"
        end
      end
      module_function :distance_of_time_in_words
    end
  end
end

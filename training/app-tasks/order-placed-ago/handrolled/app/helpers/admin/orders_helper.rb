module Admin
  module OrdersHelper
    def placed_ago(time)
      minutes = ((Time.current - time) / 60.0).round
      words =
        if minutes < 1 then "less than a minute"
        elsif minutes < 45 then "#{minutes} #{"minute".pluralize(minutes)}"
        elsif minutes < 90 then "about 1 hour"
        elsif minutes < 1440 then "about #{(minutes / 60.0).round} hours"
        elsif minutes < 2520 then "1 day"
        else
          days = (minutes / 1440.0).round
          "#{days} #{"day".pluralize(days)}"
        end
      "#{words} ago"
    end
  end
end

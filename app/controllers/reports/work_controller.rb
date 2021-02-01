class Reports::WorkController < Reports::BaseController

  authorize_resource class: false

  def show
    today = Date.today

    @original_range = if @month
               UberZeit.month_as_range(@year, @month)
             else
               UberZeit.year_as_range(@year)
             end

    @range =
      case
      when today.month == @month && today.year == @year
        @display_overtime_total = true
        if today.day == 1
          Date.new(@year, @month)..today
        else
          Date.new(@year, @month)...today
        end
      when @year == today.year && !@month
        @display_overtime_total = true
        Date.new(@year)...today
      when @month
        UberZeit.month_as_range(@year, @month)
      else
        UberZeit.year_as_range(@year)
      end
    @range_of_year_till_yesterday = Date.yesterday.at_beginning_of_year..Date.yesterday

    render :table
  end
end

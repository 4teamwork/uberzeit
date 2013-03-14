class TimersController < ApplicationController
  load_and_authorize_resource :time_sheet
  authorize_resource :timer, through: :time_sheet

  def new
  end

  def edit
    @timer = Timer.find(params[:id])
    @time_types = TimeType.find_all_by_is_work(true)

    render 'edit', layout: false
  end

  def update
    @timer = Timer.find(params[:id])

    if params[:time_entry][:to_time].blank?
      @timer.update_attributes(params[:timer].except(:to_time))
    else
      @timer.stop
    end
    # if @time_entry.update_attributes(params[:time_entry])
    #   redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
    # else
    #   render :action => 'edit'
    # end
    render json: {}
  end
end

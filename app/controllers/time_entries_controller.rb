class TimeEntriesController < ApplicationController
  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :time_entry, through: :time_sheet

  def new
    @time_entry.build_recurring_schedule
  end

  def edit
    @time_entry.build_recurring_schedule if @time_entry.recurring_schedule.nil?
  end

  def create
    @time_types = TimeType.find_all_by_is_work(true)

    if @time_entry.save
      redirect_to @time_sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    if @time_entry.update_attributes(params[:time_entry])
      redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @time_entry.destroy
      redirect_to @time_sheet, :notice => 'Entry was successfully deleted.'
    else
      render :action => 'edit'
    end
  end
end

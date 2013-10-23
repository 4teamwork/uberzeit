class UsersController < ApplicationController

  load_and_authorize_resource

  def index
    authorize! :manage, User
  end

  def new
  end

  def show
    redirect_to user_employments_path(@user), flash: flash
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to users_path, flash: {success: t('model_successfully_updated', model: User.model_name.human)}
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, flash: {success: t('model_successfully_deleted', model: User.model_name.human)}
  end
end

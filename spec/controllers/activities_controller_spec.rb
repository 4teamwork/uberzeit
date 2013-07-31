require 'spec_helper'

describe ActivitiesController do
  render_views

  let(:user) { FactoryGirl.create(:user) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index, user_id: user.id
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in user
    end

    describe 'GET "index"' do
      it 'renders the :index template' do
        get :index, user_id: user.id
        response.should render_template :index
      end
    end

    describe 'GET "new"' do
      it 'renders the :new template' do
        get :new, user_id: user.id
        response.should render_template :new
      end
    end

    describe 'GET "edit"' do
      context 'with an existing activitiy' do
        let!(:activity) { FactoryGirl.create(:activity, user: user) }

        it 'renders the :edit template' do
          get :edit, user_id: user.id, id: activity
          response.should render_template :edit
        end
      end

      context 'without an existing activitiy' do
        it 'raises an error' do
          lambda do
            get :edit, user_id: user.id, id: 'one does not simply edit a not-existing activity'
          end.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe 'POST "update"' do
      let!(:activity) { FactoryGirl.create(:activity, user: user) }
      let(:customer) { FactoryGirl.create :customer }
      let(:activity_type) { FactoryGirl.create :activity_type }
      let(:date) { '1993-05-01' }

      context 'with valid parameters' do
        let(:params_activity) do
          {
            customer_id: customer.id,
            activity_type_id: activity_type.id,
            date: date,
            duration: '00:20'
          }
        end

        let(:params) do
          {
            user_id: user.id,
            id: activity.id,
            activity: params_activity
          }
        end

        it 'redirects back' do
          post :update, params
          response.should redirect_to(show_date_user_activities_path(user, date: date))
        end

        it 'changes the attributes' do
          post :update, params
          activity.reload
          activity.customer_id.should == customer.id
          activity.activity_type_id.should == activity_type.id
          activity.duration.should == 1200
        end
      end
    end

    describe 'PUT "create"' do
      let(:customer) { FactoryGirl.create :customer }
      let(:activity_type) { FactoryGirl.create :activity_type }
      let(:date) { '1993-05-01' }

      context 'with valid parameters' do
        let(:params_activity) do
          {
            customer_id: customer.id,
            activity_type_id: activity_type.id,
            date: date,
            duration: '00:20'
          }
        end

        let(:params) do
          {
            user_id: user.id,
            activity: params_activity
          }
        end

        it 'redirects back' do
          put :create, params
          response.should redirect_to(show_date_user_activities_path(user, date: date))
        end

        it 'creates an activity' do
          lambda do
            put :create, params
          end.should change(Activity, :count).by(1)
        end
      end
    end

    describe 'DELETE "destroy"' do
      context 'with an existing activitiy' do
        let(:date) { '1997-01-07' }
        let!(:activity) { FactoryGirl.create(:activity, user: user, date: date) }

        it 'deletes the activity' do
          lambda do
            delete :destroy, user_id: user.id, id: activity.id
          end.should change(Activity, :count).by(-1)
        end

        it 'redirects back' do
          delete :destroy, user_id: user.id, id: activity.id
          response.should redirect_to(show_date_user_activities_path(user, date: date))
        end
      end

      context 'without an existing activitiy' do
        it 'raises an error' do
          lambda do
            delete :destroy, user_id: user.id, id: 'abc'
          end.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

end
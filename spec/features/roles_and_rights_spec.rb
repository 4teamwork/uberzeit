require 'spec_helper'

describe 'Roles and Rights' do
  include RequestHelpers

  let(:year) { Date.current.year }
  let(:month) { Date.current.month }

  def should_have_access_to(path)
    expect { visit path }.to_not raise_error(CanCan::AccessDenied)
  end

  def should_not_have_access_to(path)
    expect { visit path }.to raise_error(CanCan::AccessDenied)
  end

  context 'role: user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }

    before do
      login(user)
    end

    context 'access' do
      describe 'time sheets' do
        it 'has access to own time sheet' do
          should_have_access_to time_sheet_path(user.current_time_sheet)
        end

        it 'has no access to another time sheet' do
          should_not_have_access_to time_sheet_path(another_user.current_time_sheet)
        end
      end

      describe 'absences' do
        it 'has access to own absences' do
          should_have_access_to time_sheet_absences_path(user.current_time_sheet)
        end

        it 'has no access to absences of other users' do
          should_not_have_access_to time_sheet_absences_path(another_user.current_time_sheet)
        end
      end

      describe 'summaries' do
        it 'has access to own summaries' do
          should_have_access_to user_summaries_work_year_path(user.current_time_sheet, year)
          should_have_access_to user_summaries_absence_year_path(user.current_time_sheet, year)
        end

        it 'has no access to summaries of other users' do
          should_not_have_access_to user_summaries_work_year_path(another_user.current_time_sheet, year)
          should_not_have_access_to user_summaries_absence_year_path(another_user.current_time_sheet, year)
        end

        it 'has full access to overall absence summary' do
          user && another_user
          visit calendar_summaries_absence_users_path(year, month)

          page.should have_selector('td', text: user.display_name)
          page.should have_selector('td', text: another_user.display_name)
        end

        it 'receives an empty view for overall work summary' do
          user && another_user
          visit year_summaries_work_users_path(year, month)

          page.should_not have_selector('td', text: user.display_name)
          page.should_not have_selector('td', text: another_user.display_name)
        end

        it 'receives an empty view for overall vacation summary' do
          user && another_user
          visit year_summaries_vacation_users_path(year, month)

          page.should_not have_selector('td', text: user.display_name)
          page.should_not have_selector('td', text: another_user.display_name)
        end
      end

      describe 'manage' do
        it 'has no acccess to public holidays' do
          should_not_have_access_to public_holidays_path
        end

        it 'has no acccess to users' do
          should_not_have_access_to users_path
        end

        it 'has no access to time types' do
          should_not_have_access_to time_types_path
        end
      end
    end

    context 'UI' do
      it 'shows the correct menu items for this role' do
        visit user_summaries_work_year_path(user.current_time_sheet, year)

        page.should have_selector('.navigation > ul > li', text: 'Zeiterfassung')
        page.should have_selector('.navigation > ul > li', text: 'Absenzen')
        page.should have_selector('.navigation > ul > li', text: 'Berichte')
        page.should_not have_selector('.navigation > ul > li', text: 'Verwalten')

        page.should have_selector('.sub-nav > dd', text: 'Meine Arbeitszeit')
        page.should have_selector('.sub-nav > dd', text: 'Meine Absenzen')
        page.should have_selector('.sub-nav > dd', text: 'Absenzen Mitarbeiter')
        page.should_not have_selector('.sub-nav > dd', text: 'Arbeitszeit Mitarbeiter')
        page.should_not have_selector('.sub-nav > dd', text: 'Ferien Mitarbeiter')
      end
    end
  end

 context 'role: team leader' do
    let(:team) { FactoryGirl.create(:team, leaders_count: 1, members_count: 1) }
    let(:team_leader) { team.leaders.first }
    let(:user) { team_leader }
    let(:managed_user) { team.members_without_leaders.first }
    let(:another_user_in_another_team) { FactoryGirl.create(:user) }

    before do
      login(team_leader)
    end

    context 'access' do
      describe 'time sheets' do
        it 'has access to own time sheet' do
          should_have_access_to time_sheet_path(user.current_time_sheet)
        end

        it 'has no access to another time sheet' do
          should_not_have_access_to time_sheet_path(managed_user.current_time_sheet)
        end
      end

      describe 'absences' do
        it 'has access to own absences' do
          should_have_access_to time_sheet_absences_path(user.current_time_sheet)
        end

        it 'has no access to summaries of other users' do
          should_not_have_access_to time_sheet_absences_path(managed_user.current_time_sheet)
        end
      end

      describe 'summaries' do
        it 'has access to own summaries' do
          should_have_access_to user_summaries_work_year_path(user.current_time_sheet, year)
          should_have_access_to user_summaries_absence_year_path(user.current_time_sheet, year)
        end

        it 'has access to summaries of managed users' do
          should_have_access_to user_summaries_work_year_path(managed_user.current_time_sheet, year)
          should_have_access_to user_summaries_absence_year_path(managed_user.current_time_sheet, year)
        end

        it 'has no access to summaries of other users which are not in the managed team' do
          should_not_have_access_to user_summaries_work_year_path(another_user_in_another_team.current_time_sheet, year)
          should_not_have_access_to user_summaries_absence_year_path(another_user_in_another_team.current_time_sheet, year)
        end

        it 'overall absence summary: has full access' do
          user && managed_user && another_user_in_another_team
          visit calendar_summaries_absence_users_path(year, month)

          page.should have_selector('td', text: user.display_name)
          page.should have_selector('td', text: managed_user.display_name)
          page.should have_selector('td', text: another_user_in_another_team.display_name)
        end

        it 'overall work summary: receives a list of users in the managed team' do
          user && managed_user && another_user_in_another_team
          visit year_summaries_work_users_path(year, month)

          page.should have_selector('td', text: user.display_name)
          page.should have_selector('td', text: managed_user.display_name)
          page.should_not have_selector('td', text: another_user_in_another_team.display_name)
        end

        it 'overall vacation summary: receives an empty view for overall vacation summary' do
          user && managed_user && another_user_in_another_team
          visit year_summaries_vacation_users_path(year, month)

          page.should have_selector('td', text: user.display_name)
          page.should have_selector('td', text: managed_user.display_name)
          page.should_not have_selector('td', text: another_user_in_another_team.display_name)
        end
      end

      describe 'manage' do
        it 'has no acccess to public holidays' do
          should_not_have_access_to public_holidays_path
        end

        it 'has no acccess to users' do
          should_not_have_access_to users_path
        end

        it 'has no access to time types' do
          should_not_have_access_to time_types_path
        end
      end
    end

    context 'UI' do
      it 'shows the correct menu items for this role' do
        visit user_summaries_work_year_path(user.current_time_sheet, year)

        page.should have_selector('.navigation > ul > li', text: 'Zeiterfassung')
        page.should have_selector('.navigation > ul > li', text: 'Absenzen')
        page.should have_selector('.navigation > ul > li', text: 'Berichte')
        page.should_not have_selector('.navigation > ul > li', text: 'Verwalten')

        page.should have_selector('.sub-nav > dd', text: 'Meine Arbeitszeit')
        page.should have_selector('.sub-nav > dd', text: 'Meine Absenzen')
        page.should have_selector('.sub-nav > dd', text: 'Absenzen Mitarbeiter')
        page.should have_selector('.sub-nav > dd', text: 'Arbeitszeit Mitarbeiter')
        page.should have_selector('.sub-nav > dd', text: 'Ferien Mitarbeiter')
      end
    end
  end

end

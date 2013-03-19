require 'spec_helper'

describe PublicHoliday do
  before do
    @public_holiday_1 = FactoryGirl.create(:public_holiday, start_date: '2013-12-25', end_date: '2013-12-26')
    @public_holiday_2 = FactoryGirl.create(:public_holiday, start_date: '2013-03-29', end_date: '2013-03-29', first_half_day: true)
    @public_holiday_3 = FactoryGirl.create(:public_holiday, start_date: '2013-04-01', end_date: '2013-04-01', second_half_day: true)
    @public_holiday_4 = FactoryGirl.create(:public_holiday, start_date: '2013-04-15', end_date: '2013-04-15', first_half_day: true, second_half_day: true)
  end

  it 'has a valid factory' do
    FactoryGirl.build(:public_holiday).should be_valid
  end

  it 'acts as paranoid' do
    @public_holiday_1.destroy
    expect { PublicHoliday.find(@public_holiday_1.id) }.to raise_error
    expect { PublicHoliday.with_deleted.find(@public_holiday_1.id) }.to_not raise_error
  end

  context 'scopes' do
    it '::half_day_on?' do
      PublicHoliday.half_day_on?('2013-07-20').should be_false
      PublicHoliday.half_day_on?('2013-12-25').should be_false
      PublicHoliday.half_day_on?('2013-12-26').should be_false
      PublicHoliday.half_day_on?('2013-03-29').should be_true
      PublicHoliday.half_day_on?('2013-04-01').should be_true
      PublicHoliday.half_day_on?('2013-04-15').should be_false
    end

    it '::whole_day_on?' do
      PublicHoliday.whole_day_on?('2013-07-20').should be_false
      PublicHoliday.whole_day_on?('2013-12-25').should be_true
      PublicHoliday.whole_day_on?('2013-12-26').should be_true
      PublicHoliday.whole_day_on?('2013-03-29').should be_false
      PublicHoliday.whole_day_on?('2013-04-01').should be_false
      PublicHoliday.whole_day_on?('2013-04-15').should be_true
    end
  end

  it '#whole_day?' do
    @public_holiday_1.whole_day?.should be_true
    @public_holiday_2.whole_day?.should be_false
    @public_holiday_3.whole_day?.should be_false
    @public_holiday_4.whole_day?.should be_true
  end

  it '#half_day?' do
    @public_holiday_1.half_day?.should be_false
    @public_holiday_2.half_day?.should be_true
    @public_holiday_3.half_day?.should be_true
    @public_holiday_4.half_day?.should be_false
  end

  it '#first_half_day?' do
    @public_holiday_1.first_half_day?.should be_false
    @public_holiday_2.first_half_day?.should be_true
    @public_holiday_3.first_half_day?.should be_false
    @public_holiday_4.first_half_day?.should be_false
  end

  it '#second_half_day?' do
    @public_holiday_1.second_half_day?.should be_false
    @public_holiday_2.second_half_day?.should be_false
    @public_holiday_3.second_half_day?.should be_true
    @public_holiday_4.second_half_day?.should be_false
  end
end

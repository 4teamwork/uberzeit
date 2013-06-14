require 'spec_helper'

describe Absence do
  it 'has a valid factory' do
    FactoryGirl.create(:absence).should be_valid
  end

  it 'acts as paranoid' do
    entry = FactoryGirl.create(:absence)
    entry.destroy
    expect { Absence.find(entry.id) }.to raise_error
    expect { Absence.with_deleted.find(entry.id) }.to_not raise_error
  end

  it 'makes sure that the end date is not before the start date' do
    entry = FactoryGirl.build(:absence, start_date: '2013-01-03', end_date: '2013-01-02')
    entry.should_not be_valid
  end

  it 'returns the duration' do
    entry = FactoryGirl.build(:absence, start_date: '2013-01-03', end_date: '2013-01-03')
    entry.duration.should eq(1.day)
  end

  it 'returns the entries sorted by start date' do
    # create the newer entry first
    entry1 = FactoryGirl.create(:absence, start_date: '2013-01-04', end_date: '2013-01-04')
    entry2 = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-03')

    Absence.all.should eq([entry2,entry1])
  end

  it 'tells you whether or not it\'s a whole day entry' do
    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04')
    entry.whole_day?.should be_true

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', second_half_day: true)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: true)
    entry.whole_day?.should be_true
  end

  describe '#daypart' do
    let(:absence) { Absence.new }
    it 'allows setting a whole day' do
      absence.daypart = :whole_day
      absence.whole_day?.should be_true
      absence.first_half_day?.should be_false
      absence.second_half_day?.should be_false
      absence.daypart.should eq(:whole_day)
    end
    it 'allows setting the first half of a day' do
      absence.daypart = :first_half_day
      absence.whole_day?.should be_false
      absence.first_half_day?.should be_true
      absence.second_half_day?.should be_false
      absence.daypart.should eq(:first_half_day)
    end
    it 'allows setting the second half of a day' do
      absence.daypart = :second_half_day
      absence.whole_day?.should be_false
      absence.first_half_day?.should be_false
      absence.second_half_day?.should be_true
      absence.daypart.should eq(:second_half_day)
    end
  end
end
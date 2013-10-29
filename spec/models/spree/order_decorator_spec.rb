require 'spec_helper'

describe Spree::Order do
  describe '#payment_reminder_candidates' do
    before :each do
      @completed_order = create :completed_order_with_totals
      @uncompleted_order = create :order

    end

    subject { Spree::Order.payment_reminder_candidates }

    it 'should return completed orders' do
      expect(subject).to eq([@completed_order])
    end
    
  end  
end
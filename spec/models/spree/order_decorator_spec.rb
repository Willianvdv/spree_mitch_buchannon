require 'spec_helper'

describe Spree::Order do
  describe '#payment_reminder_candidates' do
    before :each do
      @completed_order = create :completed_order_with_totals
      @uncompleted_order = create :order
      payment = create :payment
      @paid_order = payment.order
    end

    subject { Spree::Order.payment_reminder_candidates }

    it 'should not return uncompleted orders' do
      expect(subject).not_to include(@uncompleted_order)
    end

    it 'should not return unpaid orders' do
      expect(subject).not_to include(@paid_order)
    end
  end  
end
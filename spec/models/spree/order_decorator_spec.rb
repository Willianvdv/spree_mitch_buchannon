require 'spec_helper'

describe Spree::Order do
  describe '#payment_reminder_candidates' do
    subject { Spree::Order.payment_reminder_candidates }

    describe 'with no reminders sent' do
      before :each do
        @completed_order = create :completed_order_with_totals
        @completed_order.completed_at = 1.hour.ago
        @completed_order.save!
        @uncompleted_order = create :order
        payment = create :payment
        @paid_order = payment.order
      end
      
      it 'should return the completed order' do
        expect(subject).to eq([@completed_order])
      end

      it 'should not return uncompleted orders' do
        expect(subject).not_to include(@uncompleted_order)
      end

      it 'should not return unpaid orders' do
        expect(subject).not_to include(@paid_order)
      end

      # Refactor: Think of a nicer way to do these tests. I want
      # to test if the .payment_reminder_candidates filters out orders
      # older than 1 day and younger than 1 hour
      describe 'a order completed a second ago' do
        before :each do
          @completed_order.completed_at = 1.second.ago
          @completed_order.save!
        end

        it 'should not be a reminder candiate' do
          expect(subject).to eq([])
        end
      end

      describe 'a order completed 7 days ago' do
        before :each do
          @completed_order.completed_at = 7.days.ago
          @completed_order.save!
        end

        it 'should not be a reminder candiate' do
          expect(subject).to eq([])
        end
      end
    end

    describe 'reminder already sent' do
      before :each do
        @completed_order = create :completed_order_with_totals
        @completed_order.payment_reminder_sent_at = 1.day.ago
        @completed_order.save!
      end

      it 'should not include orders which already been reminded' do
        expect(subject).to eq([])
      end
    end
  end  
end
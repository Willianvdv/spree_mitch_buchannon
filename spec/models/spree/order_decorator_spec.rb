require 'spec_helper'
#require 'email_spec'

describe Spree::Order do
  let!(:mail_message) {
    mail_message = double "Mail::Message"
    mail_message.stub(:deliver!)
    mail_message.stub(:deliver)
    mail_message
  }

  describe '.send_payment_reminder_emails_to_unpaid_orders' do
    let!(:order) { create :order }
  
    before :each do
      Spree::Order.stub(:payment_reminder_candidates).and_return [order,]
      order.stub(:send_payment_reminder_email)
    end

    it 'sends the payment_reminder_email to all payment reminder candiates' do
      order.should_receive(:send_payment_reminder_email).once
      Spree::Order.send_payment_reminder_emails_to_unpaid_orders
    end
  end

  describe '.send_payment_reminder_email' do
    let(:order) { create :order }

    before :each do
      Spree::PaymentReminderMailer.stub(:payment_reminder_email).and_return mail_message
    end

    it 'updates the payment reminder sent at' do
      order.send_payment_reminder_email 
      expect(order.payment_reminder_sent_at).not_to be_nil
    end

    it 'sends the payment reminder email' do
      mail_message.should_receive(:deliver!).once
      order.send_payment_reminder_email 
    end
  end

  describe '#cancellation_candidates' do
    let!(:completed_paid_order) {
      order = create :completed_order_with_totals        
      order.completed_at = 3.days.ago
      order.payment_state = 'paid'
      order.save!
      order
    }
    
    let!(:completed_order) {
      order = create :completed_order_with_totals
      order.completed_at = 3.days.ago
      order.save!
      order
    }

    let!(:just_completed_order) {
      order = create :completed_order_with_totals
      order.completed_at = 1.minute.ago
      order.save!
      order
    }

    subject { Spree::Order.cancellation_candidates }

    it 'returns unpaid completed orders older than 2 days' do
      expect(subject).to eq([completed_order])
    end
  end

  describe '#cancel_cancellation_candidates' do
    let!(:completed_order) {
      order = create :completed_order_with_totals
      order.completed_at = 3.days.ago
      order.save!
      order
    }

    it 'cancels the cancellation candidates' do
      Spree::OrderMailer.stub(:cancel_email).and_return mail_message
      Spree::Order.cancel_cancellation_candidates
      completed_order.reload
      expect(completed_order.state).to eq('canceled')
    end
  end

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

      # todo: Think of a nicer way to do these tests. I want
      # to test if the .payment_reminder_candidates filters out orders
      # that are older than 1 hour and younger than 1 day
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
require 'spec_helper'
# require 'email_spec'

describe Spree::Order do
  let!(:mail_message) do
    mail_message = double 'Mail::Message'
    mail_message.stub(:deliver!)
    mail_message.stub(:deliver)
    mail_message
  end

  let(:order) { create :completed_order_with_totals }
  let(:payment) { create :payment, order: order }

  before do
    order.payments << payment
    order.save!
    payment_method = payment.payment_method
    payment_method.reminder_threshold = 1
    payment_method.save!
  end

  context 'motivational emails' do
    describe '.send_motivation_email' do
      before do
        Spree::MotivationMailer.stub(:motivation_email).and_return mail_message
      end

      subject { order }

      it 'marks the mail as sent' do
        subject.send_motivation_email
        expect(subject.reload.motivation_sent_at).not_to be_nil
      end
    end
  end

  describe '.after_cancel' do
    context 'new order' do
      before :each do
        order.completed_at = 1.day.ago
        order.save!
      end

      it 'should sent a cancel email' do
        Spree::OrderMailer.should_receive(:cancel_email).once.and_return mail_message
        order.cancel!
      end
    end

    context '6 weeks old order' do
      before :each do
        order.completed_at = 6.weeks.ago
        order.save!
      end

      it 'should not sent a cancel email' do
        Spree::OrderMailer.should_receive(:cancel_email).never
        order.cancel!
      end
    end
  end

  describe '.send_payment_reminder_email' do
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
end

require 'spec_helper'
require 'email_spec'

describe Spree::PaymentReminderMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:order) { create :order }

  describe '.payment_reminder_email' do
    subject { Spree::PaymentReminderMailer.payment_reminder_email(order) }

    it 'should have a subject' do
      expect(subject.subject).to eq('Payment reminder')
    end

    it 'should have the customers email' do
      expect(subject.to).to eq([order.email])
    end

    it 'body should say dear customer' do
      expect(subject.body).to include('Dear Customer')
    end

    it 'subject contains the payment instructions' do
      expect(subject.body).to include('Instructions')
    end
  end
end

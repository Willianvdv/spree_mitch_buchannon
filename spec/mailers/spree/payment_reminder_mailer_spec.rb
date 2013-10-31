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
  end
end
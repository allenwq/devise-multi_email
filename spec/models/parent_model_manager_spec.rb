require 'rails_helper'

RSpec.describe Devise::MultiEmail::ParentModelManager, type: :model do
  subject(:user) { create_user }

  let(:new_email) { generate_email }

  describe 'multi_email API' do
    describe '#current_email_record' do
      it 'returns the primary email if not logged in' do
        expect(user.multi_email.current_email_record).to be user.primary_email_record
      end
    end

    describe '#change_primary_email_to' do
      it 'un-sets primary email if given nil' do
        expect(user.primary_email_record).not_to be_nil
        user.multi_email.change_primary_email_to(nil)
        expect(user.primary_email_record).to be_nil
      end

      it 'changes primary email to a new one when allow_unconfirmed is true' do
        user.multi_email.change_primary_email_to(new_email, allow_unconfirmed: true)
        expect(user.primary_email_record.email).to eq(new_email)
        expect(user.primary_email_record.confirmed?).to eq(false)
        expect(user.primary_email_record.confirmed?).to eq(false)
      end

      it 'changes primary email and confirms it if allow_unconfirmed & skip_confirmations are true' do
        user.multi_email.change_primary_email_to(new_email, allow_unconfirmed: true, skip_confirmations: true)
        expect(user.primary_email_record.email).to eq(new_email)
        expect(user.primary_email_record.confirmed?).to eq(true)
      end
    end

    describe '#(un)confirmed_emails' do
      it 'works correctly' do
        new_email_record = user.multi_email.find_or_build_for_email(new_email)
        expect(user.multi_email.unconfirmed_emails).to include(new_email_record)
        new_email_record.confirm
        expect(user.multi_email.confirmed_emails).to include(new_email_record)
      end
    end
  end
end

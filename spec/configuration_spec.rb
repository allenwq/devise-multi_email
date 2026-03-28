require 'rails_helper'

RSpec.describe Devise::MultiEmail do
  # Reset configuration to defaults before and after each test to prevent
  # state leakage to other spec files when tests run in random order.
  def reset_configuration!
    described_class.instance_variable_set(:@autosave_emails, false)
    described_class.instance_variable_set(:@only_login_with_primary_email, false)
    described_class.instance_variable_set(:@parent_association_name, nil)
    described_class.instance_variable_set(:@emails_association_name, nil)
    described_class.instance_variable_set(:@primary_email_method_name, nil)
  end

  before { reset_configuration! }
  after  { reset_configuration! }

  describe '.configure' do
    it 'yields self to the configuration block' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class)
    end

    it 'allows setting configuration options through the block' do
      described_class.configure do |config|
        config.autosave_emails = true
        config.only_login_with_primary_email = true
        config.parent_association_name = :account
        config.emails_association_name = :email_addresses
        config.primary_email_method_name = :main_email
      end

      expect(described_class.autosave_emails?).to be true
      expect(described_class.only_login_with_primary_email?).to be true
      expect(described_class.parent_association_name).to eq(:account)
      expect(described_class.emails_association_name).to eq(:email_addresses)
      expect(described_class.primary_email_method_name).to eq(:main_email)
    end
  end

  describe '.autosave_emails' do
    describe 'getter (.autosave_emails?)' do
      it 'returns false by default' do
        expect(described_class.autosave_emails?).to be false
      end

      it 'returns true when set to true' do
        described_class.autosave_emails = true
        expect(described_class.autosave_emails?).to be true
      end

      it 'returns false when set to false explicitly' do
        described_class.autosave_emails = false
        expect(described_class.autosave_emails?).to be false
      end
    end

    describe 'setter (.autosave_emails=)' do
      it 'sets to true when given true' do
        described_class.autosave_emails = true
        expect(described_class.instance_variable_get(:@autosave_emails)).to be true
      end

      it 'sets to false when given false' do
        described_class.autosave_emails = false
        expect(described_class.instance_variable_get(:@autosave_emails)).to be false
      end

      it 'sets to false when given truthy but not true value' do
        described_class.autosave_emails = 'yes'
        expect(described_class.instance_variable_get(:@autosave_emails)).to be false
      end

      it 'sets to false when given nil' do
        described_class.autosave_emails = nil
        expect(described_class.instance_variable_get(:@autosave_emails)).to be false
      end
    end
  end

  describe '.only_login_with_primary_email' do
    describe 'getter (.only_login_with_primary_email?)' do
      it 'returns false by default' do
        expect(described_class.only_login_with_primary_email?).to be false
      end

      it 'returns true when set to true' do
        described_class.only_login_with_primary_email = true
        expect(described_class.only_login_with_primary_email?).to be true
      end

      it 'returns false when set to false explicitly' do
        described_class.only_login_with_primary_email = false
        expect(described_class.only_login_with_primary_email?).to be false
      end
    end

    describe 'setter (.only_login_with_primary_email=)' do
      it 'sets to true when given true' do
        described_class.only_login_with_primary_email = true
        expect(described_class.instance_variable_get(:@only_login_with_primary_email)).to be true
      end

      it 'sets to false when given false' do
        described_class.only_login_with_primary_email = false
        expect(described_class.instance_variable_get(:@only_login_with_primary_email)).to be false
      end

      it 'sets to false when given truthy but not true value' do
        described_class.only_login_with_primary_email = 'yes'
        expect(described_class.instance_variable_get(:@only_login_with_primary_email)).to be false
      end

      it 'sets to false when given nil' do
        described_class.only_login_with_primary_email = nil
        expect(described_class.instance_variable_get(:@only_login_with_primary_email)).to be false
      end
    end
  end

  describe '.parent_association_name' do
    describe 'getter (.parent_association_name)' do
      it 'returns :user by default' do
        expect(described_class.parent_association_name).to eq(:user)
      end

      it 'returns the set value when configured' do
        described_class.parent_association_name = :account
        expect(described_class.parent_association_name).to eq(:account)
      end
    end

    describe 'setter (.parent_association_name=)' do
      it 'converts string to symbol' do
        described_class.parent_association_name = 'account'
        expect(described_class.parent_association_name).to eq(:account)
      end

      it 'accepts symbol directly' do
        described_class.parent_association_name = :account
        expect(described_class.parent_association_name).to eq(:account)
      end

      it 'handles nil gracefully' do
        described_class.parent_association_name = nil
        # :user is the default
        expect(described_class.parent_association_name).to eq(:user)
      end

      it 'handles objects that respond to to_sym' do
        name_object = double('name', to_sym: :custom_user)
        described_class.parent_association_name = name_object
        expect(described_class.parent_association_name).to eq(:custom_user)
      end

      it 'handles objects that do not respond to to_sym' do
        name_object = double('name')
        described_class.parent_association_name = name_object
        expect(described_class.parent_association_name).to eq(:user)
      end
    end
  end

  describe '.emails_association_name' do
    describe 'getter (.emails_association_name)' do
      it 'returns :emails by default' do
        expect(described_class.emails_association_name).to eq(:emails)
      end

      it 'returns the set value when configured' do
        described_class.emails_association_name = :email_addresses
        expect(described_class.emails_association_name).to eq(:email_addresses)
      end
    end

    describe 'setter (.emails_association_name=)' do
      it 'converts string to symbol' do
        described_class.emails_association_name = 'email_addresses'
        expect(described_class.emails_association_name).to eq(:email_addresses)
      end

      it 'accepts symbol directly' do
        described_class.emails_association_name = :email_addresses
        expect(described_class.emails_association_name).to eq(:email_addresses)
      end

      it 'handles nil gracefully' do
        described_class.emails_association_name = nil
        expect(described_class.emails_association_name).to eq(:emails)
      end

      it 'handles objects that respond to to_sym' do
        name_object = double('name', to_sym: :custom_emails)
        described_class.emails_association_name = name_object
        expect(described_class.emails_association_name).to eq(:custom_emails)
      end

      it 'handles objects that do not respond to to_sym' do
        name_object = double('name')
        described_class.emails_association_name = name_object
        expect(described_class.emails_association_name).to eq(:emails)
      end
    end
  end

  describe '.primary_email_method_name' do
    describe 'getter (.primary_email_method_name)' do
      it 'returns :primary_email_record by default' do
        expect(described_class.primary_email_method_name).to eq(:primary_email_record)
      end

      it 'returns the set value when configured' do
        described_class.primary_email_method_name = :main_email
        expect(described_class.primary_email_method_name).to eq(:main_email)
      end
    end

    describe 'setter (.primary_email_method_name=)' do
      it 'converts string to symbol' do
        described_class.primary_email_method_name = 'main_email'
        expect(described_class.primary_email_method_name).to eq(:main_email)
      end

      it 'accepts symbol directly' do
        described_class.primary_email_method_name = :main_email
        expect(described_class.primary_email_method_name).to eq(:main_email)
      end

      it 'handles nil gracefully' do
        described_class.primary_email_method_name = nil
        expect(described_class.primary_email_method_name).to eq(:primary_email_record)
      end

      it 'handles objects that respond to to_sym' do
        name_object = double('name', to_sym: :custom_primary)
        described_class.primary_email_method_name = name_object
        expect(described_class.primary_email_method_name).to eq(:custom_primary)
      end

      it 'handles objects that do not respond to to_sym' do
        name_object = double('name')
        described_class.primary_email_method_name = name_object
        expect(described_class.primary_email_method_name).to eq(:primary_email_record)
      end
    end
  end

  describe 'Devise module registration' do
    # These tests verify that the Devise.add_module calls execute without error
    # The actual module registration is handled by Devise internals

    it 'requires multi_email modules without error' do
      expect { require 'devise/multi_email/models/authenticatable' }.not_to raise_error
      expect { require 'devise/multi_email/models/confirmable' }.not_to raise_error
      expect { require 'devise/multi_email/models/validatable' }.not_to raise_error
    end

    # Test that the module file can be reloaded without issues
    it 'reloads the main multi_email file without errors' do
      lib_path = File.expand_path('../lib/devise/multi_email.rb', __dir__)
      expect { load lib_path }.not_to raise_error
    end
  end

  describe 'configuration persistence across tests' do
    it 'maintains configuration state between method calls' do
      # Set multiple configuration options
      described_class.autosave_emails = true
      described_class.only_login_with_primary_email = true
      described_class.parent_association_name = :account
      described_class.emails_association_name = :addresses
      described_class.primary_email_method_name = :primary

      # Verify all settings persist
      expect(described_class.autosave_emails?).to be true
      expect(described_class.only_login_with_primary_email?).to be true
      expect(described_class.parent_association_name).to eq(:account)
      expect(described_class.emails_association_name).to eq(:addresses)
      expect(described_class.primary_email_method_name).to eq(:primary)
    end
  end

  describe 'edge cases and boundary conditions' do
    it 'handles rapid configuration changes correctly' do
      # Test rapid toggles
      described_class.autosave_emails = true
      described_class.autosave_emails = false
      described_class.autosave_emails = true
      expect(described_class.autosave_emails?).to be true

      # Test with various falsy values
      [false, nil, 0, ''].each do |falsy_value|
        described_class.only_login_with_primary_email = falsy_value
        expect(described_class.only_login_with_primary_email?).to be false
      end

      # Test only true gives true
      described_class.only_login_with_primary_email = true
      expect(described_class.only_login_with_primary_email?).to be true
    end

    it 'handles empty string association names' do
      described_class.parent_association_name = ''
      expect(described_class.parent_association_name).to eq(:user)

      described_class.emails_association_name = ''
      expect(described_class.emails_association_name).to eq(:emails)

      described_class.primary_email_method_name = ''
      expect(described_class.primary_email_method_name).to eq(:primary_email_record)
    end
  end
end

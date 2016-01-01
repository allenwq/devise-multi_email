require 'spec_helper'

RSpec.describe 'Authenticatable', type: :feature do
  describe 'home page' do
    it 'shows the page' do
      visit '/'

      expect(page).to have_selector('div', text: 'Home!')
    end
  end
end

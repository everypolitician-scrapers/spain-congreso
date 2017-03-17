# frozen_string_literal: true
require 'scraped'
require_relative 'membership_row'
require_relative 'remove_session_from_url_decorator'

class PersonMemberships < Scraped::HTML
  decorator RemoveSessionFromUrlDecorator

  field :memberships do
    noko.css('.all_leg').map do |row|
      fragment row => MembershipRow
    end
  end
end

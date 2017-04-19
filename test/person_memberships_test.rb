# frozen_string_literal: true
# # frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/person_memberships'

describe PersonMemberships do
  around { |test| VCR.use_cassette(File.basename(list_url), &test) }

  let(:profile_url) do
    'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/BusqForm?_piref73_1333155_73_1333154_1333154.next_page=/wc/fichaDiputado?idDiputado=338&idLegislatura=12'
  end

  let(:list_url) do
    'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/BusqForm?_piref73_1333155_73_1333154_1333154.next_page=/wc/listadoFichas?idDiputado=338&idLegislatura=12'
  end

  # To get the correct response, the request has to be sent with the correct cookie.
  # The cookie is set in the response from the membership url.
  let(:profile_page_response) { open(profile_url) }
  # We can now send a request to the memberships page with correct cookie.
  let(:header) { { 'Cookie' => profile_page_response.meta['set-cookie'] } }
  let(:request) { Scraped::Request.new(url: list_url, headers: header) }
  let(:list_page_response) { PersonMemberships.new(response: request.response) }

  it 'should return the expected number of memberships' do
    list_page_response.memberships.count.must_equal 2
  end

  describe 'membership row' do
    it 'should contain the expecte data' do
      list_page_response.memberships
                        .first
                        .to_h
                        .must_equal(url:         'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/BusqForm?_piref73_1333155_73_1333154_1333154.next_page=/wc/fichaDiputado&idLegislatura=12&idDiputado=338',
                                    legislatura: 12,
                                    diputado:    'Marcello Santos, Ana')
    end
  end
end

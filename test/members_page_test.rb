# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/members_page'

describe MembersPage do
  around { |test| VCR.use_cassette(File.basename(url), &test) }
  let(:response)  { MembersPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'first page' do
    let(:url) { 'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/DiputadosTodasLegislaturas' }
    it 'should contain the expected number of member urls' do
      response.member_urls.count.must_equal 25
    end

    it 'should contain the expected url' do
      response.member_urls.first.must_equal 'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/BusqForm?next_page=/wc/fichaDiputado&idDiputado=87&idLegislatura=10'
    end

    it 'should contain a next page link' do
      response.next_page_url.wont_be_nil
    end
  end

  describe 'second page' do
    let(:url) do
      'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/DiputadosTodasLegislaturas?next_page=/wc/busquedaAlfabeticaTodasLeg&paginaActual=1&criterio='
    end
    it 'should contain the expected number of member urls' do
      response.member_urls.count.must_equal 25
    end
  end

  describe 'last page' do
    let(:url) do
      'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/DiputadosTodasLegislaturas?_piref73_1335406_73_1335403_1335403.next_page=/wc/menuAbecedarioInicio&letraElegida=Z&tipoBusqueda=porLetra&idLegislatura=12'
    end
    it 'should not contain a next page link' do
      response.next_page_url.must_be_nil
    end
  end
end

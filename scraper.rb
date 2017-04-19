# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

require_rel 'lib'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def memberships_page_url(profile_url)
  profile_url.gsub('fichaDiputado&', 'listadoFichas?')
end

def member_urls(url, data = [])
  puts url
  page = scrape url => MembersPage
  data += page.member_urls
  return member_urls(page.next_page_url, data) unless page.next_page_url.nil?
  data
end

# Get urls of all members
start_url = 'http://www.congreso.es/portal/page/portal/Congreso/Congreso/Diputados/DiputadosTodasLegislaturas'
urls = member_urls(start_url)

# Get membership list of each member
persons_memberships = urls.map do |url|
  res = Scraped::Request.new(url: url).response
  cookie = Cookie.new(res.headers['set-cookie']).to_s
  header = { 'Cookie' => cookie }
  req = Scraped::Request.new(url: memberships_page_url(url), headers: header)
  PersonMemberships.new(response: req.response).memberships
end

# Scrape the profile page of each membership
memberships = persons_memberships.map do |mems|
  mems.map do |mem|
    (scrape mem.url => MembershipPage).to_h
  end
end

# Add ids to memberships so that memberships
# can be tied to indiviudal members.
memberships_with_ids = memberships.map do |mems|
  # sort memberships
  sorted_mems = mems.sort { |mem| mem[:term].to_i }
  # take term and url from the earliest term
  # and combine to form a unique id
  term_id = sorted_mems.first[:term]
  dip_id = sorted_mems.first[:source].split('=').last
  id = "#{term_id}_#{dip_id}"
  # now apply the id to each membership of the member
  mems.each { |mem| mem[:id] = id }
end

# Write to db
ScraperWiki.save_sqlite(%i(id term), memberships_with_ids.flatten)

# frozen_string_literal: true
class Cookie
  attr_reader :setcookie_string
  def initialize(str)
    @setcookie_string = str
  end

  def to_s
    "ORA_WX_SESSION='#{ora_wx_session_id}';portal=#{portal_id}"
  end

  def ora_wx_session_id
    setcookie_string.split('SESSION="')[1].split('";').first
  end

  def portal_id
    setcookie_string.split('portal=')[1].split('; ').first
  end
end

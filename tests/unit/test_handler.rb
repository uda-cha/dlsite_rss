require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../dlsite_rss/app'

class DlsiteRssTest < Test::Unit::TestCase
  def test_parse_latest_works
    parse_latest_works(url: target_url, updated_at: current_time)
  end
end

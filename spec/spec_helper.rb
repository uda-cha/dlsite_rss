require 'vcr'
require 'webmock/rspec'
require_relative '../lib/dlsite_rss/http_client'

RSpec.configure do |config|
  config.before(:each, :vcr) do |example|
    cassette_name = VCR::RSpec::Metadata.vcr_cassette_name_for(example.metadata)
    sanitized_name = cassette_name.gsub(/[^[:word:]\-\/]+/, '_')
    cassette_path = "#{VCR.configuration.cassette_library_dir}/#{sanitized_name}.yml"
    allow(DlsiteRss::HttpClient).to receive(:sleep) if File.exist?(cassette_path)
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = { record: :once }
  config.before_record { |i| puts "[VCR] recording: #{i.request.uri}" }
  config.before_playback { |i| puts "[VCR] playback:  #{i.request.uri}" }
end

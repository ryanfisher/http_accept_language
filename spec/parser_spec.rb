require 'http_accept_language/parser'

describe HttpAcceptLanguage::Parser do

  subject { described_class.new('en-us,en-gb;q=0.8,en;q=0.6,es-419') }

  it "should return empty array" do
    subject.header = nil
    subject.user_preferred_languages.should eq []
  end

  it "should properly split" do
    subject.user_preferred_languages.should eq %w{en-US es-419 en-GB en}
  end

  it "should ignore jambled header" do
    subject.header = 'odkhjf89fioma098jq .,.,'
    subject.user_preferred_languages.should eq []
  end

  it "should properly respect whitespace" do
    subject.header = 'en-us, en-gb; q=0.8,en;q = 0.6,es-419'
    subject.user_preferred_languages.should eq %w{en-US es-419 en-GB en}
  end

  it "should find first available language" do
    subject.preferred_language_from(%w{en en-GB}).should eq "en-GB"
  end

  it "should find first compatible language" do
    subject.compatible_language_from(%w{en-hk}).should eq "en-hk"
    subject.compatible_language_from(%w{en}).should eq "en"
  end

  it "should find first compatible from user preferred" do
    subject.header = 'en-us,de-de'
    subject.compatible_language_from(%w{de en}).should eq 'en'
  end

  it "should accept symbols as available languages" do
    subject.header = 'en-us'
    subject.compatible_language_from([:"en-HK"]).should eq :"en-HK"
  end

  it "should sanitize available language names" do
    subject.sanitize_available_locales(%w{en_UK-x3 en-US-x1 ja_JP-x2 pt-BR-x5}).should eq ["en-UK", "en-US", "ja-JP", "pt-BR"]
  end

  it "should find most compatible language from user preferred" do
    subject.header = 'ja,en-gb,en-us,fr-fr'
    subject.language_region_compatible_from(%w{en-UK en-US ja-JP}).should eq "ja-JP"
  end

end

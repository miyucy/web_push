require "spec_helper"

describe WebPush do
  it "has a version number" do
    expect(WebPush::VERSION).not_to be nil
  end

  describe 'urlsafe_(en|de)code64' do
    let(:dummy) { { endpoint: nil, keys: { p256dh: nil, auth: nil } } }
    let(:webpush) { WebPush.new dummy }
    let(:enc) { ->(bin) { webpush.urlsafe_encode64 bin } }
    let(:dec) { ->(bin) { webpush.urlsafe_decode64 bin } }

    it 'works' do
      expect(dec[dec[dec[enc[enc[enc['123']]]]]]).to eq '123'
      expect(dec[dec[dec[enc[enc[enc['aabbc']]]]]]).to eq 'aabbc'
    end
  end
end

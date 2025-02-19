# frozen_string_literal: true

RSpec.describe Monday do
  describe "configuration" do
    before do
      described_class.configure do |config|
        config.token = "test-token"
        config.proxy_address = "proxy.com"
        config.proxy_port = 8080
      end
    end

    it "takes a block to set config" do
      expect(described_class.config.token).to eq("test-token")
      expect(described_class.config.proxy_address).to eq("proxy.com")
      expect(described_class.config.proxy_port).to eq(8080)
    end

    it "updates the token after being configured" do
      described_class.config.token = "updated-token"
      expect(described_class.config.token).to eq("updated-token")
    end
  end
end

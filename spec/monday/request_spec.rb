# frozen_string_literal: true

RSpec.describe Monday::Request do
  describe ".post" do
    subject(:post) { described_class.post(uri, query, headers) }

    let(:uri) { URI.parse(monday_url) }
    let(:query) { "query{ boards {id} }" }
    let(:body) do
      {
        query: query
      }
    end
    let(:headers) do
      {
        "Content-Type": "application/json",
        Authorization: token
      }
    end

    context "when authorization token is invalid" do
      let(:token) { "invalid_token" }

      before do
        stub_request(:post, uri)
          .with(body: body.to_json)
          .to_return(status: 403, body: "", headers: {})
      end

      it "returns 403 status" do
        expect(post.code).to eq("403")
      end
    end

    context "when authorization token is valid" do
      let(:token) { "valid_token" }

      before do
        stub_request(:post, uri)
          .with(body: body.to_json)
          .to_return(status: 200, body: "", headers: {})
      end

      it "returns 200 status" do
        expect(post.code).to eq("200")
      end

      context "with a configuration" do
        let!(:configuration) do
          Monday.configure do |config|
            config.proxy_address = proxy_address
            config.proxy_port = proxy_port
          end
        end

        let(:proxy_address) { "proxy.com" }
        let(:proxy_port) { 8080 }

        it "uses the proxy" do
          expect(Net::HTTP).to receive(:new)
            .with(uri.host, uri.port, proxy_address, proxy_port)
            .and_call_original
          expect(post.code).to eq("200")
        end
      end
    end
  end
end

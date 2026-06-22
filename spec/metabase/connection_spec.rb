# frozen_string_literal: true

RSpec.describe Metabase::Connection do
  include_context 'client'

  describe 'get' do
    include_examples 'response handling' do
      let(:method) { :get }
    end

    context 'with params' do
      before do
        stub_request(:get, host)
          .with(query: { 'entity' => 'card', 'id' => '1' })
          .to_return(status: 200, body: 'OK')
      end

      it 'keeps params in the query string' do
        expect(client.get(path, entity: :card, id: 1)).to eq('OK')
      end
    end
  end

  describe 'post' do
    include_examples 'response handling' do
      let(:method) { :post }
    end

    context 'with false body params' do
      before do
        stub_request(:post, host)
          .with do |request|
            request.uri.query.nil? &&
              request.body.include?('"format_rows":false')
          end
          .to_return(status: 200, body: 'OK')
      end

      it 'keeps params in the request body' do
        expect(client.post(path, format_rows: false)).to eq('OK')
      end
    end

    context 'with true body params' do
      before do
        stub_request(:post, host)
          .with do |request|
            request.uri.query.nil? &&
              request.body.include?('"format_rows":true')
          end
          .to_return(status: 200, body: 'OK')
      end

      it 'keeps params in the request body' do
        expect(client.post(path, format_rows: true)).to eq('OK')
      end
    end
  end

  describe 'put' do
    include_examples 'response handling' do
      let(:method) { :put }
    end
  end

  describe 'delete' do
    include_examples 'response handling' do
      let(:method) { :delete }
    end
  end

  describe 'head' do
    include_examples 'response handling' do
      let(:method) { :head }
    end
  end
end

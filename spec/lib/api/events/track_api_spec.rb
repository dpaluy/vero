# frozen_string_literal: true

require 'spec_helper'

describe Vero::Api::Workers::Events::TrackAPI do
  let(:payload) do
    {
      auth_token: 'abcd',
      identity: { email: 'test@test.com' },
      event_name: 'test_event'
    }
  end

  subject { Vero::Api::Workers::Events::TrackAPI.new('https://api.getvero.com', payload) }

  it_behaves_like 'a Vero wrapper' do
    let(:end_point) { '/api/v2/events/track.json' }
  end

  context 'request with properties' do
    describe :validate! do
      it 'should raise an error if event_name is a blank String' do
        options = { auth_token: 'abcd', identity: { email: 'test@test.com' }, event_name: nil }
        subject.options = options
        expect { subject.send(:validate!) }.to raise_error(ArgumentError)

        subject.options = payload
        expect { subject.send(:validate!) }.to_not raise_error
      end

      it 'should raise an error if data is not either nil or a Hash' do
        payload[:data] = []
        subject.options = payload
        expect { subject.send(:validate!) }.to raise_error(ArgumentError)

        payload[:data] = nil
        subject.options = payload
        expect { subject.send(:validate!) }.to_not raise_error

        payload[:data] = {}
        subject.options = payload
        expect { subject.send(:validate!) }.to_not raise_error
      end

      it 'should not raise an error when the keys are Strings' do
        options = { 'auth_token' => 'abcd', 'identity' => { 'email' => 'test@test.com' }, 'event_name' => 'test_event', 'data' => {} }
        subject.options = options
        expect { subject.send(:validate!) }.to_not raise_error
      end

      it 'should not raise an error when keys are Strings for initialization' do
        options = { 'auth_token' => 'abcd', 'identity' => { 'email' => 'test@test.com' }, 'event_name' => 'test_event', 'data' => {} }
        expect { Vero::Api::Workers::Events::TrackAPI.new('https://api.getvero.com', options).send(:validate!) }.to_not raise_error
      end
    end

    describe :request do
      it 'should send a JSON request to the Vero API' do
        expect(RestClient::Request).to(
          receive(:execute).with(
            method: :post,
            url: 'https://api.getvero.com/api/v2/events/track.json',
            payload: { auth_token: 'abcd', identity: { email: 'test@test.com' }, event_name: 'test_event' }.to_json,
            headers: { content_type: :json, accept: :json },
            timeout: 60
          )
        )
        allow(RestClient::Request).to receive(:execute).and_return(200)
        subject.send(:request)
      end

      it 'should allow configurable timeout' do
        expect(RestClient::Request).to(
          receive(:execute).with(
            method: :post,
            url: 'https://api.getvero.com/api/v2/events/track.json',
            payload: { auth_token: 'abcd', identity: { email: 'test@test.com' }, event_name: 'test_event' }.to_json,
            headers: { content_type: :json, accept: :json },
            timeout: 30
          )
        )
        allow(RestClient::Request).to receive(:execute).and_return(200)
        Vero::Api::Workers::Events::TrackAPI.new('https://api.getvero.com', payload.merge(_config: { http_timeout: 30 })).send(:request)
      end
    end
  end

  describe 'integration test' do
    it 'should not raise any errors' do
      obj = Vero::Api::Workers::Events::TrackAPI.new('https://api.getvero.com', payload)

      allow(RestClient::Request).to receive(:execute).and_return(200)
      expect { obj.perform }.to_not raise_error
    end
  end
end

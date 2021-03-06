require 'spec_helper'

describe Vero::Sender do
  subject { Vero::Sender }

  describe ".senders" do
    it "should be a Hash" do
      expect(subject.senders).to be_a(Hash)
    end

    context 'when using Ruby with verion greater than 1.8.7' do
      before do
        stub_const('RUBY_VERSION', '1.9.3')
      end

      it "should have a default set of senders (true, false, none)" do
        expect(subject.senders).to eq({
          true          => Vero::Senders::Base,
          false         => Vero::Senders::Base,
          :none         => Vero::Senders::Base,
        })
      end
    end

    it "should automatically find senders that are not defined" do
      expect(subject.senders[:delayed_job]).to  eq(Vero::Senders::DelayedJob)
      expect(subject.senders[:sucker_punch]).to eq(Vero::Senders::SuckerPunch)
      expect(subject.senders[:resque]).to       eq(Vero::Senders::Resque)
      expect(subject.senders[:sidekiq]).to      eq(Vero::Senders::Sidekiq)
      expect(subject.senders[:invalid]).to      eq(Vero::Senders::Invalid)
      expect(subject.senders[:none]).to         eq(Vero::Senders::Base)
    end
  end
end

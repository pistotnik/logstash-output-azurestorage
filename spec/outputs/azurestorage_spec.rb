# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/azurestorage'
require 'logstash/codecs/plain'
require 'logstash/event'
require 'logstash/outputs/azurestorage_client'

describe LogStash::Outputs::Azurestorage do
  let(:sample_event) { LogStash::Event.new }
  let(:output) { LogStash::Outputs::Azurestorage.new({'storage_account_name' => 'foo',
                                                      'storage_access_key' => 'bar',
                                                      'table_name' => 'qou'}) }

  before do
    @output_client = LogStash::Outputs::AzureStorageClient.new('qou')
    expect(LogStash::Outputs::AzureStorageClient).to receive(:new).with('qou'){ @output_client }
    expect(@output_client).to receive(:init)
    output.register
  end

  describe "on receiving a message" do
    subject { output.receive(sample_event) }

    it "returns a sample event and stores it to azure" do
      expect(@output_client).to receive(:insert_entity).with(any_args)
      expect(subject).to eq(sample_event)
    end
  end
end
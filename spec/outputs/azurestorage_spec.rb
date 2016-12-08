# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/azurestorage'
require 'logstash/codecs/plain'
require 'logstash/event'
require 'logstash/outputs/azurestorage_client'
require 'timecop'

describe LogStash::Outputs::Azurestorage do
  let(:event_message) do
    LogStash::Event.new(
        'message' => 'message',
        'source' => 'source',
        'type' => 'type',
        'event_id' => 'event_id',
        'level' => 'level',
        'process_id' => 'process_id',
        'thread_id' => 'thread_id',
        'provider_guid' => 'provider_guid',
        'source_name' => 'source_name',
        'log_name' => 'log_name',
        'xml' => 'xml',
        '@timestamp' => LogStash::Timestamp.now)
  end

  let(:entity_properties) {
    {
        PartitionKey: @dateTime.strftime("%m%d%Y"),
        RowKey: @dateTime.strftime('%Q'),
        EventId: 'event_id',
        Level: 'level',
        Pid: 'process_id',
        Tid: 'thread_id',
        ProviderGuid: 'provider_guid',
        ProviderName: 'source_name',
        Channel: 'log_name',
        RawXml: 'xml',
        Description: 'message',
        Role: "",
        RoleInstance: "",
        DeploymentId: "",
        EventTickCount: ""
    }
  }

  let(:output) { LogStash::Outputs::Azurestorage.new({'storage_account_name' => 'foo',
                                                      'storage_access_key' => 'bar',
                                                      'table_name' => 'qou'}) }

  before do
    @output_client = LogStash::Outputs::AzureStorageClient.new('qou')
    expect(LogStash::Outputs::AzureStorageClient).to receive(:new).with('qou'){ @output_client }
    expect(@output_client).to receive(:init)
    output.register

    @dateTime = DateTime.parse("2009-10-11 01:38:00 +0200")
    Timecop.freeze(@dateTime)
  end

  after do
    Timecop.return
  end

  describe "on receiving a message" do
    subject { output.receive(event_message) }

    it "returns a sample event and stores it to azure" do
      expect(@output_client).to receive(:insert_entity).with(entity_properties)
      expect(subject).to eq(event_message)
    end
  end
end
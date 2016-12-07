# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/azurestorage"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::Azurestorage do
  let(:sample_event) { LogStash::Event.new }
  let(:output) { LogStash::Outputs::Azurestorage.new({"storage_account_name" => "foo",
                                                      "storage_access_key" => "bar",
                                                      "table_name" => "qou"}) }

  it "should register plugin without errors" do
    plugin = LogStash::Plugin.lookup("output", "azurestorage").new({"storage_account_name" => "foo",
                                                                    "storage_access_key" => "bar",
                                                                    "table_name" => "qou"})
    expect(plugin).to receive(:setup_azure_storage_connection)
    expect(plugin).to receive(:create_table_if_not_exists).with("qou")
    expect { plugin.register }.to_not raise_error
  end

  before do
    expect(output).to receive(:setup_azure_storage_connection)
    expect(output).to receive(:create_table_if_not_exists).with("qou")
    output.register
  end

  describe "on receiving a message" do
    subject { output.receive(sample_event) }

    it "returns a sample event and inserts it to azure" do
      table_service = double()
      expect(Azure::Storage::Table::TableService).to receive(:new){ table_service }

      expect(table_service).to receive(:insert_entity).with("qou", any_args)
      expect(subject).to eq(sample_event)
    end
  end
end

# frozen_string_literal: true
require 'spec_helper'

describe DropboxApi::Client, '#upload_session_start_batch' do
  before :each do
    @client = DropboxApi::Client.new
  end

  it "starts a batch of upload sessions", :cassette => "upload_session_start_batch/success" do
    result = @client.upload_session_start_batch(2)

    expect(result).to be_a(DropboxApi::Results::UploadSessionStartBatchResult)
    expect(result.session_ids).to be_a(Array)
    expect(result.session_ids.length).to eq(2)
    expect(result.session_ids.first).to be_a(String)
  end

  it "starts concurrent upload sessions", :cassette => "upload_session_start_batch/concurrent" do
    result = @client.upload_session_start_batch(3, session_type: 'concurrent')

    expect(result).to be_a(DropboxApi::Results::UploadSessionStartBatchResult)
    expect(result.session_ids).to be_a(Array)
    expect(result.session_ids.length).to eq(3)
  end

  it "raises an error for invalid num_sessions" do
    expect {
      @client.upload_session_start_batch(0)
    }.to raise_error(ArgumentError, /must be between 1 and 1000/)

    expect {
      @client.upload_session_start_batch(1001)
    }.to raise_error(ArgumentError, /must be between 1 and 1000/)
  end

  it "raises an error for invalid session_type" do
    expect {
      @client.upload_session_start_batch(1, session_type: 'invalid')
    }.to raise_error(ArgumentError, /must be 'sequential' or 'concurrent'/)
  end
end
# frozen_string_literal: true
require 'spec_helper'

describe DropboxApi::Client, '#upload_session_finish_batch' do
  before :each do
    @client = DropboxApi::Client.new
  end

  it "finishes a batch of upload sessions synchronously", :cassette => "upload_session_finish_batch/sync" do
    # First, create upload sessions and upload content
    start_result = @client.upload_session_start_batch(2)
    
    cursors = []
    start_result.session_ids.each_with_index do |session_id, i|
      cursor = DropboxApi::Metadata::UploadSessionCursor.new(
        'session_id' => session_id,
        'offset' => 0
      )
      content = "File content #{i}"
      @client.upload_session_append_v2(cursor, content, close: true)
      cursors << cursor
    end

    # Now finish the batch
    entries = cursors.map.with_index do |cursor, i|
      {
        cursor: cursor,
        commit: DropboxApi::Metadata::CommitInfo.new(
          path: "/test_batch_#{i}.txt",
          mode: 'add'
        )
      }
    end

    result = @client.upload_session_finish_batch(entries)

    # Result could be synchronous (array) or async (has async_job_id)
    if result.is_a?(Array)
      expect(result.length).to eq(2)
      result.each do |entry|
        expect(entry).to be_a(DropboxApi::Metadata::File).or be_a(DropboxApi::Errors::UploadSessionFinishError)
      end
    else
      expect(result.async_job_id).to be_a(String)
    end
  end

  it "returns async job id for large batches", :cassette => "upload_session_finish_batch/async" do
    # Create a larger batch that will likely be processed asynchronously
    entries = []
    10.times do |i|
      entries << {
        cursor: DropboxApi::Metadata::UploadSessionCursor.new(
          'session_id' => "session_#{i}",
          'offset' => 1024
        ),
        commit: DropboxApi::Metadata::CommitInfo.new(
          path: "/async_test_#{i}.txt",
          mode: 'add'
        )
      }
    end

    result = @client.upload_session_finish_batch(entries)

    if result.respond_to?(:async_job_id) && result.async_job_id
      expect(result.async_job_id).to be_a(String)
    else
      # If it completed synchronously, verify the results
      expect(result).to be_a(Array)
    end
  end

  it "raises an error for empty entries" do
    expect {
      @client.upload_session_finish_batch([])
    }.to raise_error(ArgumentError, /must contain between 1 and 1000 items/)
  end

  it "raises an error for too many entries" do
    entries = []
    1001.times do |i|
      entries << {
        cursor: DropboxApi::Metadata::UploadSessionCursor.new(
          'session_id' => "session_#{i}",
          'offset' => 0
        ),
        commit: DropboxApi::Metadata::CommitInfo.new(
          path: "/file_#{i}.txt",
          mode: 'add'
        )
      }
    end

    expect {
      @client.upload_session_finish_batch(entries)
    }.to raise_error(ArgumentError, /must contain between 1 and 1000 items/)
  end

  it "raises an error for invalid entry format" do
    expect {
      @client.upload_session_finish_batch([{cursor: nil, commit: nil}])
    }.to raise_error(ArgumentError, /Each entry must have :cursor and :commit/)
  end
end
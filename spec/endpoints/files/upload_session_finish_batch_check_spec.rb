# frozen_string_literal: true
require 'spec_helper'

describe DropboxApi::Client, '#upload_session_finish_batch_check' do
  before :each do
    @client = DropboxApi::Client.new
  end

  it "returns in_progress for ongoing jobs", :cassette => "upload_session_finish_batch_check/in_progress" do
    result = @client.upload_session_finish_batch_check("sample_async_job_id")

    expect(result).to eq(:in_progress)
  end

  it "returns file metadata for completed jobs", :cassette => "upload_session_finish_batch_check/complete" do
    result = @client.upload_session_finish_batch_check("completed_job_id")

    expect(result).to be_a(Array)
    result.each do |entry|
      # Each entry should be either a File metadata or an error
      expect(entry).to be_a(DropboxApi::Metadata::File).or be_a(DropboxApi::Errors::UploadSessionFinishError)
    end
  end

  it "handles mixed success and failure results", :cassette => "upload_session_finish_batch_check/mixed" do
    result = @client.upload_session_finish_batch_check("mixed_results_job_id")

    expect(result).to be_a(Array)
    
    # Check that we have both success and failure entries
    successes = result.select { |r| r.is_a?(DropboxApi::Metadata::File) }
    failures = result.select { |r| r.is_a?(DropboxApi::Errors::UploadSessionFinishError) }
    
    expect(successes).not_to be_empty
    expect(failures).not_to be_empty
  end

  it "raises PollError for invalid job id", :cassette => "upload_session_finish_batch_check/invalid_job_id" do
    expect {
      @client.upload_session_finish_batch_check("invalid_job_id")
    }.to raise_error(DropboxApi::Errors::PollError)
  end

  it "handles internal errors", :cassette => "upload_session_finish_batch_check/internal_error" do
    expect {
      @client.upload_session_finish_batch_check("error_job_id")
    }.to raise_error(DropboxApi::Errors::InternalError)
  end
end
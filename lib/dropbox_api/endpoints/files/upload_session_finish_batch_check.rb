# frozen_string_literal: true
module DropboxApi::Endpoints::Files
  class UploadSessionFinishBatchCheck < DropboxApi::Endpoints::Rpc
    Method      = :post
    Path        = '/2/files/upload_session/finish_batch/check'
    ResultType  = DropboxApi::Results::UploadSessionFinishBatchJobStatus
    ErrorType   = DropboxApi::Errors::PollError

    # Returns the status of an asynchronous job for {Client#upload_session_finish_batch}.
    # If success, it returns list of result for each entry.
    #
    # @param async_job_id [String] Id of the asynchronous job.
    #   This is the value of a response returned from the method that
    #   launched the job.
    # @return [:in_progress, Array] This could be either the `:in_progress`
    #   flag or a list of file metadata entries.
    # @example
    #   # First, start a batch finish operation
    #   batch_result = client.upload_session_finish_batch(entries)
    #   
    #   # If async, check the status
    #   if batch_result.async_job_id
    #     job_status = client.upload_session_finish_batch_check(batch_result.async_job_id)
    #     
    #     if job_status == :in_progress
    #       # Job is still processing
    #     else
    #       # job_status is an array of file metadata
    #       job_status.each do |file_metadata|
    #         puts "Uploaded: #{file_metadata.path_display}"
    #       end
    #     end
    #   end
    add_endpoint :upload_session_finish_batch_check do |async_job_id|
      perform_request async_job_id: async_job_id
    end
  end
end
# frozen_string_literal: true
module DropboxApi::Results
  # Result returned by {Client#upload_session_finish_batch} that may
  # either launch an asynchronous job or complete synchronously.
  #
  # The value will be either an async_job_id string or a list of file metadata entries.
  class UploadSessionFinishBatchResult < DropboxApi::Results::Base
    def self.new(result_data)
      case result_data['.tag']
      when 'async_job_id'
        # Return a result object that has the async_job_id
        super(result_data)
      when 'complete'
        # Return the array of entries directly
        result_data['entries'].map do |entry|
          DropboxApi::Results::UploadSessionFinishBatchResultEntry.new(entry)
        end
      else
        raise NotImplementedError, "Unknown result type: #{result_data['.tag']}"
      end
    end

    # Returns the async job ID if the operation is asynchronous
    #
    # @return [String, nil] The async job ID or nil if operation completed synchronously
    def async_job_id
      @data['async_job_id'] if @data
    end
  end
end
# frozen_string_literal: true
module DropboxApi::Results
  # Result returned by {Client#upload_session_finish_batch_check} representing
  # the status of an asynchronous batch upload session finish operation.
  #
  # The value will be either `:in_progress` or a list of file metadata entries.
  class UploadSessionFinishBatchJobStatus < DropboxApi::Results::Base
    def self.new(result_data)
      case result_data['.tag']
      when 'in_progress'
        :in_progress
      when 'complete'
        result_data['entries'].map do |entry|
          DropboxApi::Results::UploadSessionFinishBatchResultEntry.new(entry)
        end
      else
        raise NotImplementedError, "Unknown result type: #{result_data['.tag']}"
      end
    end
  end
end
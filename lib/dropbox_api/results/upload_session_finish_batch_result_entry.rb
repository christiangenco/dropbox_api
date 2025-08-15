# frozen_string_literal: true
module DropboxApi::Results
  # Entry in the result returned by {Client#upload_session_finish_batch}
  # representing the result for each file in the batch.
  class UploadSessionFinishBatchResultEntry < DropboxApi::Results::Base
    def self.new(result_data)
      case result_data['.tag']
      when 'success'
        # Return file metadata
        DropboxApi::Metadata::File.new(result_data)
      when 'failure'
        # Return error information
        # The actual error is in result_data['failure']
        DropboxApi::Errors::UploadSessionFinishError.build(
          result_data['failure']['.tag'],
          result_data['failure']
        )
      else
        raise NotImplementedError, "Unknown result type: #{result_data['.tag']}"
      end
    end
  end
end
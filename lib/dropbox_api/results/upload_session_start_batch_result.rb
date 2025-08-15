# frozen_string_literal: true
module DropboxApi::Results
  class UploadSessionStartBatchResult < DropboxApi::Results::Base
    # Returns a list of unique identifiers for the upload sessions.
    # Pass each session_id to upload_session/append:2 and upload_session/finish.
    #
    # @return [Array<String>] List of session IDs
    def session_ids
      @data['session_ids']
    end
  end
end
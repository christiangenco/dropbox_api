# frozen_string_literal: true
module DropboxApi::Endpoints::Files
  class UploadSessionFinishBatch < DropboxApi::Endpoints::Rpc
    Method      = :post
    Path        = '/2/files/upload_session/finish_batch_v2'
    ResultType  = DropboxApi::Results::UploadSessionFinishBatchResult
    ErrorType   = nil

    include DropboxApi::OptionsValidator

    # This route helps you commit many files at once into a user's Dropbox.
    # Use {Client#upload_session_start} and {Client#upload_session_append_v2} to
    # upload file contents. We recommend uploading many files in parallel to
    # increase throughput. Once the file contents have been uploaded, rather
    # than calling {Client#upload_session_finish}, use this route to finish all
    # your upload sessions in a single request.
    #
    # UploadSessionStartArg.close or UploadSessionAppendArg.close needs to be
    # true for the last upload_session/start or upload_session/append:2 call
    # of each upload session. The maximum size of a file one can upload to an
    # upload session is 350 GiB. We allow up to 1000 entries in a single request.
    #
    # @param entries [Array<Hash>] Commit information for each file in the batch.
    #   Each entry should contain:
    #   - cursor: A DropboxApi::Metadata::UploadSessionCursor
    #   - commit: A DropboxApi::Metadata::CommitInfo
    # @return [DropboxApi::Results::UploadSessionFinishBatchResult] Result containing
    #   either an async_job_id or the file metadata for each entry
    # @example
    #   entries = [
    #     {
    #       cursor: DropboxApi::Metadata::UploadSessionCursor.new({
    #         session_id: "session123",
    #         offset: 1024
    #       }),
    #       commit: DropboxApi::Metadata::CommitInfo.new({
    #         path: "/file1.txt",
    #         mode: "add"
    #       })
    #     },
    #     {
    #       cursor: DropboxApi::Metadata::UploadSessionCursor.new({
    #         session_id: "session456",
    #         offset: 2048
    #       }),
    #       commit: DropboxApi::Metadata::CommitInfo.new({
    #         path: "/file2.txt",
    #         mode: "add"
    #       })
    #     }
    #   ]
    #   result = client.upload_session_finish_batch(entries)
    add_endpoint :upload_session_finish_batch do |entries|
      if !entries.is_a?(Array)
        raise ArgumentError, "entries must be an array"
      end

      if entries.empty? || entries.size > 1000
        raise ArgumentError, "entries must contain between 1 and 1000 items"
      end

      formatted_entries = entries.map do |entry|
        unless entry[:cursor] && entry[:commit]
          raise ArgumentError, "Each entry must have :cursor and :commit"
        end

        {
          cursor: entry[:cursor].to_hash,
          commit: entry[:commit].to_hash
        }
      end

      perform_request(entries: formatted_entries)
    end
  end
end
# frozen_string_literal: true
module DropboxApi::Endpoints::Files
  class UploadSessionStartBatch < DropboxApi::Endpoints::Rpc
    Method      = :post
    Path        = '/2/files/upload_session/start_batch'
    ResultType  = DropboxApi::Results::UploadSessionStartBatchResult
    ErrorType   = nil

    include DropboxApi::OptionsValidator

    # This route starts batch of upload_sessions. Please refer to
    # {Client#upload_session_start} usage.
    #
    # @param num_sessions [Integer] The number of upload sessions to start.
    #   Must be between 1 and 1000.
    # @option options session_type [String] Type of upload session you want to
    #   start. If not specified, default is 'sequential'. Valid values are
    #   'sequential' or 'concurrent'.
    # @return [DropboxApi::Results::UploadSessionStartBatchResult] Result containing
    #   session IDs that can be used with upload_session/append and upload_session/finish
    add_endpoint :upload_session_start_batch do |num_sessions, options = {}|
      validate_options([
        :session_type
      ], options)

      if num_sessions < 1 || num_sessions > 1000
        raise ArgumentError, "num_sessions must be between 1 and 1000"
      end

      params = {
        num_sessions: num_sessions
      }

      if options[:session_type]
        unless %w[sequential concurrent].include?(options[:session_type])
          raise ArgumentError, "session_type must be 'sequential' or 'concurrent'"
        end
        params[:session_type] = options[:session_type]
      end

      perform_request(params)
    end
  end
end
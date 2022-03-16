require 'ovirtsdk4'
require 'ovirtsdk4/connection'

module VagrantPlugins
  module OVirtProvider
    module Util
      module Connection
        # Use OVirtSDK4::ConnectionError if available; SDK versions older than
        # 4.2.0 used the generic OVirtSDK4::Error.
        ERROR_CLASSES = (OvirtSDK4.const_defined?(:ConnectionError) ? [OvirtSDK4::ConnectionError, OvirtSDK4::Error] : [OvirtSDK4::Error]).freeze

      module_function

        # Close a connection, suppressing errors generated by the SDK.  Yield
        # the error to the caller to re-raise if appropriate (or log, or do
        # whatever).
        def safe_close_connection!(conn)
          conn.close
        rescue *ERROR_CLASSES => e
          yield e if block_given?
        rescue StandardError => e
          yield e if block_given?
          raise e
        end

        # Wrapper for "#safe_close_connection" that issues a warning message
        # with diagnostic information about the exception raised.
        def safe_close_connection_with_warning!(conn, ui)
          safe_close_connection!(conn) { |e| ui.warn("Encountered exception of class #{e.class}: #{e.message}") }
        end

        # Wrapper for "#safe_close_connection_with_warning" that extracts the
        # connection and UI from a Vagrant environment.
        def safe_close_connection_standard!(env)
          safe_close_connection_with_warning!(env[:connection], env[:ui])
        end
      end
    end
  end
end
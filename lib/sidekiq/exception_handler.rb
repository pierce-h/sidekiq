# frozen_string_literal: true
require 'sidekiq'

module Sidekiq
  module ExceptionHandler

    class Logger
      def call(ex, ctxHash)
        puts "#" * 100
        puts ctxHash
        Sidekiq.logger.tagged(ctxHash.dig('job')) do
          Sidekiq.logger.warn(ctxHash) if !ctxHash.empty?
          Sidekiq.logger.warn("#{ex.class.name}: #{ex.message}")
          Sidekiq.logger.warn(ex.backtrace.join("\n")) unless ex.backtrace.nil?
        end
      end

      Sidekiq.error_handlers << Sidekiq::ExceptionHandler::Logger.new
    end

    def handle_exception(ex, ctxHash={})
      Sidekiq.error_handlers.each do |handler|
        begin
          handler.call(ex, ctxHash)
        rescue => ex
          Sidekiq.logger.error "!!! ERROR HANDLER THREW AN ERROR !!!"
          Sidekiq.logger.error ex
          Sidekiq.logger.error ex.backtrace.join("\n") unless ex.backtrace.nil?
        end
      end
    end
  end
end

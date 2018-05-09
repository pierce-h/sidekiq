# frozen_string_literal: true
module Sidekiq
  class JobLogger

    def call(item, queue)
      logger.tagged(item) do
        begin
          start = Time.now
          logger.info('start')
          yield
          logger.info("done: #{elapsed(start)} sec")
        rescue Exception
          logger.info("fail: #{elapsed(start)} sec")
          raise
        end
      end
    end

    private

    def log_payload(item)
      {
        class_name: item['wrapped'],
        jid: item['jid']
      }
    end

    def elapsed(start)
      (Time.now - start).round(3)
    end

    def logger
      Sidekiq.logger
    end
  end
end

# frozen_string_literal: true

require 'thread'


module Stagnum

  VERSION = '1.0.0'.freeze

  class Pool

    attr_reader :name

    def initialize(name, worker_count)

      @name = name
      @work_queue = ::Thread::Queue.new
      @worker_count = worker_count

      @maintenance_mutex = ::Thread::Mutex.new
      @next_worker_thread_id = -1
      @worker_threads = []
    end

    def enqueue(done_queue=Stagnum::DoneQueue.new, data, &block)

      maintain

      done_queue.increment if done_queue.respond_to?(:increment)

      @work_queue << [ done_queue, data, block ]

      done_queue
    end

    def next_worker_thread_id

      @next_worker_thread_id += 1
    end

    protected

    def maintain

      @maintenance_mutex.synchronize do

        @worker_threads = @worker_threads.select { |t| t.alive? }

        while @worker_threads.size < @worker_count

          @worker_threads << Stagnum::WorkerThread.new(self, @work_queue)
        end
      end
    end
  end

  class DoneQueue < ::Thread::Queue

    attr_reader :count

    def initialize(items=[])

      super

      @listeners = []

      @count = 0
    end

    def increment

      @count += 1
    end

    # Returns [ successes, failures ]
    #
    def pop_all

      @count.times
        .inject([ [], [] ]) { |a, i|
          r = pop
          a[r[0] == :success ? 0 : 1] << r
          a }
    end

    def pop(non_blocking=false)

      r = super

      @listeners.each { |l| l[1].call(r) if l[0] == :any || l[0] == r[0] }

      r
    end

    def on_success(&block)

      @listeners << [ :success, block ]
    end

    def on_failure(&block)

      @listeners << [ :failure, block ]
    end

    def on_pop(&block)

      @listeners << [ :any, block ]
    end
  end

  class WorkerThread < ::Thread

    def initialize(pool, work_queue)

      @pool = pool
      @work_queue = work_queue

      self.name = "#{pool.name}__#{pool.next_worker_thread_id}"

      super do

        loop do

          done_queue, data, block = @work_queue.pop

          block.call(data)

          done_queue << [ :success, data ]

        rescue => err

          done_queue << [ :failure, data, err ]
        end
      end
    end
  end
end


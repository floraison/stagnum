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
          r = self.pop
          a[r[0] == :success ? 0 : 1] << r
          a }
    end
  end

  class WorkerThread < ::Thread

    def initialize(stagnum, work_queue)

      @stagnum = stagnum
      @work_queue = work_queue

      self.name = "#{stagnum.name}__#{stagnum.next_worker_thread_id}"

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


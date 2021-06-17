require "./secret"

module Crypto::Secret
  # Development guide:
  # 1. Create your initialize method and optionally allocate memory
  # 2. Create a finalize method to deallocate memory if necessary
  # 3. Fill in the missing abstract methods
  # 4. Optionally override any included methods (especially wipe_impl if the secret is not held in the provided slice)
  # 5. Provide and test a dup method or raise on dup if not possible
  #
  # When state changes are required (such as using #noaccess) and the buffer is accessed from multiple threads wrap each #readonly/#readwrite block in a lock.
  module Stateful
    include Crypto::Secret

    macro included
      extend ClassMethods
    end

    @state = State::Readwrite

    # Temporarily make buffer readwrite within the block returning to the prior state on exit.
    # WARNING: Not thread safe unless this object is **readwrite**
    def readwrite
      with_state State::Readwrite do
        to_slice do |slice|
          yield slice
        end
      end
    end

    # Marks a region allocated as readable and writable
    # WARNING: Not thread safe
    def readwrite : self
      raise Error::KeyWiped.new if @state == State::Wiped
      readwrite_impl
      @state = State::Readwrite
      self
    end

    # Temporarily make buffer readonly within the block returning to the prior state on exit.
    # WARNING: Not thread safe unless this object is readonly or readwrite
    def readonly
      with_state State::Readonly do
        to_slice do |slice|
          yield slice
        end
      end
    end

    # Marks a region allocated using sodium_malloc() or sodium_allocarray() as read-only.
    # WARNING: Not thread safe
    def readonly : self
      raise Error::KeyWiped.new if @state == State::Wiped
      readonly_impl
      @state = State::Readonly
      self
    end

    # Makes a region inaccessible. It cannot be read or written, but the data are preserved.
    # WARNING: Not thread safe
    def noaccess : self
      raise Error::KeyWiped.new if @state == State::Wiped
      noaccess_impl
      @state = State::Noaccess
      self
    end

    # WARNING: Not thread safe
    # Kept public for .dup
    # :nodoc:
    def set_state(new_state : State)
      return if @state == new_state

      case new_state
      when State::Readwrite; readwrite
      when State::Readonly ; readonly
      when State::Noaccess ; noaccess
      when State::Wiped    ; raise Error::InvalidStateTransition.new
      else
        raise "unknown state #{new_state}"
      end
    end

    # WARNING: Only thread safe when current state >= requested state
    private def with_state(new_state : State)
      old_state = @state
      # Only change when new_state needs more access than @state.
      if old_state >= new_state
        yield
      else
        begin
          set_state new_state
          yield
        ensure
          set_state old_state
        end
      end
    end

    # WARNING: Not thread safe
    def wipe
      return if @state == State::Wiped
      readwrite do |slice|
        wipe_impl slice
      end
      noaccess_impl
      @state = State::Wiped
    end

    def dup
      super.tap do |obj|
        obj.set_state @state
      end
    end

    protected abstract def readwrite_impl : Nil
    protected abstract def readonly_impl : Nil
    protected abstract def noaccess_impl : Nil
  end
end

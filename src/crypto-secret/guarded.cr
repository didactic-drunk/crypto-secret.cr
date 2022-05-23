require "./stateful"
require "mmap"

abstract class Crypto::Secret
  # * Wipes on finalize but should not be relied on
  # * Not locked in memory
  # * Access protected
  # * Guard pages
  # * Won't appear in core dumps (some platforms)
  class Guarded < Secret
    include Stateful

    protected getter buffer_bytesize : Int32
    @dregion : Mmap::SubRegion
    @data : Mmap::SubRegion

    def initialize(size : Int32)
      ps = Mmap::PAGE_SIZE
      pages = (size.to_f / ps).ceil + 2
      msize = pages * ps

      @buffer_bytesize = size

      @mmap = Mmap::Region.new(msize)
      @mmap[0, ps].guard_page
      @mmap[(pages - 1) * ps, ps].guard_page

      @dregion = @mmap[ps, (pages - 2) * ps]
      @dregion.crypto_key
      @data = @dregion[0, size]
    end

    protected def readwrite_impl : Nil
      @dregion.readwrite
    end

    protected def readonly_impl : Nil
      @dregion.readonly
    end

    protected def noaccess_impl : Nil
      @dregion.noaccess
    end

    delegate_to_slice @data
  end
end

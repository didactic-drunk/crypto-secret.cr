macro test_secret_class(to sclass)
  describe {{sclass}} do
    sclass = {{sclass}}

    it "returns a random secret" do
      secret1 = sclass.new 8
      secret2 = sclass.random 8
      secret1.should_not eq secret2
    end

    it "copies & wipes on .move" do
      ksize = 4
      key1 = Bytes.new ksize
      key1[1] = 1_u8
      key2 = key1.dup
      secret = sclass.move_from key2

      secret.readonly { |s| s.should eq key1 }
      key2.should eq Bytes.new(ksize)
    end

    it "copies & preserves on .copy" do
      ksize = 2
      key1 = Bytes.new ksize
      key1[1] = 1_u8
      key2 = key1.dup
      secret = sclass.copy_from key2

      secret.readonly { |s| s.should eq key1 }
      key2.should eq key1
    end

    it "compares with ==" do
      ksize = 32
      key = Bytes.new ksize
      key[1] = 1_u8

      secret1 = sclass.copy_from key
      secret1.readonly { |s| s.should eq key }

      secret2 = sclass.copy_from key

      (secret1 == secret2).should be_true
      secret1.readonly do |s1|
        secret2.readonly do |s2|
          (s1 == s2).should be_true
        end
      end
    end

    it "dups" do
      ksize = 2
      key = Bytes.new ksize
      key[1] = 1_u8

      secret1 = sclass.copy_from key
      secret2 = secret1.dup
      (secret1 == secret2).should be_true

      if secret1.is_a?(Crypto::Secret::Stateful) && secret2.is_a?(Crypto::Secret::Stateful)
        secret1.@state.should eq secret2.@state
      end
    end

    it "bytesize" do
      secret = sclass.new 5
      secret.bytesize.should eq 5
      secret.readonly { |s| s.bytesize.should eq 5 }
    end

    it "doesn't leak key material when inspecting" do
      secret = sclass.new 5

      secret.to_s.should_not match /Bytes|Slice|StaticArray/
      secret.inspect.should_not match /Bytes|Slice|StaticArray/

      secret.inspect.should match /\(\*\*\*SECRET\*\*\*\)$/
    end
  end
end

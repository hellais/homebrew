require 'open3'
require 'utils'
require 'exceptions'

class GPG

  def run cmd, *arg
    args = []
    args += ["--status-fd", "1"]
    args << "--no-default-keyring"
    args << "--keyring"
    args << @keyring_file
    args << cmd
    args += arg
  
    # safe_system @gpg_binary, *args
    args.collect!{|arg| arg.to_s}
    cmd = "#{@gpg_binary} #{args.join(" ")}"
    puts "Running: #{cmd}"
    i, o, e = Open3.popen3(cmd)
    lines = o.readlines
    return lines
    # puts cmd
    # return %x[ #{cmd} ]
    # fork do
    #   exec(@gpg_binary.to_s, *args)
    # end
    # Process.wait
    # $?.success?
  end
  
  def fingerprint_to_id fingerprint
    return fingerprint.slice(24, 16)
  end

  def import_key id
    run "--recv-key", "0x#{id}"
  end

  def fingerprint id
    fingerprint_string = nil
    lines = run "--fingerprint", id
    lines.each do |line|
      if line.strip.index('Key fingerprint =') == 0
        fingerprint_string = line.strip.split("=")[1].gsub(" ", "")
      end
    end
    if not fingerprint_string
      raise GPGKeyNotFound
    end
    return fingerprint_string
  end

  def verify_signature sig_file, good_fingerprint
    lines = run "--verify", sig_file
    valid = false
    
    lines.each do |line|
      if line.index("[GNUPG:] GOODSIG") == 0
        valid = true
      elsif line.index("[GNUPG:] VALIDSIG") == 0
        fingerprint_string = line.split(" ")[2]
      end
    end

    if not (valid and fingerprint_string == good_fingerprint):
        raise GPGInvalidSignature

  end

  def delete_key id
    deleted_key = "#{@keyring_dir}/#{id}.deleted.gpg"
    run "-o", deleted_key, "-a", "--export", id
    run "--delete-keys", id
    put "Key with ID #{id} deleted. Saved a copy of it in #{deleted_key}"
  end

  def verify_key id, good_fingerprint
    local_fingerprint = fingerprint(id)
    if local_fingerprint != good_fingerprint
      opoo <<-EOS.undent
        The local key fingerprint does not match the expected fingerprint.
        #{local_fingerprint} != #{good_fingerprint}
        This can be the simptom of somebody having maliciously served you the
        wrong PGP key.
        You should freak out a little bit and read more about what this means
        here: https://github.com/mxcl/homebrew/issues/22238.
        To continue and bypass this warning message you should manually remove
        the key by running:

        brew keyrm #{@id}
        EOS

      raise GPGKeyInvalidFingerprint
    end
    oh1 "The fingerprint for 0x#{id} seems valid."
  end

  def initialize
    @gpg_binary = which 'gpg'
    if not @gpg_binary
      raise GPGNotInstalled "GPG is not installed. Run brew install gpg."
    end
    @keyring_dir = "#{HOMEBREW_REPOSITORY}/Library/Keyring"
    @keyring_file = "#{@keyring_dir}/Keyring.gpg"
  end

end

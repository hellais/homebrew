require 'signing'
require 'utils/json'

module Homebrew extend self
  def key

    formula = ARGV[0]
    fingerprint = ARGV[1]

    gpg = GPG.new
    key_id = gpg.fingerprint_to_id(fingerprint)
    gpg.import_key(key_id)
    gpg.verify_key(key_id, fingerprint)

    if formula
      add_key(formula, fingerprint)
    else
      list_keys()
    end

  end

    # if ARGV.include? '--macports'
    #   exec_browser "http://www.macports.org/ports.php?by=name&substr=#{ARGV.next}"
    # elsif ARGV.include? '--fink'
    #   exec_browser "http://pdb.finkproject.org/pdb/browse.php?summary=#{ARGV.next}"
    # elsif ARGV.include? '--debian'
    #   exec_browser "http://packages.debian.org/search?keywords=#{ARGV.next}&searchon=names&suite=all&section=all"
    # elsif ARGV.include? '--opensuse'
    #   exec_browser "http://software.opensuse.org/search?q=#{ARGV.next}"
    # elsif ARGV.include? '--fedora'
    #   exec_browser "https://admin.fedoraproject.org/pkgdb/acls/list/*#{ARGV.next}*"
    # elsif ARGV.include? '--ubuntu'
    #   exec_browser "http://packages.ubuntu.com/search?keywords=#{ARGV.next}&searchon=names&suite=all&section=all"

  def add_key(formula, keyFingerprint)
    json = Utils::JSON.dump(
      {
        "formula" => formula,
        "keyFingerprint" => keyFingerprint, 
        "keyID" => "",
        "publicKey" => "",
      }
    )
    File.open("#{HOMEBREW_REPOSITORY}/Library/Keyring/#{formula}.json", 'w') do |key|  
      key.puts json
    end
  end

  def list_keys()
    Dir["#{HOMEBREW_REPOSITORY}/Library/Keyring/*"].each do |key_path|
      key = Utils::JSON.load(open(key_path).read)
      
      puts "---"
      puts "Formula: #{key["formula"]}"
      puts "Key Fingerprint: #{key["keyFingerprint"]}"
      puts "Key ID: #{key["keyID"]}"
      puts "---"

    end
  end

end

require "formula"

class Ooniprobe < Formula
  homepage "https://ooni.torproject.org/"
  url "https://github.com/TheTorProject/ooni-probe/archive/v1.2.2.tar.gz"
  sha1 "7a3f8d0ca4fcfb2a093172e75720574600cf6a9d"

  depends_on :python if MacOS.version <= :snow_leopard

  depends_on "geoip"
  depends_on "openssl"
  depends_on "libyaml"
  depends_on "libffi"
  depends_on "libdnet" => "with-python"

  resource "txtorcon" do
    url "https://pypi.python.org/packages/source/t/txtorcon/txtorcon-0.11.0.tar.gz"
    sha1 "5d4ee9c320b7c33322bea998ff337ebfeac16557"
  end

  resource "pyyaml" do
    url "https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.11.tar.gz"
    sha1 "1a2d5df8b31124573efb9598ec6d54767f3c4cd4"
  end

  resource "pypcap" do
    url "https://pypi.python.org/packages/source/p/pypcap/pypcap-1.1.1.tar.gz"
    sha1 "c9892fd649589d4ebf1c91e103e4a25602e9574f"
  end

  resource "cryptography" do
    url "https://pypi.python.org/packages/source/c/cryptography/cryptography-0.6.1.tar.gz"
    sha1 "ebebd789e70a9106095a693a031fd3f2f1a44026"
  end

  resource "pycparser" do
    url "https://pypi.python.org/packages/source/p/pycparser/pycparser-2.10.tar.gz"
    sha1 "378a7a987d40e2c1c42cad0b351a6fc0a51ed004"
  end

  resource "pyopenssl" do
    url "https://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-0.14.tar.gz"
    sha1 "eb51f23f29703b647b0f194beaa9b2412c05e0f6"
  end

  resource "zope.interface" do
    url "https://pypi.python.org/packages/source/z/zope.interface/zope.interface-4.1.1.tar.gz"
    sha1 "20a9284429e29eb8cc63eee5ed686c257c01b1fc"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.8.0.tar.gz"
    sha1 "aa3b0659cbc85c6c7a91efc51f2d1007040070cd"
  end

  resource "ipaddr" do
    url "https://pypi.python.org/packages/source/i/ipaddr/ipaddr-2.1.11.tar.gz"
    sha1 "f9a16ddb3cf774b8dcf8894c2f4295c4e17d0ed3"
  end

  resource "twisted" do
    url "https://pypi.python.org/packages/source/T/Twisted/Twisted-14.0.2.tar.bz2"
    sha1 "b908dc0d117a782d2becc83fbb906ba4311f3351"
  end

  resource "parsley" do
    url "https://pypi.python.org/packages/source/P/Parsley/Parsley-1.2.tar.gz"
    sha1 "131c5ddce8a78ff608554602538cf43166883d79"
  end

  resource "service-identity" do
    url "https://pypi.python.org/packages/source/s/service_identity/service_identity-14.0.0.tar.gz"
    sha1 "10d7e29937f22d516659533f83af1e1427afdbd0"
  end

  resource "scapy" do
    url "https://pypi.python.org/packages/source/s/scapy-real/scapy-real-2.2.0-dev.tar.gz"
    sha1 "4e00dff8dfc6544d189a743c887ed827ad1af9f4"
  end

  resource "setuptools" do
    url "https://pypi.python.org/packages/source/s/setuptools/setuptools-7.0.tar.gz"
    sha1 "971d3efef71872c9d420df4cff6e04255024f9ae"
  end

  resource "characteristic" do
    url "https://pypi.python.org/packages/source/c/characteristic/characteristic-14.2.0.tar.gz"
    sha1 "58edb08a39eb413e5770703cb4f10dde29477ce2"
  end

  resource "pyasn1-modules" do
    url "https://pypi.python.org/packages/source/p/pyasn1-modules/pyasn1-modules-0.0.5.tar.gz"
    sha1 "108bdef1b3ca7050ff93c59e7ef7225c9c1a8b07"
  end

  resource "pyasn1" do
    url "https://pypi.python.org/packages/source/p/pyasn1/pyasn1-0.1.7.tar.gz"
    sha1 "e32b91c5a5d9609fb1d07d8685a884bab22ca6d0"
  end

  resource "txsocksx" do
    url "https://pypi.python.org/packages/source/t/txsocksx/txsocksx-1.13.0.3.tar.gz"
    sha1 "6ac2affb57384f481129ac4e35c909ab9bf7690d"
  end

  resource "cffi" do
    url "https://pypi.python.org/packages/source/c/cffi/cffi-0.8.6.tar.gz"
    sha1 "4e82390201e6f30e9df8a91cd176df19b8f2d547"
  end

  resource "geoip" do
    url "https://pypi.python.org/packages/source/G/GeoIP/GeoIP-1.3.2.tar.gz"
    sha1 "ce6025c28946ac5364f04e44ca0f73584b303df3"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", "#{libexec}/vendor/lib/python2.7/site-packages"
    %w[setuptools zope.interface six characteristic pycparser pyasn1 pyasn1-modules geoip pyopenssl service-identity pyyaml ipaddr pypcap cffi cryptography twisted parsley txtorcon scapy txsocksx].each do |r|
      resource(r).stage do
        Language::Python.setup_install "python", libexec/"vendor"
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    Language::Python.setup_install "python", libexec

    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/ooniprobe", "--version"
  end

end

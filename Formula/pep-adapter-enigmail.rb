class PepAdapterEnigmail < Formula

  desc "pEp Mini Adapter for Enigmail"
  homepage "https://pep.foundation"
  version "1.0.101"

  url "https://pep.foundation/dev/repos/pEpJSONServerAdapter/archive/69eccc3967269745297c13706b8d946f1c4df5b7.zip"
  # moving target: no sha256 ""

  depends_on "asn1c" => :build
  depends_on "x-pep/core/pep-core-yml2" => :build
  depends_on "x-pep/core/pep-core-libetpan" => :build
  depends_on "gnupg" => :build
  depends_on "libevent" => :build
  depends_on "boost" => :build
  depends_on "ossp-uuid" => :build

  depends_on "python" => :recommended if MacOS.version <= :snow_leopard
  # depends_on "python3" => :optional

  # depends_on "asn1c" => :build

  resource "engine" do
    # enigmail_tests_pre_revision_2535
    url "https://pep.foundation/dev/repos/pEpEngine/archive/3c5db90b50e8f1639d22b51b6d45a00b185835fc.zip"
    sha256 "78e449630ab04eace24b574364c53da154abf51263aa357a2d0b26ddf76658d8"
  end

  resource "googletest" do
    url "https://github.com/google/googletest/archive/release-1.8.0.zip"
    sha256 "f3ed3b58511efd272eb074a3a6d6fb79d7c2e6a0e374323d1e6bcbcc1ef141bf"
  end

  def install

    (buildpath / "contrib/engine").install resource("engine")
    (buildpath / "contrib/gtest").install resource("googletest")

    pyver = Language::Python.major_minor_version "python"
    site_packages = "lib/python#{pyver}/site-packages"
    yml_path = "#{Formula["pep-core-yml2"].libexec/site_packages}/yml2"
    local_conf = "PREFIX=#{prefix}",
        "SYSTEM_DB=\"#{prefix}/share/pEp/system.db\"",
        "YML2_PATH=\"#{yml_path}\"",
        "YML2_PROC=LC_ALL=C yml2proc -I'#{yml_path}'",
        "LIBGPGME=libgpgme.11.dylib", "GPG_CMD=gpg",
        "ASN1C=#{HOMEBREW_PREFIX}/opt/asn1c/bin/asn1c"

    system "make", "-C", "contrib/engine", *local_conf
    system "make", "-C", "contrib/engine", "install", *local_conf
    system "make", "-C", "contrib/engine/db", "db"
    system "mkdir", "-p", "#{prefix}/share/pEp"
    system "install", "contrib/engine/db/system.db", "#{prefix}/share/pEp/system.db"
  
    local_conf = "PREFIX=#{prefix}",
        "HTML_DIRECTORY=#{prefix}/share/pEp/html",
        "GTEST_DIR=#{buildpath / "contrib/gtest/googletest"}", "GTEST_INC=#{buildpath / "contrib/gtest/googletest/include"}",
        "ENGINE_LIB=-L#{prefix / "lib"}", "ENGINE_INC=-I#{prefix / "include"}",
        "EVENT_LIB=-L#{Formula["libevent"].prefix}/lib", "EVENT_INC=-I#{Formula["libevent"].prefix}/include"
    # ENV["LDFLAGS"] = "-Wl,-rpath,@executable_path/../lib"

    system "make", "-C", "server", *local_conf
    system "make", "-C", "server", "install", *local_conf
    # # system "ln", "-sf", "libpEpEngine.1.dylib" "$PREFIX"lib/libpEpEngine.dylib
  end

end

__END__


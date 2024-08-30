class Nghttp2 < Formula
  desc "HTTP/2 C Library"
  homepage "https://nghttp2.org/"
  url "https://github.com/nghttp2/nghttp2/releases/download/v1.63.0/nghttp2-1.63.0.tar.gz"
  mirror "http://fresh-center.net/linux/www/nghttp2-1.63.0.tar.gz"
  sha256 "9318a2cc00238f5dd6546212109fb833f977661321a2087f03034e25444d3dbb"
  license "MIT"

  bottle do
    sha256 arm64_sonoma:   "4946bbad571b81c2f4bd98e23193fa5580f61fc875cd603c36c528cf227c5b55"
    sha256 arm64_ventura:  "83da0d138f6c05b6a2a5717b54565318ffa0f4e7310f3a44f58cbcc4ac036580"
    sha256 arm64_monterey: "df1f53bed3f80ebeccc01b404fa3501f985819f8bee88e29527a480e5ec7ca46"
    sha256 sonoma:         "aee77b84e83bf6145bd54727f5214466d65fb9616d3a64205e0138e132ec396c"
    sha256 ventura:        "9aff06288db6cbeb942eca1b3db6adb184006a3e9609b22c5eae06082910e9dd"
    sha256 monterey:       "d31eb933de7d8bd619ef340adacd9913e8ec708430546696886d041a6be588be"
    sha256 x86_64_linux:   "648304c0ff49cbb5e1fa32cc46a8c0f57c72f7a25ff589489a76762dd94a8b2c"
  end

  head do
    url "https://github.com/nghttp2/nghttp2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "c-ares"
  depends_on "jemalloc"
  depends_on "libev"
  depends_on "libnghttp2"
  depends_on "openssl@3"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_macos do
    # macOS 12 or older
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1400
  end

  on_linux do
    depends_on "gcc"
  end

  fails_with :clang do
    build 1400
    cause "Requires C++20 support"
  end

  fails_with gcc: "11"

  def install
    ENV.llvm_clang if OS.mac? && DevelopmentTools.clang_build_version <= 1400

    # fix for clang not following C++14 behaviour
    # https://github.com/macports/macports-ports/commit/54d83cca9fc0f2ed6d3f873282b6dd3198635891
    inreplace "src/shrpx_client_handler.cc", "return dconn;", "return std::move(dconn);"

    # Don't build nghttp2 library - use the previously built one.
    inreplace "Makefile.in", /(SUBDIRS =) lib/, "\\1"
    inreplace Dir["**/Makefile.in"] do |s|
      # These don't exist in all files, hence audit_result being false.
      s.gsub!(%r{^(LDADD = )\$[({]top_builddir[)}]/lib/libnghttp2\.la}, "\\1-lnghttp2", false)
      s.gsub!(%r{\$[({]top_builddir[)}]/lib/libnghttp2\.la}, "", false)
    end

    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --enable-app
      --disable-examples
      --disable-hpack-tools
      --disable-python-bindings
      --without-systemd
    ]

    system "autoreconf", "-ivf" if build.head?
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    system bin/"nghttp", "-nv", "https://nghttp2.org"
    refute_path_exists lib
  end
end

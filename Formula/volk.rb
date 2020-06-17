class Volk < Formula
  desc "The Vector Optimized Library of Kernels"
  homepage "https://libvolk.org"
  url "https://github.com/gnuradio/volk/releases/download/v2.3.0/volk-2.3.0.tar.xz"
  sha256 "40645886d713ed23295d7fb3e69734b5173a22259886b1a4abdad229a44123b9"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build
  depends_on "orc"

  def install
    mkdir "build" do
      ENV.append "LDFLAGS", "-undefined dynamic_lookup"
      system "cmake", "..", *std_cmake_args
      inreplace "lib/constants.c", %r{/usr/local/Homebrew/.*/mac/super/}, "/usr/local/bin/"
      system "make"
      system "make", "test"
      system "make", "install"
    end
  end

  test do
    ohai Run all volk kernels once to confirm proper installation
    system "#{bin}/volk_profile", "--dry-run", "--iter", "1"
  end
end

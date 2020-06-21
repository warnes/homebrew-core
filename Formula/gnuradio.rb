class Gnuradio < Formula
  include Language::Python::Virtualenv

  desc "SDK providing the signal processing runtime and processing blocks"
  homepage "https://gnuradio.org/"
  url "https://github.com/gnuradio/gnuradio/releases/download/v3.8.1.0/gnuradio-3.8.1.0.tar.xz"
  sha256 "2372f501e86536981e71806d9b0f0b7e7879429418d7ad30f18e7779db2d5d3f"
  head "https://github.com/gnuradio/gnuradio.git"

  bottle do
    sha256 "74aa8a8d8c32be557ea8a8864cb8617e82a939e667b73e11c45da13d72b52a3a" => :catalina
    sha256 "ee2e794d854ab87e00ca35805d4f57232d49e688df5e71a7e9e448883402f540" => :mojave
    sha256 "ae53bf0abbdda23f25a45829483a6d1e03f096447289f2df72a6855be7af1619" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "swig" => :build

  depends_on "adwaita-icon-theme"
  depends_on "boost"
  depends_on "cairo"
  depends_on "codec2"
  depends_on "doxygen"
  depends_on "fftw"
  depends_on "gmp"
  depends_on "gsl"
  depends_on "gtk+3"
  depends_on "jack"
  depends_on "libgsm"
  depends_on "log4cpp"
  depends_on "mpir"
  depends_on "numpy"
  depends_on "pango"
  depends_on "portaudio"
  depends_on "py3cairo"
  depends_on "pygobject3"
  depends_on "pyqt"
  depends_on "python"
  depends_on "qt"
  depends_on "qwt"
  depends_on "sdl"
  depends_on "sphinx"
  depends_on "thrift"
  depends_on "uhd"
  depends_on "volk"
  depends_on "zeromq"

  resource "Cheetah" do
    url "https://files.pythonhosted.org/packages/50/d5/34b30f650e889d0d48e6ea9337f7dcd6045c828b9abaac71da26b6bdc543/Cheetah3-3.2.5.tar.gz"
    sha256 "ececc9ca7c58b9a86ce71eb95594c4619949e2a058d2a1af74c7ae8222515eb1"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz"
    sha256 "29872e92839765e546828bb7754a68c418d927cd064fd4708fab9fe9c8bb116b"
  end

  resource "Mako" do
    url "https://files.pythonhosted.org/packages/72/89/402d2b4589e120ca76a6aed8fee906a0f5ae204b50e455edd36eda6e778d/Mako-1.1.3.tar.gz"
    sha256 "8195c8c1400ceb53496064314c6736719c6f25e7479cd24c77be3d9361cddc27"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/6b/34/415834bfdafca3c5f451532e8a8d9ba89a21c9743a0c59fbd0205c7f9426/six-1.15.0.tar.gz"
    sha256 "30639c035cdb23534cd4aa2dd52c3bf48f06e5f4a941509c8bafd8ce11080259"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/64/c2/b80047c7ac2478f9501676c988a5411ed5572f35d1beff9cae07d321512c/PyYAML-5.3.1.tar.gz"
    sha256 "b8eac752c5e14d3eca0e6dd9199cd627518cb5ec06add0de9d32baeee6fe645d"
  end

  resource "pyzmq" do
    url "https://files.pythonhosted.org/packages/86/08/e5fc492317cc9d65b32d161c6014d733e8ab20b5e78e73eca63f53b17004/pyzmq-19.0.1.tar.gz"
    sha256 "13a5638ab24d628a6ade8f794195e1a1acd573496c3b85af2f1183603b7bf5e0"
  end

  resource "cppzmq" do
    url "https://raw.githubusercontent.com/zeromq/cppzmq/46fc0572c5e9f09a32a23d6f22fd79b841f77e00/zmq.hpp"
    sha256 "964031c0944f913933f55ad1610938105a6657a69d1ac5a6dd50e16a679104d5"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/27/6f/be940c8b1f1d69daceeb0032fee6c34d7bd70e3e649ccac0951500b4720e/click-7.1.2.tar.gz"
    sha256 "d2b5255c7c6349bc1bd1e59e08cd12acbbd63ce649f2588755783aa94dfb6b1a"
  end

  resource "click-plugins" do
    url "https://files.pythonhosted.org/packages/5f/1d/45434f64ed749540af821fd7e42b8e4d23ac04b1eda7c26613288d6cd8a8/click-plugins-1.1.1.tar.gz"
    sha256 "46ab999744a9d831159c3411bb0c79346d94a444df9a3a3742e9ed63645f264b"
  end

  patch :DATA

  def install
    ENV.cxx11

    ENV.prepend_path "PATH", Formula["qt"].opt_bin.to_s

    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"

    venv_root = libexec/"venv"
    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", "#{venv_root}/lib/python#{xy}/site-packages"
    venv = virtualenv_create(venv_root, "python3")

    ohai "Installing python packages"
    %w[Mako six Cheetah PyYAML click click-plugins pyzmq].each do |r|
      ENV.append "PYTHON_LIBS", "-undefined dynamic_lookup"
      ENV.append "LDFLAGS", "-undefined dynamic_lookup"
      venv.pip_install resource(r)
    end

    resource("cppzmq").stage include.to_s

    args = std_cmake_args + %W[
      -DGR_PKG_CONF_DIR=#{etc}/gnuradio/conf.d
      -DGR_PREFSDIR=#{etc}/gnuradio/conf.d
      -DENABLE_DEFAULT=OFF
      -DPYTHON_EXECUTABLE=#{venv_root}/bin/python
      -DPYTHON_VERSION_MAJOR=3
      -DCMAKE_PREFIX_PATH=#{Formula["qt"].opt_lib}
      -DQT_BINARY_DIR=#{Formula["qt"].opt_bin}
      -DENABLE_TESTING=OFF
      -DENABLE_INTERNAL_VOLK=OFF
    ]

    enabled = %w[
      GNURADIO_RUNTIME
      GR_ANALOG
      GR_AUDIO
      GR_BLOCKS
      GR_CHANNELS
      GR_CTRLPORT
      GR_DIGITAL
      GR_DTV
      GR_FEC
      GR_FFT
      GR_FILTER
      GR_MODTOOL
      GR_NETWORK
      GR_QTGUI
      GR_TRELLIS
      GR_UHD
      GR_UTILS
      GR_VIDEO_SDL
      GR_VOCODER
      GR_WAVELET
      GR_ZEROMQ
      GRC
      PYTHON
      VOLK
    ]
    enabled.each do |c|
      args << "-DENABLE_#{c}=ON"
    end

    disabled = %w[]
    disabled.each do |c|
      args << "-DENABLE_#{c}=OFF"
    end

    ohai "Starting build"
    mkdir "build" do
      ohai "Running cmake"
      system "cmake", "..", *args
      inreplace "gnuradio-runtime/lib/constants.cc", %r{/usr/local/Homebrew/.*/mac/super/}, "/usr/local/bin/"
      ohai "Running make"
      system "make"
      ohai "Running make install"
      system "make", "install", "PYTHON_LDFLAGS=-undefined dynamic_lookup"
    end
    ohai "Finished build"

    ohai "Starting packaging"

    mv Dir[lib/"python#{xy}/dist-packages/*"], lib/"python#{xy}/site-packages/"
    rm_rf lib/"python#{xy}/dist-packages"

    site_packages = lib/"python#{xy}/site-packages"
    pth_contents = "import site; site.addsitedir('#{site_packages}')\n"
    (venv_root/"lib/python#{xy}/site-packages/homebrew-gnuradio.pth").write pth_contents

    ohai "Creating a shell script to replace 'xterm' for gnuradio-companion"
    grc_term = bin/"grc_term"
    grc_term.write <<~EOS
      #!/usr/bin/env bash

      APPNAME=iTerm
      TEMPNAME=$(mktemp)

      cat > $TEMPNAME <<EOF
      #!/bin/zsh
      source #{venv_root}/bin/activate;
      cd $PWD;
      $*
      ;
      exit
      EOF

      chmod +x $TEMPNAME

      open -a $APPNAME $TEMPNAME
    EOS
    chmod "a+x", grc_term

    ohai "Editing grc configration to use grc_term instead of xterm"
    File.open(etc/"gnuradio/conf.d/grc.conf", "a") do |f|
      f << "xterm_executable = #{bin}/grc_term\n"
    end

    rm bin.children.reject(&:executable?)

    ohai "Done"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gnuradio-config-info -v")

    (testpath/"test.c++").write <<~EOS
      #include <gnuradio/top_block.h>
      #include <gnuradio/blocks/null_source.h>
      #include <gnuradio/blocks/null_sink.h>
      #include <gnuradio/blocks/head.h>
      #include <gnuradio/gr_complex.h>

      class top_block : public gr::top_block {
      public:
        top_block();
      private:
        gr::blocks::null_source::sptr null_source;
        gr::blocks::null_sink::sptr null_sink;
        gr::blocks::head::sptr head;
      };

      top_block::top_block() : gr::top_block("Top block") {
        long s = sizeof(gr_complex);
        null_source = gr::blocks::null_source::make(s);
        null_sink = gr::blocks::null_sink::make(s);
        head = gr::blocks::head::make(s, 1024);
        connect(null_source, 0, head, 0);
        connect(head, 0, null_sink, 0);
      }

      int main(int argc, char **argv) {
        top_block top;
        top.run();
      }
    EOS
    system ENV.cxx, "-std=c++11", "-L#{lib}", "-L#{Formula["boost"].opt_lib}",
           "-lgnuradio-blocks", "-lgnuradio-runtime", "-lgnuradio-pmt",
           "-lboost_system", "-L#{Formula["log4cpp"].opt_lib}", "-llog4cpp",
            testpath/"test.c++", "-o", testpath/"test"
    system "./test"

    (testpath/"test.py").write <<~EOS
      from gnuradio import blocks
      from gnuradio import gr

      class top_block(gr.top_block):
          def __init__(self):
              gr.top_block.__init__(self, "Top Block")
              self.samp_rate = 32000
              s = gr.sizeof_gr_complex
              self.blocks_null_source_0 = blocks.null_source(s)
              self.blocks_null_sink_0 = blocks.null_sink(s)
              self.blocks_head_0 = blocks.head(s, 1024)
              self.connect((self.blocks_head_0, 0),
                           (self.blocks_null_sink_0, 0))
              self.connect((self.blocks_null_source_0, 0),
                           (self.blocks_head_0, 0))

      def main(top_block_cls=top_block, options=None):
          tb = top_block_cls()
          tb.start()
          tb.wait()

      main()
    EOS
    system "python3", testpath/"test.py"
  end
end

__END__
diff --git a/cmake/Modules/GrPython.cmake b/cmake/Modules/GrPython.cmake
index fd9b7583a..388da7371 100644
--- a/cmake/Modules/GrPython.cmake
+++ b/cmake/Modules/GrPython.cmake
@@ -56,7 +56,12 @@ set(QA_PYTHON_EXECUTABLE ${QA_PYTHON_EXECUTABLE} CACHE FILEPATH "python interpre
 add_library(Python::Python INTERFACE IMPORTED)
 # Need to handle special cases where both debug and release
 # libraries are available (in form of debug;A;optimized;B) in PYTHON_LIBRARIES
-if(PYTHON_LIBRARY_DEBUG AND PYTHON_LIBRARY_RELEASE)
+if(APPLE)
+    set_target_properties(Python::Python PROPERTIES
+      INTERFACE_INCLUDE_DIRECTORIES "${PYTHON_INCLUDE_DIRS}"
+      INTERFACE_LINK_LIBRARIES "-undefined dynamic_lookup"
+      )
+elseif(PYTHON_LIBRARY_DEBUG AND PYTHON_LIBRARY_RELEASE)
     set_target_properties(Python::Python PROPERTIES
       INTERFACE_INCLUDE_DIRECTORIES "${PYTHON_INCLUDE_DIRS}"
       INTERFACE_LINK_LIBRARIES "$<$<NOT:$<CONFIG:Debug>>:${PYTHON_LIBRARY_RELEASE}>;$<$<CONFIG:Debug>:${PYTHON_LIBRARY_DEBUG}>"

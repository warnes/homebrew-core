class DependencyCheck < Formula
  desc "OWASP dependency-check"
  homepage "https://owasp.org/www-project-dependency-check/"
  url "https://dl.bintray.com/jeremy-long/owasp/dependency-check-5.3.2-release.zip"
  sha256 "4c6f40cb596e335fd0cd816bd6c25773e1e029c3109979ce4c429f3b49850252"

  bottle :unneeded

  depends_on "openjdk"

  def install
    rm_f Dir["bin/*.bat"]

    chmod 0755, "bin/dependency-check.sh"
    libexec.install Dir["*"]

    (bin/"dependency-check").write_env_script libexec/"bin/dependency-check.sh",
      :JAVA_HOME => Formula["openjdk"].opt_prefix

    (var/"dependencycheck").mkpath
    libexec.install_symlink var/"dependencycheck" => "data"

    (etc/"dependencycheck").mkpath
    jar = "dependency-check-core-#{version}.jar"
    corejar = libexec/"lib/#{jar}"
    system "unzip", "-o", corejar, "dependencycheck.properties", "-d", libexec/"etc"
    (etc/"dependencycheck").install_symlink libexec/"etc/dependencycheck.properties"
  end

  test do
    output = shell_output("#{bin}/dependency-check --version").strip
    assert_match "Dependency-Check Core version #{version}", output

    (testpath/"temp-props.properties").write <<~EOS
      cve.startyear=2017
      analyzer.assembly.enabled=false
    EOS
    system bin/"dependency-check", "-P", "temp-props.properties", "-f", "XML",
               "--project", "dc", "-s", libexec, "-d", testpath, "-o", testpath
    assert_predicate testpath/"dependency-check-report.xml", :exist?
  end
end

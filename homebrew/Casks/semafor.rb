cask "semafor" do
  version "1.0.0"
  sha256 :no_check  # Pro development, později nahradíš skutečným SHA256

  url "https://github.com/rnavratil/semafor/releases/download/v#{version}/Semafor.app.zip"
  name "Semafor"
  desc "Menu bar status indicator with CLI support"
  homepage "https://github.com/rnavratil/semafor"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "Semafor.app"

  # Automaticky nainstalovat CLI nástroj
  postflight do
    cli_path = "#{appdir}/Semafor.app/Contents/Resources/semafor"
    target_path = "/usr/local/bin/semafor"
    
    if File.exist?(cli_path)
      system_command "/bin/mkdir",
                     args: ["-p", "/usr/local/bin"],
                     sudo: false
      system_command "/bin/cp",
                     args: [cli_path, target_path],
                     sudo: true
      system_command "/bin/chmod",
                     args: ["+x", target_path],
                     sudo: false
    end
  end

  uninstall delete: "/usr/local/bin/semafor"

  zap trash: [
    "~/Library/Preferences/com.rnavratil.semafor.plist",
    "~/Library/Application Support/Semafor",
  ]
end

require 'formula'

class Redis12 < Formula
  url 'http://redis.googlecode.com/files/redis-1.2.1.tar.gz'
  homepage 'http://code.google.com/p/redis/'
  sha1 'a668befcd26f27cc90f6808d3119875f75453788'
  homepage 'http://redis.io/'


  def install
    ENV.gcc_4_2
    system "make"
    bin.install 'redis-benchmark' => 'redis-benchmark1.2', 'redis-cli' => 'redis-cli1.2',
                'redis-server' => 'redis-server1.2'

    %w( run db/redis1.2 log ).each { |p| (var+p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", "#{var}/run/redis1.2.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis1.2/"
      s.gsub! "port 6379", "port 6380"
      s.gsub! "vm-swap-file /tmp/redis.swap", "vm-swap-file /tmp/redis1.2.swap"
    end

    doc.install Dir["doc/*"]
    etc.install "redis.conf" => "redis1.2.conf"
    (prefix+'io.redis.redis-server1.2.plist').write startup_plist
    (prefix+'io.redis.redis-server1.2.plist').chmod 0644
  end

  def caveats
    <<-EOS.undent
    If this is your first install, automatically load on login with:
        mkdir -p ~/Library/LaunchAgents
        cp #{prefix}/io.redis.redis-server1.2.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/io.redis.redis-server1.2.plist

    If this is an upgrade and you already have the io.redis.redis-server1.2.plist loaded:
        launchctl unload -w ~/Library/LaunchAgents/io.redis.redis-server1.2.plist
        cp #{prefix}/io.redis.redis-server1.2.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/io.redis.redis-server1.2.plist

      To start redis manually:
        redis-server1.2 #{etc}/redis1.2.conf

      To access the server:
        redis-cli1.2
    EOS
  end

  def startup_plist
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>KeepAlive</key>
    <true/>
    <key>Label</key>
    <string>io.redis.redis-server1.2</string>
    <key>ProgramArguments</key>
    <array>
      <string>#{bin}/redis-server1.2</string>
      <string>#{etc}/redis1.2.conf</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>UserName</key>
    <string>#{`whoami`.chomp}</string>
    <key>WorkingDirectory</key>
    <string>#{var}</string>
    <key>StandardErrorPath</key>
    <string>#{var}/log/redis1.2.log</string>
    <key>StandardOutPath</key>
    <string>#{var}/log/redis1.2.log</string>
  </dict>
</plist>
    EOPLIST
  end
end

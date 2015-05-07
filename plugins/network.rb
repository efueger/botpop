#encoding: utf-8

module BotpopPlugins

  def self.exec_intra m
    m.reply Action.intra_state rescue m.reply "I'm buggy. Sorry"
  end

  INTRA_PING_SLEEP = 30
  def self.exec_intra_on m
    @intra ||= Mutex.new
    if @intra.try_lock
      @intra_on = true
      m.reply "INTRANET SPY ON"
      while @intra_on
        m.reply Action.intra_state rescue return @intra.unlock
        sleep INTRA_PING_SLEEP
      end
      @intra.unlock
    else
      m.reply "INTRA SPY ALREADY ON"
    end
  end

  def self.exec_intra_off m
    if @intra_on
      @intra_on = false
      m.reply "INTRA SPY OFF"
    else
      m.reply "INTRA SPY ALREADY OFF"
    end
  end

  def self.exec_ping m
    m.reply "#{m.user} pong"
  end

  def self.exec_ping_target m
    ip = get_ip m
    p = Net::Ping::External.new ip
    str = "failed"
    if p.ping?
      str = "#{(p.duration*100.0).round 2}ms (#{p.host})"
    end
    m.reply "#{ip} ping> #{str}"
  end

  DOS_DURATION = "2s"
  DOS_WAIT = 5
  def self.exec_dos m
    @dos ||= Mutex.new
    if @dos.try_lock
      ip = get_ip m
      begin
        if not Action.ping(ip)
          m.reply "Cannot reach the host '#{ip}'"
          raise "Unreachable host"
        end
        m.reply "Begin attack against #{ip}"
        # Calculations
        s = Action.dos(ip, DOS_DURATION).split("\n")[3].to_s
        # Display
        m.reply (Action.ping(ip) ? "failed :(" : "down !!!") + " " + s
        # Wait a little before the next authorized attack
        sleep DOS_WAIT
        @dos.unlock
      rescue
        @dos.unlock
      end
    else
      m.reply "Wait for the end of the last dos"
    end
  end

  def self.get_ip_from_nick m
    nick = get_ip m
    ip = m.target.users.keys.find{|u| u.nick == nick rescue nil}.host rescue nil
    return {nick: nick, ip: ip}
  end

  def self.exec_fok m
    nick = get_ip_from_nick(m)[:nick]
    ip = get_ip_from_nick(m)[:ip]
    return m.reply "User '#{nick}' doesn't exists" if ip.nil?
    return m.reply "Cannot reach the host '#{ip}'" if not Action.ping(ip)
    s = Action.dos(ip, DOS_DURATION).split("\n")[3].to_s
    m.reply "#{nick} : " + (Action.ping(ip) ? "failed :(" : "down !!!") + " " + s
  end

  # Trace is complexe. 3 functions used exec_trace_display_lines, exec_trace_with_time, exec_trace
  TRACE_DURATION_INIT = 0.3
  TRACE_DURATION_INCR = 0.1
  def self.exec_trace_display_lines m, lines
    lines.select!{|e| not e.include? "no reply" and e =~ /\A \d+: .+/}
    duration = TRACE_DURATION_INIT
    lines.each do |l|
      m.reply l
      sleep duration
      duration += TRACE_DURATION_INCR
    end
    m.reply 'finished'
  end

  def self.exec_trace_with_time ip
    t1 = Time.now
    s = Action.trace ip
    t2 = Time.now
    return [s, t1, t2]
  end

  def self.exec_trace m
    @trace ||= Mutex.new
    if @trace.try_lock
      ip = get_ip m
      m.reply "It can take time"
      begin
        # Calculations
        s, t1, t2 = exec_trace_with_time ip
        m.reply "Trace executed in #{(t2 - t1).round(3)} seconds"
        @trace.unlock
      rescue => e
        m.reply "Sorry, but the last author of this plugin is so stupid his mother is a tomato"
        @trace.unlock
      end
      # Display
      exec_trace_display_lines m, s
    else
      m.reply "Please retry after when the last trace end"
    end
  end

  def self.exec_poke m
    nick = get_ip_from_nick(m)[:nick]
    ip = get_ip_from_nick(m)[:ip]
    return m.reply "User '#{nick}' doesn't exists" if ip.nil?
    # Calculations
    p = Net::Ping::External.new ip
    # Display
    response = p.ping? ? "#{(p.duration*100.0).round 2}ms (#{p.host})" : "failed"
    m.reply "#{nick} poke> #{response}"
  end

end

log show --style syslog --predicate 'subsystem == "com.apple.XProtectFramework.PluginAPI" && eventMessage contains "status_message"' --last 24h

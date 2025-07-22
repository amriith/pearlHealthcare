
# Config.pm - Configuration module for the Network Health Monitor

package Config;

use strict;
use warnings;

# This subroutine returns the configuration hash.
# In a real application, you might load this from a JSON or YAML file.
sub get_config {
    my %config = (
        # 💻 List of servers to monitor
        servers => [
            {
                host  => 'localhost', # Can be an IP address or domain name
                ports => [80, 22, 443] # Common ports: HTTP, SSH, HTTPS
            },
            {
                host  => 'google.com',
                ports => [80, 443]
            },
            {
                host => '192.168.1.250', # A non-existent local IP for testing failure
                ports => [8080]
            }
        ],

        # 📝 Log analysis settings
        log_analysis => {
            # On Linux/macOS, a common log is /var/log/system.log or /var/log/syslog
            # On Windows, you might need to export event logs to a text file first.
            # Create a dummy 'system.log' file for testing.
            log_file => 'system.log',
            patterns => [
                'error',
                'failed',
                'login failure',
                'critical',
                'denied'
            ]
        },

        # 📧 Email alert settings
        email => {
            to          => 'admin@example.com', # <-- ❗ CHANGE THIS
            from        => 'monitor@yourdomain.com', # <-- ❗ CHANGE THIS
            smtp_server => 'smtp.example.com', # <-- ❗ CHANGE THIS to your mail server
        }
    );
    return %config;
}

1; # Required for a Perl module to be valid